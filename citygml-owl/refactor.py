import rdflib
import fire

RDF_SCHEMA_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
COMMON_PREFIX="common"


def update_graph(g, old_element, new_element):
    for s, p, o in g:
        str_s = str(s)
        str_p = str(p)
        str_o = str(o)
        if str_s == old_element and str_p == RDF_TYPE:
            g.remove((s, p, o))
            print("removed", s,p,o)
        elif str_s == old_element and str_p == RDF_SCHEMA_LABEL:
            g.remove((s, p, o))
            print("removed", s,p,o)
        elif  str_s == old_element:
            g.remove((s, p, o))
            g.add((rdflib.URIRef(new_element), p, o))
            print("removed", s,p,o)
            print("addded", new_element,p,o)
        elif str_o == old_element:
            g.remove((s, p, o))
            g.add((s, p, rdflib.URIRef(new_element)))
            print("removed", s,p,o)
            print("addded", s,p,new_element)            
    return g

def refactor(infile=None, outfile=None, old_prefix=None, new_prefix=None, elements=None):
    g = rdflib.Graph()
    g.parse(infile, format='ttl')
    g.bind(COMMON_PREFIX, new_prefix)
    elements = elements.split(",")
    for element in elements:
        update_graph(g, f"{old_prefix}{element}", f"{new_prefix}{element}")
    
    g.serialize(destination=outfile, format='ttl')
    print('Refactored RDF file saved to', outfile)

if __name__ == '__main__':
  fire.Fire(refactor)
  
