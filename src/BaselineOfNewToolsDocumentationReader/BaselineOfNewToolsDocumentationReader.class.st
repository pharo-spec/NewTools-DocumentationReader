Class {
	#name : #BaselineOfNewToolsDocumentationReader,
	#superclass : #BaselineOf,
	#category : #BaselineOfNewToolsDocumentationReader
}

{ #category : #baselines }
BaselineOfNewToolsDocumentationReader >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		
		"spec
			baseline: 'Spec'
			with: [
				spec
					repository: 'github://pharo-spec/spec:dev/src' ]."
		spec
			baseline: 'Microdown'
			with: [
				spec
					loads: #('RichText');
					repository: 'github://Pillar-markup/Microdown:master/src' ].
		
		spec
			package: #'NewTools-DocumentationReader'
				with: [ spec requires: #( #'Microdown' ) ];
			package: #'NewTools-DocumentationReader-Tests'
				with: [ spec requires: #( #'NewTools-DocumentationReader') ]].
			
			
	
]
