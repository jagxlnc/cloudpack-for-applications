#ARG WEBSPHERE_VERSION=9.0.0.11

# Migration requires websphere-traditional >= 9.0.0.11
#FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION as migration
FROM ibmcom/websphere-traditional:9.0.0.11 as migration

USER root

COPY --chown=was:0 ./tWAS/PASSWORD /tmp/PASSWORD
COPY --chown=was:0 ./resources/db2/ /opt/IBM/db2drivers/
