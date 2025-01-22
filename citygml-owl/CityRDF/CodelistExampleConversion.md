Source

```turtle
bldgcode:BuildingClassValue a skos:ConceptScheme ;
    rdfs:label "BuildingClassValue"@en ;
    dct:isFormatOf bldg:BuildingClassValue ;
    skos:definition "BuildingClassValue is a code list used to further classify a Building."@en .
...
bldg:BuildingClassValue a owl:Class ;
    rdfs:label "BuildingClassValue"@en ;
    rdfs:subClassOf skos:Concept ;
    skos:definition "BuildingClassValue is a code list used to further classify a Building."@en .
```

Target

Similarly ro app:TextureType

```turtle
app:TextureType a rdfs:Datatype ;
    rdfs:label "TextureType"@en ;
    owl:equivalentClass [ a rdfs:Datatype ;
            owl:oneOf ( "specific" "typical" "unknown" ) ] ;
    skos:definition "TextureType enumerates the different texture types."@en .
```
app:TextureType is the enumeration, values are known.

```turtle
bldg:BuildingClassValue a rdfs:Datatype ;
    rdfs:label "BuildingClassValue"@en ;
    owl:equivalentClass [ a rdfs:Datatype ;
            owl:oneOf ( ) ] ;
    skos:definition "BuildingClassValue is a code list used to further classify a Building."@en .
```
Minuses: 
    - we loose conformance to UML - in UML BuildingClassValue is a CodeList, not a Datatype.
    Here is how INSPIRE codelists are explained: https://wetransform.to/news-and-events/inspire-codelists/
    - codelists cannot be defined externally, as skos:ConceptSchema and skos:Concepts, it violates data interoperability. Example: if we define some strict codelist for BuildingClassValue, it will be enumeration, but to add a new value to this list we shold edit Building ontology. 

Pluses:
    - we don't mix formal ontologies and thesauri, see [skos-reference](https://www.w3.org/TR/skos-reference/):

    “To understand this distinction, consider that the “knowledge” made explicit in a formal ontology is expressed as sets of axioms and facts. A thesaurus or classification scheme is of a completely different nature, and does not assert any axioms or facts. Rather, a thesaurus or classification scheme identifies and describes, through natural language and other informal means, a set of distinct ideas or meanings, which are sometimes conveniently referred to as “concepts”.” And this is about my comment about making certain ‘ontological commitment’ by including SKOS Concepts in OWL. More here: https://www.w3.org/TR/skos-reference/