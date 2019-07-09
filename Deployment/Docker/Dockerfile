#ARG WEBSPHERE_VERSION=9.0.0.11

# Migration requires websphere-traditional >= 9.0.0.11
#FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION as migration
FROM ibmcom/websphere-traditional:9.0.0.11 as migration


USER root

COPY --chown=was:0 ./Deployment/Docker/migr /tmp/migr
COPY --chown=was:0 ./Deployment/Docker/migration.properties /opt/IBM/WebSphere/AppServer/properties/migration.properties
