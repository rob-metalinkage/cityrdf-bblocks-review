# #!/bin/sh

if test ! -d ../CityOWL; then
    mkdir ../CityOWL
fi

# ### Add codeList concept schemes, copy files without codeLists
echo 'Copying appearance.ttl'
cp ../stage-2/appearance.ttl ../CityOWL/
echo 'Adding bridge-codes.ttl'
python add_triples.py ../stage-2/bridge.ttl ../stage-1/ACMAPPER/bridge/bridge_codes.ttl ../CityOWL/bridge.ttl
echo 'Adding building-codes.ttl'
python add_triples.py ../stage-2/building.ttl ../stage-1/ACMAPPER/building/building_codes.ttl ../CityOWL/building.ttl
echo 'Adding construction-codes.ttl'
echo 'Adding group-codes.ttl'
python add_triples.py ../stage-2/cityfurniture.ttl ../stage-1/ACMAPPER/cityfurniture/cityfurniture_codes.ttl ../CityOWL/cityfurniture.ttl
echo 'Adding generics-codes.ttl'
python add_triples.py ../stage-2/cityobjectgroup.ttl ../stage-1/ACMAPPER/cityobjectgroup/cityobjectgroup_codes.ttl ../CityOWL/cityobjectgroup.ttl
echo 'Adding landuse-codes.ttl'
python add_triples.py ../stage-2/construction.ttl ../stage-1/ACMAPPER/construction/construction_codes.ttl ../CityOWL/construction.ttl
echo 'Adding core-codes.ttl'
python add_triples.py ../stage-2/core.ttl ../stage-1/ACMAPPER/core/core_codes.ttl ../CityOWL/core.ttl
echo 'Adding document-codes.ttl'
python add_triples.py ../stage-2/document.ttl ../stage-1/ACMAPPER/document/document_codes.ttl ../CityOWL/document.ttl
echo 'Adding dynamizer-codes.ttl'
python add_triples.py ../stage-2/dynamizer.ttl ../stage-1/ACMAPPER/dynamizer/dynamizer_codes.ttl ../CityOWL/dynamizer.ttl
echo 'Adding furniture-codes.ttl'
python add_triples.py ../stage-2/generics.ttl ../stage-1/ACMAPPER/generics/generics_codes.ttl ../CityOWL/generics.ttl
python add_triples.py ../stage-2/landuse.ttl ../stage-1/ACMAPPER/landuse/landuse_codes.ttl ../CityOWL/landuse.ttl
echo 'Adding transportation-codes.ttl'
echo 'Copying pointcloud.ttl'
cp ../stage-2/pointcloud.ttl ../CityOWL/
echo 'Copying relief.ttl'
cp ../stage-2/relief.ttl ../CityOWL/
python add_triples.py ../stage-2/transportation.ttl ../stage-1/ACMAPPER/transportation/transportation_codes.ttl ../CityOWL/transportation.ttl
echo 'Adding tunnel-codes.ttl'
python add_triples.py ../stage-2/tunnel.ttl ../stage-1/ACMAPPER/tunnel/tunnel_codes.ttl ../CityOWL/tunnel.ttl
echo 'Adding vegetation-codes.ttl'
python add_triples.py ../stage-2/vegetation.ttl ../stage-1/ACMAPPER/vegetation/vegetation_codes.ttl ../CityOWL/vegetation.ttl
echo 'Copying versioning.ttl'
cp ../stage-2/versioning.ttl ../CityOWL/
echo 'Adding waterbody-codes.ttl'
python add_triples.py ../stage-2/waterbody.ttl ../stage-1/ACMAPPER/waterbody/waterbody_codes.ttl ../CityOWL/waterbody.ttl
echo 'Copying workspace.ttl'
cp ../stage-2/workspace.ttl ../CityOWL/

# ### Additional modification ###
echo 'Adding cityModelMember modifications'
python add_triples.py ../CityOWL/core.ttl ../additional-triples/citymodelmember.ttl ../CityOWL/core.ttl
echo 'Adding GeoSPARQL and OWL-Time alignments'
python add_triples.py ../CityOWL/core.ttl ../additional-triples/alignments.ttl ../CityOWL/core.ttl
echo 'Removing outdated core triples'
python update_graph.py ../CityOWL/core.ttl ../CityOWL/core.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
    PREFIX core: <https://www.opengis.net/ont/citygml/core/>

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
python update_graph.py ../CityOWL/core.ttl ../CityOWL/core.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
    PREFIX core: <https://www.opengis.net/ont/citygml/core/>

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
python update_graph.py ../CityOWL/versioning.ttl ../CityOWL/versioning.ttl \
    'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vers: <https://www.opengis.net/ont/citygml/versioning/>

    DELETE DATA {
        vers:TransactionTypeValue a rdfs:Datatype .
    } ;
    INSERT DATA {
        vers:TransactionTypeValue a owl:Class ;
            rdfs:subClassOf skos:Concept .
    }'
