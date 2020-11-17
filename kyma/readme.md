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

## Deployment to Kyma

1. Create a secret for docker deployment from Github

``` shell
kubectl create secret docker-registry regcred --docker-server=https://docker.pkg.github.com --docker-username=<Github.com User> --docker-password=<Github password or token> --docker-email=<github email>
```

2. Run k8s_deploy.sh

3. Return to the Kyma Console and the API Rules. You should see a new API Rule named calc-service and the URL for this endpoint.
