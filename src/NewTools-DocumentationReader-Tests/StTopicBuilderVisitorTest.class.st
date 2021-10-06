Class {
	#name : #StTopicBuilderVisitorTest,
	#superclass : #TestCase,
	#category : #'NewTools-DocumentationReader-Tests'
}

{ #category : #resources }
StTopicBuilderVisitorTest class >> spFileContentsLevelsSections [

	^ '# Section 1
blabla1
## Section 2
blabla2
### Section 3
blabla3
#### Section 4
blabla4
##### Section 5
blabla5
###### Section 6
blabla6'
]

{ #category : #resources }
StTopicBuilderVisitorTest class >> spFileContentsMoreSections [

	^ '# Section 1
blabla1
# Section 2
blabla2
'
]

{ #category : #resources }
StTopicBuilderVisitorTest class >> spFileContentsOneSection [

	^ '# Section 1	
_blabla_
blabla'

]

{ #category : #resources }
StTopicBuilderVisitorTest class >> spFileContentsWithMoreSubSection [

	^ '# Section 1
blabla1
## Section 2
blabla2
## Section 3
blabla3'
]

{ #category : #resources }
StTopicBuilderVisitorTest class >> spFileContentsWithOneSubSection [

	^ '# Section 1
blabla1
## Section 2
blabla2'
]

{ #category : #resources }
StTopicBuilderVisitorTest class >> spFileName [

	^ 'test.md'
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorVisitHeader [

	| text topic |
	text := '# SectionTest
	This is a paragraphe'.
	topic := self topicIn: text.
	self assert: topic subtopics first title equals: 'SectionTest'.
	self assert: topic subtopics first subtopics isEmpty 

]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorVisitHeaderAtLevel2 [

	| text topic |
	text := '## SectionTest
	This is a paragraphe'.
	topic := self topicIn: text.
	self assert: topic subtopics first title equals: 'SectionTest'.
	self assert: topic subtopics first subtopics isEmpty 

]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithLevelsSections [

	|  topic |
	topic := self topicIn: self class spFileContentsLevelsSections.
	self assert: topic subtopics first title equals: 'Section 1'.
	self assert: topic subtopics first subtopics first title equals: 'Section 2'.
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithMoreSections [

	| topic |
	topic := self topicIn: self class spFileContentsMoreSections.
	self assert: topic subtopics second title equals: 'Section 2'.
	self assert: topic subtopics size equals: 2
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithMoreSubSection [

	| topic |	
	topic := self topicIn: self class spFileContentsWithMoreSubSection.
	self
		assert: (topic subtopics first subtopics second) title
		equals: 'Section 3'.
	self assert: topic subtopics size equals: 1.
	self assert: topic subtopics first subtopics size equals: 2
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithOneSection [
	
	| topic |
	topic := self topicIn: self class spFileContentsOneSection.
	self assert: topic subtopics first title equals: 'Section 1'.
	self assert: topic subtopics size equals: 1
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithOneSubSection [

	| topic |
	topic := self topicIn: self class spFileContentsWithOneSubSection.
	self
		assert: topic subtopics first subtopics first title
		equals: 'Section 2'.
	self assert: topic subtopics size equals: 1.
	self assert: topic subtopics first subtopics size equals: 1
]

{ #category : #helper }
StTopicBuilderVisitorTest >> topicIn: aString [

	| visitor |
	visitor := StTopicBuilderVisitor new.
	visitor visit: (MicroDownParser new parse: aString).
	^ visitor helpTopic 
]
