# Global Properties explication

There are some attributes named equally in different packages, such as `usage`, `class`, `function`, `address` and `value`.
In OWL object properties are first-class citizens whereas in UML and UML converted into OWL with ShapeChange) they are converted into package-level and class-level attributes.

we explicate such attributes, and make a custom postprocessing step.

Here is an example:

```turtle
con:usage  rdf:type      owl:ObjectProperty;
        rdfs:label       "usage"@en;
        rdfs:range       con:DoorUsageValue;
        skos:definition  "Specifies the actual uses of the Door."@en .
```
will be splitted into one defined in the particular package
```turtle
common:usage  rdfs:range       con:DoorUsageValue;
        skos:definition  "Specifies the actual uses of the Door."@en .
```
and the second defined once in `common` package

```turtle
common:usage  rdf:type      owl:ObjectProperty;
        rdfs:label       "usage"@en;
```

So in general, postprocessing step is:

```
for file in files,
  for ns in citygml_ns, 
    
        refactor.py (file, ./refactored/file, ns, "common", "address,usage,function,value,class")
        


