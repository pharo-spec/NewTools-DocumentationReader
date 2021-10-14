"
Execute the following code to open HelpBrowser on doc:
```
StHelpBrowserPresenter openOnHelpFolder:  FileSystem workingDirectory / 'doc'.
```

Execute the following code to load doc in the cache:
```
| doc |
doc := FileSystem workingDirectory / 'pharo-local' / 'doc'.
StHelpBrowserPresenter internalizeHelpFrom: doc.
```
And to watch the cache inspect the following:
```
StNewHelpBrowserPresenter helpCache
```

To flush the cache execute the following code:
```
StNewHelpBrowserPresenter emptyHelpCache
```

Code to load and use the cache:
```
StHelpBrowserPresenter internalizeHelpFrom: FileSystem disk workingDirectory / 'doc'.
StHelpBrowserPresenter open
```
"
Class {
	#name : #StHelpBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'textOutput',
		'rootTopic',
		'topicList',
		'helpTopicVisitor'
	],
	#classInstVars : [
		'filesystem',
		'helpCache',
		'lastopenHelp'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #specs }
StHelpBrowserPresenter class >> defaultSpec [
	| searchInput |
	searchInput := (SpTextInputFieldPresenter new
				placeholder: 'Enter you search').
	 ^ SpBoxLayout newTopToBottom
			add: (SpPanedLayout newLeftToRight
				add: #topicList;
				add: #textOutput;
				yourself);
			add: searchInput height: 30 ;
			add: (SpButtonPresenter new
				label: 'Search';
				action: [ lastopenHelp searchAndClick: searchInput text ]) height: 50;
			yourself
]

