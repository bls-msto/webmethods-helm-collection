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
The command deploys a single instance of Universal Messaging, which is already set up with the initial configuration required for Universal Messaging.

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
helm install um1 -f ~/docker-credentials.yaml sag-helm-repo/universal-messaging
```
- To install more than one replica:
``` bash
helm install um1 -f ~/docker-credentials.yaml --set replicaCount=3  sag-helm-repo/universal-messaging
```
- To provide a custom license and replace the time-limited license included in the docker image, for example to add a custom license with name "~/my-custom-license.xml":
``` bash
helm install um1 -f ~/docker-credentials.yaml --set-file externalFiles.licenseFile=~/my-custom-license.xml   sag-helm-repo/universal-messaging
```
- To specify a custom configuration file, for example the custom configuration file with name "~/my-custom-config.xml":
``` bash
helm install um1 -f ~/docker-credentials.yaml --set-file externalFiles.configFile="~/my-custom-config.xml" sag-helm-repo/universal-messaging
```
You can use this command for custom configurations, such as the UM realm export.

## Consuming the UM messaging service
After you deploy a Universal Messaging instance from the UM chart, the intance runs so that all other containers in the same cluster/namespace can consume the UM service. The chart does not create an external loadbalancer for the UM instance and the UM service is not accessible from outside the cluster.
The UM instance runs as a stateful set and because Universal Messaging does not require a load balancing service for the instances, each instance can be consumed at the following URLs:
```
nsp://um1-universal-messaging-0.um1-universal-messaging:9000
nsp://um1-universal-messaging-1.um1-universal-messaging:9000
...
```
where "um1" is the name of the helm chart release.
If you want to use the Enterprise Manager of Universal Messaging to check the UM status and manage the product, you can use port forwarding to connect to each instance:
```bash
 kubectl port-forward  um1-universal-messaging-0 9000:9000
```
where "um1" is the name of the helm chart release and the left-hand side of the tuple 9000:9000 is the port of the dev/admin host. After running the command, you can access the UM instance on "localhost:9000", using Enterprise Manager.
