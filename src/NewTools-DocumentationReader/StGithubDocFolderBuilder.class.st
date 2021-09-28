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
StGithubDocFolderBuilder >> buildTopic: pathCollection level: level [
	"I assume collectionOfPaths to share a root"
	| documents subTopics  title topic |
	title := pathCollection first at: level.
	documents := self getFiles: (pathCollection select: [ :p | p size = level ]).
	subTopics := ((pathCollection select: [ :p | p size > level ]) 
			groupedBy: [ :p | p at: (level+1)]) 
			values collect: [ :grp | self buildTopic: grp level: level + 1 ].
	topic := StNodeHelpTopic named: title with: self iconBuilder.
	topic node children: documents.
	topic subtopics: subTopics.
	^topic
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> buildTopics [
	^ self 
		buildTopic: self pharoDocTree 
		level: 1
	
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> documentForPath: aPath [
	"https://raw.githubusercontent.com/pharo-project/pharo/Pharo10/doc/Epicea/1-Epicea.md"
	|url response|
	url := 'https://raw.githubusercontent.com/pharo-project/pharo/'
		,self pharoVersion,'/', aPath pathString.
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
	|url response json|
	url := 'https://api.github.com/repos/pharo-project/pharo/git/trees/'
		,self pharoVersion,'?recursive=1.'.
	response := ZnClient new beOneShot;get: url.
	json := STONJSON fromString: response.
	^ ((json at: 'tree') 
		select: [ :e| ((e at: 'type') = 'blob') and: [(e at: 'path') beginsWith: 'doc/']]) 
		collect: [:e| Path from: (e at: 'path')]
]

{ #category : #protocol }
StGithubDocFolderBuilder >> pharoVersion [
	^'Pharo10'
]
