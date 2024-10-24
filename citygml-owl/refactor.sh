#!/bin/bash
python refactor.py \
    --infile=./data/output/building.ttl \
    --outfile=./data/refactored/building.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/building#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/appearance.ttl \
    --outfile=./data/refactored/appearance.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/appearance#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"
    
python refactor.py \
    --infile=./data/output/bridge.ttl \
    --outfile=./data/refactored/bridge.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/bridge#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/cityfurniture.ttl \
    --outfile=./data/refactored/cityfurniture.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/cityfurniture#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/cityobjectgroup.ttl \
    --outfile=./data/refactored/cityobjectgroup.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/cityobjectgroup#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/construction.ttl \
    --outfile=./data/refactored/construction.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/construction#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/document.ttl \
    --outfile=./data/refactored/document.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/document#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/core.ttl \
    --outfile=./data/refactored/core.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/core#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/dynamizer.ttl \
    --outfile=./data/refactored/dynamizer.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/dynamizer#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/generics.ttl \
    --outfile=./data/refactored/generics.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/generics#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/landuse.ttl \
    --outfile=./data/refactored/landuse.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/landuse#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/pointcloud.ttl \
    --outfile=./data/refactored/pointcloud.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/pointcloud#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/relief.ttl \
    --outfile=./data/refactored/relief.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/relief#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/transactiontypevalues.ttl \
    --outfile=./data/refactored/transactiontypevalues.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/transactiontypevalues#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/transportation.ttl \
    --outfile=./data/refactored/transportation.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/transportation#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"
    
python refactor.py \
    --infile=./data/output/tunnel.ttl \
    --outfile=./data/refactored/tunnel.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/tunnel#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/vegetation.ttl \
    --outfile=./data/refactored/vegetation.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/vegetation#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/versioning.ttl \
    --outfile=./data/refactored/versioning.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/versioning#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"

python refactor.py \
    --infile=./data/output/waterbody.ttl \
    --outfile=./data/refactored/waterbody.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/waterbody#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"   

python refactor.py \
    --infile=./data/output/workspace.ttl \
    --outfile=./data/refactored/workspace.ttl \
    --old_prefix="https://ogcblocks.org/CityGML/3.0/waterbody#" \
    --new_prefix="https://ogcblocks.org/CityGML/3.0/common#" \
    --elements="address,usage,function,value,class"   

    
    
    
