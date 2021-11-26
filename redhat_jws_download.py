#!/usr/bin/python3

# Download jws zip from the Red Hat customer portal
# using username/password from a docker secret file.
#
# The most easy is to use podman login registry.redhat.io to create
# the username/password in $HOME/.docker/config.json and use that
# file.
#
# of course to have create the username/password in red hat portal

##############################################################################

import requests
import lxml.html
import ujson
import base64
import sys

def get_jws_file(username,password,url,dest):
    
    # Setup Auth Struct
    auth = {'j_username': username, 'j_password': password}
    
    session = requests.Session()
    
    # Get initial request
    r = session.get(url)

    # Parse initial response
    root = lxml.html.fromstring(r.text)
    
    post_url = root.xpath('//form[@method="post"]')[0].action
    
    # Final Post to download file
    data = {'username': username, 'password': password}
    r = session.post(post_url, data=data)
    
    # Download file
    with open(dest, "wb") as code:
        code.write(r.content)

    # Close session
    session.close()


# read the file name (from a mounted secret in kubernetes)
if len(sys.argv) != 4:
    sys.exit("Need a file name like: /home/jfclere/.docker/config.json, an url like https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=37193 and a destination file")
    
# Opening JSON file
f = open(sys.argv[1])

# returns JSON object as
# a dictionary
data = ujson.load(f)['auths']['registry.redhat.io']['auth']
auth = base64.b64decode(data)
userpass = auth.split(b':')
username = userpass[0].decode('ascii')
password = userpass[1].decode('ascii')

url = sys.argv[2]
dest = sys.argv[3]
    
get_jws_file(username,password,url,dest)
