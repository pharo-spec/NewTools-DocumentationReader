"
I'm a help topic and as such I hold a Microdown root document. 
This is in this document that further microdown elements will be added. 

Note that I can have subtopics in addition to the microdown element. 
A subtopic is just similar to myself.

I store the location I was retrieved from. This location is used for caching of help topics
"
Class {
	#name : #StNodeHelpTopic,
	#superclass : #HelpTopic,
	#instVars : [
		'node'
	],
	#classInstVars : [
		'locationCache'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #adding }
StNodeHelpTopic >> addNode: aNode [

	node addChild: aNode
]

{ #category : #adding }
StNodeHelpTopic >> addSubtopic: aSubTopic [

	self iconName: #bookIcon.
	super addSubtopic: aSubTopic
]

{ #category : #adding }
StNodeHelpTopic >> addSubtopic: aHelpTopic with: aLevel [
		
	(aLevel > 1 and: [ self subtopics isNotEmpty] )
		ifTrue: [ self subtopics last addSubtopic: aHelpTopic with: aLevel - 1 ] 
		ifFalse: [ self addSubtopic: aHelpTopic ]
]

{ #category : #initialize }
StNodeHelpTopic >> initialize [

	super initialize.
	self iconName: #pageIcon.
	node := MicRootBlock new.
]

{ #category : #inspecting }
StNodeHelpTopic >> inspectionMCTopicTree [
	<inspectorPresentationOrder: 930 title: 'TopicTree'>

	^ SpTreePresenter new 
		roots: { self };
		children: [ :aNode | aNode subtopics ];
		display: [ :each | 
			String
				streamContents: [ :stream | 
					each displayStringOn: stream						
			 ] ];
		yourself
]

{ #category : #accessing }
StNodeHelpTopic >> node [
	"Returns the microdown elements holding the document of the help"
	
	^ node
]

{ #category : #accessing }
StNodeHelpTopic >> subtopics: aCollection [

	aCollection ifNotEmpty: [self iconName: #bookIcon].
	super subtopics: aCollection
]
