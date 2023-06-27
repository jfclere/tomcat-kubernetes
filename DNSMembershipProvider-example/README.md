## Example to demo the org.apache.catalina.tribes.membership.cloud.DNSMembershipProvider

Show the labels and selector logic of the DNS service.

## Files:

tomcat1.yml, tomcat2.yml and tomcat3.yml yaml files to create tomcat pods

dns-membership-service.yml yaml file to create the service for the DNS logic

nslookup.java java sources to test the DNS logic.

## To run it

Create pods and service:
```bash
kubectl create -f dns-membership-service.yml
kubectl create -f tomcat1.yml
kubectl create -f tomcat2.yml
```
Create the nslookup.java file on one of the tomcat pod
```bash
kubectl exec --stdin --tty tomcat1 -- /bin/bash
root@tomcat:/usr/local/tomcat# cat > nslookup.java
import java.net.InetAddress;
import java.net.UnknownHostException;

public class nslookup {
  public static void main(String[] argv)
  {
     InetAddress[] inetAddresses = null;
     try {
        inetAddresses = InetAddress.getAllByName("my-tomcat-app-membership");
     } catch (UnknownHostException exception) {
        System.out.println("service not found");
        System.exit(1);
     }
     for (InetAddress inetAddress : inetAddresses) {
        String ip = inetAddress.getHostAddress();
        System.out.println("ip: " + ip);
     }
  }
}
^D
```
Compile the nslookup.java on the tomcat pod
```bash
root@tomcat1:/usr/local/tomcat# javac nslookup.java
```
Run the class
```bash
root@tomcat1:/usr/local/tomcat# java nslookup
ip: 172.17.5.146
ip: 172.17.3.136
```
172.17.5.146 and 172.17.3.136 are the IP addresses of the tomcat1 and tomcat2 pods running in the cluster.

Start tomcat3 by kubectl create -f tomcat3.yml and rerun the java class:
```bash
root@tomcat1:/usr/local/tomcat# java nslookup
ip: 172.17.5.146
ip: 172.17.5.147
ip: 172.17.3.136
```
