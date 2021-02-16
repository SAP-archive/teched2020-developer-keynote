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
    port: 8080
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
docker run --publish 8080:8080 --detach --name calcservie calcservice:1.0

```

Alternatively, the [docker_run.sh](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/docker_run.sh) shell script can be run.


Detached mode `--detach` will tell Docker to run this container in the background.

The Docker Image is published to a Docker package registry on GitHub. For more information about the [GitHub Container Registry](https://docs.github.com/en/free-pro-team@latest/packages/getting-started-with-github-container-registry/about-github-container-registry) go to the official documentation.

To publish the Docker Image to the GitHub Container Registry run the [`docker_publish.sh`](https://github.com/SAP-samples/teched2020-developer-keynote/blob/main/kyma/docker_publish.sh) shell script. The shell script is publishing the Docker Image to the TechEd 2020 Developer Keynote registry entry.

## Deployment to the SAP Cloud Platform, Kyma runtime

The SAP Cloud Platform, Kyma runtime is a Kubernetes based runtime which can be enabled through the SAP Cloud Platform and is available for trial. With the SAP Cloud Platform, Kyma runtime (following Kyma) you can deploy containerized applications and services to the runtime itself and manage these through the [Kubernetes-CLI](https://kubernetes.io/docs/reference/kubectl/) or the Kyma Console UI.

![Kyma_Console_UI](https://user-images.githubusercontent.com/9074514/99507827-2c43e100-2984-11eb-9036-2483243a3278.png)

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

   * Run the k8s_deploy.sh

   The easiest way for you to deploy to Kyma would be to run the `k8s_deploy.sh` shell script. The script uses `kubectl replace` which will initially deploy the  ressource and if re-deployed just replace the current deployment.

   * Use kubectl

   Instead of executing the `k8s_deploy.sh`, you can just execute the command youself:

  ```cli
  kubectl replace --force -f deployment.yaml -n default
  ```

   * Use the Kyma Console UI

   If you want to use the User Interface in order to deploy the service you can do this via the Kyma Console UI.

   |         |            |
   | ------------- |:-------------:|
   | ![Kyma_Console_UI_Deploy](https://user-images.githubusercontent.com/9074514/99509893-ac6b4600-2986-11eb-9389-feca1b21ada5.png) | ![Kyma_Console_UI_Deploy_2](https://user-images.githubusercontent.com/9074514/99509888-ab3a1900-2986-11eb-95b5-f4807bb4e612.png) |

3. Return to the Kyma Console UI

In the Kyma Console UI you can now see your new deployments, pods, the defined API Rule from the `deployment.yaml` and more.

**Deployment**

![Kyma_Console_UI_Deployment](https://user-images.githubusercontent.com/9074514/99512003-46cc8900-2989-11eb-840e-f836cf818e5f.png)

**Replica Set**

![Kyma_Console_UI_Replica_Set](https://user-images.githubusercontent.com/9074514/99512078-5b108600-2989-11eb-808c-97ae8e72254e.png)

**Changing the amount of Replicas**

In order to change the amount of replicas you can simply do this over the Kyma Console UI via the `Deployment` detail page. In there look for the service you want to change the replica amount for and click on the `...` and `Edit`. A popup with the service definition pops up where you can change the number from 1 to, for example 5.

![Kyma_Console_UI_Change_ReplicaSet](https://user-images.githubusercontent.com/9074514/99512339-a034b800-2989-11eb-8cfe-e1228acccedb.png)

You will see that Kyma recognizes the change and shows you `1/5` pods being started.

![Kyma_Console_UI_Change_ReplicaSet_2](https://user-images.githubusercontent.com/9074514/99512436-bd698680-2989-11eb-9afd-15617db3032d.png)

Navigate to the Pods and you will see that Kyma started up 4 new pods for the `calc-service` to run in.

![Kyma_Console_UI_Change_ReplicaSet_3](https://user-images.githubusercontent.com/9074514/99512513-d7a36480-2989-11eb-9df8-43fe9e4a5a4b.png)

Going to the Replica Set section you can see that in the meantime 5 of 5 replica sets should be running in your cluster.

![Kyma_Console_UI_Change_ReplicaSet_4](https://user-images.githubusercontent.com/9074514/99512591-f0ac1580-2989-11eb-8ecd-1a6d169fe54d.png)

If you navigate out of your namespace and into the `Diagnostics/Logs` you can see that Kyma took the changes and started up more replicas of the service on `Port 8080`. With this you can simply scale your application or service at anytime.

![Kyma_Console_UI_Change_ReplicaSet_5](https://user-images.githubusercontent.com/9074514/99512756-205b1d80-298a-11eb-9c30-230ab52528be.png)

Even if you want to reduce the amount of replica sets you can do this at any time the same way as you would increase the amount. Kyma will make sure to reduce the amount of replica sets and so the amount of running pods to the specified amount with zero downtime of your service. In order for Kyma to do that it utilizes the Service Mesh provided by Istio. With Istio it allows Kyma to enable you to define certain rules to enforce secure pod injection at any time. To read more about Kyma's Service Mesh and Istio visit the [Service Mesh - Overview](https://kyma-project.io/docs/components/service-mesh) documentation.

## Calling the Calculation Service

The calculation service in this project is used as charity fund converter which can be called to convert a sales amount to charity credits. If you have successfully deployed the calculation service to the SAP Cloud Platform, Kyma runtime it will be exposed via an API Rule. The API rule defines the path over which the service can be reached.

![kyma_api_rule](https://user-images.githubusercontent.com/9074514/101039448-23563080-357c-11eb-9483-6e54f1d30485.png)

To request a conversion use the path ``` /conversion ```, e.g. ``` /conversion?salesAmount=100 ```. The calculation service will then respond with a JSON response the calculated charity credits.
