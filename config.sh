#!/bin/bash

# Usage: execute.sh [WildFly mode] [configuration file]
#
# The default mode is 'standalone' and default configuration is based on the
# mode. It can be 'standalone.xml' or 'domain.xml'.

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

function wait_for_wildfly() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    sleep 1
  done
}

echo "==> Starting WildFly..."
$JBOSS_HOME/bin/$JBOSS_MODE.sh -c $JBOSS_CONFIG &

echo "==> Waiting..."
wait_for_wildfly

# --file=`dirname "$0"`/batch.cli
echo "==> Executing jdbc driver script..."
$JBOSS_CLI -c << EOF
batch

# Add Postgres module
module add --name=org.postgresql --resources=/tmp/psql-jdbc.jar:/tmp/postgis-jdbc.jar --dependencies=javax.api,javax.transaction.api

# Add Postgres driver
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql,driver-module-name=org.postgresql,driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)

# Add datasource
data-source add --name=PostgrePool --jndi-name=java:jboss/datasources/PGDS --connection-url=jdbc:postgresql://$PG_PORT_5432_TCP_ADDR:$PG_PORT_5432_TCP_PORT --driver-name=postgresql --user-name=postgres

run-batch
EOF

# echo "==> Removing old snapshots..."snapshots...
# $JBOSS_CLI -c ":delete-snapshot(name=\"all\")"

echo "==> Shutting down WildFly..."
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi
