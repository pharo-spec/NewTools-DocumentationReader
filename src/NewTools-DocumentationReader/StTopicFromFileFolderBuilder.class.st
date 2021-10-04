"
I am able to build a topic tree from a root folder.

The topic tree will have one root - based on the root folder.
It will have subtropics based on subfoldes and the heading hiearchy of the markdown files in the folders.
"
Class {
	#name : #StTopicFromFileFolderBuilder,
	#superclass : #Object,
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
	topic subtopics do: [ :each | self propagateNodeIn: each ].
	self rootTopic: topic.
	^ topic 
]

{ #category : #internals }
StTopicFromFileFolderBuilder >> createTopicsFromFile: aFileOrFolder [

	| visitor |
	visitor := self helpTopicVisitor new.
	visitor visit: (Microdown new resolvedTreeFromFile: aFileOrFolder).
	^ visitor helpTopics subtopics
]

{ #category : #internals }
StTopicFromFileFolderBuilder >> createTopicsFromFileOrFolder: aFileOrFolder [

	| subTopic sorted topic |
	(aFileOrFolder isFile and: [ self isMicFile: aFileOrFolder ]) 
		ifTrue: [ ^ self createTopicsFromFile: aFileOrFolder ].

	topic := self helpTopicClass named: aFileOrFolder basenameWithoutExtension capitalized.
	sorted := self sortFileAndFolder: aFileOrFolder.
	sorted do: [ :fileOrFolder | 
		(self createTopicsFromFileOrFolder: fileOrFolder) do: [ :each | 
			topic addSubtopic: each ] ].
	subTopic := OrderedCollection new.
	subTopic add: topic.
	^ subTopic
]

{ #category : #hooks }
StTopicFromFileFolderBuilder >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #accessing }
StTopicFromFileFolderBuilder >> helpTopicVisitor [
	
	helpTopicVisitor ifNil: [ helpTopicVisitor := StTopicBuilderVisitor ].
	^ helpTopicVisitor
]

{ #category : #testing }
StTopicFromFileFolderBuilder >> isMicFile: aFile [

	^ #( 'mic' 'md' ) includes: aFile extension
]

{ #category : #internals }
StTopicFromFileFolderBuilder >> propagateNodeIn: aRootTopic [
	"If root node (microdown document) is empty, lift nodes from subtopics into node of root"
	aRootTopic node children ifEmpty: [ 
		aRootTopic subtopics do: [ :each | 
			self propagateNodeIn: each.
			each node children do: [ :node |
				aRootTopic addNode: node ]
			 ] ]
	
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
