# #!/bin/sh

#echo '=== cleaning workspace ==='
#./clean.sh

#echo '=== download input ==='
#mkdir ./input
#wget -O ./input/CityGML_3.0-workspaces-documents_shapechange-export.xml \
#    https://raw.githubusercontent.com/VCityTeam/UD-Graph/master/Transformations/test-data/UML/CityGML_3.0-workspaces-documents_shapechange-export.xml

echo '=== stage 1 ==='
./run.sh

echo '=== stage 2 ==='
./patch-ontologies.sh

echo '=== stage 3 ==='
./update-triples.sh

echo '=== optional stage 4 ==='
./refactor.sh
echo 'Done!'
