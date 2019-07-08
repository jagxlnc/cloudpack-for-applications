## PMI

In order to configure Performance Monitoring Infrastructure (PMI) with the traditional WebSphere Application Server in containers (tWAS), we have three options:

1. Configure PMI manually
    - Log into the was admin console and change PMI manually on the runtime section for your server
    - Execute the following commands on the wsadmin util:
    ```
    AdminControl.invoke('WebSphere:name=PerfPrivateMBean,process=server1,platform=dynamicproxy,node=DefaultNode01,version=9.0.0.11,type=PerfPrivate,mbeanIdentifier=PerfPrivateMBean,cell=DefaultCell01,spec=1.0', 'setSynchronizedUpdate', '[false]')
    AdminControl.invoke('WebSphere:name=PerfPrivateMBean,process=server1,platform=dynamicproxy,node=DefaultNode01,version=9.0.0.11,type=PerfPrivate,mbeanIdentifier=PerfPrivateMBean,cell=DefaultCell01,spec=1.0', 'setStatisticSetID', '[extended]')
    ```
  where you can set the PMI level to `none`, `basic`, `extended`, `all` and `custom`.

2. Configure PMI at runtime - Use the [ConfigMap the tWAS container reads at startup](https://github.com/IBM/charts/tree/master/stable/ibm-websphere-traditional#configure-environment-using-configuration-properties) to provide the `pmi.props` file with your PMI configuration:
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: pmi-configmap
  data:
    pmi.props: |-
      #
      # Configuration properties file for cells/DefaultCell01/nodes/DefaultNode01/servers/server1|server.xml#PMIService_1183122130078#
      # Extracted on Mon Jul 01 12:50:56 UTC 2019
      #

      #
      # Section 1.0 ## Cell=!{cellName}:Node=!{nodeName}:Server=!{serverName}:PMIService=
      #

      #
      # SubSection 1.0 # PMIService Section
      #
      ResourceType=PMIService
      ImplementingResourceType=PMIService
      ResourceId=Cell=!{cellName}:Node=!{nodeName}:Server=!{serverName}:PMIService=
      AttributeInfo=services
      #

      #
      #Properties
      #
      synchronizedUpdate=false #boolean,default(false)
      enable=true #boolean,default(false)
      context=!{serverName}
      statisticSet=all
      initialSpecLevel=

      #
      # SubSection 1.0.1 # PMIService properties
      #
      ResourceType=PMIService
      ImplementingResourceType=PMIService
      ResourceId=Cell=!{cellName}:Node=!{nodeName}:Server=!{serverName}:PMIService=
      AttributeInfo=properties(name,value)
      #

      #
      #Properties
      #

      #
      # End of Section 1.0# Cell=!{cellName}:Node=!{nodeName}:Server=!{serverName}:PMIService=
      #
      #
      #
      EnvironmentVariablesSection
      #
      #
      #Environment Variables
      cellName=DefaultCell01
      nodeName=DefaultNode01
      serverName=server1
  ```
  where you can set **statisticSet** to `none`, `basic`, `extended`, `all` and `custom`.

3. Configure PMI permanently - Place the `pmi.props` file where [the tWAS container expects properties files](https://github.com/WASdev/ci.docker.websphere-traditional#adding-properties-during-build-phase) at docker image build time so that such PMI configuration will be baked into the container.

Checkout the files included in this repository location for more info.
