"
When I visit a header I create a `StNodeHelpTopic`.
When I visit anything else I add the node at the last `StNodeHelpTopic` create.
"
Class {
	#name : #StTopicBuilderVisitor,
	#superclass : #MicrodownVisitor,
	#instVars : [
		'actualTopic',
		'helpTopic'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #internals }
StTopicBuilderVisitor >> extractNode: aNode into: aTopic [

	aTopic owner ifNotNil: [ 
		aTopic owner addNode: aNode.
		self extractNode: aNode into: aTopic owner ]
	
	
	
	
]

{ #category : #accessing }
StTopicBuilderVisitor >> helpTopic [

	^ helpTopic
]

{ #category : #'visiting-document' }
StTopicBuilderVisitor >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #initialization }
StTopicBuilderVisitor >> initialize [ 
	
	super initialize.
	helpTopic := StNodeHelpTopic new.
	actualTopic := helpTopic
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
		self extractNode: each into: actualTopic ].
	^ helpTopic
	
	
]

{ #category : #'visiting-document' }
StTopicBuilderVisitor >> visitHeader: aHeader [

	aHeader level < 3 ifTrue:[
		| topic |
		topic := self helpTopicClass named: aHeader header capitalized.
		actualTopic := topic.
		helpTopic addSubtopic: topic with: aHeader level ]
]
