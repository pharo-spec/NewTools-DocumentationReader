"
I'm a help topic and as such I hold a Microdown root document. 
This is in this document that further microdown elements will be added. 

Note that I can have subtopics in addition to the microdown element. 
A subtopic is just similar to myself.
"
Class {
	#name : #MDNodeHelpTopic,
	#superclass : #HelpTopic,
	#instVars : [
		'node',
		'iconBuilder'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #'instance creation' }
MDNodeHelpTopic class >> named: aName with: anIconBuilder [
	| topic |
	topic := self named: aName.
	topic iconBuilder: anIconBuilder.
	topic iconBuilder buildIcon: topic.
	^ topic
]

{ #category : #adding }
MDNodeHelpTopic >> addNode: aNode [

	node addChild: aNode
]

{ #category : #adding }
MDNodeHelpTopic >> addSubtopic: aSubTopic [

	iconBuilder buildIcon: self.
	super addSubtopic: aSubTopic
]

{ #category : #adding }
MDNodeHelpTopic >> addSubtopic: aHelpTopic with: aLevel [
		
	(aLevel - 1 > 1 and: [ self subtopics isNotEmpty] )
		ifTrue: [ self subtopics last addSubtopic: aHelpTopic with: aLevel - 1 ] 
		ifFalse: [ self addSubtopic: aHelpTopic ]
]

{ #category : #accessing }
MDNodeHelpTopic >> iconBuilder [ 
	^ iconBuilder
]

{ #category : #accessing }
MDNodeHelpTopic >> iconBuilder: aIconBuilder [

	iconBuilder := aIconBuilder
]

{ #category : #initialize }
MDNodeHelpTopic >> initialize [

	super initialize.
	node := MicRootBlock new.
	iconBuilder := IconBookBuilder new.
	iconBuilder setIconOf: self
]

{ #category : #inspecting }
MDNodeHelpTopic >> inspectionMCTopicTree [
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
MDNodeHelpTopic >> node [
	"Returns the microdown elements holding the document of the help"
	
	^ node
]

{ #category : #accessing }
MDNodeHelpTopic >> subtopics: aCollection [

	iconBuilder buildIcon: self.
	super subtopics: aCollection
]
