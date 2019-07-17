FROM ibmcom/websphere-traditional:9.0.0.11

#Hardcode password for admin console

COPY ./session-mgmt/PASSWORD /tmp/PASSWORD

COPY ./session-mgmt/app-update.props  /work/config/app-update.props

COPY ./session-mgmt/SessionSample-1.0.war /work/config/SessionSample-1.0.war

RUN /work/configure.sh
