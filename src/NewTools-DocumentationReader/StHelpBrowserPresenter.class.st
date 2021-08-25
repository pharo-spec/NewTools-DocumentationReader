"
Execute the following code to open HelpBrowser on doc :
```
StNewHelpBrowserPresenter openOnHelpFolder:  FileSystem workingDirectory / 'doc'.
```

Execute the following code to load doc in the cache :
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
MDSpNewHelpBrowserPresenter internalizeHelpFrom: FileSystem disk workingDirectory / 'doc'.
MDSpNewHelpBrowserPresenter open
```
"
Class {
	#name : #StHelpBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'textOutput',
		'rootTopic',
		'topicList',
		'helpTopicVisitor',
		'searchInput',
		'nextButton'
	],
	#classInstVars : [
		'filesystem',
		'helpCache'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #specs }
StHelpBrowserPresenter class >> defaultSpec [

	 ^ SpBoxLayout newTopToBottom
			add: (SpPanedLayout newLeftToRight
				add: #topicList;
				add: #textOutput;
				yourself);
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
	self filesystem: FileSystem memory.
	[ self internalizeHelpFrom: aFolderOrFile  at: filesystem workingDirectory basename.
	self helpCache: self filesystem workingDirectory / aFolderOrFile basename ] 
		on: FileDoesNotExistException 
		do: [  "We do not do anything special because the only thing we could do is to reinitialize
			and we may lose the contents there was one." ]
]

{ #category : #cache }
StHelpBrowserPresenter class >> internalizeHelpFrom: aFolderOrFile  at: aFolderName [

	aFolderOrFile isDirectory 
		ifTrue:  [ | directoryPath |
					directoryPath := aFolderName , '/' , aFolderOrFile basename.
					self filesystem createDirectory: directoryPath.
					aFolderOrFile children do: [ :folderOrFile | self internalizeHelpFrom: folderOrFile  at: directoryPath ] ]
		ifFalse: [ | file filePath |
					(self new isMicFile: aFolderOrFile) 
						ifTrue: [ 
							filePath := aFolderName , '/' , aFolderOrFile basename.
							file := self filesystem workingDirectory / filePath.
							file writeStreamDo: [ :stream |stream nextPutAll: aFolderOrFile contents ] ] ]
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> open [
	"Open a HelpBrowser on the internalized docs."
	<example>

	^ self openOnHelpFolder: helpCache 
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

	| inst fileReference |
	inst := self basicNew.
	fileReference := aFileReference exists
		ifFalse: [  self helpCache ]
		ifTrue: [ aFileReference ].
	inst createRootTopicFromFolder: fileReference.
	^ inst
		  setModelBeforeInitialization: inst rootTopic;
		  initialize;
		  openWithSpec;
		  yourself
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

{ #category : #utils }
StHelpBrowserPresenter >> createRootTopicFromFolder: aFolder [
	| topic |
	topic := (self createTopicsFromFileOrFolder: aFolder) first.
	self rootTopic: topic.
]

{ #category : #utils }
StHelpBrowserPresenter >> createTopicsFromCache [
	self createRootTopicFromFolder: self class helpCache.
]

{ #category : #utils }
StHelpBrowserPresenter >> createTopicsFromFile: aFileOrFolder [

	| visitor |
	visitor := self helpTopicVisitor new.
	visitor visit: (self parserClass new parseFile: aFileOrFolder).
	^ visitor helpTopics subtopics
]

{ #category : #utils }
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

{ #category : #utils }
StHelpBrowserPresenter >> dummyHelp [

	^  '# Empty Help
	This a dummy help.'
]

{ #category : #utils }
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

{ #category : #utils }
StHelpBrowserPresenter >> isMicFile: aFile [

	^ #( 'mic' 'md' ) includes: aFile extension
]

{ #category : #utils }
StHelpBrowserPresenter >> morphWriter [

	^ MicRichTextComposer new
]

{ #category : #utils }
StHelpBrowserPresenter >> parserClass [ 
	^ MicroDownParser
]

{ #category : #utils }
StHelpBrowserPresenter >> render [

	| document |
	document := self parserClass parse: self dummyHelp.
	textOutput morph setText: (self morphWriter start: document)
]

{ #category : #utils }
StHelpBrowserPresenter >> render: aString [

	| document text |
	aString 
		ifNil: [ text := self dummyHelp ]
		ifNotNil: [ text := aString ].
	 document := [ self parserClass parse: text ] 
							on: MicParsingError
							do: [ :ex | textOutput morph setText: text. ^ self ].
	textOutput morph setText: (self morphWriter start: document) 
]

{ #category : #utils }
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

{ #category : #initialization }
StHelpBrowserPresenter >> setModelBeforeInitialization: anHelpTopic [
	
	rootTopic := anHelpTopic
]

{ #category : #utils }
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
