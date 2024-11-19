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
    PREFIX core: <https://www.opengis.net/ont/citygml/core#>

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
    PREFIX core: <https://www.opengis.net/ont/citygml/core#>

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
    PREFIX vers: <https://www.opengis.net/ont/citygml/versioning#>

    DELETE DATA {
        vers:TransactionTypeValue a rdfs:Datatype .
    } ;
    INSERT DATA {
        vers:TransactionTypeValue a owl:Class ;
            rdfs:subClassOf skos:Concept .
    }'
echo 'patching room height status'
python update_graph.py ./output/building.ttl ./output/building.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX bldg: <https://www.opengis.net/ont/citygml/building#>

    DELETE DATA {
        bldg:RoomHeight.status a owl:ObjectProperty .
    } ;
    INSERT DATA {
        bldg:RoomHeight.status a owl:DatatypeProperty .
    }'

### sequence added for global attributes ###

files=("./output/appearance.ttl" "./output/bridge.ttl" "./output/building.ttl" "./output/cityfurniture.ttl" 
        "./output/cityobjectgroup.ttl" "./output/construction.ttl" "./output/core.ttl" "./output/document.ttl" "./output/dynamizer.ttl" 
        "./output/generics.ttl" "./output/landuse.ttl" "./output/pointcloud.ttl" "./output/relief.ttl" "./output/transportation.ttl"
        "./output/tunnel.ttl" "./output/vegetation.ttl" "./output/versioning.ttl" "./output/waterbody.ttl" "./output/workspace.ttl")

for file in ${files[@]}; do

### #1. inserts common:propertyname where ns:propertyname refs to package level
echo $file
echo 'inserting common:propertyname'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
        ?new rdfs:range ?range .
    	?new rdfs:label ?label .
        ?new skos:definition ?def .
    }
where { 
    select ?new ?range ?def ?label
    where {
	      ?s a owl:ObjectProperty ;
              rdfs:range ?range ;
              rdfs:label ?label;
              skos:definition ?def .
    filter (strafter(str(?s),"#") in ("class", "usage", "function", "value", "status", "mimeType", "occupancy", "elevation","lowReference","highReference"))         bind(IRI(concat("https://www.opengis.net/ont/citygml/common#",strafter(str(?s),"#"))) as ?new)
        }
    }'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX common: <https://ogcblocks.org/CityGML/3.0/common#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?new rdfs:range ?range .
    ?new rdfs:label ?label .
    ?new skos:definition ?def .
}
where { 
    select ?new ?range ?def ?label ?domain
    where {
	?s a owl:DatatypeProperty ;
       rdfs:label ?label ;
       rdfs:range ?range ;
       skos:definition ?def .
    filter (strafter(str(?s),"#") in ("name", "description"))
    bind(IRI(concat("https://www.opengis.net/ont/citygml/common#",strafter(str(?s),"#"))) as ?new)
    }}'

