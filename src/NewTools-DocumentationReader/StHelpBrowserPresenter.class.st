"
Execute the following code to open HelpBrowser on doc :
```
MDSpNewHelpBrowserPresenter openOnHelpFolder:  FileSystem workingDirectory / 'doc'.
```

Execute the following code to charge doc in the cache :
```
| doc |
doc := FileSystem disk workingDirectory / 'doc'.
MDSpNewHelpBrowserPresenter internalizeHelpFrom: doc.
```
And to watch the cache inspect that :
```
MDSpNewHelpBrowserPresenter helpCache
```

After that you can also open the HelpBrowser with the helpCache :
```
| browser |
browser := MDSpNewHelpBrowserPresenter new topicsFromSystem.
MDSpNewHelpBrowserPresenter openOn: browser rootTopic
```

to empty the cache execute the following code :
```
MDSpNewHelpBrowserPresenter emptyHelpCache
```

code to charge and use the cache :
```
MDSpNewHelpBrowserPresenter internalizeHelpFrom: FileSystem disk workingDirectory / 'doc'.
MDSpNewHelpBrowserPresenter open
```
"
Class {
	#name : #StHelpBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'helpText',
		'textOutput',
		'syntaxHelper',
		'textInput',
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
			"add: (SpBoxLayout newLeftToRight
				add: #searchInput withConstraints:  [ :constraints | constraints height: 18 ];
				add: #nextButton withConstraints:  [ :constraints | constraints height: 18 ] ;
				yourself);"
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
	helpCache := aCache.
]

{ #category : #cache }
StHelpBrowserPresenter class >> internalizeHelpFrom: aFolderOrFile [
	self filesystem: FileSystem memory.
	[ aFolderOrFile isDirectory 
		ifTrue:  [self filesystem createDirectory: aFolderOrFile basename. 
					(aFolderOrFile children select: [ :e |  e isDirectory or: [ e extension = 'mic' ] ])
						do: [ :folderOrFile | self internalizeHelpFrom: folderOrFile  at: aFolderOrFile basename ] ]
		ifFalse: [ | file |
					file := self filesystem workingDirectory / aFolderOrFile basename.
					file writeStreamDo: [ :stream |stream nextPutAll: aFolderOrFile contents ] ].
	self helpCache: self filesystem workingDirectory / aFolderOrFile basename.
	] 
		on: FileDoesNotExistException 
		do: [  "We do not do anything special because the only thing we could do is to reinitialize
			and we may lose the contents there was one." ]
		
		
	
	
]

{ #category : #cache }
StHelpBrowserPresenter class >> internalizeHelpFrom: aFolderOrFile  at: aFolderName [

	aFolderOrFile isDirectory 
		ifTrue:  [ | directoryPath |
					directoryPath := aFolderName , '/' ,aFolderOrFile basename.
					self filesystem createDirectory: directoryPath.
					aFolderOrFile children do: [ :folderOrFile | self internalizeHelpFrom: folderOrFile  at: directoryPath ] ]
		ifFalse: [ | file filePath |
					filePath := aFolderName , '/' , aFolderOrFile basename.
					file := self filesystem workingDirectory / filePath.
					file writeStreamDo: [ :stream |stream nextPutAll: aFolderOrFile contents ] ].
	
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
StHelpBrowserPresenter class >> openOnHelpFolder: aFileReference [

	"Open an help browser on a given folder."

	"Implementation note: the logic is not really good because I have to copy the logic from SpPresenter class>>#newApplication:model:.
	Especially how to pass a model before the initialization which is normally done via message #on: "

	| inst fileReference |
	inst := self basicNew.
	aFileReference exists
		ifFalse: [ fileReference := self helpCache ]
		ifTrue: [ fileReference := aFileReference ].
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
						 node ifNotNil: [
							self renderNode: node ]];
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
	visitor start: (MicroDownParser new parseFile: aFileOrFolder).
	^ visitor rootTopics
]

{ #category : #utils }
StHelpBrowserPresenter >> createTopicsFromFileOrFolder: aFileOrFolder [

	| subTopic sorted topic |
	
	(aFileOrFolder isFile and: aFileOrFolder extension = 'mic')
		ifTrue: [ ^ self createTopicsFromFile: aFileOrFolder ].
		
	subTopic := OrderedCollection new.
	topic := self helpTopicClass named: aFileOrFolder basenameWithoutExtension capitalized.
	sorted := self sortFileAndFolder: aFileOrFolder.
	sorted do: [ :fileOrFolder | 
		(self createTopicsFromFileOrFolder: fileOrFolder) do: [ :each | 
			topic addSubtopic: each ] ].
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

	^ MDNodeHelpTopic
]

{ #category : #accessing }
StHelpBrowserPresenter >> helpTopicVisitor [
	
	helpTopicVisitor ifNil: [ ^ helpTopicVisitor := MDTopicBuilderVisitor. ].
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
	searchInput := self newTextInput.
	nextButton := self newButton 
						help: 'To select the next one';
						label: 'Next'.




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
	^ rootTopic ifNil: [ self rootTopic: SystemHelp2 asHelpTopic. rootTopic ]
]

{ #category : #accessing }
StHelpBrowserPresenter >> rootTopic: aHelpTopic [ 
	rootTopic := aHelpTopic asHelpTopic
]

{ #category : #search }
StHelpBrowserPresenter >> search: aString [

	| topics |
	topics := self rootTopic subtopics.
	^ self search: aString into: topics. 
]

{ #category : #search }
StHelpBrowserPresenter >> search: aString into: aTopicCollection [

	| collection |
	collection := OrderedCollection new.
	aTopicCollection do: [ :topic | 
		(self word: aString in: topic )
			ifTrue: [ collection add: topic ]
			ifFalse: [ collection addAll: (self search: aString into: topic subtopics) ] ].
	^ collection
]

{ #category : #search }
StHelpBrowserPresenter >> searchList: aString [

	| topics |
	topics := self rootTopic subtopics.
	^ self searchList: aString into: topics. 
]

{ #category : #search }
StHelpBrowserPresenter >> searchList: aString into: aTopicCollection [

	| collection |
	collection := OrderedCollection new.
	aTopicCollection do: [ :topic | 
		(self word: aString in: topic) 
			ifTrue: [ collection add: topic ].
		collection addAll: (self search: aString into: topic subtopics) ].
	^ collection
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
			 e isDirectory or: [ e extension = 'mic' ] ]).
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

{ #category : #search }
StHelpBrowserPresenter >> word: aString in: aTopic [

	^ (aTopic node text findString: aString startingAt: 1) > 0 | ((aTopic title findString: aString startingAt: 1) > 0)
]
