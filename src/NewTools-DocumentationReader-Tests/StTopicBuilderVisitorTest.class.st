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
StTopicBuilderVisitorTest >> testAddSubtopicsNodesAddPRDocumentInNodeTopic [

	| topics |
	topics := OrderedCollection new.
	topics
		add: (self helpTopicClass named: '1');
		add: (self helpTopicClass named: '2');
		add: (self helpTopicClass named: '3').
	visitor
		nodesListAdd: (OrderedCollection new: 1);
		nodesListAdd: (OrderedCollection new: 2);
		nodesListAdd: (OrderedCollection new: 3).
	visitor addSubtopicsNodes: topics.
	self assert: topics first node class equals: MicRootBlock.
	self assert: topics second node class equals: MicRootBlock.
	self assert: topics third node class equals: MicRootBlock
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testAddSubtopicsNodesUseNodesList [

	| topics size |
	topics := OrderedCollection new.
	topics 
		add: (HelpTopic named: '1');
		add: (HelpTopic named: '2');
		add: (HelpTopic named: '3').
	visitor 
		nodesListAdd: (OrderedCollection new: 1);
		nodesListAdd: (OrderedCollection new: 2);
		nodesListAdd: (OrderedCollection new: 3);
		nodesListAdd: (OrderedCollection new: 4).
	size := visitor nodesList size.
	visitor addSubtopicsNodes: topics.
	self assert: visitor nodesList size equals: size - 3 

]

{ #category : #tests }
StTopicBuilderVisitorTest >> testGetNodesListAfterAddObject [

	visitor 
		nodesListAdd: 1;
		nodesListAdd: 2.
	self assert: visitor nodesList size equals: 2.
	self assert: visitor nodesList first equals: 1.
	self assert: visitor nodesList second equals: 2
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testGetNodesListAtInitialization [

	self assert: visitor nodesList isEmpty
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorVisitAllAddInNodesList [

	| file text document |
	text := '# SectionTest
This is a paragraphe'.
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: text ].
	document := (MicroDownParser new parse: file contents).
	visitor visitAll: document children.
	self assert: visitor nodesList first isEmpty.
	self assert: visitor nodesList second size equals: 2 

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
	self assert: visitor rootTopics first title equals: 'SectionTest'.
	self assert: visitor rootTopics first contents equals: ''

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
	self assert: visitor rootTopics first title equals: 'SectionTest'.
	self assert: visitor rootTopics first contents equals: ''

]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithLevelsSections [

	| file topic |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: self class spFileContentsLevelsSections ].
	self visitFile: file.
	topic := visitor rootTopics first.
	self assert: topic title equals: 'Section 1'.
	
	topic := topic subtopics first.
	self assert: topic title equals: 'Section 2'.
	
	topic := topic subtopics first.
	self assert: topic title equals: 'Section 3'.
	
	topic := topic subtopics first.
	self assert: topic title equals: 'Section 4'.
	
	topic := topic subtopics first.
	self assert: topic title equals: 'Section 5'.
	
	topic := topic subtopics first.
	self assert: topic title equals: 'Section 6'.
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithMoreSections [

	| file |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
		stream nextPutAll: self class spFileContentsMoreSections ].
	self visitFile: file.
	self assert: (visitor rootTopics at: 2) title equals: 'Section 2'.
	self assert: visitor rootTopics size equals: 2
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithMoreSubSection [

	| file |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
			stream nextPutAll: self class spFileContentsWithMoreSubSection ].
	self visitFile: file.
	self
		assert: ((visitor rootTopics at: 1) subtopics at: 2) title
		equals: 'Section 3'.
	self assert: visitor rootTopics size equals: 1.
	self assert: visitor rootTopics first subtopics size equals: 2
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
	self assert: (visitor rootTopics at: 1) title equals: 'Section 1'.
	self assert: visitor rootTopics size equals: 1
]

{ #category : #tests }
StTopicBuilderVisitorTest >> testTopicBuilderVisitorWithOneSubSection [

	| file |
	(file := filesystem workingDirectory / self class spFileName) 
		writeStreamDo: [ :stream | 
			stream nextPutAll: self class spFileContentsWithOneSubSection ].
	self visitFile: file.
	self
		assert: ((visitor rootTopics at: 1) subtopics at: 1) title
		equals: 'Section 2'.
	self assert: visitor rootTopics size equals: 1.
	self assert: visitor rootTopics first subtopics size equals: 1
]

{ #category : #tests }
StTopicBuilderVisitorTest >> visitFile: file [

	visitor start: (MicroDownParser new parse: file contents)
]