### #2 deletes all objprops defs that will be replaced with global scope ones
echo 'deleting package-level ns:propertyname'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX common: <https://www.opengis.net/ont/citygml/common#>
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    delete { 
        ?s a owl:ObjectProperty .
        ?s rdfs:label ?label .
        ?s rdfs:range ?range .
        ?s skos:definition ?def .
    }
    where {
    select ?s ?label ?range ?def
    	where {
    		?s a owl:ObjectProperty .
    		?s rdfs:label ?label .
        	?s rdfs:range ?range .
        	?s skos:definition ?def .
  			filter (strafter(str(?s), "#") in ("class", "usage", "function", "value", "status", "mimeType", "occupancy", "elevation","lowReference","highReference"))
    		filter (strbefore(str(?s),"#") in ("https://www.opengis.net/ont/citygml/appearance", 
"https://www.opengis.net/ont/citygml/bridge", 
"https://www.opengis.net/ont/citygml/building", 
"https://www.opengis.net/ont/citygml/cityfurniture", 
"https://www.opengis.net/ont/citygml/cityobjectgroup", 
"https://www.opengis.net/ont/citygml/construction",  
"https://www.opengis.net/ont/citygml/core",  
"https://www.opengis.net/ont/citygml/document",  
"https://www.opengis.net/ont/citygml/dynamizer", 
"https://www.opengis.net/ont/citygml/generics", 
"https://www.opengis.net/ont/citygml/landuse", 
"https://www.opengis.net/ont/citygml/pointcloud", 
"https://www.opengis.net/ont/citygml/relief", 
"https://www.opengis.net/ont/citygml/transportation", 
"https://www.opengis.net/ont/citygml/tunnel", 
"https://www.opengis.net/ont/citygml/vegetation", 
"https://www.opengis.net/ont/citygml/versioning",
"https://www.opengis.net/ont/citygml/waterbody", 
"https://www.opengis.net/ont/citygml/workspace"))
    }}'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX common: <https://www.opengis.net/ont/citygml/common#>
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    delete { 
        ?s a owl:DatatypeProperty .
        ?s rdfs:label ?label .
        ?s rdfs:range ?range .
        ?s skos:definition ?def .
    }
    where {
    select ?s ?label ?range ?def
    	where {
    		?s a owl:DatatypeProperty .
    		?s rdfs:label ?label .
        	?s rdfs:range ?range .
        	?s skos:definition ?def .
  			filter (strafter(str(?s), "#") in ("name","description"))
    		filter (strbefore(str(?s),"#") in ("https://www.opengis.net/ont/citygml/appearance", 
"https://www.opengis.net/ont/citygml/bridge", 
"https://www.opengis.net/ont/citygml/building", 
"https://www.opengis.net/ont/citygml/cityfurniture", 
"https://www.opengis.net/ont/citygml/cityobjectgroup", 
"https://www.opengis.net/ont/citygml/construction",  
"https://www.opengis.net/ont/citygml/core",  
"https://www.opengis.net/ont/citygml/document",  
"https://www.opengis.net/ont/citygml/dynamizer", 
"https://www.opengis.net/ont/citygml/generics", 
"https://www.opengis.net/ont/citygml/landuse", 
"https://www.opengis.net/ont/citygml/pointcloud", 
"https://www.opengis.net/ont/citygml/relief", 
"https://www.opengis.net/ont/citygml/transportation", 
"https://www.opengis.net/ont/citygml/tunnel", 
"https://www.opengis.net/ont/citygml/vegetation", 
"https://www.opengis.net/ont/citygml/versioning",
"https://www.opengis.net/ont/citygml/waterbody", 
"https://www.opengis.net/ont/citygml/workspace"))
    }}'

### #3 inserts common:objprops refs into axioms

echo 'inserts presence of global properties in axioms'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX common: <https://www.opengis.net/ont/citygml/common#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?s owl:onProperty ?new .
}
where { 
    select ?s ?new
    where {
	?s owl:onProperty ?old ;
    filter (strafter(str(?old),"#") in ("class", "usage", "function", "value","status", "mimeType", "occupancy", "elevation","lowReference","highReference"))
    bind(IRI(concat("https://www.opengis.net/ont/citygml/common#",strafter(str(?old),"#"))) as ?new)
    }}'

### #4 deletes all objprops mentions in axioms that will be replaced with global scope ones
echo 'deletes presence of global properties in axioms'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
delete { 
	?s owl:onProperty ?old .
}
where {
    ?s owl:onProperty ?old.
  	filter (strafter(str(?old), "#") in ("class", "usage", "function", "value","status", "mimeType", "occupancy", "elevation","lowReference","highReference"))
    filter (strbefore(str(?old),"#") in ("https://www.opengis.net/ont/citygml/appearance", 
"https://www.opengis.net/ont/citygml/bridge", 
"https://www.opengis.net/ont/citygml/building", 
"https://www.opengis.net/ont/citygml/cityfurniture", 
"https://www.opengis.net/ont/citygml/cityobjectgroup", 
"https://www.opengis.net/ont/citygml/construction",  
"https://www.opengis.net/ont/citygml/core",  
"https://www.opengis.net/ont/citygml/document",  
"https://www.opengis.net/ont/citygml/dynamizer", 
"https://www.opengis.net/ont/citygml/generics", 
"https://www.opengis.net/ont/citygml/landuse", 
"https://www.opengis.net/ont/citygml/pointcloud", 
"https://www.opengis.net/ont/citygml/relief", 
"https://www.opengis.net/ont/citygml/transportation", 
"https://www.opengis.net/ont/citygml/tunnel", 
"https://www.opengis.net/ont/citygml/vegetation", 
"https://www.opengis.net/ont/citygml/versioning",
"https://www.opengis.net/ont/citygml/waterbody", 
"https://www.opengis.net/ont/citygml/workspace"))
}'

