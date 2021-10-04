"
I am read the microdown files in the pharo-project/pharo/doc folder. 
From these files I create a topic hiearachy.

My implementation is suffering from the structure of the github api, which do not return a folder tree, but a list of folders. 
In the key method `buildSubtopics: pathCollection level: level` the pathCollection and level is a approximation of a folder. Level 3 and path collection:

```
	aaa/bbb/ccc/ddd/eee
	aaa/bbb/ccc/fff
	aaa/bbb/ccc/hhh/ggg
```

would represent the folder: 'aaa/bbb/ccc' (first 3) with subfolders/files: {ddd/eee. fff. hhh/ggg}
"
Class {
	#name : #StTopicFromGithubBuilder,
	#superclass : #StTopicMicrodownBuilder,
	#instVars : [
		'githubClientConnection',
		'readingJob',
		'jobCounter'
	],
	#classInstVars : [
		'githubTopics'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #accessing }
StTopicFromGithubBuilder class >> githubTopics [
	githubTopics ifNil: [ githubTopics := self new buildTopics].
	^githubTopics
]

{ #category : #accessing }
StTopicFromGithubBuilder class >> openBrowser [
	<script>
	StHelpBrowserPresenter openTopic: self githubTopics 
]

{ #category : #accessing }
StTopicFromGithubBuilder class >> reset [
	<script>
	githubTopics := nil.
]

{ #category : #private }
StTopicFromGithubBuilder >> buildSubtopics: pathCollection level: level [
	"I assume pachCollection shares path below level"
	| subDirectories subTopics |
	subDirectories := pathCollection select: [ :p | p size >= level ].
	subDirectories := subDirectories groupedBy: [ :p | p at: (level)].
	subTopics := subDirectories values collect: [ :grp | self buildTopic: grp level: level ].
	^ subTopics 
]

{ #category : #private }
StTopicFromGithubBuilder >> buildTopic: pathCollection level: level [
	"I assume collectionOfPaths to share a root"
	| docTopics subTopics topic |
	
	docTopics := self getFiles: (pathCollection select: [ :p | p size = level ]).
	subTopics := docTopics , (self buildSubtopics: pathCollection level: level + 1).
	subTopics size = 1 
		ifTrue: [ ^ subTopics first ].
	topic := StNodeHelpTopic named: subTopics first title.
	(docTopics, subTopics) do: [ :t | topic addSubtopic: t"; addNode: t node" ].
	self liftNodesIn: topic.
	^topic
]

{ #category : #'public-api' }
StTopicFromGithubBuilder >> buildTopics [
	"I return a topic (with subtopics) read from the pharo-project repository on github"
	| root subTopics|
	[ :job |
		readingJob := job.
		jobCounter := 1.
		githubClientConnection := ZnClient new.
		root := StNodeHelpTopic named: 'Pharo Help'.
		subTopics := self buildSubtopics: self pharoDocPaths level: 1.
		subTopics do: [ :t | root addSubtopic: t ].
		githubClientConnection close.
	] asJob run.
	^ root
	
]

{ #category : #private }
StTopicFromGithubBuilder >> documentForPath: aPath [
	"https://raw.githubusercontent.com/pharo-project/pharo/Pharo10/doc/Epicea/1-Epicea.md"
	"aPath is the stuff after the doc/"
	|url response doc |
	readingJob title: aPath segments last.
	url := 'https://raw.githubusercontent.com/pharo-project/pharo/'
		,self pharoVersion,'/doc/', aPath pathString.
	response := githubClientConnection  get: url.
	doc := MicroDownParser parse: response. 
	readingJob progress: (jobCounter / 10).
	jobCounter := (jobCounter % 10) + 1.
	^ self createTopicsFromDocument: doc
]

{ #category : #private }
StTopicFromGithubBuilder >> getFiles: pathCollection [
	"Return an OrderedCollection of documents in the pathCollection"
	^ (pathCollection collect: [ :path | self documentForPath: path ]) flattened.
]

{ #category : #private }
StTopicFromGithubBuilder >> locationFrom: pathCollection level: level [
	^ (pathCollection first segments copyFrom: 1 to: level) joinUsing: '/'
]

{ #category : #private }
StTopicFromGithubBuilder >> pharoDocPaths [
	"I return an ordered collection of paths for documents in the doc tree"
	|pharoURL docURL json|
	"get the files in the pharo-project repository"
	pharoURL := 'https://api.github.com/repos/pharo-project/pharo/git/trees/',self pharoVersion.
	json := STONJSON fromString: (githubClientConnection get: pharoURL).
	"get the url for reading the doc folder only"
	docURL := ((json at: 'tree') detect: [ :e| (e at: 'path') = 'doc']) at: 'url'.
	"read the subfolder structure too"
	docURL := docURL , '?recursive=1'.
	json := STONJSON fromString: (githubClientConnection  get: docURL).
	^ ((json at: 'tree') 
		select: [ :e| ((e at: 'type') = 'blob')]) 
		collect: [:e| Path from: (e at: 'path')]
]

{ #category : #accessing }
StTopicFromGithubBuilder >> pharoVersion [
	^'Pharo10'
]
