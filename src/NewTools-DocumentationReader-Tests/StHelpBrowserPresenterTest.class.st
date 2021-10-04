Class {
	#name : #StHelpBrowserPresenterTest,
	#superclass : #TestCase,
	#instVars : [
		'filesystem',
		'window'
	],
	#category : #'NewTools-DocumentationReader-Tests'
}

{ #category : #resources }
StHelpBrowserPresenterTest class >> spDirectoryName [

	^ 'tests'
]

{ #category : #resources }
StHelpBrowserPresenterTest class >> spFd1 [

	^ '# Chapitre Bar
Un paragraphe sur Bar

## 1
_Un paragraphe 1_

## 2
Un paragraphe 2

# Chapitre Foo

un paragraphe sur Foo'
]

{ #category : #resources }
StHelpBrowserPresenterTest class >> spFd2 [

	^ '# Chapitre 3
Un paragraphe sur 3'
]

{ #category : #resources }
StHelpBrowserPresenterTest class >> spFileContentsOneSection [

	^ '# Section 1
This is a test'
]

{ #category : #resources }
StHelpBrowserPresenterTest class >> spFileName [

	^ 'test.md'
]

{ #category : #'tests - search' }
StHelpBrowserPresenterTest >> helpTopicClass [

	^ StNodeHelpTopic
]

{ #category : #'tests - search' }
StHelpBrowserPresenterTest >> presenterClass [

	^ StHelpBrowserPresenter
]

{ #category : #running }
StHelpBrowserPresenterTest >> setUp [
	super setUp.
	filesystem := FileSystem memory.
	
]

{ #category : #running }
StHelpBrowserPresenterTest >> tearDown [ 

	window ifNotNil: [ window close ].
	super tearDown.
]

{ #category : #'tests - interaction' }
StHelpBrowserPresenterTest >> testOpenIsWorkingSmokeTest [
	"When this fails we have found a default way to open the help browser, then this test should be changed"
	| browser |
	self 
		should: [
			browser := self presenterClass new.
			window := browser openWithSpec]
		raise: Exception 
]

{ #category : #'tests - interaction' }
StHelpBrowserPresenterTest >> testOpenIsWorkingSmokeTestOnSpecificHelp [

	| browser topic |
	topic := StNodeHelpTopic named: 'Test'.
	browser := self presenterClass on: topic.
	self assert: browser rootTopic equals: topic.
	window := browser openWithSpec
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnCustomHelp2 [

	| browser rootTopic |
	browser := self presenterClass on: CustomHelp2 asHelpTopic.
	self flag: #toFix.
	"return an help topic and not a nodeHelpTopic"
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: 'Help'.
	self assert: rootTopic icon isNotNil.
	window := browser openWithSpec
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnSystemHelp2 [

	| browser rootTopic |
	browser := self presenterClass on: SystemHelp2 asHelpTopic.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: 'Help'.
	self assert: rootTopic icon isNil.
	window := browser openWithSpec
]
