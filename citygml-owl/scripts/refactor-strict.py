import rdflib
from rdflib import Graph, URIRef, BNode
from rdflib.namespace import OWL, RDF, RDFS
import fire
import pandas as pd

SCHEMA_DOMAIN = "https://schema.org/domainIncludes"
SCHEMA_RANGE = "https://schema.org/rangeIncludes"

"""
Source definition:
ns:prop a owl:ObjectProperty ;
    rdfs:label "prop"@en ;
    schema:domainIncludes bldg:A bldg:B wtr:C tun:D ;
    schema:rangeIncludesbldg:A1 bldg:B1 wtr:C1 tun:D1 .      

Target definition: 
ns:prop a owl:ObjectProperty ;
    rdfs:label "prop"@en ;
    rdfs:domain [a owl:Class;
                   owl:unionOf (bldg:A bldg:B wtr:C tun:D)];
    rdfs:range [a owl:Class;
                   owl:unionOf (bldg:A1 bldg:B1 wtr:C1 tun:D1)];      
"""
def update_graph(g):
    q = g.query("""
                PREFIX owl: <http://www.w3.org/2002/07/owl#>
                PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                PREFIX schema: <https://schema.org/>
                select ?s ?domainToInclude ?rangeToInclude
                where {
                    ?s schema:rangeIncludes ?rangeToInclude .
                    ?s schema:domainIncludes ?domainToInclude .
                }""", initNs={
                    'owl': rdflib.Namespace("http://www.w3.org/2002/07/owl#"),
                    "rdfs": rdflib.Namespace("http://www.w3.org/2000/01/rdf-schema#"),
                    "schema": rdflib.Namespace("https://schema.org/"),
                })
    qf = pd.DataFrame(q,columns=["s","domainToInclude","rangeToInclude"])
    domains = qf.groupby(['s'])['domainToInclude'].apply(lambda x:','.join(set(x))).reset_index()
    ranges =  qf.groupby(['s'])['rangeToInclude'].apply(lambda x:','.join(set(x))).reset_index()

    for s, p, o in g:
        str_p = str(p)
        if str_p == SCHEMA_DOMAIN:
            g.remove((s, p, o))
        elif str_p == SCHEMA_RANGE:
#        if str_p == SCHEMA_RANGE:
            g.remove((s, p, o))

#recursive creation of rdf:parseType = "Collection"
    def union_from_list(*rest):
        node_union = rdflib.BNode()
        
        g.add((node_union, RDF.first, rest[0]))
        if len(rest) > 1:
            g.add((node_union, RDF.rest, union_from_list(*(rest[1:]))))
        else:
            g.add((node_union, RDF.rest, RDF.nil))
        return node_union

    for id in domains.itertuples():
        prop = rdflib.URIRef(id.s)
#apply URIRef to each element of the row in id.domainToInclude
        listd = list(map(rdflib.URIRef,id.domainToInclude.split(",")))
        if len(listd) == 1:
            g.add((prop, RDFS.domain, listd[0]))            
        else:    
            node_restriction = rdflib.BNode()
            node_union = rdflib.BNode()
            g.add((node_restriction, RDF.type, OWL.Class))
            g.add((prop, RDFS.domain, node_restriction))
            g.add((node_restriction, OWL.unionOf, union_from_list(*listd) ))

    for id in ranges.itertuples():
        prop = rdflib.URIRef(id.s)
#apply URIRef to each element of the row in id.rangeToInclude
        listd = list(map(rdflib.URIRef,id.rangeToInclude.split(",")))
        if len(listd) == 1:
            g.add((prop, RDFS.range, listd[0]))            
        else:    
            node_restriction = rdflib.BNode()
            node_union = rdflib.BNode()
            g.add((node_restriction, RDF.type, OWL.Class))
            g.add((prop, RDFS.range, node_restriction))
            g.add((node_restriction, OWL.unionOf, union_from_list(*listd) ))

    return g

def refactor(infile=None, outfile=None):
    g = rdflib.Graph()
    g.parse(infile, format='ttl')

    update_graph(g)
    
    g.serialize(destination=outfile, format='ttl')
#    print('Refactored RDF file saved to', outfile)

if __name__ == '__main__':
  fire.Fire(refactor)
  
