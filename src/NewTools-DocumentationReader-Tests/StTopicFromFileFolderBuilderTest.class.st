"
A StTopicFromFileFolderBuilderTest is a test class for testing the behavior of StTopicFromFileFolderBuilder
"
Class {
	#name : #StTopicFromFileFolderBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'docDir',
		'rootTopic'
	],
	#category : #'NewTools-DocumentationReader-Tests'
}

{ #category : #'manual inspection' }
StTopicFromFileFolderBuilderTest class >> eyeballTest [
	"This should be able to open the HelpBrowser on the test data"
	<script>
	StHelpBrowserPresenter openOnHelpFolder: self new initializeTestFileStore.
]

{ #category : #initialization }
StTopicFromFileFolderBuilderTest >> contribute_md [
	^'# How to Contribute

Yes you can have an impact on Pharo. 
You can join and participate to build a great system and learn so much

Contributions can be
- answering question on the mailing-list or discord channel (see Documentation item) [https://discord.gg/QewZMZa](https://discord.gg/QewZMZa)
- fixing typos in books [http://books.pharo.org](http://books.pharo.org)
- writing tests
- reproducing and confirming a bug on your OS
- fixing bugs

You see there are plenty of opportunities to learn while improve Pharo 

To propose a bug fix or enhancement is easy and relatively well documented. 
The following website contains a clear description of the change:
	[http://pharo.org/contribute-propose-fix](http://pharo.org/contribute-propose-fix) 
 '
]

{ #category : #initialization }
StTopicFromFileFolderBuilderTest >> createFilesIn: root from: anArray [
	"Helper method to create a directory hierarchy with files.
	Adapted from MemoryFileSystemTest>>createFilesIn:from:"

	| dir path |

	dir := (root / anArray first) createDirectory.
	anArray allButFirstDo: [ :each |
		each isArray ifTrue: 
			[ self createFilesIn: dir from: each ]
		ifFalse: 
			[ (path := dir / each) writeStreamDo: [ :stream |
				stream nextPutAll: (self fileContents: each) ] ] ].
	^dir
]

{ #category : #initialization }
StTopicFromFileFolderBuilderTest >> fileContents: fileName [
	"We replace . by _ because the methods are named sunit_md."
	
	^ self perform: (fileName copyReplaceAll: '.' with: '_' ) asSymbol 
	
]

{ #category : #initialization }
StTopicFromFileFolderBuilderTest >> initializeTestFileStore [

	docDir ifNotNil: [ ^ docDir ].
	docDir := self 
		createFilesIn: FileSystem memory workingDirectory
		from:  #( doc #(welcome 'welcome.md' 'contribute.md') #(sunit 'sunitFramework.md')).
	^docDir
]

{ #category : #running }
StTopicFromFileFolderBuilderTest >> setUp [

	super setUp.
	self initializeTestFileStore.
	rootTopic := StTopicFromFileFolderBuilder new createRootTopicFromFolder: docDir
]

{ #category : #initialization }
StTopicFromFileFolderBuilderTest >> sunitFramework_md [
	^'# SUnit framework

SUnit is the mother of all unit testing frameworks, and serves as one of the cornerstones of test-driven development methodologies such as eXtreme Programming. 

The culture of testing has always been part of the philosophy of development in Smalltalk:
You write a method, accept the code and test it by writing a small script in a workspace, in a comment or an example as a class method. But this approach does not allow to automatically repeat the testing or ensure that the code is working. SUnit is a framework you can use to describe and execute unit tests. Unit testing is a method by which individual units of source code are tested to determine if they are fit for use. A unit is the smallest testable part of an application.'
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testCaching [
	"test that the presumed caching speeds things up"
	| raw cached first second |
	StTopicFromFileFolderBuilder resetCache.
	raw := Time microsecondsToRun: 
		[ first := StTopicFromFileFolderBuilder onDirectory: docDir ].
	cached := Time microsecondsToRun: 
		[ second := StTopicFromFileFolderBuilder onDirectory: docDir ].
	self assert: raw > cached.
	self assert: second equals: first.
	
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testGetsTopics [
	"Checking that anything works at all"
	self assert: rootTopic isNotNil.
	self assert: rootTopic class equals: StNodeHelpTopic.
	self assert: rootTopic title equals: 'Doc'
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testHeadersExtractedToTopics [
	"The Welcome file in the test data has a header 'Quick setup' which should be made into a topic"
	| welcome welcomeTo10 |
	welcome := rootTopic subtopics detect: [ :topic | topic title = 'Welcome' ].
	welcomeTo10 := welcome subtopics detect: [ :topic | topic title = 'Welcome to Pharo 10' ].
	self assert: welcomeTo10 subtopics first title equals: 'Quick setup'
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testNodesGetLifted [
	"The document contents of files should be aggregated into a combined document for folders"
	rootTopic subtopics do: [ :dirLevelTopic |
		self assert: dirLevelTopic node children isNotEmpty ]
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testOpenOnDoesNotExistFolder [

	self 
		should: [ StTopicFromFileFolderBuilder new createRootTopicFromFolder: 'nowhere' asFileReference  ]
		raise: DirectoryDoesNotExist 
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testRootTopicHasNoContents [
	self assert: rootTopic contents children isEmpty
]

{ #category : #tests }
StTopicFromFileFolderBuilderTest >> testSubtopics [
	self assert: rootTopic subtopics size equals: 2.
	self assert: (rootTopic subtopics collect: #title) asSet equals: #(Welcome Sunit) asSet
]

{ #category : #initialization }
StTopicFromFileFolderBuilderTest >> welcome_md [
	^'# Welcome to Pharo 10

Welcome to Pharo, an immersive live programming environment.

Pharo is a pure object-oriented programming language and a powerful environment, focused on simplicity and immediate feedback (think IDE and OS rolled into one).

For more information, please visit here: [http://pharo.org](http://pharo.org)

## Quick setup

Choose your preferred color theme: 
- `PharoLightTheme beCurrent` or `PharoDarkTheme beCurrent` 
- and  switch fullscreen mode executing  `Display toggleFullscreen`

Click if you have access to a: regular network connection or slow network
or if need to setup a network proxy.

You can also apply many other other settings by opening the `SettingBrowser open`.'
]
