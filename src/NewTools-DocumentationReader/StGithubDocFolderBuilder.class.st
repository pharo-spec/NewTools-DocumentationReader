"
I am read the microdown files in the pharo-project/pharo/doc folder. 
From these files I create a topic hiearachy.
"
Class {
	#name : #StGithubDocFolderBuilder,
	#superclass : #Object,
	#instVars : [
		'iconBuilder'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> buildSubtopics: pathCollection level: level [
	"I assume pachCollection shares path below level"
	| subDirectories subTopics |
	subDirectories := pathCollection select: [ :p | p size >= level ].
	subDirectories := subDirectories groupedBy: [ :p | p at: (level)].
	subTopics := subDirectories values collect: [ :grp | self buildTopic: grp level: level ].
	^ subTopics 
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> buildTopic: pathCollection level: level [
	"I assume collectionOfPaths to share a root"
	| documents subTopics  title topic |
	title := pathCollection first at: level.
	documents := self getFiles: (pathCollection select: [ :p | p size = level ]).
	subTopics := self buildSubtopics: pathCollection level: level + 1.
	topic := StNodeHelpTopic named: title with: self iconBuilder.
	documents do: [ :doc | topic addNode: doc ].
	subTopics do: [ :t | topic addSubtopic: t ].
	^topic
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> buildTopics [
	| root subTopics|
	root := StNodeHelpTopic named: 'Pharo Help' with: self iconBuilder.
	subTopics := self buildSubtopics: self pharoDocTree level: 1.
	subTopics do: [ :t | root addSubtopic: t ].
	^ root
	
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> documentForPath: aPath [
	"https://raw.githubusercontent.com/pharo-project/pharo/Pharo10/doc/Epicea/1-Epicea.md"
	|url response|
	url := 'https://raw.githubusercontent.com/pharo-project/pharo/'
		,self pharoVersion,'/doc/', aPath pathString.
	response := ZnClient new beOneShot;get: url.
	^ MicroDownParser parse: response. 
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> getFiles: pathCollection [
	"Return an OrderedCollection of documents in the pathCollection"
	^ pathCollection collect: [ :path | self documentForPath: path ].
]

{ #category : #accessing }
StGithubDocFolderBuilder >> iconBuilder [
	iconBuilder ifNil: [ iconBuilder := StIconBookBuilder new ].
	^ iconBuilder 
]

{ #category : #protocol }
StGithubDocFolderBuilder >> pharoDocTree [
	"I return an ordered collection of paths for documents in the doc tree"
	|pharoURL docURL json|
	"get the files in the pharo-project repository"
	pharoURL := 'https://api.github.com/repos/pharo-project/pharo/git/trees/',self pharoVersion.
	json := STONJSON fromString: (ZnClient new beOneShot;get: pharoURL).
	"get the url for reading the doc folder only"
	docURL := ((json at: 'tree') detect: [ :e| (e at: 'path') = 'doc']) at: 'url'.
	"read the subfolder structure too"
	docURL := docURL , '?recursive=1'.
	json := STONJSON fromString: (ZnClient new beOneShot;get: docURL).
	^ ((json at: 'tree') 
		select: [ :e| ((e at: 'type') = 'blob')]) 
		collect: [:e| Path from: (e at: 'path')]
]

{ #category : #protocol }
StGithubDocFolderBuilder >> pharoVersion [
	^'Pharo10'
]
