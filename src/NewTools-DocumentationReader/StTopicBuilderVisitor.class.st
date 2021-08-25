"
When I visit a header I create a NodeHelpTopic.
When I visit something else I add it to the nodelist of the current node (help topic).
"
Class {
	#name : #StTopicBuilderVisitor,
	#superclass : #MicrodownVisitor,
	#instVars : [
		'helpTopics',
		'actualTopic'
	],
	#classInstVars : [
		'helpCache'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #'visiting-document' }
StTopicBuilderVisitor >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #accessing }
StTopicBuilderVisitor >> helpTopics [
	^ helpTopics
]

{ #category : #initialization }
StTopicBuilderVisitor >> initialize [ 
	
	super initialize.
	helpTopics := StNodeHelpTopic new.
	actualTopic := helpTopics
]

{ #category : #'visiting-document' }
StTopicBuilderVisitor >> visit: anObject [
	"The normal case is to have
	
	#header 
		ljklj
		jlkklk
		jlkl
		
	#header 2
		fgddfg	
		gjhgj
		
	Now it may be the case where we have some text before a header and we should not lose it. 
	"
	
	self visitAll: anObject children.
	
	
]

{ #category : #'visiting-document' }
StTopicBuilderVisitor >> visitAll: aCollection [

	aCollection do: [ :each |
		each accept: self.
		actualTopic addNode: each ].
	^ helpTopics
	
	
]

{ #category : #'visiting-document' }
StTopicBuilderVisitor >> visitHeader: aHeader [

	aHeader level < 3 ifTrue:[
		| topic |
		topic := self helpTopicClass named: aHeader header capitalized.
		actualTopic := topic.
		helpTopics addSubtopic: topic with: aHeader level ]
]
