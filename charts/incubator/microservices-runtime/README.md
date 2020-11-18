# Microservices Runtime
This chart deploys one or several [Microservices Runtime](https://hub.docker.com/_/softwareag-webmethods-microservicesruntime) instances on a Kubernetes cluster using the Helm package manager.

## Prerequisites
- Provision a Kubernetes cluster version x.x (TBD)
- Install and configure Helm 3 (installs the charts without using Tiller)
- Enable support for persistent volume

## Deploying the Microservices Runtime chart
To deploy the chart, you must:
1. Add the webmethods-helm-collection chart repository to the local Helm.
2. Download the Microservices Runtime image from Docker Hub
3. Install the chart.

### Add the webmethods-helm-collection chart repository to the local Helm
Note that you can get the chart only from the incubator right now. When we have the stable version, you will get the chart from the stable folder.
To add the chart repository, run the helm repo add command with the repository URL and specify a name for the repository, for example "sag-helm-repo":
```bash
$ helm repo add sag-helm-repo https://softwareag.github.io/webmethods-helm-collection/charts-repo/incubator
```
To update the repository contents, run the following command:
```bash
$ helm repo update
```
### Download the Microservices Runtime image from [dockerhub](https://hub.docker.com)
The docker image for Microservices Runtime that you must use with the chart is stored on [dockerhub](https://hub.docker.com). To download the image:
1. Log in to [dockerhub](https://hub.docker.com)
2. Locate the Microservices Runtime [image here](https://hub.docker.com/_/softwareag-webmethods-microservicesruntime)
3. Click the **Proceed to Checkout** button and accept the license terms and conditions.

### Install the chart
Install the chart with a command, in which you specify a release name for the Microservices Runtime instance, for example "msr1", the user credentials that you specified when downloading the image from Docker Hub, and the path to the Microservices Runtime chart:
```bash
helm install um1 --set imageCredentials.username="<dockerhub_username>" --set imageCredentials.password="<dockerhub_password>"  sag-helm-repo/microservices-runtime
```
The command deploys a single instance of Microservices Runtime , which is already set up with the initial configuration.

You can also use one of the following advanced options to install the chart (note that you can combine the options in one command):
- To avoid exposing the user credentials on the command line, you can create an YAML file, for example "~/docker-credentials.yaml", with the following parameters:
```yaml
imageCredentials:
  registry: "https://index.docker.io/v1/"
  username: "<dockerhub_username>"
  password: "<dockerhub_password>"
```
and then use the YAML file when installing the chart as follows:
```bash
helm install msr1 -f ~/docker-credentials.yaml sag-helm-repo/microservices-runtime
```

- To provide a custom license and replace the time-limited license included in the docker image, for example to add a custom license with name "~/my-custom-license.xml":
``` bash
helm install msr1 -f ~/docker-credentials.yaml --set-file externalFiles.licenseFile=~/my-custom-license.xml   sag-helm-repo/microservices-runtime
```

### customization using ENV variables

You can provide env variables to the container by setting them in values file or overwrite them or adding new variables by using --set flag. The chart will process them and set them in the container environment.

```
helm install msr1 -f ~/docker-credentials.yaml --set envVariables.MSR_JDBC_URL="jdbc:mysql://mysql:3306/webm" --set envVariables.CUSTOMENV_VAR="somecustomvalue" sag-helm-repo/microservices-runtime
```
Here are the predefined variables and their values:

  * MSR_JDBC_URL: "jdbc:mysql://mysql:3306/webm" 
  * MSR_JDBC_PASSWORD: "webm"
  * MSR_JDBC_USER: "webm"
  * MSR_JNDI_PROVIDER_URL: "nsp://um1-universal-messaging:9000"
  * JAVA_DEBUGGER_OPTS: "-Dcom.softwareag.um.jndi.cf.url.override=true"
  * MSR_PACKAGE_URLS: ""


### customization using helm chart values file

You can provide or set values in the values.yaml file , create custom one with required values and structure or set them using --set flag
```
helm install msr1 -f ~/customvalues.yaml --set image.repository=daerepository03.eur.ad.sag:4443/ccdevops/pcmsr --set image.tag=10.5.0.0 sag-helm-repo/microservices-runtime
```
Here is the complete list of values and their description:
**you can specify custom docker image**
  * image.repository
  * image.tag
  * image.pullPolicy
**Set the credentials used for pulling the image if needed**
  * imageCredentials.registry: "https://index.docker.io/v1/"
  * imageCredentials.username: ""
  * imageCredentials.password: ""
**The kubernetes service's type and port to be used in order to access the pod with MSR**  
  * service.type: ClusterIP
  * service.port: 5555
  
**If this is going to be run on Azure Kubernetes Services (AKS) and you want to make MSR endpoint to be exposed to the world**
  * createAzLB: true
**If there is no load balancing k8s service, but want to expose the MSR endpoint using nginx ingress controller** 
Generally this is mutually exlusive with createAzLB by design, but both can coexist
  * ingress.enabled
  * ingress.hosts:
    - host: msr2.ninjacloud.eur.ad.sag
	    paths: [ "/" ]



## Accessing the Microservices Runtime
After deploying the product using helm and if it is exposed to the world it can be accessed in two ways depending whether you created LB or ingress controller

### using Azure LB
You should check the external IP address of the service once it has been created. Usually it takes a couple of minutes before externalIP is being provided after helm install command
```
$ kubectl get service
NAME                            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
kubernetes                      ClusterIP      10.0.0.1       <none>          443/TCP          176d
msr1-microservices-runtime      ClusterIP      10.0.108.117   <none>          5555/TCP         6d1h
msr1-microservices-runtime-lb   LoadBalancer   10.0.22.201    20.56.184.112   5555:31023/TCP   6d1h
```
So then use browser and point to: http://20.56.184.112:5555/

### Using Ingress
If there is an option to use ingress controller and the dns servers are configured for that then you should use the url specified in the host option as described above as url. In this example http://msr2.ninjacloud.eur.ad.sag  however
