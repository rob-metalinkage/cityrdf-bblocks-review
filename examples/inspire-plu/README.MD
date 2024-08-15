# INSPIRE Planned Land Use
## 1. Introduction
INSPIRE Infrastructure for Spatial Information in Europe(https://knowledge-base.inspire.ec.europa.eu/index_en) is the source of various data models and inplementation rules covering aspects of spatial information in Europe. 
The [ontology of Planned Land Use](./plu.ttl) is generated with the help of [ShapeChange](https://shapechange.net/) from the official [INSPIRE UML model](https://inspire-mif.github.io/uml-models/approved/).


*Figure 1. Data model for INSPIRE Planned Land Use*
![](./inspire-plu-data-model.png)

## 2. Legend
Prefix | Namespace
--- | ---
[plu](http://inspire.ec.europa.eu/ont/plu#) | `http://inspire.ec.europa.eu/ont/plu#`
[lunom](http://inspire.ec.europa.eu/ont/lunom#) | `http://inspire.ec.europa.eu/ont/lunom#`

## 3. Modelling Decisions
>SpatialPlan

- The main element, incorporates one or several `ZoningElement` items, is restricted by (possibly) present `SupplementaryRegulation` items described in one or several `OfficialDocumentation` items.

>ZoningElement

- describes a geometry in GML and a `HILUCSValue` - one of land use categories. 

>HILUCSValue

 - The list is populated with the land use categories of the Hierarchical INSPIRE Land Use Classification System (HILUCS).The elements of the list should be both applicable to existing land use and planned land use (taken from https://inspire.ec.europa.eu/codelist/HILUCSValue). HILUCS is encoded in [Land Use Nomenclature](./lunom.ttl)

![](./landuse-classification.png)