echo 'patching room height status: 1/5'
python update_graph.py ../CityOWL/building.ttl ../CityOWL/building.ttl \
   'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    PREFIX bldg: <https://www.opengis.net/ont/citygml/building/>

    DELETE DATA {
        bldg:status a owl:ObjectProperty .
    } ;
    INSERT DATA {
        bldg:status a owl:DatatypeProperty .
    }'
echo 'patching room height status: 2/5'
python update_graph.py ../CityOWL/building.ttl ../CityOWL/building.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX con: <https://www.opengis.net/ont/citygml/construction/>
insert { 
    ?s owl:onDataRange con:HeightStatusValue .
}
where { 
    select ?s 
        where {
	        ?s owl:onClass con:HeightStatusValue .
        }}'
echo 'patching room height status: 3/5'
python update_graph.py ../CityOWL/construction.ttl ../CityOWL/construction.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX con: <https://www.opengis.net/ont/citygml/construction/>
insert { 
    ?s owl:onDataRange con:HeightStatusValue .
}
where { 
    select ?s 
        where {
	        ?s owl:onClass con:HeightStatusValue .
        }}'
echo 'patching room height status: 4/5'
python update_graph.py ../CityOWL/building.ttl ../CityOWL/building.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX con: <https://www.opengis.net/ont/citygml/construction/>
delete { 
    ?s owl:onClass con:HeightStatusValue .
}
where { 
    select ?s 
        where {
	        ?s owl:onDataRange con:HeightStatusValue ;
               owl:onClass con:HeightStatusValue .
        }}'
echo 'patching room height status: 5/5'
python update_graph.py ../CityOWL/construction.ttl ../CityOWL/construction.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX con: <https://www.opengis.net/ont/citygml/construction/>
delete { 
    ?s owl:onClass con:HeightStatusValue .
}
where { 
    select ?s 
        where {
	        ?s owl:onDataRange con:HeightStatusValue ;
               owl:onClass con:HeightStatusValue .
        }}'

echo 'patching core:uRI and core:value whose ranges in restrictions mentioned as classes, should be DataRanges: 1/4'
python update_graph.py ../CityOWL/core.ttl ../CityOWL/core.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
insert { 
    ?s owl:onDataRange xsd:anyURI .
}
where { 
    select ?s 
        where {
	        ?s owl:onClass xsd:anyURI ;
               owl:onProperty core:uRI .
        }}'

echo 'patching core:uRI and core:value whose ranges in restrictions mentioned as classes, should be DataRanges: 2/4'
python update_graph.py ../CityOWL/core.ttl ../CityOWL/core.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
delete { 
    ?s owl:onClass xsd:anyURI .
}
where { 
    select ?s 
        where {
	        ?s owl:onClass xsd:anyURI ;
               owl:onDataRange xsd:anyURI .
        }}'

echo 'patching core:uRI and core:value whose ranges in restrictions mentioned as classes, should be DataRanges: 3/4'
python update_graph.py ../CityOWL/core.ttl ../CityOWL/core.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
insert { 
    ?s owl:onDataRange xsd:double .
}
where { 
    select ?s 
        where {
	        ?s owl:onClass xsd:double ;
               owl:onProperty core:value .
        }}'

echo 'patching core:uRI and core:value whose ranges in restrictions mentioned as classes, should be DataRanges: 4/4'
python update_graph.py ../CityOWL/core.ttl ../CityOWL/core.ttl \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
delete { 
    ?s owl:onClass xsd:double .
}
where { 
    select ?s 
        where {
	        ?s owl:onClass xsd:double ;
               owl:onDataRange xsd:double .
        }}'

### sequence added for global attributes ###

