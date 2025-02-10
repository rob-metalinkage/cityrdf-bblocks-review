# #!/bin/sh

mkdir -p ../rdfxml

python converter.py ../CityRDF-strict/appearance.ttl ../rdfxml/appearance.rdf
python converter.py ../CityRDF-strict/bridge.ttl ../rdfxml/bridge.rdf
python converter.py ../CityRDF-strict/building.ttl ../rdfxml/building.rdf
python converter.py ../CityRDF-strict/cityfurniture.ttl ../rdfxml/cityfurniture.rdf
python converter.py ../CityRDF-strict/cityobjectgroup.ttl ../rdfxml/cityobjectgroup.rdf
python converter.py ../CityRDF-strict/construction.ttl ../rdfxml/construction.rdf
python converter.py ../CityRDF-strict/core.ttl ../rdfxml/core.rdf
python converter.py ../CityRDF-strict/document.ttl ../rdfxml/document.rdf
python converter.py ../CityRDF-strict/dynamizer.ttl ../rdfxml/dynamizer.rdf
python converter.py ../CityRDF-strict/generics.ttl ../rdfxml/generics.rdf
python converter.py ../CityRDF-strict/landuse.ttl ../rdfxml/landuse.rdf
python converter.py ../CityRDF-strict/pointcloud.ttl ../rdfxml/pointcloud.rdf
python converter.py ../CityRDF-strict/relief.ttl ../rdfxml/relief.rdf
python converter.py ../CityRDF-strict/transportation.ttl ../rdfxml/transportation.rdf
python converter.py ../CityRDF-strict/tunnel.ttl ../rdfxml/tunnel.rdf
python converter.py ../CityRDF-strict/vegetation.ttl ../rdfxml/vegetation.rdf
python converter.py ../CityRDF-strict/versioning.ttl ../rdfxml/versioning.rdf
python converter.py ../CityRDF-strict/waterbody.ttl ../rdfxml/waterbody.rdf
python converter.py ../CityRDF-strict/workspace.ttl ../rdfxml/workspace.rdf
python converter.py ../CityRDF-strict/common.ttl ../rdfxml/common.rdf

cat ../rdfxml/*.rdf > rdfxml.rdf