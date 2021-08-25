"
I set pageIcon when the topic has not subtopics.
I set bookIcon when the topic has subtopics.
"
Class {
	#name : #StIconBookBuilder,
	#superclass : #Object,
	#instVars : [
		'bookIcon',
		'pageIcon'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #build }
StIconBookBuilder >> buildBookIcon: aTopic [

	^ aTopic iconName: bookIcon
]

{ #category : #build }
StIconBookBuilder >> buildIcon: aTopic [

	self buildBookIcon: aTopic
]

{ #category : #initialization }
StIconBookBuilder >> initialize [
	super initialize.
	bookIcon := #bookIcon.
	pageIcon := #pageIcon
]

{ #category : #build }
StIconBookBuilder >> setIconOf: aTopic [
	^ aTopic iconName: pageIcon
]
