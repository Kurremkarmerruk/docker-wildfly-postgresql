#!/bin/bash

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}

function wait_for_wildfly() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    sleep 1
  done
}

echo "==> Starting WildFly..."
$JBOSS_HOME/bin/$JBOSS_MODE.sh &

echo "==> Waiting..."
wait_for_wildfly

echo "==> Executing..."
$JBOSS_CLI -c --file=`dirname "$0"`/batch.cli

echo "==> Shutting down WildFly..."
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi
