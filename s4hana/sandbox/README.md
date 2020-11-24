# Mock Router

This is a small app that acts as a proxy in front of the SAP API Business Hub (API Hub) sandbox system.

## Overview

The context in which it runs is shown as the highlighted section of the whiteboard:

![whiteboard, with SANDBOX highlighted](whiteboard-sandbox.png)

Access to the API Hub sandbox system is protected; each and every call to it needs to have an API key specified in an HTTP header. That is what this app does - attach the API key to all requests during transit.

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

2. Replace `YOUR-API-KEY` in [`deployment.yaml`](deployment.yaml) with your API key - this is for the Kyma deployment

3. Replace `YOUR-API-KEY` in [`router/default-env.json`](router/default-env.json) with your API key - this is for the other environments

Note that you will see another environment variable `destinations` specified in both places - this is a quick way of defining simple destinations instead of setting them up at the subaccount or service instance level on SAP Cloud Platform. (The `destinations.json` file is an unused configuration file used when having a destination automatically defined on SAP Cloud Platform, and has been kept in this repo for reference.)

## Running the app

As mentioned earlier, you can run this app in a number of different contexts. It's useful to go through each of these contexts to gain some familiarity and also to understand what's similar and what's different.

### Locally

You can run the app locally. Try this first. After moving to the app's directory (`router/`), install the module dependencies, and then start the app up:

```
$ cd router/
$ npm install
$ npm start
```

> Here, and elsewhere - the shell prompt is indicated with a `$` symbol.

You should see log output similar to this:

```
approuter@ start /Users/username/Projects/teched2020-developer-keynote/s4hana/sandbox/router
> node index.js

#2.0#2020 11 23 16:38:43:371#+00:00#WARNING#/LoggingLibrary################PLAIN##Dynamic log level switching not available#
#2.0#2020 11 23 16:38:43:585#+00:00#INFO#/approuter#####khuryg01##########khuryg01#PLAIN##Application router version 8.5.5#
#2.0#2020 11 23 16:38:43:589#+00:00#INFO#/Configuration#####khuryg05##########khuryg05#PLAIN##No COOKIES environment variable#
#2.0#2020 11 23 16:38:43:592#+00:00#WARNING#/Configuration#####khuryg08##########khuryg08#PLAIN##No authentication will be used when accessing backends. Scopes defined in routes will be ignored.#
#2.0#2020 11 23 16:38:43:592#+00:00#INFO#/Configuration#####khuryg08##########khuryg08#PLAIN##xs-app.json: Application does not have directory for static resources!#
#2.0#2020 11 23 16:38:43:593#+00:00#INFO#/Configuration#####khuryg08##########khuryg08#PLAIN##Replacing $XSAPPNAME will not take place - 'xsappname' property not found in UAA configuration.#
#2.0#2020 11 23 16:38:43:606#+00:00#INFO#/approuter#####khuryg01##########khuryg01#PLAIN##Application router is listening on port: 5000#
```

At this point, the app is running and listening for requests on the local loopback interface (`localhost`, or 127.0.0.1) on port 5000. To test it, try to access the `API_SALES_ORDER_SRV`'s service document at this address: http://localhost:5000/sap/opu/odata/sap/API_SALES_ORDER_SRV/. You should see the service document served to you.


### Locally in a Docker container

If you have Docker installed on your machine, you can also run this in a Docker container. You'll need to create a Docker image of this app if you want to deploy it to the Kyma runtime anyway, so now's a good time to set that image up and fire up a container based on that image to test it.

There is already a [`Dockerfile`](Dockerfile) contained in this directory that will inform the Docker image build process, and you can build the image with an invocation similar to this:

```
$ docker build -t <TAG> -f <DOCKERFILE> router/
```

This has been wrapped into a script along with other Docker related actions that you'll need. The script, also in this directory, is called `d` and you can see the actions that it supports by invoking it with no arguments:

```
$ ./d
Usage: d <action>
where <action> is one of:
- login: login to GitHub Packages
- build: create the Docker image
- run: run a container locally based on the image
- publish: publish the image to GitHub
```

The container you are going to run is based on an image defined in the `Dockerfile` file, and the image must be built first. So invoke the `d` script with the "build" action. Here's the invocation, and the sort of output that you should see:

```
$ ./d build
Building image for router
[+] Building 4.0s (10/10) FINISHED
=> [internal] load .dockerignore
=> transferring context: 2B
=> [internal] load build definition from Dockerfile
=> transferring dockerfile: 37B
=> [internal] load metadata for docker.io/library/node:12.18.1
=> [1/5] FROM docker.io/library/node:12.18.1@sha256:2b85f4981f92ee034b51a3c8bb22dbb451d650d5c12b6439a169f8adc750e4b6
=> [internal] load build context
=> transferring context: 1.04MB
=> CACHED [2/5] WORKDIR /usr/src/app
=> CACHED [3/5] COPY /package*.json ./
=> CACHED [4/5] RUN npm install
=> [5/5] COPY /. .
=> exporting to image
=> exporting layers
=> writing image sha256:2a53e4da22f1fda40a69db1e1c7a46caa1b22ac960beddc811e29fdec2785499
=> naming to docker.pkg.github.com/sap-samples/teched2020-developer-keynote/s4mock:latest
```

You can check the image that has just been created, like this:

```
$ docker image ls
REPOSITORY                                                              TAG                 IMAGE ID            CREATED             SIZE
docker.pkg.github.com/sap-samples/teched2020-developer-keynote/s4mock   latest              2a53e4da22f1        9 minutes ago       994MB
...
```

Now the image exists, you can instantiate a container from it. Do this by using the "run" action with the `d` script.

```
$ ./d run
Running detached instance of image locally
61538774a32d66eaa5e28ad721389ca1378cb1d485ca6f4d19cdf33a07d423a2
```

Note that the invocation includes the `-d` switch to tell Docker to run the image in "detached" (i.e. background) mode - in which case just the container ID is printed. But the container is running, and inside it, the same Node process as before is running. The `-p` switch (inspect the source code of the [`d`](d) script to check) exposes the port 5000 to the host (i.e. your machine) so you can connect to the service as if it was running directly locally, as before. Check that you can access the `API_SALES_ORDER_SRV`'s service document again, at this same address: http://localhost:5000/sap/opu/odata/sap/API_SALES_ORDER_SRV/. You should see the service document served to you again, but this time, via the proxy app running inside the container.

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
