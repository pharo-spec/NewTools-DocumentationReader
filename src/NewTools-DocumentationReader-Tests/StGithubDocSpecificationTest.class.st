"
A StGithubDocSpecificationTest is a test class for testing the behavior of StGithubDocSpecification
"
Class {
	#name : #StGithubDocSpecificationTest,
	#superclass : #TestCase,
	#category : #'NewTools-DocumentationReader-Tests'
}

{ #category : #tests }
StGithubDocSpecificationTest >> testUrlForDocFolder [
	| spec |
	spec := StGithubDocSpecification new branch: 'Pharo10'.
	self 
		assert: spec urlForDocFolder 
		equals: 'https://api.github.com/repos/pharo-project/pharo/git/trees/Pharo10'
]

{ #category : #tests }
StGithubDocSpecificationTest >> testUrlForFile [
	| spec |
	spec := StGithubDocSpecification new branch: 'Pharo10'.
	self 
		assert: (spec urlForFile: 'foo/bar.md')
		equals: 'https://raw.githubusercontent.com/pharo-project/pharo/Pharo10/doc/foo/bar.md'
]
