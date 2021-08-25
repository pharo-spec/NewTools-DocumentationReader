"
I set the icon of topic with a class icon
"
Class {
	#name : #StIconClassBuilder,
	#superclass : #Object,
	#category : #'NewTools-DocumentationReader'
}

{ #category : #build }
StIconClassBuilder >> buildIcon: aTopic [
	^ aTopic icon: (self class environment at: aTopic title asSymbol) systemIcon
]
