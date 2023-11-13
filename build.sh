#!/bin/sh
# The parameters are:
# webAppWarFileName=%s;
# webAppWarImage
# webAppSourceRepositoryURL=%s;
# webAppSourceRepositoryRef=%s;
# webAppSourceRepositoryContextDir=%s;
# webAppSourceImage


# Some pods don't have root privileges, so the build takes place in /tmp
cd tmp

# Create a custom .m2 repo in a location where no root privileges are required
mkdir -p /tmp/.m2/repo

# Create custom maven settings that change the location of the .m2 repo
echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' >> /tmp/.m2/settings.xml
echo 'xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">' >> /tmp/.m2/settings.xml
echo '<localRepository>/tmp/.m2/repo</localRepository>' >> /tmp/.m2/settings.xml
echo '</settings>' >> /tmp/.m2/settings.xml


if [ -z ${webAppSourceRepositoryURL} ]; then
	echo "Need an URL like https://github.com/jfclere/demo-webapp.git"
	exit 1
fi

git clone ${webAppSourceRepositoryURL}
if [ $? -ne 0 ]; then
	echo "Can't clone ${webAppSourceRepositoryURL}"
	exit 1
fi

# Get the name of the source code directory
DIR=$(echo ${webAppSourceRepositoryURL##*/})
DIR=$(echo ${DIR%%.*})

cd ${DIR}

if [ ! -z ${webAppSourceRepositoryRef} ]; then
	git checkout ${webAppSourceRepositoryRef}
fi

if [ ! -z ${webAppSourceRepositoryContextDir} ]; then
	cd ${webAppSourceRepositoryContextDir}
fi

# Builds the webapp using the custom maven settings
mvn clean install -gs /tmp/.m2/settings.xml
if [ $? -ne 0 ]; then
	echo "mvn install failed please check the pom.xml in ${webAppSourceRepositoryURL}"
	exit 1
fi

# Copies the resulting war to deployments
echo "Copies the resulting war to deployments/${webAppWarFileName}"
mkdir /tmp/deployments
cp /tmp/*/target/*.war /tmp/deployments/${webAppWarFileName}

# on not privileged openshift arrange /etc/subuid and /etc/subgid to the current user.
# note sed -i can't we can't write a new file /etc
MYUSER=`id -u`
echo "Current user: ${MYUSER}"
if [ ${MYUSER} != "1000" ]; then
  sed "s:1000:${MYUSER}:" /etc/subuid > subuid.new
  cat subuid.new >> /etc/subuid
  sed "s:1000:${MYUSER}:" /etc/subgid > subgid.new
  cat subgid.new >> /etc/subgid
fi

# The secret is mounted in /auth
# the /auth/.dockerconfigjson comes from mounting the secret in the pod
# the source here is the $HOME/.docker/config.json create like:
# kubectl create secret generic jfc --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
# if you just use a podman do something like:
# podman run --mount type=bind,target=/home/jfclere/.docker/config.json,destination=/auth/.dockerconfigjson quay.io/jfclere/tomcat10-buildah
# 
# ${webAppWarImage} is where we push the result
# ${webAppSourceImage} is what we use in FROM of the Dockerfile
#
echo "Use buildah to build and push to ${webAppWarImage}"
echo "Running STORAGE_DRIVER=vfs buildah bud -f /Dockerfile.JWS -t ${webAppWarImage} --authfile /auth/.dockerconfigjson --build-arg webAppSourceImage=${webAppSourceImage}"
cd /tmp
HOME=/tmp
STORAGE_DRIVER=vfs buildah bud -f /Dockerfile.JWS -t ${webAppWarImage} --authfile /auth/.dockerconfigjson --build-arg webAppSourceImage=${webAppSourceImage}
STORAGE_DRIVER=vfs buildah push --authfile /auth/.dockerconfigjson ${webAppWarImage}
