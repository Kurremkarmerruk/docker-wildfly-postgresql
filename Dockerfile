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
# ADD standalone.xml /opt/jboss/wildfly/standalone/configuration/

# Remove standalone_xml_history/current directory
RUN rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
