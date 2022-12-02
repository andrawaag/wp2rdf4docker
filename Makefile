WPRDFS := ${shell ls gpml | sed -e 's/\(.*\)/wp\/\1.ttl/' }
GPMLRDFS := ${shell ls gpml | sed -e 's/\(.*\)/wp\/gpml\/\1.ttl/' }

FRAMEWORKVERSION=release-4
JENAVERSION=4.3.0
GPMLRDFJAR=GPML2RDF-3.0.0-SNAPSHOT.jar
WPCURJAR=wikipathways.curator-1-SNAPSHOT.jar

all: docker_wikipathways-rdf-wp.zip docker_wikipathways-rdf-gpml.zip

install:
	@wget -O libs/${GPMLRDFJAR} https://github.com/wikipathways/wikipathways-curation-template/releases/download/${FRAMEWORKVERSION}/${GPMLRDFJAR}
	@wget -O libs/${WPCURJAR} https://github.com/wikipathways/wikipathways-curation-template/releases/download/${FRAMEWORKVERSION}/${WPCURJAR}
	@wget -O libs/slf4j-simple-1.7.32.jar https://search.maven.org/remotecontent?filepath=org/slf4j/slf4j-simple/1.7.32/slf4j-simple-1.7.32.jar
	@wget -O libs/jena-arq-${JENAVERSION}.jar https://repo1.maven.org/maven2/org/apache/jena/jena-arq/${JENAVERSION}/jena-arq-${JENAVERSION}.jar

clean:
	@rm -f ${GPMLS}

distclean: clean
	@rm libs/*.jar

gpml/%.gpml:
	@echo "Git fetching $@ ..."
	@echo '$@' | sed -e 's/gpml\/\(.*\)\.gpml/\1/' | xargs bash getPathway.sh

wikipathways-rdf-wp.zip: ${WPRDFS}
	@rm -f wikipathways-rdf-wp.zip
	@zip wikipathways-rdf-wp.zip wp/*

wikipathways-rdf-gpml.zip: ${GPMLRDFS}
	@rm -f wikipathways-rdf-gpml.zip
	@zip wikipathways-rdf-gpml.zip wp/gpml/*

wp/%.ttl: gpml/%.gpml src/java/main/org/wikipathways/curator/CreateRDF.class
	@mkdir -p wp/
	@cat "$<.rev" | xargs java -cp src/java/main/.:libs/${GPMLRDFJAR}:libs/derby-10.14.2.0.jar:libs/slf4j-simple-1.7.32.jar org.wikipathways.curator.CreateRDF $< $@

wp/gpml/%.ttl: gpml/%.gpml src/java/main/org/wikipathways/curator/CreateGPMLRDF.class
	@mkdir -p wp/gpml/
	@cat "$<.rev" | xargs java -cp src/java/main/.:libs/${GPMLRDFJAR}:libs/derby-10.14.2.0.jar:libs/slf4j-simple-1.7.32.jar org.wikipathways.curator.CreateGPMLRDF $< $@

src/java/main/org/wikipathways/curator/CreateRDF.class: src/java/main/org/wikipathways/curator/CreateRDF.java
	@echo "Compiling $@ ..."
	@javac -cp libs/${GPMLRDFJAR} src/java/main/org/wikipathways/curator/CreateRDF.java

src/java/main/org/wikipathways/curator/CreateGPMLRDF.class: src/java/main/org/wikipathways/curator/CreateGPMLRDF.java
	@echo "Compiling $@ ..."
	@javac -cp libs/${GPMLRDFJAR} src/java/main/org/wikipathways/curator/CreateGPMLRDF.java

src/java/main/org/wikipathways/curator/CheckRDF.class: src/java/main/org/wikipathways/curator/CheckRDF.java libs/${WPCURJAR}
	@echo "Compiling $@ ..."
	@javac -cp libs/${WPCURJAR} src/java/main/org/wikipathways/curator/CheckRDF.java

update: install
	@wget -O Makefile https://raw.githubusercontent.com/wikipathways/wikipathways-curation-template/main/Makefile
	@wget -O extractTests.groovy https://raw.githubusercontent.com/wikipathways/wikipathways-curation-template/main/extractTests.groovy
	@wget -O src/java/main/org/wikipathways/curator/CheckRDF.java https://raw.githubusercontent.com/wikipathways/wikipathways-curation-template/main/src/java/main/org/wikipathways/curator/CheckRDF.java
	@wget -O src/java/main/org/wikipathways/curator/CreateRDF.java https://raw.githubusercontent.com/wikipathways/wikipathways-curation-template/main/src/java/main/org/wikipathways/curator/CreateRDF.java
	@wget -O src/java/main/org/wikipathways/curator/CreateGPMLRDF.java https://raw.githubusercontent.com/wikipathways/wikipathways-curation-template/main/src/java/main/org/wikipathways/curator/CreateGPMLRDF.java

updateTests:
	@jar tf libs/wikipathways.curator-1-SNAPSHOT.jar | grep '.class' \
	  | grep 'nl.unimaas.bigcat.wikipathways.curator.tests' | tr / . \
	  | sed 's/\.class//' | xargs javap -public -cp libs/wikipathways.curator-1-SNAPSHOT.jar \
	  > tests.tmp
	@groovy extractTests.groovy > tests.tmp2
	@mv tests.tmp2 tests.txt
