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
