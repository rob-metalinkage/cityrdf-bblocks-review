# CityGML-OWL derivation

This directory is used to define a CityGML OWL derived from the UML source.

The intention is to set this up as a proof of concept that can be migrated to the (or an) official CityGML specification repository.


## Background

A proposal to implement a CityGML OWL representation to support RDF encodings was presented to the CityGML Working Group in June 2023.

The CHEK project has identified a need to reconcile related sources of information from different systems and designed an approach around "semantic uplift" to a minimal profile of each standard used to a common model that can support regulation evaluation. (Thus this complex task does not need to be repeated for each version of each encoding approach - such as CityGML, CityJSON, BIM/IFC and various planning GIS layers.)

Resources described in CityGML WG proposal (thanks to Diego Vinasco-Alvarez)

* CityGML 3.0 ShapeChange config: https://github.com/VCityTeam/UD-Graph/blob/master/Transformations/ShapeChange/CityGML3.0_to_OWL_config.xml

* The most recent generated CityGML 3.0 OWL Ontologies: https://dataset-dl.liris.cnrs.fr/rdf-owl-urban-data-ontologies/Ontologies/CityGML/3.0/

* A Python script that fixes a few logical inconsistencies in the ShapeChange output: https://github.com/VCityTeam/UD-Graph/blob/master/Transformations/ShapeChange/ontologyPatcher.py

## Current solution

