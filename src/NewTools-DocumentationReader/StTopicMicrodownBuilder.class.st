"
I implement subtopic generation from headers inside a microdown document.
This is shared behaviour for different kind of builders.
"
Class {
	#name : #StTopicMicrodownBuilder,
	#superclass : #Object,
	#category : #'NewTools-DocumentationReader'
}

{ #category : #'as yet unclassified' }
StTopicMicrodownBuilder >> createTopicsFromDocument: doc [

	| visitor |
	visitor := self helpTopicVisitor new.
	visitor visit: doc.
	^ visitor helpTopic subtopics
]

{ #category : #accessing }
StTopicMicrodownBuilder >> helpTopicVisitor [
	^ StTopicBuilderVisitor 
]

{ #category : #internals }
StTopicMicrodownBuilder >> liftNodesIn: aRootTopic [
	"If root node (microdown document) is empty, lift nodes from subtopics into node of root"
	aRootTopic node children ifEmpty: [ 
		aRootTopic subtopics do: [ :each | 
			self liftNodesIn: each.
			each node children do: [ :node |
				aRootTopic addNode: node ]
			 ] ]
	
]
