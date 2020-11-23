# Mock Router

This is a small app that acts as a proxy in front of the SAP API Business Hub (API Hub) sandbox system.

## Overview

The context in which it runs is shown as the highlighted section of the whiteboard:

![whiteboard, with SANDBOX highlighted](whiteboard-sandbox.png)

Access to the API Hub sandbox system is protected; each and every call to it needs to have an API key specified in the HTTP header. That is what this app does - attach the API key to all requests during transit.

There are two APIs that are used on the sandbox system that the API Hub makes available. Both are SAP S/4HANA Cloud APIs: [Sales Order (A2X)](https://api.sap.com/api/API_SALES_ORDER_SRV/resource) and [Business Partner (A2X)](https://api.sap.com/api/API_BUSINESS_PARTNER/resource).

In the developer keynote, this app is running in the Kyma runtime, but you can run it locally, locally in a Docker container, and also in Cloud Foundry. This README will show you how to get this app running in all four environments so you can compare and contrast them.

## Prerequisites

1. [Configure Essential Local Development Tools](https://developers.sap.com/group.scp-local-tools.html)

2. Clone this repository
    ```
    git clone https://github.com/SAP-samples/teched2020-developer-keynote
    ```

## Configuration

The API key is unique to you and is available in the [preferences section](https://api.sap.com/preferences) of the API Hub. You'll need to specify it in two places, one for the Kyma runtime (Kubernetes deployment) and one for the other environments.

1. Log on to the API Hub and grab your API key from the [preferences section](https://api.sap.com/preferences).

2. Replace "YOUR-API-KEY" in [`deployment.yaml`](deployment.yaml) with your API key - this is for the Kyma deployment

3. Replace "YOUR-API-KEY" in [`router/default-env.json`](router/default-env.json) with your API key - this is for the other environments

Note that you will see another environment variable `destinations` defined in both places - this is a quick way of defining simple destinations instead of defining them at the subaccount or service instance level on SAP Cloud Platform.

## Running locally

You can run the app locally. Try this first. After moving to the app's directory, install the module dependencies, and then start the app up:

```
$ cd router/
$ npm install
$ npm start
```

You should see log output similar to this:

```
pprouter@ start /Users/i347491/Projects/teched2020-developer-keynote/s4hana/sandbox/router
> node index.js

#2.0#2020 11 23 16:38:43:371#+00:00#WARNING#/LoggingLibrary################PLAIN##Dynamic log level switching not available#
#2.0#2020 11 23 16:38:43:585#+00:00#INFO#/approuter#####khuryg01##########khuryg01#PLAIN##Application router version 8.5.5#
#2.0#2020 11 23 16:38:43:589#+00:00#INFO#/Configuration#####khuryg05##########khuryg05#PLAIN##No COOKIES environment variable#
#2.0#2020 11 23 16:38:43:592#+00:00#WARNING#/Configuration#####khuryg08##########khuryg08#PLAIN##No authentication will be used when accessing backends. Scopes defined in routes will be ignored.#
#2.0#2020 11 23 16:38:43:592#+00:00#INFO#/Configuration#####khuryg08##########khuryg08#PLAIN##xs-app.json: Application does not have directory for static resources!#
#2.0#2020 11 23 16:38:43:593#+00:00#INFO#/Configuration#####khuryg08##########khuryg08#PLAIN##Replacing $XSAPPNAME will not take place - 'xsappname' property not found in UAA configuration.#
#2.0#2020 11 23 16:38:43:606#+00:00#INFO#/approuter#####khuryg01##########khuryg01#PLAIN##Application router is listening on port: 5000#
```

At this point, the app is running and listening for requests on port 5000. To test it, try to access the `API_SALES_ORDER_SRV`'s service document at this address: http://localhost:5000/sap/opu/odata/sap/API_SALES_ORDER_SRV/. You should see the service document served to you.


## Deployment to Cloud Foundry

1. Build the project
    ```
    mbt build
    ```
2. Deploy
    ```
    cf deploy mta_archives/s4-mock_1.0.0.mtar
    ```
3. Access <https://YOUR-APP.hana.ondemand.com/sap/opu/odata/sap/API_SALES_ORDER_SRV/$metadata> to see that in action. Useful command:
    ```
    open `cf app s4-mock-router | awk '/^routes/ { print "https://"$2"/sap/opu/odata/sap/API_SALES_ORDER_SRV/" }'`
    ```

## Deployment to Kyma

1. Create a secret for docker deployment from Github

``` shell
kubectl create secret docker-registry regcred --docker-server=https://docker.pkg.github.com --docker-username=<Github.com User> --docker-password=<Github password or token> --docker-email=<github email>
```

2. Add your SAP API Hub API Key to the deployment.yaml file on line 6

3. Run k8s_deploy.sh

4. Return to the Kyma Console and the API Rules. You should see a new API Rule named s4mock and the URL for this endpoint. Add **/sap/opu/odata/sap/API_SALES_ORDER_SRV/$metadata** to this URL to test.
![API Rules](api.png)

## Local run

You can also run the application router locally for testing purposes. To do this, change

Change in `default-env.json`:
```
  "destinations": [
    {
      "name": "apihub_sandbox",
      "url": "https://sandbox.api.sap.com"
    }
  ]
```