files=("../CityOWL/appearance.ttl" "../CityOWL/bridge.ttl" "../CityOWL/building.ttl" "../CityOWL/cityfurniture.ttl" 
        "../CityOWL/cityobjectgroup.ttl" "../CityOWL/construction.ttl" "../CityOWL/core.ttl" "../CityOWL/document.ttl" "../CityOWL/dynamizer.ttl" 
        "../CityOWL/generics.ttl" "../CityOWL/landuse.ttl" "../CityOWL/pointcloud.ttl" "../CityOWL/relief.ttl" "../CityOWL/transportation.ttl"
        "../CityOWL/tunnel.ttl" "../CityOWL/vegetation.ttl" "../CityOWL/versioning.ttl" "../CityOWL/waterbody.ttl" "../CityOWL/workspace.ttl")

for file in ${files[@]}; do
echo $file

python update_graph.py $file $file \
    'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
     INSERT {
        ?ont owl:versionIRI ?vers .
	    ?ont owl:versionInfo "3.0.0" .    
        } where {select ?ont ?vers where {?ont a owl:Ontology .
                bind(IRI(concat(str(?ont), "/3.0.0/")) as ?vers)
            }}'

python update_graph.py $file $file \
    'PREFIX owl:  <http://www.w3.org/2002/07/owl#>
     INSERT {
        ?ont owl:imports <https://www.opengis.net/ont/citygml/common> .     
            } where {select ?ont where {?ont a owl:Ontology .
        filter(strends(str(?ont),"code")=false) }}'


### added removal of ADE*/ade*
### #1 deletes bnodes representing restrictions involving ade* objprops AND subclass axioms mentioning those bnodes

echo '#1 removal of ADE* classes and ade* properties'

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
            bind(replace(str(?adeclass), "^.*/([^/]*)$", "$1") as ?xc)
            bind(replace(str(?adeprop), "^.*/([^/]*)$", "$1") as ?xp)
            filter (strstarts(?xp, "ade") )
        	filter (strstarts(?xc, "ADE") )
    }}'

### #2. inserts common:propertyname where ns:propertyname refs to package level

echo '#2 insert common:propertyname'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX schema: <https://schema.org/>
insert { 
        ?new schema:rangeIncludes ?range .
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
    bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    filter (?x in ("area", "class", "usage", "function", "mimeType", "occupancy", "elevation","lowReference","highReference"))         
    bind(IRI(concat("https://www.opengis.net/ont/citygml/common/",?x)) as ?new)
       }}'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX common: <https://ogcblocks.org/CityGML/3.0/common/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX schema: <https://schema.org/>
insert { 
    ?new schema:rangeIncludes ?range .
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
    bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    filter (?x in ("name", "description", "value", "status"))
        bind(IRI(concat("https://www.opengis.net/ont/citygml/common/",?x)) as ?new)
    }}'

### #3 deletes all objprops defs that will be replaced with global scope ones
echo '#3 delete package-level ns:propertyname for common properties'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX common: <https://www.opengis.net/ont/citygml/common/>
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
            bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
  			filter (?x in ("area", "class", "usage", "function", "mimeType", "occupancy", "elevation","lowReference","highReference"))
        filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

python update_graph.py $file $file \
   'PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX common: <https://www.opengis.net/ont/citygml/common/>
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
            bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
  			filter (?x in ("name", "description", "value", "status"))
        filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

### #4 inserts common:objprops refs into axioms

echo '#4 insert global properties in axioms'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX common: <https://www.opengis.net/ont/citygml/common/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?s owl:onProperty ?new .
}
where { 
    select ?s ?new
    where {
	?s owl:onProperty ?old ;
	bind(replace(str(?old), "^.*/([^/]*)$", "$1") as ?x)
    filter (?x in ("name", "description", "area", "class", "usage", "value", "function", "status", "mimeType", "occupancy", "elevation","lowReference","highReference"))         
    bind(IRI(concat("https://www.opengis.net/ont/citygml/common/",?x)) as ?new)
    }}'

### #5 delete all objprops mentions in axioms that will be replaced with global scope ones
echo '#5 delete local-scoped reused properties in axioms'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
delete { 
	?s owl:onProperty ?old .
}
where {
    select ?s ?old
    where {
    ?s owl:onProperty ?old.
	bind(replace(str(?old), "^.*/([^/]*)$", "$1") as ?x)
    filter (?x in ("name", "description", "area", "class", "usage", "value", "function", "status", "mimeType", "occupancy", "elevation","lowReference","highReference"))         
    filter (strbefore(str(?old),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
}}'

### 6 add new global properties for those reused >1 per CityGML family and having names like ns:Class.prop
echo '#6 add properties reused more than once per CityGML family'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <https://schema.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert {
?classIndependentPropNameNew rdfs:label ?classIndependentPropName ;
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
    bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    optional{bind(strafter(?x,".") as ?classIndependentPropName).}
    ?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    optional{?s skos:definition ?def .}
    filter (str(?classIndependentPropName) in ("boundary","address","mimeType","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","occupancy","elevation","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization", "referringTo"))
    bind(IRI(concat("https://www.opengis.net/ont/citygml/common/",str(?classIndependentPropName))) 
            					as ?classIndependentPropNameNew)
    }}'

