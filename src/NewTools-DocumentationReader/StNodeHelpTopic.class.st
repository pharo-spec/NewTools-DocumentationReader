"
I'm a help topic and my content is a Microdown root document. 

Note that I can have subtopics in addition to the microdown element. 
A subtopic is just similar to myself.

"
Class {
	#name : #StNodeHelpTopic,
	#superclass : #HelpTopic,
	#category : #'NewTools-DocumentationReader'
}

{ #category : #adding }
StNodeHelpTopic >> addNode: aNode [

	self node addChild: aNode
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
	contents := MicRootBlock new
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
	
	^ self contents 
]

{ #category : #accessing }
StNodeHelpTopic >> subtopics: aCollection [

	aCollection ifNotEmpty: [ self iconName: #bookIcon ].
	super subtopics: aCollection
]
