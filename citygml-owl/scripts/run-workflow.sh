# #!/bin/sh

#echo '=== cleaning workspace ==='
#./clean.sh

#echo '=== download input ==='
#mkdir ./input
#wget -O ./input/CityGML_3.0-workspaces-documents_shapechange-export.xml \
#    https://raw.githubusercontent.com/VCityTeam/UD-Graph/master/Transformations/test-data/UML/CityGML_3.0-workspaces-documents_shapechange-export.xml

echo '=== stage 1 ==='
java -jar ~/prog/ShapeChange/target/ShapeChange-3.1.1-SNAPSHOT.jar -Dfile.encoding=UTF-8 -c CityGML3.0_to_OWL_ontotext_config.xml \
  -x '$input$' './CityGML_3.0-workspaces-documents_shapechange-export.xml' \
  -x '$output$' '../stage-1'

echo '=== stage 2 ==='
./patch-ontologies.sh

echo '=== stage 3 ==='
./update-triples.sh

echo 'Done!'
