FROM amazoncorretto:11-alpine-jdk
RUN apk add --no-cache curl tar bash procps git apache-ant tree make

# Downloading and installing Maven
# 1- Define a constant with the version of maven you want to install
ARG MAVEN_VERSION=3.8.6

# 2- Define a constant with the working directory
ARG USER_HOME_DIR="/wp"

# 3- Define the SHA key to validate the maven download
ARG SHA=f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26

# 4- Define the URL where maven can be downloaded from
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

# 5- Create the directories, download maven, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Checking download hash" \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  \
  && echo "Unziping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 6- Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Download bridgeDB
WORKDIR /tmp
RUN mkdir OPSBRIDGEDB
RUN mkdir bdbfiles
RUN wget -c https://zenodo.org/record/6502115/files/Hs_Derby_Ensembl_105.bridge?download=1 -O /tmp/OPSBRIDGEDB/geneproteinMappings.bridge
RUN wget -c https://figshare.com/ndownloader/files/36197283 -O /tmp/OPSBRIDGEDB/metaboliteMappings.bridge
RUN wget -c https://ndownloader.figshare.com/files/26003138 -O /tmp/OPSBRIDGEDB/interactionMappings.bridge
RUN echo "bridgefiles=/tmp/bdbfiles" > /tmp/OPSBRIDGEDB/config.properties

WORKDIR /wp
# Fetch WP2RDF scripts 
RUN git clone https://github.com/andrawaag/wp2rdf4docker
WORKDIR wp2rdf4docker
RUN make install
