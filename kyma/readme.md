## Deployment to Kyma

1. Create a secret for docker deployment from Github

``` shell
kubectl create secret docker-registry regcred --docker-server=https://docker.pkg.github.com --docker-username=<Github.com User> --docker-password=<Github password or token> --docker-email=<github email>
```

2. Run k8s_deploy.sh

3. Return to the Kyma Console and the API Rules. You should see a new API Rule named calc-service and the URL for this endpoint.
