# Docker
This repo contains a Dockerfile to build a docker container for the RDF generation of Wikipathways (GPML) content.

## Run docker
```
sudo docker container run -d -v /home/ubuntu/wikipathways_docker/gpml:/wp/wp2rdf4docker/gpml -v /home/ubuntu/wikipathways_docker/gpml/reports:/wp/wp2rdf4docker/reports -v /home/ubuntu/wikipathways_docker/gpml/wp:/wp/wp2rdf4docker/wp  -t micelio/wikipathways_rdf:latest
```
The docker command will print a hash like the one below:
`5bfa8c26ca80da265b06ce419edf5cd2d804e6898fffa2ebef1cda631eb3fee2`

Copy that hash and type
`sudo docker exec -it <hash> bash`

e.g. (per the example hash above)
`sudo docker exec -t 5bfa8c26ca80da265b06ce419edf5cd2d804e6898fffa2ebef1cda631eb3fee2 bash

a command line will appear
`bash-5.1# `

# Docker
## Build the docker container
## Run
`sudo docker container run -d -v /home/ubuntu/wikipathways_docker/gpml:/gpml -v /home/ubuntu/wikipathways_docker/reports:/reports -v /home/ubuntu/wikipathways_docker/wp:/wp  sudo docker container run -d -v /home/ubuntu/wikipathways_docker/gpml:/gpml -v /home/ubuntu/wikipathways_docker/reports:/reports -v /home/ubuntu/wikipathways_docker/wp:/wp  -t micelio:wikipathwaysRDF`
