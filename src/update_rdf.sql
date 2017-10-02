--
-- Fix database cross-references in Ensembl RDF graphs.
--

log_enable(2) ; -- disable transaction logging & enable row-by-row autocommit
SET u{BASE_URI} http://localhost:8890 ;
SET u{ENSEMBL_RELEASE} 86 ;
SET u{ENSEMBL-HSA_G_URI} http://www.ensembl.org/human ;
--SET u{BIO2RDF_RELEASE} 4 ;
SET u{BIO2RDF_G_URI} http://bio2rdf.org/omim_resource:bio2rdf.dataset.omim.R4 ;


SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s rdfs:seeAlso ?o }
INSERT { ?s rdfs:seeAlso ?fixed }
WHERE {
   ?s rdfs:seeAlso ?o .
   FILTER regex(?o, 'http://identifiers.org/hgnc') .
   BIND(uri(replace(str(?o), '%253A', ':')) AS ?fixed)
} ;

SPARQL
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s <http://semanticscience.org/resource/SIO:000630> ?o }
INSERT { ?s <http://semanticscience.org/resource/SIO_000630> ?o }
WHERE { ?s <http://semanticscience.org/resource/SIO:000630> ?o } ;

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s rdfs:seeAlso ?o }
INSERT { ?s rdfs:seeAlso ?fixed }
WHERE {
   ?s rdfs:seeAlso ?o .
   FILTER regex(?o, 'http://identifiers.org/go') .
   BIND(uri(replace(str(?o), '%253A', ':')) AS ?fixed)
} ;


--
-- Fix SO predicates
--

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s obo:SO_translates_to ?o }
INSERT { ?s so:translates_to ?o }
WHERE { ?s obo:SO_translates_to ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s obo:SO_has_part ?o }
INSERT { ?s so:has_part ?o }
WHERE { ?s obo:SO_has_part ?o } ;

SPARQL
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?s obo:SO_transcribed_from ?o }
INSERT { ?s so:transcribed_from  ?o }
WHERE { ?s obo:SO_transcribed_from ?o } ;


--
-- Cross-link human protein-coding genes in OMIM and Ensembl.
--

SPARQL
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
INSERT INTO <$u{ENSEMBL-HSA_G_URI}> {
   ?gene1 owl:sameAs ?gene2 ;
      obo:RO_0002331 ?omim
} WHERE {
   GRAPH <$u{BIO2RDF_G_URI}> {
      ?gene2 ^<http://bio2rdf.org/omim_vocabulary:x-ensembl> ?omim ;
         <http://bio2rdf.org/bio2rdf_vocabulary:identifier> ?gene_id .
      BIND(uri(concat('http://rdf.ebi.ac.uk/resource/ensembl/', ?gene_id)) AS ?gene1)
   }
   GRAPH <$u{ENSEMBL-HSA_G_URI}> {
      ?gene1 a obo:SO_0001217
   }
} ;

--
-- Delete triples
--
--SPARQL
--PREFIX obo: <http://purl.obolibrary.org/obo/>
--PREFIX owl: <http://www.w3.org/2002/07/owl#>
--WITH  <$u{ENSEMBL-HSA_G_URI}>
--DELETE WHERE {
--   ?gene1 owl:sameAs ?gene2;
--      obo:RO_0002331 ?omim
--} ;


--
-- Append OMIM IDs to rdfs:label(s) for human genes where applicable (e.g. 'VSX2' -> 'VSX2 [omim:142993]').
--

SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
WITH <$u{ENSEMBL-HSA_G_URI}>
DELETE { ?gene rdfs:label ?lb }
INSERT { ?gene rdfs:label ?new }
WHERE {
   ?gene rdfs:label ?lb ;
      obo:RO_0002331 ?omim .
   BIND(concat(?lb, ' [', replace(str(?omim), '.+/', ''), ']') AS ?new)
} ;

--
-- Restore original rdfs:label(s) for genes.
--
--SPARQL
--PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
--PREFIX obo: <http://purl.obolibrary.org/obo/>
--WITH <$u{ENSEMBL-HSA_G_URI}>
--DELETE { ?gene rdfs:label ?lb }
--INSERT { ?gene rdfs:label ?new }
--WHERE {
--   ?gene rdfs:label ?lb ;
--      obo:RO_0002331 ?omim .
--   BIND(replace(?lb, ' \\[.+', '') as ?new)
--} ;
