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
StGithubDocFolderBuilder >> buildTopicFor: collectionOfPaths [
	"I assume collectionOfPaths to share a root"
	| title subElements files subDirs topic |
	collectionOfPaths ifEmpty: [ ^nil ].
	title := collectionOfPaths first first.
	subElements := (collectionOfPaths
		collect: [ :p | p copyWithoutFirst ]).
	files := subElements select: [ :p | p size = 1 ].
	subDirs := subElements select: [ :p | p size > 1 ].
	topic := StNodeHelpTopic named: title with: self iconBuilder.
	self addFiles: files toTopic: topic.
	self addDirs: subDirs toTopic: topic.
	^ topic
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> documentForPath: aPath [
	"https://raw.githubusercontent.com/pharo-project/pharo/Pharo10/doc/Epicea/1-Epicea.md"
	|url response|
	url := 'https://raw.githubusercontent.com/pharo-project/pharo/'
		,self pharoVersion, aPath pathString.
	response := ZnClient new beOneShot;get: url.
	^ MicroDownParser parse: response. 
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> getFiles: pathCollection [
	"Return an OrderedDictionary mapping filename (last element in path) to a markdown root node"
	^ pathCollection 
		inject: OrderedDictionary new
		into: [ :dic :path | 
			dic at: path segments last put: (self documentForPath: path).
			dic ]
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> groupPaths: pathCollection level: level [
	|subLevels groups thisLevel files |
	thisLevel := pathCollection select: [ :p | p size = level ].
	files := self getFiles: thisLevel.
	subLevels := pathCollection select: [ :p | p size > level ].
	groups := subLevels groupedBy: [ :p | p at: level ].
	^ files addAll: (groups collect: [ :grp | self groupPaths: grp level: level + 1 ]) associations; yourself
]

{ #category : #'as yet unclassified' }
StGithubDocFolderBuilder >> grouped: splitted [
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
		collect: [:e| e at: 'path']
]

{ #category : #protocol }
StGithubDocFolderBuilder >> pharoVersion [
	^'Pharo10'
]
