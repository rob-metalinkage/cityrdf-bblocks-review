# #!/bin/sh

files=("../CityRDF/appearance.ttl" "../CityRDF/bridge.ttl" "../CityRDF/building.ttl" "../CityRDF/cityfurniture.ttl" 
        "../CityRDF/cityobjectgroup.ttl" "../CityRDF/construction.ttl" "../CityRDF/core.ttl" "../CityRDF/document.ttl" "../CityRDF/dynamizer.ttl" 
        "../CityRDF/generics.ttl" "../CityRDF/landuse.ttl" "../CityRDF/pointcloud.ttl" "../CityRDF/relief.ttl" "../CityRDF/transportation.ttl"
        "../CityRDF/tunnel.ttl" "../CityRDF/vegetation.ttl" "../CityRDF/versioning.ttl" "../CityRDF/waterbody.ttl" "../CityRDF/workspace.ttl")

for file in ${files[@]}; do
    echo "refactor " $file
    python refactor.py $file $file
done