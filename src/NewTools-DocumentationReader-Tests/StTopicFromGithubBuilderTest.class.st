"
A StTopicFromGithubBuilderTest is a test class for testing the behavior of StTopicFromGithubBuilder
"
Class {
	#name : #StTopicFromGithubBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'root'
	],
	#classInstVars : [
		'root'
	],
	#category : #'NewTools-DocumentationReader-Tests'
}

{ #category : #'as yet unclassified' }
StTopicFromGithubBuilderTest class >> eyeballTest [
	"This should be able to open the HelpBrowser on the test data (actual data from github)"
	<script>
	StHelpBrowserPresenter openTopic: self new root.
]

{ #category : #initialization }
StTopicFromGithubBuilderTest >> initialize [
	"Reset cache first time"
	
	StTopicFromGithubBuilder reset.
]

{ #category : #accessing }
StTopicFromGithubBuilderTest >> root [
	^ StTopicFromGithubBuilder githubTopics
]

{ #category : #tests }
StTopicFromGithubBuilderTest >> testIncludesWelcome [
	| welcome |
	welcome := self root subtopics detect: [ :topic | topic title = 'Welcome to Pharo 10' ].
	self assert: welcome isNotNil.
	self assert: welcome subtopics size equals: 4.
	self assert: (welcome subtopics detect: [ :t | t title = 'To Learn Pharo'] ) subtopics size equals: 5.
]

{ #category : #tests }
StTopicFromGithubBuilderTest >> testNodesGetLifted [
	"The document contents of files should be aggregated into a combined document for folders"
	self root subtopics do: [ :dirLevelTopic |
		self assert: dirLevelTopic node children isNotEmpty ]
]

{ #category : #tests }
StTopicFromGithubBuilderTest >> testReadRoot [
	self assert: self root class equals: StNodeHelpTopic 
]

{ #category : #tests }
StTopicFromGithubBuilderTest >> testRootTopicHasNoContents [
	self assert: self root contents children isEmpty
]

{ #category : #tests }
StTopicFromGithubBuilderTest >> testSubtopics [
	self assert: 
		((self root subtopics collect: #title) 
				intersection: #(Introduction 'Regular expressions framework')) size = 2
]
