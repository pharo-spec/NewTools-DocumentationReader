Class {
	#name : #StTopicBuilderVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'filesystem',
		'visitor'
	],
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
StTopicBuilderVisitorTest >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #running }
StTopicBuilderVisitorTest >> setUp [
	super setUp.
	filesystem := FileSystem memory.
	visitor := StTopicBuilderVisitor new
	
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorVisitHeader [

	| file text header |
	text := '# SectionTest
	This is a paragraphe'.
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: text ].
	header := (MicroDownParser new parse: file contents) children first.
	visitor visitHeader: header.
	self assert: visitor helpTopics subtopics first title equals: 'SectionTest'.
	self assert: visitor helpTopics subtopics first contents equals: ''

]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorVisitHeaderAtLevel2 [

	| file text header |
	text := '## SectionTest
	This is a paragraphe'.
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: text ].
	header := (MicroDownParser new parse: file contents) children first.
	visitor visitHeader: header.
	self assert: visitor helpTopics subtopics first title equals: 'SectionTest'.
	self assert: visitor helpTopics subtopics first contents equals: ''

]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithLevelsSections [

	| file topics |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: self class spFileContentsLevelsSections ].
	self visitFile: file.
	topics := visitor helpTopics subtopics.
	self assert: topics first title equals: 'Section 1'.
	self assert: topics first subtopics first title equals: 'Section 2'.
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithMoreSections [

	| file |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: self class spFileContentsMoreSections ].
	self visitFile: file.
	self assert: (visitor helpTopics subtopics second) title equals: 'Section 2'.
	self assert: visitor helpTopics subtopics size equals: 2
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithMoreSubSection [

	| file |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
			stream nextPutAll: self class spFileContentsWithMoreSubSection ].
	self visitFile: file.
	self
		assert: (visitor helpTopics subtopics first subtopics second) title
		equals: 'Section 3'.
	self assert: visitor helpTopics subtopics size equals: 1.
	self assert: visitor helpTopics subtopics first subtopics size equals: 2
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithOneSection [

	| file text |
	text := '
blabla
blabla
'.
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: self class spFileContentsOneSection ].
	self visitFile: file.
	self assert: (visitor helpTopics subtopics first) title equals: 'Section 1'.
	self assert: visitor helpTopics subtopics size equals: 1
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithOneSubSection [

	| file |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
			stream nextPutAll: self class spFileContentsWithOneSubSection ].
	self visitFile: file.
	self
		assert: ((visitor helpTopics subtopics first) subtopics first) title
		equals: 'Section 2'.
	self assert: visitor helpTopics subtopics size equals: 1.
	self assert: visitor helpTopics subtopics first subtopics size equals: 1
]

{ #category : #helper }
StTopicBuilderVisitorTest >> visitFile: file [

	visitor visit: (MicroDownParser new parse: file contents)
]
