#!/bin/sh
set -e

TYPE=$(echo $TYPE | tr '[:upper:]' '[:lower:]')

if [ "$TYPE" == 'tunned' ] ; then
  cp /opt/wildfly/standalone/configuration/standalone-tunned.xml  /opt/wildfly/standalone/configuration/standalone.xml
fi

supervisord --nodaemon -c /etc/supervisord.conf -j /tmp/supervisord.pid -l /var/log/supervisord.log
