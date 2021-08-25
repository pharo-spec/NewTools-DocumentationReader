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

{ #category : #'tests - cache' }
StHelpBrowserPresenterTest >> testHelpCache [

	| docFolder file cache save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'this is a text' ].
	self presenterClass internalizeHelpFrom: docFolder.
	cache := self presenterClass helpCache.
	self assert: cache basenameWithoutExtension equals: 'doc'.
	self
		assert: cache children first basenameWithoutExtension
		equals: 'file' ] ensure: [ self presenterClass helpCache: save ]
]

{ #category : #'tests - cache' }
StHelpBrowserPresenterTest >> testHelpCacheHandleShittyFiles [

	| docFolder file cache save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'this is a text' ].

	file := filesystem workingDirectory / 'doc' / '.DS_Store'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'crap crap' ].
	self presenterClass internalizeHelpFrom: docFolder.
	cache := self presenterClass helpCache.
	self assert: cache basenameWithoutExtension equals: 'doc'.
	self assert: cache children size equals: 1 ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #'tests - cache' }
StHelpBrowserPresenterTest >> testHelpCacheOnlyAcceptFolderAndMicFiles [

	| docFolder file cache save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'this is a text' ].

	file := filesystem workingDirectory / 'doc' / 'Stupid.txt'.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: 'This is a stupid mistyped extension text' ].

	filesystem createDirectory: 'doc/Epicea'.
	file := filesystem workingDirectory / 'doc' / 'Epicea' / 'fileEp.mic'.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: 'this is a text about Epicea' ].
	self presenterClass internalizeHelpFrom: docFolder.
	cache := self presenterClass helpCache.
	self assert: cache children size equals: 2.
	self assert: cache allChildren size equals: 4 ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #'tests - cache' }
StHelpBrowserPresenterTest >> testHelpCacheReturnFileReferenceEmptyIfNil [

	| cache |
	cache := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	self assert: self presenterClass helpCache hasChildren not.
	self presenterClass helpCache: cache
]

{ #category : #'tests - interaction' }
StHelpBrowserPresenterTest >> testOpenIsWorkingSmokeTest [

	| browser |
	browser := self presenterClass new.
	window := browser openWithSpec
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
StHelpBrowserPresenterTest >> testOpenOnCustomHelpWithClass [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp: self presenterClass.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnCustomHelpWithDescription [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp: SUnitTutorial.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: 'Tutorial'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnCustomHelpWithMethod [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp:
		           self presenterClass >> #rootTopic:.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnCustomHelpWithObject [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp: Object new.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnCustomHelpWithString [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp:
		           self presenterClass >> #rootTopic:.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testOpenOnDoesNotExistFolder [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnHelpFolder:
		           FileSystem workingDirectory
		           / 'ojdoajdjvsaidqsjkjfzeuican'.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
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

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserGotHelpTopicVisitorPerDefault [

	| visitor browser |
	browser := self presenterClass new.
	visitor := browser helpTopicVisitor.
	self assert: visitor equals: StTopicBuilderVisitor
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserGotHelpTopicVisitorThatISpecify [

	| visitor browser |
	browser := self presenterClass new.
	browser helpTopicVisitor: StTopicBuilderVisitor.
	visitor := browser helpTopicVisitor.
	self assert: visitor equals: StTopicBuilderVisitor
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserGotRootTopicThatISpecify [

	| topic browser |
	browser := self presenterClass new.
	topic := self helpTopicClass  named: 'Test'.
	browser rootTopic: topic.
	self assert: browser rootTopic equals: topic
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserGotTopicsPerDefault [

	| topic browser |
	browser := self presenterClass new.
	topic := browser rootTopic.
	self assert: topic title equals: 'Help'
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserGotTopicsThatISpecify [

	| topic browser |
	browser := self presenterClass new.
	browser rootTopic: (self helpTopicClass named: 'foo').
	topic := browser rootTopic.
	self assert: topic title equals: 'foo'
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserPresenterDocTopicFromFileSystemOnFile [

	| file browser rootTopic |
	file := filesystem workingDirectory / 'fd1.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].
	browser := self presenterClass new.
	rootTopic := browser createTopicsFromFileOrFolder: file.
	self assert: rootTopic size equals: 2
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserPresenterDocTopicFromSystem [

	| file directory browser rootTopic |
	filesystem createDirectory: 'test'.
	directory := filesystem workingDirectory / 'test'.
	file := filesystem workingDirectory / 'test/fd1.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].
	browser := self presenterClass new.
	rootTopic := (browser createRootTopicFromFolder: directory) rootTopic.
	self assert: rootTopic subtopics size equals: 2
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserPresenterOpenADirectory [

	| directory browser |
	directory := filesystem workingDirectory / self class spDirectoryName.
	filesystem createDirectory: self class spDirectoryName.
	browser := self presenterClass new.
	browser createRootTopicFromFolder: directory.

	self
		assert: browser rootTopic title
		equals: directory basenameWithoutExtension capitalized
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserPresenterTopicFromSystemOnDirectoryWithFiles [

	| directory file1 file2 browser rootTopic |
	filesystem createDirectory: 'test'.
	directory := filesystem workingDirectory / 'test'.


	file1 := filesystem workingDirectory / 'test/fd1.mic'.
	file1 writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].

	file2 := filesystem workingDirectory / 'test/fd2.mic'.
	file2 writeStreamDo: [ :stream | stream nextPutAll: self class spFd2 ].

	browser := self presenterClass new.
	rootTopic := (browser createRootTopicFromFolder: directory) rootTopic.
	self assert: rootTopic subtopics size equals: 3
]

{ #category : #tests }
StHelpBrowserPresenterTest >> testSpHelpBrowserPresenterTopicFromSystemOnFile [

	| file browser rootTopic |
	file := filesystem workingDirectory / 'fd1.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].
	browser := self presenterClass new.
	rootTopic := (browser createRootTopicFromFolder: file) rootTopic.
	self assert: rootTopic subtopics size equals: 2
]

{ #category : #'tests - cache' }
StHelpBrowserPresenterTest >> testTopicsWithCacheFrom [

	| docFolder file browser save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: '# section
this is a text' ].
	self presenterClass internalizeHelpFrom: docFolder.
	browser := self presenterClass open.
	window := browser window.
	self assert: browser rootTopic title equals: 'Doc'.
	self assert: browser rootTopic subtopics size equals: 1 ] ensure: [ 
		self presenterClass helpCache: save ]
]
