# #!/bin/sh

if test ! -d ./output; then
    mkdir ./output
fi

# ### Add codeList concept schemes
echo 'Adding bridge-codes.ttl'
python add_triples.py ./stage-2/bridge.ttl ./stage-1/ACMAPPER/bridge/bridge_codes.ttl ./output/bridge.ttl
echo 'Adding building-codes.ttl'
python add_triples.py ./stage-2/building.ttl ./stage-1/ACMAPPER/building/building_codes.ttl ./output/building.ttl
echo 'Adding construction-codes.ttl'
python add_triples.py ./stage-2/construction.ttl ./stage-1/ACMAPPER/construction/construction_codes.ttl ./output/construction.ttl
echo 'Adding core-codes.ttl'
python add_triples.py ./stage-2/core.ttl ./stage-1/ACMAPPER/core/core_codes.ttl ./output/core.ttl
echo 'Adding document-codes.ttl'
python add_triples.py ./stage-2/document.ttl ./stage-1/ACMAPPER/document/document_codes.ttl ./output/document.ttl
echo 'Adding dynamizer-codes.ttl'
python add_triples.py ./stage-2/dynamizer.ttl ./stage-1/ACMAPPER/dynamizer/dynamizer_codes.ttl ./output/dynamizer.ttl
echo 'Adding furniture-codes.ttl'
python add_triples.py ./stage-2/cityfurniture.ttl ./stage-1/ACMAPPER/cityfurniture/cityfurniture_codes.ttl ./output/cityfurniture.ttl
echo 'Adding generics-codes.ttl'
python add_triples.py ./stage-2/generics.ttl ./stage-1/ACMAPPER/generics/generics_codes.ttl ./output/generics.ttl
echo 'Adding group-codes.ttl'
python add_triples.py ./stage-2/cityobjectgroup.ttl ./stage-1/ACMAPPER/cityobjectgroup/cityobjectgroup_codes.ttl ./output/cityobjectgroup.ttl
echo 'Adding landuse-codes.ttl'
python add_triples.py ./stage-2/landuse.ttl ./stage-1/ACMAPPER/landuse/landuse_codes.ttl ./output/landuse.ttl
echo 'Adding transportation-codes.ttl'
python add_triples.py ./stage-2/transportation.ttl ./stage-1/ACMAPPER/transportation/transportation_codes.ttl ./output/transportation.ttl
echo 'Adding tunnel-codes.ttl'
python add_triples.py ./stage-2/tunnel.ttl ./stage-1/ACMAPPER/tunnel/tunnel_codes.ttl ./output/tunnel.ttl
echo 'Adding vegetation-codes.ttl'
python add_triples.py ./stage-2/vegetation.ttl ./stage-1/ACMAPPER/vegetation/vegetation_codes.ttl ./output/vegetation.ttl
echo 'Copying versioning.ttl'
cp ./stage-2/versioning.ttl ./output/
echo 'Adding waterbody-codes.ttl'
python add_triples.py ./stage-2/waterbody.ttl ./stage-1/ACMAPPER/waterbody/waterbody_codes.ttl ./output/waterbody.ttl
# ### Additional modification ###
echo 'Adding cityModelMember modifications'
python add_triples.py ./output/core.ttl ./additional-triples/citymodelmember.ttl ./output/core.ttl
echo 'Adding GeoSPARQL and OWL-Time alignments'
python add_triples.py ./output/core.ttl ./additional-triples/alignments.ttl ./output/core.ttl
echo 'Removing outdated core triples'
python update_graph.py ./output/core.ttl ./output/core.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
    PREFIX core: <https://dataset-dl.liris.cnrs.fr/rdf-owl-urban-data-ontologies/Ontologies/CityGML/3.0/core#>

    DELETE DATA {
        core:AbstractFeatureWithLifespan.validFrom a owl:DatatypeProperty ;
            rdfs:range xsd:dateTime .
        core:AbstractFeatureWithLifespan.validTo a owl:DatatypeProperty ;
            rdfs:range xsd:dateTime .
        core:AbstractFeatureWithLifespan.creationDate a owl:DatatypeProperty ;
            rdfs:range xsd:dateTime .
        core:AbstractFeatureWithLifespan.terminationDate a owl:DatatypeProperty ;
            rdfs:range xsd:dateTime .
    }'
echo 'Removing hanging restrictions'
python update_graph.py ./output/core.ttl ./output/core.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
    PREFIX core: <https://dataset-dl.liris.cnrs.fr/rdf-owl-urban-data-ontologies/Ontologies/CityGML/3.0/core#>

    DELETE {
        ?restriction ?predicate ?object .
        core:AbstractFeatureWithLifespan rdfs:subClassOf ?restriction .
    }
    WHERE {
        core:AbstractFeatureWithLifespan rdfs:subClassOf ?restriction .
        ?restriction a owl:Restriction ;
            owl:allValuesFrom|owl:onDataRange xsd:dateTime ;
            ?predicate ?object .
    }'
echo 'Removing outdated versioning triples'
python update_graph.py ./output/versioning.ttl ./output/versioning.ttl \
    'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vers: <https://dataset-dl.liris.cnrs.fr/rdf-owl-urban-data-ontologies/Ontologies/CityGML/3.0/versioning#>

    DELETE DATA {
        vers:TransactionTypeValue a rdfs:Datatype .
    } ;
    INSERT DATA {
        vers:TransactionTypeValue a owl:Class ;
            rdfs:subClassOf skos:Concept .
    }'
echo 'patching room height status'
python update_graph.py ./output/versioning.ttl ./output/versioning.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX bldg: <https://dataset-dl.liris.cnrs.fr/rdf-owl-urban-data-ontologies/Ontologies/CityGML/3.0/building#>

    DELETE DATA {
        bldg:RoomHeight.status a owl:ObjectProperty .
    } ;
    INSERT DATA {
        bldg:RoomHeight.status a owl:DatatypeProperty .
    }'

### Copy remaining files ###
for file in ./stage-2/*
do 
    file_name=$(basename "$file")
    if test ! -f "./output/$file_name" ; then
        echo "Copying $file to ./output/$file_name"
        cp $file ./output/$file_name
    fi
done

echo 'Copying CityOWL.ttl to output'
cp ./additional-triples/CityOWL.ttl ./output
echo 'Copying transactiontypevalues.ttl to output'
cp ./additional-triples/transactiontypevalues.ttl ./output

read -p "Continue?"