"
I am able to build a topic tree from a root folder.

The topic tree will have one root - based on the root folder.
It will have subtropics based on subfoldes and the heading hiearchy of the markdown files in the folders.
"
Class {
	#name : #StTopicFromFileFolderBuilder,
	#superclass : #StTopicMicrodownBuilder,
	#instVars : [
		'rootTopic',
		'helpTopicVisitor'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #internals }
StTopicFromFileFolderBuilder >> createRootTopicFromFolder: aFolder [
	"I am the entry method"
	| topic |
	topic := (self createTopicsFromFileOrFolder: aFolder) first.
	topic subtopics do: [ :each | self liftNodesIn: each ].
	self rootTopic: topic.
	^ topic 
]

{ #category : #internals }
StTopicFromFileFolderBuilder >> createTopicsFromFile: aFileOrFolder [
	^ self createTopicsFromDocument:  (Microdown new resolvedTreeFromFile: aFileOrFolder).
]

{ #category : #internals }
StTopicFromFileFolderBuilder >> createTopicsFromFileOrFolder: aFileOrFolder [

	| sorted topic |
	(aFileOrFolder isFile and: [ self isMicFile: aFileOrFolder ]) 
		ifTrue: [ ^ self createTopicsFromFile: aFileOrFolder ].

	topic := self helpTopicClass named: aFileOrFolder basenameWithoutExtension capitalized.
	sorted := self sortFileAndFolder: aFileOrFolder.
	sorted do: [ :fileOrFolder | 
		(self createTopicsFromFileOrFolder: fileOrFolder) do: [ :each | 
			topic addSubtopic: each ] ].
	^ OrderedCollection with: topic.
]

{ #category : #hooks }
StTopicFromFileFolderBuilder >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #testing }
StTopicFromFileFolderBuilder >> isMicFile: aFile [

	^ #( 'mic' 'md' ) includes: aFile extension
]

{ #category : #accessing }
StTopicFromFileFolderBuilder >> rootTopic [
	^ rootTopic ifNil: [ self rootTopic: (self helpTopicClass named: 'Help'). rootTopic ]
]

{ #category : #accessing }
StTopicFromFileFolderBuilder >> rootTopic: aHelpTopic [ 
	rootTopic := aHelpTopic asHelpTopic
]

{ #category : #internals }
StTopicFromFileFolderBuilder >> sortFileAndFolder: aFileOrFolder [

	| sorted |
	sorted := SortedCollection sortBlock: [ :a :b | 
		          a basename <= b basename ].
	sorted addAll: (aFileOrFolder children select: [ :e | 
			 e isDirectory or: [ self isMicFile: e ] ]).
	^ sorted
]
