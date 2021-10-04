"
I represent a specification of where to find documentation in a github repository.


"
Class {
	#name : #StGithubDocSpecification,
	#superclass : #Object,
	#instVars : [
		'user',
		'project',
		'branch',
		'folder'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #accessing }
StGithubDocSpecification >> branch [

	^ 'master'
]

{ #category : #accessing }
StGithubDocSpecification >> branch: anObject [

	branch := anObject
]

{ #category : #accessing }
StGithubDocSpecification >> folder [

	^ folder
]

{ #category : #accessing }
StGithubDocSpecification >> folder: anObject [

	folder := anObject
]

{ #category : #initialize }
StGithubDocSpecification >> initialize [
	super initialize.
	branch := 'master'.
	folder := 'doc'.
	project := 'pharo'.
	user := 'pharo-project'
]

{ #category : #printing }
StGithubDocSpecification >> printOn: aStream [
	aStream
		<< 'GithubSpec['
		<< user << '/' << project << '/' << branch << '/' << folder
		<< ']'.
]

{ #category : #accessing }
StGithubDocSpecification >> project [

	^ project
]

{ #category : #accessing }
StGithubDocSpecification >> project: anObject [

	project := anObject
]

{ #category : #url }
StGithubDocSpecification >> urlForDocFolder [
	^ 'https://api.github.com/repos/{1}/{2}/git/trees/{3}' format: { user. project. branch }
]

{ #category : #url }
StGithubDocSpecification >> urlForFile: aPath [
	^ 'https://raw.githubusercontent.com/{1}/{2}/{3}/{4}/{5}' 
			format: { user. project. branch. folder. aPath }
]

{ #category : #accessing }
StGithubDocSpecification >> user [

	^ user
]

{ #category : #accessing }
StGithubDocSpecification >> user: anObject [

	user := anObject
]