### 7 removes old definitions of (local) properties for those reused >1 per CityGML family
echo '#7 remove old definitions of properties reused more than once per CityGML family'

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
    bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    optional{bind(strafter(?x,".") as ?classIndependentPropName).}
	?s rdfs:label ?classIndependentPropName .
    ?s rdfs:domain ?domainToInclude .
    ?s rdfs:range ?rangeToInclude .
    optional{?s skos:definition ?def .}
    filter (str(?classIndependentPropName) in ("boundary","address","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization", "referringTo"))
        filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

### #8 inserts common:props refs into axioms for those properties that are reused > 1 per Ontology family

echo '#8 insert presence of global properties in axioms'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX common: <https://www.opengis.net/ont/citygml/common>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?s owl:onProperty ?new .
}
where { 
    select ?s ?new
    where {
	?s owl:onProperty ?old ;
    bind(replace(str(?old), "^.*/([^/]*)$", "$1") as ?x)
    filter (strafter(?x,".") in ("boundary","address","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization", "referringTo"))
bind(IRI(concat("https://www.opengis.net/ont/citygml/common/",strafter(?x,"."))) as ?new)
    }}
'

### #9 deletes all (local) props mentions in axioms for those properties reused >1 
echo '#9 delete presence of global properties in axioms'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
delete { 
	?s owl:onProperty ?old .
}
where {
    select ?s ?old
    where {
    ?s owl:onProperty ?old.
  	bind(replace(str(?old), "^.*/([^/]*)$", "$1") as ?x)
    filter (strafter(?x,".") in ("boundary","address","intersection","section","genericAttribute","pointCloud","buildingFurniture","buildingInstallation","appearance","relatedTo","lod0MultiCurve","lod0MultiSurface","lod2MultiSurface","lod3MultiSurface","versionMember","referencePoint","tunnelFurniture","tunnelInstallation","groupMember","buildingConstructiveElement","buildingRoom","bridgeFurniture","bridgeInstallation","textureParameterization", "referringTo"))
    filter (strbefore(str(?old),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

### #10 inserts class-less (=without class in ns:Class.prop) local props used once in a package
echo '#10 insert class-less (=without class in ns:Class.prop) local props used once in a package'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?new a owl:ObjectProperty .    
    ?new rdfs:range ?range .
    	?new rdfs:label ?classIndependentPropName .
        ?new skos:definition ?def .
    	?new rdfs:domain ?domain .
    }
where {
select ?s ?domain ?range ?def ?classIndependentPropName ?new
    where {
	      ?s a owl:ObjectProperty .
          optional{?s rdfs:domain ?domain.}
          ?s rdfs:range ?range .
          ?s rdfs:label ?classIndependentPropName .
          ?s skos:definition ?def .
	bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    filter(?classIndependentPropName !="")
    bind (IRI(concat(strbefore(str(?s),str(?x)),?classIndependentPropName)) as ?new)
    filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

### for properties defined without skos:definition
python update_graph.py $file $file \
     'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?new a owl:ObjectProperty .    
    ?new rdfs:range ?range .
    ?new rdfs:label ?classIndependentPropName .
    ?new rdfs:domain ?domain .
    }
where {
select ?domain ?range ?def ?classIndependentPropName ?new
    where {
	      ?s a owl:ObjectProperty .
          optional{?s rdfs:domain ?domain.}
          ?s rdfs:range ?range .
          ?s rdfs:label ?classIndependentPropName .
	bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    filter(?classIndependentPropName !="")
    bind (IRI(concat(strbefore(str(?s),str(?x)),?classIndependentPropName)) as ?new)
    filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'


### #11 deletes initial (=with class in ns:Class.prop) local props used once in a package
echo '#11 delete initial (=with class in ns:Class.prop) local props used once in a package'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
delete { 
        ?s a owl:ObjectProperty .
        ?s rdfs:label ?label .
        ?s rdfs:range ?range .
    	?s rdfs:domain ?domain .
        ?s skos:definition ?def .
    }
where {
select ?s ?domain ?range ?def ?label 
    where {
	      ?s a owl:ObjectProperty .
          optional{?s rdfs:domain ?domain.}
          ?s  rdfs:range ?range ;
              rdfs:label ?label;
              skos:definition ?def .
	bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    bind(strbefore(?x,".") as ?class).
    filter(?class !="")
    filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

###for properties defined without skos:definition

python update_graph.py $file $file \
'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
delete { 
        ?s a owl:ObjectProperty .
        ?s rdfs:label ?label .
        ?s rdfs:range ?range .
    	?s rdfs:domain ?domain .
    }
where {
select ?s ?domain ?range ?def ?label 
    where {
	      ?s a owl:ObjectProperty .
          optional{?s rdfs:domain ?domain.}
          ?s  rdfs:range ?range ;
              rdfs:label ?label;
	bind(replace(str(?s), "^.*/([^/]*)$", "$1") as ?x)
    bind(strbefore(?x,".") as ?class).
    filter(?class !="")
    filter (strbefore(str(?s),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'


### #12 inserts owl:onProperty for simplified (=without class in ns:Class.prop) local props used once in a package

echo '#12 insert owl:onProperty for simplified (=without class in ns:Class.prop) local props used once in a package'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert { 
    ?s owl:onProperty ?new .
}
where { 
    select ?s ?new
    where {
	    ?s owl:onProperty ?old .
	    bind(replace(str(?old), "^.*/([^/]*)$", "$1") as ?x)
        bind(strafter(?x,".") as ?classIndependentPropName).
        filter(?classIndependentPropName !="")
        bind (IRI(concat(strbefore(str(?old),str(?x)),?classIndependentPropName)) as ?new)
    }
}'

### #13 deletes owl:onProperty for initial (=with class in ns:Class.prop) local props used once in a package

echo '#13 delete owl:onProperty for initial (=with class in ns:Class.prop) local props used once in a package'

python update_graph.py $file $file \
    'PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
delete { 
	?s owl:onProperty ?old .
}
where { 
    select ?s ?old
    where {
	      ?s owl:onProperty ?old .
	bind(replace(str(?old), "^.*/([^/]*)$", "$1") as ?x)
    bind(strbefore(?x,".") as ?class).
    filter(?class !="")
    filter (strbefore(str(?old),str(?x)) in ("https://www.opengis.net/ont/citygml/appearance/", 
"https://www.opengis.net/ont/citygml/bridge/", 
"https://www.opengis.net/ont/citygml/building/", 
"https://www.opengis.net/ont/citygml/cityfurniture/", 
"https://www.opengis.net/ont/citygml/cityobjectgroup/", 
"https://www.opengis.net/ont/citygml/construction/",  
"https://www.opengis.net/ont/citygml/core/",  
"https://www.opengis.net/ont/citygml/document/",  
"https://www.opengis.net/ont/citygml/dynamizer/", 
"https://www.opengis.net/ont/citygml/generics/", 
"https://www.opengis.net/ont/citygml/landuse/", 
"https://www.opengis.net/ont/citygml/pointcloud/", 
"https://www.opengis.net/ont/citygml/relief/", 
"https://www.opengis.net/ont/citygml/transportation/", 
"https://www.opengis.net/ont/citygml/tunnel/", 
"https://www.opengis.net/ont/citygml/vegetation/", 
"https://www.opengis.net/ont/citygml/versioning/",
"https://www.opengis.net/ont/citygml/waterbody/", 
"https://www.opengis.net/ont/citygml/workspace/"))
    }}'

done

### Copy remaining files ###
for file in ../stage-2/*
do 
    file_name=$(basename "$file")
    if test ! -f "../CityOWL/$file_name" ; then
        echo "Copying $file to ../CityOWL/$file_name"
        cp $file ../CityOWL/$file_name
    fi
done

echo 'Copying CityOWL.ttl to CityOWL'
cp ../additional-triples/CityOWL.ttl ../CityOWL
echo 'Copying transactiontypevalues.ttl to CityOWL'
cp ../additional-triples/transactiontypevalues.ttl ../CityOWL
echo 'Copying common.ttl to CityOWL'
cp ../additional-triples/common.ttl ../CityOWL

read -p "Continue?"