"
When I visit a header I create a `StNodeHelpTopic`.
When I visit anything node I add the node at the last `StNodeHelpTopic` create.
"
Class {
	#name : #StTopicBuilderVisitor,
	#superclass : #MicrodownVisitor,
	#instVars : [
		'helpTopics',
		'actualTopic'
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

{ #category : #internals }
StTopicBuilderVisitor >> propagateNode: aNode from: aTopic [
	aTopic owner ifNotNil: [ 
		aTopic owner addNode: aNode.
		self propagateNode: aNode from: aTopic owner ]
	
	
	
	
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
		actualTopic addNode: each.
		self propagateNode: each from: actualTopic ].
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
