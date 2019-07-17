FROM ibmcom/websphere-traditional:9.0.0.11

#Hardcode password for admin console

COPY ./tWAS/PASSWORD /tmp/PASSWORD

COPY ./tWAS/app-update.props  /work/config/app-update.props

COPY ./tWAS/SessionSample-1.0.war /work/config/SessionSample-1.0.war

RUN /work/configure.sh