{ #category : #accessing }
StHelpBrowserPresenter class >> emptyHelpCache [

	helpCache := nil
]

{ #category : #accessing }
StHelpBrowserPresenter class >> filesystem [
	^ filesystem
]

{ #category : #accessing }
StHelpBrowserPresenter class >> filesystem: aFileSystem [
	filesystem := aFileSystem
]

{ #category : #accessing }
StHelpBrowserPresenter class >> helpCache [

	^ helpCache ifNil: [ helpCache := FileSystem memory workingDirectory ]
]

{ #category : #accessing }
StHelpBrowserPresenter class >> helpCache: aCache [
	helpCache := aCache
]

{ #category : #cache }
StHelpBrowserPresenter class >> internalizeHelpFrom: aFolderOrFile [

	| fileRef |
	fileRef := aFolderOrFile asFileReference.
	self filesystem: FileSystem memory.
	[ self internalizeHelpFrom: fileRef at: filesystem workingDirectory.
	self helpCache: self filesystem workingDirectory / fileRef basename ] 
		on: FileDoesNotExistException 
		do: [  'We do not do anything special because the only thing we could do is to reinitialize
and we may lose the contents if there was one.' ]
]

{ #category : #cache }
StHelpBrowserPresenter class >> internalizeHelpFrom: aFolderOrFile  at: aFolderReference [

	aFolderOrFile isDirectory 
		ifTrue:  [ | directoryPath |
					directoryPath := aFolderReference / aFolderOrFile basename.
					self filesystem createDirectory: directoryPath.
					aFolderOrFile children do: [ :folderOrFile | self internalizeHelpFrom: folderOrFile  at: directoryPath ] ]
		ifFalse: [ | file filePath |
					(self new isMicFile: aFolderOrFile) 
						ifTrue: [ 
							filePath := aFolderReference / aFolderOrFile basename.
							file := self filesystem workingDirectory resolve: filePath.
							file writeStreamDo: [ :stream |stream nextPutAll: aFolderOrFile contents ] ] ]
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> open [
	"Open a HelpBrowser on the internalized docs."
	<example>

	^ self openOnHelpFolder: self helpCache 
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openOn: aHelpTopic [
	"Open the receiver on the given help topic or any other object that can be transformed into
	 a help topic by sending #asHelpTopic."

	^ (self on:  aHelpTopic)
		openWithSpec;
		yourself
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openOnCustomHelp: aDescription [
	[ aDescription bookName.
	 ^ self openOn: (CustomHelpHelpBuilder new createTopicFrom: aDescription)] 
	on: MessageNotUnderstood do: [ | inst |
		inst:= self basicNew.
		inst createTopicsFromCache.
		^ inst 
				setModelBeforeInitialization: inst rootTopic;
				initialize;
				openWithSpec;
				yourself
	 ]
	
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openOnHelpFolder [
	"Open an help browser."
	
	self openOnHelpFolder: FileSystem workingDirectory / 'pharo-local' / 'doc'

	
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openOnHelpFolder: aFileReference [

	"Open an help browser on a given folder."

	"Implementation note: the logic is not really good because I have to copy the logic from SpPresenter class>>#newApplication:model:.
	Especially how to pass a model before the initialization which is normally done via message #on: "

	| fileReference |
	lastopenHelp := self basicNew.
	fileReference := aFileReference exists
		ifFalse: [  self helpCache ]
		ifTrue: [ aFileReference ].
	lastopenHelp createRootTopicFromFolder: fileReference.
	^ lastopenHelp
		  setModelBeforeInitialization: lastopenHelp rootTopic;
		  initialize;
		  openWithSpec;
		  yourself
]

{ #category : #'basic search' }
StHelpBrowserPresenter class >> search: aTopicName in: topicCollection with: aCollection [
	
	| lookedup |
	lookedup := aTopicName asLowercase.	
		
	topicCollection ifNotEmpty: [ 
		topicCollection doWithIndex: [ :topic :i |
		aCollection add: i.
		((topic title asLowercase splitOn: Character space) anySatisfy: [ :each | lookedup match: each ])
			ifTrue: [ ^ aCollection ]
			ifFalse: [ (self search: aTopicName in: topic subtopics with: aCollection) isCollection 
				ifTrue: [ ^ aCollection]].
			aCollection removeLast ]
		 ]
	
]

{ #category : #initialization }
StHelpBrowserPresenter >> connectPresenters [
 
	topicList
		whenSelectionChangedDo: [ :selection | 
					| item node |
					item := selection selectedItem.
					node := item node.
					node ifNotNil: [ self renderNode: node ]];
				displayIcon: [ :each | each icon ]
]

{ #category : #internals }
StHelpBrowserPresenter >> createRootTopicFromFolder: aFolder [
	| topic |
	topic := (self createTopicsFromFileOrFolder: aFolder) first.
	topic subtopics do: [ :each | self propagateNodeIn: each ].
	self rootTopic: topic.
]

{ #category : #internals }
StHelpBrowserPresenter >> createTopicsFromCache [
	self createRootTopicFromFolder: self class helpCache.
]

{ #category : #internals }
StHelpBrowserPresenter >> createTopicsFromFile: aFileOrFolder [

	| visitor |
	visitor := self helpTopicVisitor new.
	visitor visit: (Microdown new resolvedTreeFromFile: aFileOrFolder).
	^ visitor helpTopics subtopics
]

{ #category : #internals }
StHelpBrowserPresenter >> createTopicsFromFileOrFolder: aFileOrFolder [

	| subTopic sorted topic |
	(aFileOrFolder isFile and: [ self isMicFile: aFileOrFolder ]) 
		ifTrue: [ ^ self createTopicsFromFile: aFileOrFolder ].

	topic := self helpTopicClass named:
		         aFileOrFolder basenameWithoutExtension capitalized.
	sorted := self sortFileAndFolder: aFileOrFolder.
	sorted do: [ :fileOrFolder | 
		(self createTopicsFromFileOrFolder: fileOrFolder) do: [ :each | 
			topic addSubtopic: each ] ].
	subTopic := OrderedCollection new.
	subTopic add: topic.
	^ subTopic
]

{ #category : #internals }
StHelpBrowserPresenter >> dummyHelp [

	^  '# Empty Help
	This a dummy help.'
]

{ #category : #hooks }
StHelpBrowserPresenter >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #accessing }
StHelpBrowserPresenter >> helpTopicVisitor [
	
	helpTopicVisitor ifNil: [ helpTopicVisitor := StTopicBuilderVisitor ].
	^ helpTopicVisitor
]

{ #category : #accessing }
StHelpBrowserPresenter >> helpTopicVisitor: aClass [ 
	helpTopicVisitor := aClass
]

{ #category : #initialization }
StHelpBrowserPresenter >> initialExtent [
	^ 800@600
]

{ #category : #initialization }
StHelpBrowserPresenter >> initializePresenters [

	super initializePresenters.
	topicList := self newTree.
	topicList 
		roots: { self rootTopic };
		children: [ :aNode | aNode subtopics ];
		display: [ :each | each title ].
	
	"Using a morph container as the output because a text presenter is intended to receive 
	 strings, not instances of Text (the fact that it works now is just casual, and will 
	 be removed in the future)"
	textOutput := self newMorph
		morph: (RubScrolledTextMorph new 
			hResizing: #spaceFill; 
			vResizing: #spaceFill;
			in: [ :this | this textArea readOnly: true ];
			yourself);
		yourself.




]

{ #category : #testing }
StHelpBrowserPresenter >> isMicFile: aFile [

	^ #( 'mic' 'md' ) includes: aFile extension
]

{ #category : #hooks }
StHelpBrowserPresenter >> morphWriter [

	^ MicRichTextComposer new
]

{ #category : #hooks }
StHelpBrowserPresenter >> parserClass [ 
	^ MicroDownParser
]

{ #category : #internals }
StHelpBrowserPresenter >> propagateNodeIn: aRootTopic [

	aRootTopic node children ifEmpty: [ 
		aRootTopic subtopics do: [ :each | 
			self propagateNodeIn: each.
			each node children do: [ :node |
				aRootTopic addNode: node ]
			 ] ]
	
]

{ #category : #internals }
StHelpBrowserPresenter >> render [

	| document |
	document := self parserClass parse: self dummyHelp.
	textOutput morph setText: (self morphWriter start: document)
]

{ #category : #internals }
StHelpBrowserPresenter >> renderNode: aNode [

	textOutput morph setText: (self morphWriter visit: aNode)
]

{ #category : #accessing }
StHelpBrowserPresenter >> rootTopic [
	^ rootTopic ifNil: [ self rootTopic: (self helpTopicClass named: 'Help'). rootTopic ]
]

{ #category : #accessing }
StHelpBrowserPresenter >> rootTopic: aHelpTopic [ 
	rootTopic := aHelpTopic asHelpTopic
]

{ #category : #search }
StHelpBrowserPresenter >> searchAndClick: aTopicName [ 
	| collection |
	collection := OrderedCollection new.
	collection add: 1.
	self class search: aTopicName in: rootTopic subtopics  with: collection.
	self topicList clickAtPath: collection
]

{ #category : #initialization }
StHelpBrowserPresenter >> setModelBeforeInitialization: anHelpTopic [
	
	rootTopic := anHelpTopic
]

{ #category : #internals }
StHelpBrowserPresenter >> sortFileAndFolder: aFileOrFolder [

	| sorted |
	sorted := SortedCollection sortBlock: [ :a :b | 
		          a basename <= b basename ].
	sorted addAll: (aFileOrFolder children select: [ :e | 
			 e isDirectory or: [ self isMicFile: e ] ]).
	^ sorted
]

{ #category : #initialization }
StHelpBrowserPresenter >> title [
	^ 'Help Topic Browser'
]

{ #category : #accessing }
StHelpBrowserPresenter >> topicList [
	^ topicList
]
