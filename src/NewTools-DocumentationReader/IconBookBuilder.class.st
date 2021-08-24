Class {
	#name : #IconBookBuilder,
	#superclass : #Object,
	#instVars : [
		'bookIcon',
		'pageIcon'
	],
	#category : #'NewTools-DocumentationReader'
}

{ #category : #build }
IconBookBuilder >> buildBookIcon: aTopic [

	^ aTopic iconName: bookIcon
]

{ #category : #build }
IconBookBuilder >> buildIcon: aTopic [

	self buildBookIcon: aTopic
]

{ #category : #initialization }
IconBookBuilder >> initialize [
	super initialize.
	bookIcon := #bookIcon.
	pageIcon := #pageIcon
]

{ #category : #build }
IconBookBuilder >> setIconOf: aTopic [
	^ aTopic iconName: pageIcon
]
