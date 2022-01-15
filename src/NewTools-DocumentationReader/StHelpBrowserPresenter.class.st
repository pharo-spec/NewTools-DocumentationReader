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
			"add: searchInput height: 30 ;
			add: (SpButtonPresenter new
				label: 'Search';
				action: [ lastopenHelp searchAndClick: searchInput text ]) height: 50;"
			yourself
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> open [
	"Open a HelpBrowser on the internalized docs."
	<example>

	^ self error: 'We need to define a default starting point' 
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openOnCustomHelp: aDescription [
	[ aDescription bookName.
	 ^ self openTopic: (CustomHelpHelpBuilder new createTopicFrom: aDescription)] 
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

	self openTopic: (StTopicFromFileFolderBuilder onDirectory: aFileReference )
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openPharoRepo [
	"Open a HelpBrowser on the internalized docs."
	<example>

	self openTopic: (StTopicFromGithubBuilder githubTopics)
]

{ #category : #'instance creation' }
StHelpBrowserPresenter class >> openTopic: aHelpTopic [
	"Open the receiver on the given help topic or any other object that can be transformed into
	 a help topic by sending #asHelpTopic."

	^ (self on:  aHelpTopic)
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
StHelpBrowserPresenter >> dummyHelp [

	^  '# Empty Help
	This a dummy help.'
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
			beWrapped;
			hResizing: #spaceFill; 
			vResizing: #spaceFill;
			in: [ :this | this textArea readOnly: true ];
			yourself);
		yourself.




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
StHelpBrowserPresenter >> render [

	| document |
	document := self parserClass parse: self dummyHelp.
	textOutput morph setText: (self morphWriter start: document)
]

{ #category : #internals }
StHelpBrowserPresenter >> renderNode: aNode [

	textOutput morph setText: (self morphWriter visit: aNode)
]

{ #category : #initialization }
StHelpBrowserPresenter >> rootTopic [ 
	^ rootTopic 
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
StHelpBrowserPresenter >> setModelBeforeInitialization: topic [
	rootTopic := topic
]

{ #category : #initialization }
StHelpBrowserPresenter >> title [
	^ 'Help Topic Browser'
]

{ #category : #accessing }
StHelpBrowserPresenter >> topicList [
	^ topicList
]
