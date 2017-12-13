#!/bin/sh
set -e
chown wildfly:wildfly /opt/wildfly -R
supervisord --nodaemon -c /etc/supervisord.conf -j /tmp/supervisord.pid -l /var/log/supervisord.log