### added removal of ADE*/ade*
### #5 deletes bnodes representing restrictions involving ade* objprops AND subclass axioms mentioning those bnodes

echo 'deletes presence of ADE* classes and ade* properties'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX iso19150-2: <http://def.isotc211.org/iso19150/-2/2012/base#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
delete { 
	?x a owl:Restriction .
    ?x owl:allValuesFrom ?adeclass .
    ?x owl:onProperty ?adeprop .
    ?s skos:definition ?def .
    ?s rdfs:subClassOf ?x .
    ?adeclass a owl:Class .
    ?adeprop a owl:ObjectProperty .
    ?adeprop rdfs:range ?adeclass .
    ?adeclass rdfs:label ?labelc . 
    ?adeclass skos:definition ?defc.
    ?adeprop rdfs:label ?labelp .
    ?adeprop skos:definition ?defp.
    ?adeclass iso19150-2:isAbstract true .
    }
    where {
    select ?s ?x ?adeclass ?def ?adeprop ?labelc ?labelp ?defc ?defp
    	where {
    		?s a owl:Class .
        	?s rdfs:subClassOf ?x .
        	?s skos:definition ?def .
			?x a owl:Restriction .
    		?x owl:allValuesFrom ?adeclass .
    		?x owl:onProperty ?adeprop .
            ?adeclass a owl:Class .
    		?adeprop a owl:ObjectProperty .
    		?adeprop rdfs:range ?adeclass .
            ?adeclass rdfs:label ?labelc . 
    		?adeclass skos:definition ?defc.
    		?adeprop rdfs:label ?labelp .
    		?adeprop skos:definition ?defp.
            filter (strstarts(strafter(str(?adeprop), "#"), "ade") )
        	filter (strstarts(strafter(str(?adeclass), "#"), "ADE") )
    }}'

### 6 adds properties reused >1 per CityGML family
echo 'add properties reused more than once per CityGML family'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <https://schema.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert {
?classIndependentPropNameNew a owl:ObjectProperty ;
    						 rdfs:label ?classIndependentPropName ;
							 schema:domainIncludes ?domainToInclude ;
        					 schema:rangeIncludes ?rangeToInclude ;
              				 skos:definition ?def.
} where { select  
    ?classIndependentPropNameNew 
    ?rangeToInclude 
    ?domainToInclude
    ?def
where {
	?s a owl:ObjectProperty .
    optional{bind(strafter(str(?s),"#") as ?classIndependentPropName).}
	?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    ?s skos:definition ?def .    
    filter (str(?classIndependentPropName) in ("boundary","address","mimeType","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","occupancy","elevation","lowReference","highReference","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization"))
        bind(IRI(concat("https://www.opengis.net/ont/citygml/common#",str(?classIndependentPropName))) 
            					as ?classIndependentPropNameNew)
}}'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <https://schema.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert {
?classIndependentPropNameNew a owl:DatatypeProperty ;
    						 rdfs:label ?classIndependentPropName ;
							 schema:domainIncludes ?domainToInclude ;
        					 schema:rangeIncludes ?rangeToInclude ;
              				 skos:definition ?def.
} where { select  
    ?classIndependentPropNameNew 
    ?rangeToInclude 
    ?domainToInclude
    ?def
where {
	?s a owl:DatatypeProperty .
    optional{bind(strafter(str(?s),"#") as ?classIndependentPropName).}
	?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    ?s skos:definition ?def .    
    filter (str(?classIndependentPropName) in ("name","description"))
        bind(IRI(concat("https://www.opengis.net/ont/citygml/common#",str(?classIndependentPropName))) 
            					as ?classIndependentPropNameNew)
}}'

