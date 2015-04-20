FROM jboss/wildfly:latest

# Get Postgres stuff
RUN curl -o /tmp/psql-jdbc.jar https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar
RUN curl -o /tmp/postgis-jdbc.jar http://postgis.net/stuff/postgis-jdbc-2.1.3.jar 
ADD config.sh /tmp/
ADD batch.cli /tmp/

# Set up modules
RUN /tmp/config.sh

# Add admin user
RUN /opt/jboss/wildfly/bin/add-user.sh admin Admin#007 --silent

# Use the modules
# ATTN: Configuring standalone via jboss_cli instead
# ADD standalone.xml /opt/jboss/wildfly/standalone/configuration/

# Remove standalone_xml_history/current directory
# ATTN: Attempting user creation instead
# RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current

# Create wildfly group and user, set file ownership to that user
RUN groupadd -r wildfly -g 433 && \
    useradd -u 431 -r -g wildfly -d /opt/jboss/wildfly -s /sbin/nologin -c "Wildfly user" wildfly && \
    chown -R wildfly:wildfly /opt/jboss/wildfly

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0" "-Djboss.management.http.port" "9090"]
