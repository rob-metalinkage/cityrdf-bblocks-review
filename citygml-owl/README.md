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

We addressed the missing `<<Union>>` stereotype conversion, added conversion for <<Enumeration>>, extended missing conversion for `iso19136` adding basic types for `MeasureOrNilReasonList, DoubleOrNilReasonList, NilReason` that was not available in the [original ShapeChange config from UD-Graph](https://github.com/VCityTeam/UD-Graph/blob/master/Transformations/ShapeChange/CityGML3.0_to_OWL_config.xml).

To run the conversion write in bash

```./run.sh```

The results will be in the folder `converted`.

