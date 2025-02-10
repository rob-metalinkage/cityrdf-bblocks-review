import rdflib
from rdflib import Graph
import fire

def refactor(infile=None, outfile=None):
    g = rdflib.Graph()
    g.parse(infile, format='ttl')

    g.serialize(destination=outfile, format='xml')
    
#    print('Refactored RDF file saved to', outfile)

if __name__ == '__main__':
  fire.Fire(refactor)
  
