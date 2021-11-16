# tomcat-kubernetes
What is needed to create a Tomcat Docker image to run a cluster of tomcats in Kubernetes.

Get the latest tomcat snapshot of tomcat:
```
mvn clean
mvn install
```
Build the Docker image:
```
podman build -t quay.io/<user>/tomcat-in-the-cloud --build-arg registry_id=tomcat-in-the-cloud .
```
or (to add your sample.war webapp to my existing image).
```
podman build -f Dockerfile.webapp -t quay.io/<user>/tomcat-in-the-cloud-war --build-arg war=/sample.war --build-arg registry_id=tomcat-in-the-cloud .
```
Push the image on docker (use tomcat-in-the-cloud-war for the war one)
```
podman login quay.io/<user>/tomcat-in-the-cloud
podman push quay.io/<user>/tomcat-in-the-cloud
```

For OpenShift
https://manage.openshift.com/account/index use add a New Plan (Starter is enough) creating the plan takes a while...
open the web console and create project
On the left of the console you can get the login command ("Copy Login Command"). Use it on you laptop to connect.
```
oc login https://blabla --token=blabla
```
Use the project you have created (in my case I have created tomcat-in-the-cloud)
```
oc project tomcat-in-the-cloud
```
Add the user to view the pods
```
oc policy add-role-to-user view system:serviceaccount:tomcat-in-the-cloud:default -n tomcat-in-the-cloud
```
Create the first pod
```
kubectl run tomcat-in-the-cloud --image=docker.io/jfclere/tomcat-in-the-cloud --port=8080
```
Scale it do 2 replicas
```
kubectl scale deployment tomcat-in-the-cloud --replicas=2
```
Expose the deployment
```
kubectl expose deployment tomcat-in-the-cloud --type=LoadBalancer --port 80 --target-port 8080
```
Use the console to create the route then change it to make it not sticky and session less, lastly edit the yaml and save it.
Something like
```
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    haproxy.router.openshift.io/balance: roundrobin
    haproxy.router.openshift.io/disable_cookies: 'true'
    openshift.io/host.generated: 'true'
    ...
```
The route will be modified when you save it.
To access to the tomcat use the hostname something like
http://tomcat-in-the-cloud-tomcat-in-the-cloud.193b.starter-ca-central-1.openshiftapps.com/