We use [CityGML_3.0-workspaces-documents_shapechange-export.xml](https://github.com/VCityTeam/UD-Graph/blob/master/Transformations/test-data/UML/CityGML_3.0-workspaces-documents_shapechange-export.xml) as a source of CityGML3.0 model.

We added `<<Union>>` stereotype conversion and experiment with `rule-owl-prop-globalScopeAttributes`.

To run the ShapeChange conversion write in bash

```./run.sh```

The results will be in the folder `stage-1`.

To apply patches to make the results better viewable in Protege, see the explanation in [VCityTeam solution](https://github.com/VCityTeam/UD-Graph/tree/master/Transformations/ShapeChange) that is the solution to get the [initial version of CityGML3.0 in OWL](https://dataset-dl.liris.cnrs.fr/rdf-owl-urban-data-ontologies/Ontologies/CityGML/3.0/)

```./patch-ontologies.sh```

The results will be in the folder `stage-2`.

VCityTeam detected several obsolete/hanging definitions that were to be patched, and proposed `update-triples.sh` to patch them. 
The script did the following:

- merges in one file an ontology for the UML package with codelist values defined in it.
- adds cityModelMember modifications
- adds GeoSPARQL and OWL-Time alignments
- removes outdated core triples and correspondent hanging restrictions
- patches RoomHeight.status range

We extended this script to implement our vision on how we can benefit from custom UML-to-OWL conversion.

### Global Properties explication

There are some attributes named equally in different packages, such as `usage`, `class`, `function`, `address`, `value` and others.

In OWL object/datatype properties are first-class citizens whereas in UML and UML converted into OWL with ShapeChange they are converted into package-level and class-level attributes.

We explicate such attributes, and make a custom postprocessing step.

The explication query is below, resulting in lists of [object properties](./statistics/citygml-how%20many%20ObjectProperties%20reuse%20the%20same%20label.csv), [datatype properties](./statistics/citygml-how%20many%20DatatypeProperites%20reuse%20the%20same%20label.csv)

```sparql
select ?o (count(?s) as ?count) where { 
	?s rdfs:label ?o .
        ?s a owl:ObjectProperty .
#       ?s rdfs:label ?o .
#       ?s a owl:DatatypeProperty .
} group by ?o having (count(?s)>1)
order by desc(?count)
```

Here is an example:

```turtle
con:usage  rdf:type      owl:ObjectProperty;
        rdfs:label       "usage"@en;
        rdfs:range       con:DoorUsageValue;
        skos:definition  "Specifies the actual uses of the Door."@en .
```
will be splitted into the one defined in the particular package

```turtle
common:usage  rdfs:range       con:DoorUsageValue;
        skos:definition  "Specifies the actual uses of the Door."@en .
```
and another defined once in the `common` package

```turtle
common:usage  rdf:type      owl:ObjectProperty;
        rdfs:label       "usage"@en;
```
We add the following:
- we introduce an ontology `/additional-triples/common.ttl` and a namespace `PREFIX common: <https://ogcblocks.org/CityGML/3.0/common#>` keeping all ObjectProperties and DatatypeProperties sharing the same domain and varying in the `rdfs:range` (and `rdfs:label/skos:definition`). 

We apply four SPARQL queries ([##1-4 in the file](./update-triples.sh)) across all ontologies in `stage-2` to do this.

However some of the usages of such properties are in abstract classes. For example, object property `boundary` has domain in some abstract class 4 times, and 9 times is has a non-abstract domain (in total, 13 occurences) (see the full list of duplications in abstract classes [here](./statistics/citygml-duplications%20of%20properties%20with%20domain%20in%20Abstractclass.csv)). As we would like to avoid appearance of abstract classes in OWL (since they are not instantiated), the full list of actions on duplicated definitions of object/datatype properties is described below.

### ADE* classes/ade* properties removal
As far as the implementation of Application Domain Extensions (ADEs) is optional, we decided to remove mentioning of ADE* classes/ade* properties from CityGML ontologies.

Here is the typical example of a restriction involving ADE* class and ade* property:

```turtle
luse:LandUse a owl:Class ;
    rdfs:label "LandUse"@en ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:allValuesFrom luse:ADEOfLandUse ;
            owl:onProperty luse:adeOfLandUse ],
    ...
luse:adeOfLandUse a owl:ObjectProperty ;
    rdfs:label "adeOfLandUse"@en ;
    rdfs:range luse:ADEOfLandUse ;
    skos:definition "Augments the LandUse with properties defined in an ADE."@en .
luse:ADEOfLandUse a owl:Class ;
    rdfs:label "ADEOfLandUse"@en ;
    iso19150-2:isAbstract true ;
    skos:definition "ADEOfLandUse acts as a hook to define properties within an ADE that are to be added to a LandUse."@en .
```
We apply one SPARQL query ([#5 in the file](./update-triples.sh)) across all ontologies in `stage-2` to do this.

### Abstract classes removal
As far as in practice Abstract* classes are not instantiated, we decided to have a possibility to "switch abstract classes/properties off" and do not have them declared in OWL.

To keep the knowledge of which non-abstract classes can be domains/ranges of properties of those classes, we propose to do the following:

each property of an Abstract class is defined as first-class citizen in OWL, with relaxed domain and range restriction using [schema:domainIncludes](https://schema.org/domainIncludes)/[schema:rangeIncludes](https://schema.org/rangeIncludes).

Qualifying query making use of the naming conventions in OWL generated by ShapeChange:

```sparql
#duplications of properties with domain in Abstract* class
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select 
(count(?classIndependentPropName) as ?countClasses)
# ?s 
  ?classIndependentPropName 
# ?classThePropDepends
where { 
	?s a owl:ObjectProperty .
    optional{bind(strafter(str(?s),"#") as ?classIndependentPropName).}
    optional{bind(strbefore(strafter(str(?s),"#"),".") as ?classThePropDepends).}
	?s rdfs:label ?classIndependentPropName .
    filter (strafter(str(?s),"Abstract") != "")
} group by ?classIndependentPropName having (count(?classIndependentPropName) > 1)
# group by ?classIndependentPropName having (count(?classIndependentPropName) = 1)
```
shows that there are two options:

- a property is unique within the whole family (i.e. there exists exactly one usage of it), for example, `tunnelFurniture`: 

```turtle
tun:AbstractTunnel.tunnelFurniture a owl:ObjectProperty ;
    rdfs:label "tunnelFurniture"@en ;
    rdfs:domain tun:AbstractTunnel ;
    rdfs:range tun:TunnelFurniture ;
    skos:definition "Relates the furniture objects to the Tunnel or TunnelPart."@en .
```

- a property is not unique within the whole family, but is used within one (package) ontology, for example, `lod0MultiCurve`:

```turtle
core:AbstractSpace.lod0MultiCurve a owl:ObjectProperty ;
    rdfs:label "lod0MultiCurve"@en ;
    rdfs:domain core:AbstractSpace ;
    rdfs:range gmlowl:MultiCurve ;
    skos:definition "Relates to a 3D MultiCurve geometry that represents the space in Level of Detail 0."@en .
...
core:AbstractThematicSurface.lod0MultiCurve a owl:ObjectProperty ;
    rdfs:label "lod0MultiCurve"@en ;
    rdfs:domain core:AbstractThematicSurface ;
    rdfs:range gmlowl:MultiCurve ;
    skos:definition "Relates to a 3D MultiCurve geometry that represents the thematic surface in Level of Detail 0."@en .
```
- a property is not unique within the whole family, and used across package ontologies, for example, `boundary`:

in construction package

```turtle
con:AbstractConstruction.boundary a owl:ObjectProperty ;
    rdfs:label "boundary"@en ;
    rdfs:domain con:AbstractConstruction ;
    rdfs:range core:AbstractThematicSurface ;
    skos:definition "Relates to the surfaces that bound the construction. This relation is inherited from the Core module."@en .
```
in core package

```turtle
core:AbstractSpace.boundary a owl:ObjectProperty ;
    rdfs:label "boundary"@en ;
    rdfs:domain core:AbstractSpace ;
    rdfs:range core:AbstractSpaceBoundary ;
    skos:definition "Relates to surfaces that bound the space."@en .
```
in building package (used twice)

```turtle
bldg:BuildingRoom.boundary a owl:ObjectProperty ;
    rdfs:label "boundary"@en ;
    rdfs:domain bldg:BuildingRoom ;
    rdfs:range core:AbstractThematicSurface ;
    skos:definition "Relates to the surfaces that bound the BuildingRoom. This relation is inherited from the Core module."@en .
...
bldg:Storey.boundary a owl:ObjectProperty ;
    rdfs:label "boundary"@en ;
    rdfs:domain bldg:Storey ;
    rdfs:range core:AbstractThematicSurface ;
    skos:definition "Relates to the surfaces that bound the Storey. This relation is inherited from the Core module."@en .
```
The qualifying query (for `boundary`) is:

```sparql
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select 
#?s 
?classIndependentPropName 
?classThePropDepends
?domainToInclude
?rangeToInclude
where { 
	?s a owl:ObjectProperty .
    optional{bind(strafter(str(?s),"#") as ?classIndependentPropName).}
    optional{bind(strbefore(strafter(str(?s),"#"),".") as ?classThePropDepends).}
	?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    filter (strafter(str(?domainToInclude),"Abstract") = "")
    filter (str(?classIndependentPropName)="boundary")
}
```
with the results:

| classIndependentPropName | classThePropDepends   | domainToInclude                                                        | rangeToInclude                                                           |
|--------------------------|-----------------------|------------------------------------------------------------------------|--------------------------------------------------------------------------|
| boundary                 | WaterBody             | https://ogcblocks.org/CityGML/3.0/waterbody#WaterBody                  | https://ogcblocks.org/CityGML/3.0/waterbody#AbstractWaterBoundarySurface |
| boundary                 | HollowSpace           | https://ogcblocks.org/CityGML/3.0/tunnel#HollowSpace                   | https://ogcblocks.org/CityGML/3.0/core#AbstractThematicSurface           |
| boundary                 | AuxiliaryTrafficSpace | https://ogcblocks.org/CityGML/3.0/transportation#AuxiliaryTrafficSpace | https://ogcblocks.org/CityGML/3.0/transportation#AuxiliaryTrafficArea    |
| boundary                 | TrafficSpace          | https://ogcblocks.org/CityGML/3.0/transportation#TrafficSpace          | https://ogcblocks.org/CityGML/3.0/transportation#TrafficArea             |
| boundary                 | Door                  | https://ogcblocks.org/CityGML/3.0/construction#Door                    | https://ogcblocks.org/CityGML/3.0/construction#DoorSurface               |
| boundary                 | Window                | https://ogcblocks.org/CityGML/3.0/construction#Window                  | https://ogcblocks.org/CityGML/3.0/construction#WindowSurface             |
| boundary                 | BuildingRoom          | https://ogcblocks.org/CityGML/3.0/building#BuildingRoom                | https://ogcblocks.org/CityGML/3.0/core#AbstractThematicSurface           |
| boundary                 | Storey                | https://ogcblocks.org/CityGML/3.0/building#Storey                      | https://ogcblocks.org/CityGML/3.0/core#AbstractThematicSurface           |
| boundary                 | BridgeRoom            | https://ogcblocks.org/CityGML/3.0/bridge#BridgeRoom                    | https://ogcblocks.org/CityGML/3.0/core#AbstractThematicSurface           |

We aim at creating a definition of the kind:

```turtle
common:boundary a owl:ObjectProperty ;
    rdfs:label "boundary"@en ;
# all non-abstract classes in domain
    schema:domainIncludes bldg:BuildingRoom, bldg:Storey, wtr:WaterBody, tun:HollowSpace, transportation:AuxiliaryTrafficSpace, transportation:TrafficSpace, con:Door, con:Window, brid:BridgeRoom ;
# all non-abstract classes in range
    schema:rangeIncludes con:WindowSurface, con:DoorSurface, transportation:TrafficArea, transportation:AuxiliaryTrafficArea .
```
and in each of ontologies mentioning `boundary` (here `bldg`, `wtr`, `tun`, `transportation`, `con`, `brid`):

```turtle
common:boundary skos:definition "Here goes the definition that originate in the package, 
        for each package it will be different"
```
