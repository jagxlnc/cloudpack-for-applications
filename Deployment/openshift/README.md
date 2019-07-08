# Deployment yaml for OpenShift

This readme explains the process for getting a Traditional WebSphere Application Server Docker image to run on an OpenShift cluster.

## Security Configuration

In order to deploy and run the Traditional WebSphere Docker image (tWAS) in an OpenShift cluster, we first need to configure certain security aspects for this cluster. The reason is that the tWAS Docker image has some security requisites an OpenShift cluster does not provide out of the box.

The way we are going to tell our OpenShift cluster to give certain security privileges to the tWAS Docker containers for these to be able to run is by adding a [Security Context Constraint](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_scc.html) (SCC) to the Service Account (in our namespace) we are going to deploy our tWAS containers as:

https://docs.openshift.com/container-platform/3.11/admin_guide/manage_scc.html#add-scc-to-user-group-project


1. Create a new **Security Context Constraint** (SCC) using `ssc.yaml`\*

    ```
    oc apply -f ssc.yaml
    ```

    \* This step requires cluster administration privileges so you might need to ask your cluster administrator to create the Security Context Constraint for you.

2. Create a new **Service Account**:

    ```
    oc create serviceaccount websphere -n appmod-twas
    ```

    where we have decided that our Service Account and Namespace will be named `websphere` and `appmod-twas` respectively.

3. **Bind**\* the previously created Security Context Constraint to the Service Account in our Namespace we have just created:

    ```
    oc adm policy add-scc-to-user ibm-websphere-scc -z websphere -n appmod-twas
    ```

    where `ibm-websphere-scc` is the name for the Security Context Constraint we created in step 1.

    \* This step requires cluster administration privileges so you might need to ask your cluster administrator to create the Security Context Constraint for you.


## Deployment

Use the following yaml files as a guidance as to how to deploy your tWAS Docker images in your OpenShift cluster. Notice that we have used `appmod-twas` as our namespace and `cos-twas` as our deployment config name in these yaml files. Update them as necessary.

```
oc apply -f dc.yaml -n appmod-twas
oc apply -f service.yaml -n appmod-twas
oc apply -f route.yaml -n appmod-twas
```

**IMPORTANT**: By default, [OpenShift Container Platform runs containers using an arbitrarily assigned user ID](https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html#openshift-specific-guidelines). This provides additional security against processes escaping the container due to a container engine vulnerability and thereby achieving escalated permissions on the host node.

However, the IBM Traditional WebSphere Application Server Docker image **must run as user 1001** due to the image being built for that particular user ID: https://github.com/WASdev/ci.docker.websphere-traditional/blob/master/docker-build/9.0.5.x/Dockerfile.ubi#L82-L91

As a result, we have specified such requisite, as well as the appropriate Service Account this Docker image has to be deployed as in order to use the Security Context Constraint created in the Security Configuration section above, in the deployment configuration:
```
serviceAccountName: websphere
serviceAccount: websphere
securityContext:
  runAsUser: 1001
  runAsNonRoot: true
```

Also, you must specify a liveness and readiness probe in your deployment configuration for Kubernetes to know when your tWAS Docker container is ready and is working fine: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#define-a-tcp-liveness-probe

The tWAS Docker container comes with TCP socket connection on port 9443 by default: https://github.com/IBM/charts/tree/master/stable/ibm-websphere-traditional#configure-liveness-and-readiness-probes

## Result
By following the steps defined in this readme, the result is:
-  a Deployment Config for the application with **liveness** and **readiness** probes for Kubernetes to properly manage your tWAS deployment, a **Service Account** set to `websphere` bound to a **Security Context Constraint** as required by the tWAS container to function.
- a Service for ports `9080` and `9443`.
- a Route to access the application from outside your OpenShift cluster.
