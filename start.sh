#!/bin/sh

# This script executes any script in the list ENV_FILES
# the ENV_FILES can be created by the operator
# and are sources here.
# The entry point is modified...
# ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar app.jar" ]
# ENTRYPOINT [ "sh", "-c", "/opt/start.sh" ]

if [ -n "$ENV_FILES" ]; then
  (
    for prop_file_arg in $(echo $ENV_FILES | sed "s/,/ /g"); do
      for prop_file in $(find $prop_file_arg -maxdepth 0 2>/dev/null); do
        (
          if [ -f $prop_file ]; then
            echo "Run: $prop_file"
            sh $prop_file
          else
            echo "Could not process environment for $prop_file.  File does not exist."
          fi
        )
      done
    done
  )
fi

# Copy the war in webapps (probably we can use a ENV_FILES for that)
cp /deployments/*.war /deployments/webapps/ || true

# start the tomcat
java $JAVA_OPTS -jar app.jar
