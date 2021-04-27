# bourne shell script snippet
# used by the start.sh tomcat launch script
# add kube cluster
FILE=`find / -name server.xml`
grep -q MembershipProvider ${FILE}
if [ $? -ne 0 ]; then
  sed -i '/cluster.html/a        <Cluster className=\"org.apache.catalina.ha.tcp.SimpleTcpCluster\" channelSendOptions=\"6\">\\n <Channel className=\"org.apache.catalina.tribes.group.GroupChannel\">\\n <Membership className=\"org.apache.catalina.tribes.membership.cloud.CloudMembershipService\" membershipProviderClassName=\"org.apache.catalina.tribes.membership.cloud.KubernetesMembershipProvider\"/>\\n </Channel>\\n </Cluster>\\n' ${FILE}
fi
