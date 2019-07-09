#ARG WEBSPHERE_VERSION=9.0.0.11

# Migration requires websphere-traditional >= 9.0.0.11
#FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION as migration
FROM ibmcom/websphere-traditional:9.0.0.11 as migration

USER root

# Use --build-arg PASSWORD="your password" to specify password for WASPostUpgrade.
#ARG PASSWORD

COPY --chown=was:0 ./Deployment/Docker/migr /tmp/migr
COPY --chown=was:0 ./Deployment/Docker/migration.properties /opt/IBM/WebSphere/AppServer/properties/migration.properties

# All other parameters to WASPostUpgrade are set in migration.properties. If you want to change those settings,
# either edit migration.properties or specify them on the command line here, if available.
# NOTE: Some parameters are required for container migration, and should not be changed
RUN /opt/IBM/WebSphere/AppServer/bin/WASPostUpgrade.sh /tmp/migr -oldProfile AppSrv01 -profileName AppSrv01 -username wasadmin -password wasadmin && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/temp/* && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/wstemp/* && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/installableApps/*

# Requires the same websphere-traditional level as migration
#FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION
FROM ibmcom/websphere-traditional:9.0.0.11

RUN rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/servers/server1/configuration/wsBundleMetadata/jpa-2.1.xml && \
    rm -rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/servers/server1/configuration/wsBundleMetadata/jaxrs-2.0.xml && \
    touch /tmp/passwordupdated && cp /tmp/passwordupdated /tmp/PASSWORD 


COPY --from=migration --chown=was:0 /opt/IBM/WebSphere/AppServer/profiles/AppSrv01 /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/
COPY --from=migration --chown=was:0 /opt/IBM/WebSphere/AppServer/java/8.0/jre/lib/security/java.security /opt/IBM/WebSphere/AppServer/java/8.0/jre/lib/security/

COPY --chown=was:0 ./Deployment/Docker/db2drivers/ /opt/IBM/db2drivers/
#COPY --chown=was:0 update_app.py /work/config/update_app.py
COPY --chown=was:0 ./Deployment/Docker/app-update.props  /work/config/app-update.props
COPY --chown=was:0 ./Deployment/Docker/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /work/config/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear

RUN /work/configure.sh

ENV ADMIN_USER_NAME=wasadmin
