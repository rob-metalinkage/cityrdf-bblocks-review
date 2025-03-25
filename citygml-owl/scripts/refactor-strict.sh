# #!/bin/sh

mkdir -p ../CityRDF-strict && cp -r ../CityRDF/* "$_" 

files=("../CityRDF-strict/appearance.ttl" "../CityRDF-strict/bridge.ttl" "../CityRDF-strict/building.ttl" "../CityRDF-strict/cityfurniture.ttl" 
        "../CityRDF-strict/cityobjectgroup.ttl" "../CityRDF-strict/construction.ttl" "../CityRDF-strict/core.ttl" "../CityRDF-strict/document.ttl" 
        "../CityRDF-strict/dynamizer.ttl" 
        "../CityRDF-strict/generics.ttl" "../CityRDF-strict/landuse.ttl" "../CityRDF-strict/pointcloud.ttl" "../CityRDF-strict/relief.ttl" 
        "../CityRDF-strict/transportation.ttl"
        "../CityRDF-strict/tunnel.ttl" "../CityRDF-strict/vegetation.ttl" "../CityRDF-strict/versioning.ttl" "../CityRDF-strict/waterbody.ttl" 
        "../CityRDF-strict/workspace.ttl")

for file in ${files[@]}; do
    echo "refactor " $file
    python refactor-strict.py $file $file
done