# Using buildah and a pod to build image

The idea is to have pod builder that can be used in kubernetes

## build and push the builder

```
podman build -f Dockerfile.buildah -t quay.io/${USER}/tomcat10-buildah
podman push quay.io/${USER}/tomcat10-buildah
```

## Use the image to build your webapp

```
podman run --mount type=bind,target=/home/${USER}/.docker/config.json,destination=/auth/config.json quay.io/${USER}/tomcat10-buildah
```
It supports a bunch of parameters:

###webAppWarFileName
That is the name of the war to deploy in webapps, the default is ROOT.war

###webAppWarImage
That is the name of docker image that is build and contains the war file, for quay.io/jfclere/test

### webAppSourceRepositoryURL
That is the URL of the source repository, for example https://github.com/jfclere/demo-webapp.git

### webAppSourceRepositoryRef
That is the branch in the git sources, the default is main

### webAppSourceRepositoryContextDir
That is the sub directory in the git sources, the default is empty.

### webAppSourceImage
That is the base image to which the webapp is added, the default is: registry.redhat.io/jboss-webserver-5/webserver55-openjdk8-tomcat9-openshift-rhel8

To use any of the parameters use --env var=val

## Use a pod to build your image in kubernetes
Ajust JWSbuildah.yaml to what you need and run:
```
kubectl create -f JWSbuildah.yaml
```
Note you need a secret the most easy is to adapt your $HOME/.docker/config.json and do something like:
```
kubectl create secret generic jfc --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
```
The secret is mount in /auth/.dockerconfigjson in the pod by the yaml file.
