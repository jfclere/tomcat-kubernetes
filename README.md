# tomcat-kubernetes
What is needed to create a Tomcat Docker image to run a cluster of tomcats in Kubernetes.

Get the latest tomcat snapshot of tomcat from the ASF tomcat repo:
```
git clone https://github.com/apache/tomcat.git
cd modules/stuffed
mvn clean
mvn install
```
Build the Docker image:
```
podman build -t quay.io/${USER}/tomcat-stuffed
podman login quay.io/${USER}/tomcat-stuffed
podman push quay.io/${USER}/tomcat-stuffed
```
This tomcat image can used to prepare a custom image with you webapp (here sample.war)  

```
cd $HOME
git clone https://github.com/jfclere/tomcat-kubernetes.git 
cd tomcat-kubernetes
podman build -f Dockerfile.webapp -t quay.io/${USER}/tomcat-in-the-cloud-war --build-arg war=/sample.war --build-arg IMAGE=quay.io/${USER}/tomcat-stuffed .
```
Push the image on docker
```
podman login quay.io/${USER}/tomcat-in-the-cloud-war
podman push quay.io/${USER}/tomcat-in-the-cloud-war
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
Create the first pod ajust tomcat-in-the-cloud.yaml like:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-in-the-cloud
  labels:
    app: tomcat-in-the-cloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tomcat-in-the-cloud
  template:
    metadata:
      labels:
        app: tomcat-in-the-cloud
    spec:
      containers:
      - name: tomcat-in-the-cloud
        image: quay.io/jfclere/tomcat-in-the-cloud
        ports:
        - containerPort: 8080
        env:
        - name: OPENSHIFT_KUBE_PING_NAMESPACE
          value: "tomcat-in-the-cloud"
        - name: ENV_FILES
          value: "/opt/usekube.sh"
```
start it:
```
kubectl create -f tomcat-in-the-cloud.yaml
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

You can also use:
```
kubectl get services
NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP                         PORT(S)        AGE
tomcat-in-the-cloud   LoadBalancer   172.21.33.123   ad04ef07-eu-de.lb.appdomain.cloud   80:32475/TCP   31s
```

Here use http://ad04ef07-eu-de.lb.appdomain.cloud/sample/ to reach the application
