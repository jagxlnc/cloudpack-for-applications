ARG WEBSPHERE_VERSION=9.0.0.11

# Migration requires websphere-traditional >= 9.0.0.11
FROM ibmcom/websphere-traditional:$WEBSPHERE_VERSION as migration

#Hardcode password for admin console
COPY --chown=was:0 tWAS/PASSWORD /tmp/PASSWORD

COPY --chown=was:0 resources/db2/ /opt/IBM/db2drivers/

COPY --chown=was:0 resources/jmx_exporter/jmx_prometheus_javaagent-0.11.0.jar /opt/IBM/jmx_exporter/
COPY --chown=was:0 resources/jmx_exporter/jmx-config.yaml /opt/IBM/jmx_exporter/

# Uncomment to test locally
#COPY --chown=was:0 tWAS/jvm.props /work/config

COPY --chown=was:0 tWAS/cosConfig.py /work/config/

COPY --chown=was:0 tWAS/app-update.props  /work/config/app-update.props
COPY --chown=was:0 tWAS/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /work/config/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear

RUN /work/configure.sh
