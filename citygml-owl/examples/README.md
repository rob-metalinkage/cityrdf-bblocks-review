# Test files
lod3-sample*.files are taken from lod3_building_models.gml

CityGML 2.0 property `bldg:measuredHeight` is obsolete in 3.0 and replaced with `con:height`. 

In `lod3-sample-fail.*` used `bldg:measuredHeight` and prefixes of CityGML 2.0 - validator should return error

In `lod3-sample-ok.*` used `con:height` and prefixes of CityGML 3.0. There should not be errors of validation.

The conversion from gml to ttl is done with xSPARQL script.