### 7 removes old definitions of properties reused >1 per CityGML family
echo 'removes old definitions of properties reused more than once per CityGML family'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
delete { 
	?s a owl:ObjectProperty .
    ?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    ?s skos:definition ?def .
    }
where { select ?s ?classIndependentPropName ?domainToInclude ?rangeToInclude ?def
    where {
    ?s a owl:ObjectProperty .
    optional{bind(strafter(str(?s),"#") as ?classIndependentPropName).}
    optional{bind(strbefore(strafter(str(?s),"#"),".") as ?classThePropDepends).}
	?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    filter (str(?classIndependentPropName) in ("boundary","address","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","lowReference","highReference","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization"))
	filter (strbefore(str(?s),"#") in ("https://www.opengis.net/ont/citygml/appearance", 
"https://www.opengis.net/ont/citygml/bridge", 
"https://www.opengis.net/ont/citygml/building", 
"https://www.opengis.net/ont/citygml/cityfurniture", 
"https://www.opengis.net/ont/citygml/cityobjectgroup", 
"https://www.opengis.net/ont/citygml/construction",  
"https://www.opengis.net/ont/citygml/core",  
"https://www.opengis.net/ont/citygml/document",  
"https://www.opengis.net/ont/citygml/dynamizer", 
"https://www.opengis.net/ont/citygml/generics", 
"https://www.opengis.net/ont/citygml/landuse", 
"https://www.opengis.net/ont/citygml/pointcloud", 
"https://www.opengis.net/ont/citygml/relief", 
"https://www.opengis.net/ont/citygml/transportation", 
"https://www.opengis.net/ont/citygml/tunnel", 
"https://www.opengis.net/ont/citygml/vegetation", 
"https://www.opengis.net/ont/citygml/versioning",
"https://www.opengis.net/ont/citygml/waterbody", 
"https://www.opengis.net/ont/citygml/workspace"))
    }}'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
delete { 
	?s a owl:DatatypeProperty .
    ?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    ?s skos:definition ?def .
    }
where { select ?s ?classIndependentPropName ?domainToInclude ?rangeToInclude ?def
    where {
    ?s a owl:DatatypeProperty .
    optional{bind(strafter(str(?s),"#") as ?classIndependentPropName).}
	?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    filter (str(?classIndependentPropName) in ("boundary","address","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization"))
	filter (strbefore(str(?s),"#") in ("https://www.opengis.net/ont/citygml/appearance", 
"https://www.opengis.net/ont/citygml/bridge", 
"https://www.opengis.net/ont/citygml/building", 
"https://www.opengis.net/ont/citygml/cityfurniture", 
"https://www.opengis.net/ont/citygml/cityobjectgroup", 
"https://www.opengis.net/ont/citygml/construction",  
"https://www.opengis.net/ont/citygml/core",  
"https://www.opengis.net/ont/citygml/document",  
"https://www.opengis.net/ont/citygml/dynamizer", 
"https://www.opengis.net/ont/citygml/generics", 
"https://www.opengis.net/ont/citygml/landuse", 
"https://www.opengis.net/ont/citygml/pointcloud", 
"https://www.opengis.net/ont/citygml/relief", 
"https://www.opengis.net/ont/citygml/transportation", 
"https://www.opengis.net/ont/citygml/tunnel", 
"https://www.opengis.net/ont/citygml/vegetation", 
"https://www.opengis.net/ont/citygml/versioning",
"https://www.opengis.net/ont/citygml/waterbody", 
"https://www.opengis.net/ont/citygml/workspace"))
    }}'

done

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
echo 'Copying common.ttl to output'
cp ./additional-triples/common.ttl ./output

read -p "Continue?"