ARG WEBSPHERE_VERSION=9.0.0.11
ARG NEW_RELIC_LICENSE

# Migration requires websphere-traditional >= 9.0.0.11
FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION as migration

# Use --build-arg PASSWORD="your password" to specify password for WASPostUpgrade.
ARG PASSWORD

COPY --chown=was:0 migr /tmp/migr
COPY --chown=was:0 migration.properties /opt/IBM/WebSphere/AppServer/properties/migration.properties

# All other parameters to WASPostUpgrade are set in migration.properties. If you want to change those settings,
# either edit migration.properties or specify them on the command line here, if available.
# NOTE: Some parameters are required for container migration, and should not be changed
RUN /opt/IBM/WebSphere/AppServer/bin/WASPostUpgrade.sh /tmp/migr -oldProfile AppSrv01 -profileName AppSrv01 -username wasadmin -password "$PASSWORD"  && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/temp/* && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/wstemp/* && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/installableApps/*

# Requires the same websphere-traditional level as migration
FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION

RUN rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/servers/server1/configuration/wsBundleMetadata/jpa-2.1.xml && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/servers/server1/configuration/wsBundleMetadata/jaxrs-2.0.xml && \
    touch /tmp/passwordupdated && cp /tmp/passwordupdated /tmp/PASSWORD

COPY --from=migration --chown=was:0 /opt/IBM/WebSphere/AppServer/profiles/AppSrv01 /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/
COPY --from=migration --chown=was:0 /opt/IBM/WebSphere/AppServer/java/8.0/jre/lib/security/java.security /opt/IBM/WebSphere/AppServer/java/8.0/jre/lib/security/

COPY --chown=was:0 db2drivers/ /opt/IBM/db2drivers/


COPY --chown=was:0 newrelic/newrelic-java-5.2.0.zip /tmp
COPY --chown=was:0 newrelic/new_relic_java.policy /tmp

RUN ["unzip", "/tmp/newrelic-java-5.2.0.zip", "-d", "/opt/IBM/WebSphere"]
RUN cat /tmp/new_relic_java.policy >> /opt/IBM/WebSphere/AppServer/java/8.0/jre/lib/security/java.policy
RUN sed -i 's/<%= license_key %>/$NEW_RELIC_LICENSE/g' /opt/IBM/WebSphere/newrelic/newrelic.yml

# Uncomment to test locally
#COPY --chown=was:0 jvm.props /work/config
#RUN /work/configure.sh

ENV ADMIN_USER_NAME=wasadmin
