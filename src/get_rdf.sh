#!/bin/bash
#
# Batch script to download (compressed) data in RDF and to write graph URIs into *.graph files
# required for loading RDF into Virtuoso RDF Quad Store.

set -ev

ENSEMBL_RELEASE=86
#UNIPROT_RELEASE=2017_09
BIO2RDF_RELEASE=4
DATA_DIR=$1

if [ "${DATA_DIR}" != "" ]; then
	mkdir -p $DATA_DIR && cd $DATA_DIR
fi

# download ontologies
curl --stderr - -LH "Accept: application/rdf+xml" -o faldo.rdf "http://biohackathon.org/resource/faldo.rdf" \
	&& echo "http://biohackathon.org/resource/faldo.rdf" > faldo.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o so.rdf "http://purl.obolibrary.org/obo/so.owl" \
	&& echo "http://purl.obolibrary.org/obo/so.owl" > so.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o sio.rdf "http://semanticscience.org/ontology/sio.owl" \
	&& echo "http://semanticscience.org/ontology/sio.owl" > sio.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o ro.rdf "http://purl.obolibrary.org/obo/ro.owl" \
	&& echo "http://purl.obolibrary.org/obo/ro.owl" > ro.rdf.graph

curl --stderr - -LH "Accept: application/rdf+xml" -o uniprot_core.rdf "http://purl.uniprot.org/core/" \
	&& echo "http://purl.uniprot.org/core/" > uniprot_core.rdf.graph

# download human genome and proteome data from Ensembl and UniProt Reference Proteomes, respectively
curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/rdf/homo_sapiens/homo_sapiens.ttl.gz" \
	&& echo "http://www.ensembl.org/human" > homo_sapiens.ttl.graph

curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/rdf/homo_sapiens/homo_sapiens_xrefs.ttl.gz" \
	&& echo "http://www.ensembl.org/human" > homo_sapiens_xrefs.ttl.graph

curl --stderr - -L -o uniprot_human.rdf.gz "http://www.uniprot.org/uniprot/?format=rdf&compress=yes&query=proteome:UP000005640" \
	&& echo "http://www.uniprot.org/proteomes/human" > uniprot_human.rdf.graph

# download human genome data from Ensembl
curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/rdf/homo_sapiens/homo_sapiens.ttl.gz" \
        && echo "http://www.ensembl.org/human" > homo_sapiens.ttl.graph

curl --stderr - -LO "ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/rdf/homo_sapiens/homo_sapiens_xrefs.ttl.gz" \
        && echo "http://www.ensembl.org/human" > homo_sapiens_xrefs.ttl.graph

# download OMIM genotype-phenotype data via Bio2RDF
curl --stderr - -LO "http://download.bio2rdf.org/release/${BIO2RDF_RELEASE}/omim/omim.nq.gz" \
        && echo "http://bio2rdf.org/omim_resource:bio2rdf.dataset.omim.R4" > omim.nq.graph

gzip *.rdf
