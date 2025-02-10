java -jar shapechange/ShapeChange-3.1.1-SNAPSHOT.jar -Dfile.encoding=UTF-8 -c CityGML3.0_to_OWL_ontotext_config.xml \
  -x '$input$' './CityGML_3.0-workspaces-documents_shapechange-export.xml' \
  -x '$output$' '../stage-1'

#java -jar ~/prog/ShapeChange/target/ShapeChange-3.1.1-SNAPSHOT.jar -Dfile.encoding=UTF-8 -c CityGML3.0_to_OWL_ontotext_config.xml \
#  -x '$input$' './CityGML_3.0-workspaces-documents_shapechange-export.xml' \
#  -x '$output$' '../stage-1'

