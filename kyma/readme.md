The SAP Cloud Platform, Kyma Runtime deployed GoLang service is indicated by the "Converter(Go)" block in the [schematic](https://sap.sharepoint.com/:p:/r/sites/100499/_layouts/15/Doc.aspx?sourcedoc=%7B02231566-2A17-412E-8E59-5D0A34317F12%7D&file=Scratch.pptx&action=edit&mobileredirect=true) diagram.

It can be found [`kyma/`](https://github.com/SAP-samples/teched2020-developer-keynote/tree/main/kyma) directory in this repository.

# Overview
This is a simple GoLang based service build into a Docker Image and deployed to the SAP Cloud Platform, Kyma runtime.

## main.go
The [`main.go`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/main.go) file contains simple GoLang code which is responsible for the calculation of credit points. The calculation of these credit points is dependent on the incoming sales amount of the [`Brain (CAP service)`](https://github.com/SAP-samples/teched2020-developer-keynote/tree/main/cap/brain). The GoLang service extracts the sales amount through an URL parameter `salesAmount` which gets set by the CAP service through an exposed RESTful API. The RESTful API endpoint implemented in the `main.go` file is not secured through any authentication and is available publicly through the API Endpoint which gets created through the SAP Cloud Platform, Kyma Runtime APIRule defined in the [`Deployment.yaml`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/Deployment.yaml).

```yaml
apiVersion: gateway.kyma-project.io/v1alpha1
kind: APIRule
metadata:
  name: calc-service
spec:
  gateway: kyma-gateway.kyma-system.svc.cluster.local
  service:
    name: calc-service
    port: 3000
    host: calc-service
  rules:
    - path: /.*
      methods: ["GET"]
      accessStrategies:
        - handler: noop
          config: {}    

```

For further information review the [`main.go`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/main.go) file and it's code documentation.

## The Dockerfile and building a Docker Image
The Dockerfile as is doesn't need to be changed in order to dockerize the GoLang service for deployment. The Dockerfile can be simply build with the following command:

```cli
docker build --tag calcservice:1.0 .

```

Alternatively, the [`docker_build.sh`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/docker_build.sh) shell script can be run.

The dockerized service can then be deployed locally through the command line by executing:

```cli
docker run --publish 3000:3000 --detach --name calcservie calcservice:1.0

```

Alternatively, the [docker_run.sh](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/docker_run.sh) shell script can be run.


Detached mode `--detach` will tell Docker to run this container in the background.

The Docker Image is published to a Docker package registry on GitHub. For more information about the [GitHub Container Registry](https://docs.github.com/en/free-pro-team@latest/packages/getting-started-with-github-container-registry/about-github-container-registry) go to the official documentation.

To publish the Docker Image to the GitHub Container Registry run the [`docker_publish.sh`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/docker_publish.sh) shell script. The shell script is publishing the Docker Image to the TechEd 2020 Developer Keynote registry entry.

## Deployment to the SAP Cloud Platform, Kyma runtime

The SAP Cloud Platform, Kyma runtime is a Kubernetes based runtime which can be enabled through the SAP Cloud Platform and is available for trial. With the SAP Cloud Platform, Kyma runtime (following Kyma) you can deploy containerized applications and services to the runtime itself and manage these through the [Kubernetes-CLI](https://kubernetes.io/docs/reference/kubectl/) or the Kyma Console UI.

!![kyma-getting-started-12](https://user-images.githubusercontent.com/9074514/99500857-37deda00-297b-11eb-9da3-0fdf90b125c7.png)

In order to successfully deploy a containerized application or service to Kyma you need to create a [`deployment.yaml`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/Deployment.yaml) file where you specify the runtime variables for the container to run in. These variables range from:

- amount of replicas of the container
- name
- container Port
- resource limits e.g. memory or CPU
- location of the container
- API Rules for external exposure

As mentioned above, these deployment files follow the [YAML](https://yaml.org) syntax. If you want to read more about deploying to Kyma, please refer to the [`Write your deployment file`](https://kyma-project.io/docs/#details-deploy-with-a-private-docker-registry-write-your-deployment-file) documentation.

The deployment itself is pretty simple:

1. Create a secret for docker deployment from GitHub Container Registry.

``` shell
kubectl create secret docker-registry regcred --docker-server=https://docker.pkg.github.com --docker-username=<Github.com User> --docker-password=<Github password or token> --docker-email=<github email>
```

The secret is needed for Kyma to be able to authenticate against the GitHub Container Registry

2. Deploy to the Kyma runtime in three different ways:

In order to use your local CLI, you need to generate and download the `kubeconfig` file that allows you to access the cluster. For more information [kubectl](https://kyma-project.io/docs/master/components/security#details-access-kyma-kubectl) section in the Kyma documentation.

2.1 Run the k8s_deploy.sh

The easiest way for you to deploy to Kyma would be to run the `k8s_deploy.sh` shell script. The script uses `kubectl replace` which will initially deploy the ressource and if re-deployed just replace the current deployment.

2.2 Use kubectl

Instead of executing the `k8s_deploy.sh`, you can just execute the command youself:

```cli
kubectl replace --force -f deployment.yaml -n default
```

2.3 Use the Kyma Console UI

If you want to use the User Interface in order to deploy the service you can do this via the Kyma Console UI.



3. Return to the Kyma Console and the API Rules. You should see a new API Rule named calc-service and the URL for this endpoint.
