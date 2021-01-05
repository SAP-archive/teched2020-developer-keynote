# The SANDBOX component

**Contents**
- [Overview](#overview)
- [Notes](#notes)
- [Configuration](#configuration)
- [Running the app](#running-the-app)
  - [Locally](#locally)
  - [On SAP Cloud Platform - CF runtime](#on-sap-cloud-platform---cf-runtime)
    - [Using cf push](#using-cf-push)
    - [Using cf deploy](#using-cf-deploy)
  - [On SAP Cloud Platform - Kyma runtime](#on-sap-cloud-platform---kyma-runtime)
    - [Build & publish, secrets and deployment](#build--publish-secrets-and-deployment)
    - [Check the component is up and running](#check-the-component-is-up-and-running)
- [Summary](#summary)


## Overview

The SANDBOX component is a small app that acts as a proxy in front of the SAP API Business Hub (API Hub) sandbox system. Because the app itself is small, we'll take the opportunity to explore different ways of running it, without having to worry too much about _what_ we're running. So here we'll explore running locally, on Cloud Foundry (CF) and on Kubernetes (k8s) with Kyma. In the Developer Keynote, this app is running in the Kyma runtime.

> The contents of this README assume that you've opted to use the SAP Business Application Studio (App Studio) as your [development environment](../../README.md#a-development-environment) and have followed the [App Studio setup instructions](../../usingappstudio/).

The context in which it runs is shown as the highlighted section of the whiteboard:

![whiteboard, with SANDBOX highlighted](images/whiteboard-sandbox.png)

Access to the API Hub sandbox system is protected; each and every call to it needs to have an API key specified in an HTTP header. That is what this app does - attach the API key to all requests during transit.

There are two APIs that are used on the sandbox system that the API Hub makes available for our use in the context of the Developer Keynote. Both are SAP S/4HANA Cloud APIs: [Sales Order (A2X)](https://api.sap.com/api/API_SALES_ORDER_SRV/resource) and [Business Partner (A2X)](https://api.sap.com/api/API_BUSINESS_PARTNER/resource).

There are two helper scripts in this directory that have been written to help you through the Docker related steps (the [`d`](d) script) and the Kyma / k8s related steps (the [`k`](k) script), and you can use them depending on the development environment setup that you have. In the context of the App Studio as your development environment, while you can use the `k` script for the Kyma / k8s tasks, you'll perform the Docker tasks using GitHub Actions features related to your forked GitHub repository rather than the `d` script. See the [note on Docker and App Studio](../../usingappstudio/README.md#a-note-on-docker-and-app-studio) for more details.

## Notes

Note that everything in this README is relative to this README's location in the repository, i.e. the `s4hana/sandbox/` directory:

![relative location - the `s4hana/sandbox` directory](images/relative-location.png)

Command line invocations shown here should also be made in the App Studio. To get ready, [make sure you have a terminal open and ready](usingappstudio.md#open-up-a-terminal), this should present you with a Bash shell prompt, something like this:

![Bash shell prompt in a new Terminal session](images/shell-prompt.png)

At this prompt, **move to the `s4hana/sandbox/` directory now**, like this:

```
user: teched2020-developer-keynote $ cd s4hana/sandbox/
user: sandbox $
```

> Alternatively, you can open a Terminal directly at the `s4hana/sandbox/` directory location by using the context menu on the `sandbox` directory node in the App Studio's Explorer and selecting "Open in Terminal".

As you can see here from what's displayed, the information before the `$` prompt shows you your username in the Dev Space ("user") and the last component part of your directory location ("sandbox").


## Configuration

The API key is unique to you and is available in the [preferences section](https://api.sap.com/preferences) of the API Hub. You'll need to specify it in two places, one for the Kyma runtime (k8s deployment) and one for the other environments.

1. Log on to the API Hub and grab your API key from the [preferences section](https://api.sap.com/preferences).

2. Replace `YOUR-API-KEY` in [`deployment.yaml`](deployment.yaml) with your API key - this is for the Kyma deployment

3. Also replace `YOUR-API-KEY` in [`router/default-env.json`](router/default-env.json) with your API key - this is for the local & CF execution

> Pay attention to the differences in quoting between the YAML and JSON files - the API key in the YAML file goes in raw, but in the JSON file it must be within double quotes.

Note that while editing these configuration files, you'll see another environment variable `destinations` - this is a quick way of defining simple destinations instead of setting them up at the subaccount or service instance level on SAP Cloud Platform. (The `destinations.json` file is an unused configuration file used when having a destination automatically defined on SAP Cloud Platform, and has been kept in this repo for reference.)

## Running the app

As mentioned earlier, you can run this app in a number of different contexts. We'll start with running locally, then look at a deployment to CF, and finally Kyma / k8s.

### Locally

You can run the app locally. Try this first. Move to the app's directory (`router/`), install the module dependencies, and then start the app up. Like this:

```
user: sandbox $ cd router/
user: router $ npm install
user: router $ npm start
```

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

At this point, the app is running and listening for requests on port 5000. This is of course within the context of the App Studio's environment, which is not immediately available to you in your browser. So at this point, App Studio will pop up an "Expose and Open" message allowing you to have that port exposed to you.

![App Studio port message](images/port-message.png)

> App Studio will only show this popup once once - if you restart the app, use the "Ports: Preview" command in App Studio's Command Palette (menu item "View -> Find Command") to access the feature again.

Once you opt for the "Expose and Open" feature, a new browser tab should open and you should see the `API_SALES_ORDER_SRV`'s service document. This is, then, the Sales Order (A2X) API on the API Hub's sandbox system, reversed proxied by the app you're now running.

When you've finished trying out the app locally (end it with Ctrl-C), **make sure you move back up a directory** to where this `README.md` file is:

```
user: router $ cd ..
user: sandbox $
```


### On SAP Cloud Platform - CF runtime

During the Developer Keynote demo itself, this app is run in the cloud, on SAP Cloud Platform, and specifically in the Kyma runtime. But you can also run it in the CF runtime, and this section is in case you want to do that.

Because of the simplicity of the app and the fact that it doesn't depend on anything else, we can use the simple `cf push` approach. The alternative would be to use `cf deploy`, but that's more appropriate when you want to connect up the app to services that it requires too. There's a sample [`mta.yaml`](mta.yaml) deployment descriptor in this same directory, and [an example invocation below](#using-cf-deploy), if you want to explore that.

Before running the `cf push` command, make sure you're logged in and connected to your CF organization and space. Check what your CF API endpoint is from your SAP Cloud Platform Cockpit and issue the `cf login` command. The flow will look something like this (your API endpoint may be different):

```sh
user: sandbox $ cf login
API endpoint: https://api.cf.eu10.hana.ondemand.com

Email: sapdeveloper@example.com

Password:
Authenticating...
OK

Select an org:
1. 14ee89fftrial
2. ...

Org (enter to skip): 1
Targeted org 14ee89fftrial

Targeted space dev

API endpoint:   https://api.cf.eu10.hana.ondemand.com (API version: 3.88.0)
User:           sapdeveloper@example.com
Org:            14ee89fftrial
Space:          dev
$
```

#### Using cf push

Now you can make the `cf push` invocation. Specify a name for the app ("proxyapp") and include some options. Here's a copy-pasteable version, with explanations:

```
cf push \
  --random-route \
  -k 512M \
  -m 256M \
  -p router/ \
  proxyapp
```

|Option|Explanation|
|-|-|
|`--random-route`|request a random route so the app doesn't clash with any existing routes|
|`-k 512M`|The app should have 512M of disk space|
|`-m 256M`|The app should have 256M of memory|
|`-p router/`|The app is located in the `router/` directory|

Here's what the invocation looks like, and the sort of thing you should see (lots of output removed for readability):

```
user: sandbox $ cf push --random-route -k 512M -m 256M -p router/ proxyapp
Pushing app proxyapp to org 14ee89fftrial / space dev as sapdeveloper@example.com...
Getting app info...
Creating app with these attributes...
+ name:       proxyapp
  path:       /Users/username/Projects/teched2020-developer-keynote/s4hana/sandbox/router
  routes:
+   proxyapp-wise-gnu-hc.cfapps.eu10.hana.ondemand.com

Creating app proxyapp...
Mapping routes...
Comparing local files to remote cache...
Packaging files to upload...
Uploading files...
...
Staging app and tracing logs...
   Downloading uas_dataflow_server_buildpack...
   Downloading ruby_buildpack...
   ...
   Exit status 0
   Uploading droplet, build artifacts cache...
   ...
   Uploading complete
   Cell f0e91f7f-390f-4ac0-9c81-28a3ae3c58cb stopping instance 4a89654f-6605-437c-bc76-c6d1f9bf63a4
   Cell f0e91f7f-390f-4ac0-9c81-28a3ae3c58cb destroying container for instance 4a89654f-6605-437c-bc76-c6d1f9bf63a4
   Cell f0e91f7f-390f-4ac0-9c81-28a3ae3c58cb successfully destroyed container for instance 4a89654f-6605-437c-bc76-c6d1f9bf63a4

Waiting for app to start...

name:                proxyapp
requested state:     started
isolation segment:   trial
routes:              proxyapp-wise-gnu-hc.cfapps.eu10.hana.ondemand.com
last uploaded:       Tue 24 Nov 10:18:22 GMT 2020
stack:               cflinuxfs3
buildpacks:          nodejs

type:            web
instances:       1/1
memory usage:    1024M
start command:   npm start
     state     since                  cpu    memory          disk         details
#0   running   2020-12-23T13:50:21Z   0.0%   39.1K of 256M   8K of 512M
```

In the output, the route is shown, and you can check that you can access the `API_SALES_ORDER_SRV`'s service document again, at the URL relating to the route URL. In this case, it is:

`https://proxyapp-wise-gnu-hc.cfapps.eu10.hana.ondemand.com/sap/opu/odata/sap/API_SALES_ORDER_SRV/`

Your URL will be different, mostly because of the use of the `--random-route` switch. You should see the service document served to you again, but this time, via the proxy app running in the CF environment on SAP Cloud Platform.

#### Using cf deploy

In case you prefer the Multi Target Application (MTA) approach, there's an [`mta.yaml`](mta.yaml) file in this directory too, so you can use the build-and-deploy approach if you really want to, like this (a reduced sample output is also shown):

```
user: sandbox $ mbt build && cf deploy mta_archives/s4-mock_1.0.0.mtar
[2020-11-24 11:03:38]  INFO Cloud MTA Build Tool version 1.0.16
[2020-11-24 11:03:38]  INFO generating the "Makefile_20201124110338.mta" file...
[2020-11-24 11:03:38]  INFO done
[2020-11-24 11:03:38]  INFO executing the "make -f Makefile_20201124110338.mta p=cf mtar= strict=true mode=" command...
[2020-11-24 11:03:38]  INFO validating the MTA project
[2020-11-24 11:03:38]  INFO validating the MTA project
[2020-11-24 11:03:38]  INFO building the "proxyapp" module...
[2020-11-24 11:03:38]  INFO executing the "npm install --production" command...
...
[2020-11-24 11:03:41]  INFO finished building the "proxyapp" module
[2020-11-24 11:03:41]  INFO generating the metadata...
[2020-11-24 11:03:41]  INFO generating the "/Users/username/Projects/teched2020-developer-keynote/s4hana/sandbox/.sandbox_mta_build_tmp/META-INF/mtad.yaml" file...
[2020-11-24 11:03:41]  INFO generating the MTA archive...
[2020-11-24 11:03:41]  INFO the MTA archive generated at: /Users/username/Projects/teched2020-developer-keynote/s4hana/sandbox/mta_archives/s4-mock_1.0.0.mtar
[2020-11-24 11:03:41]  INFO cleaning temporary files...
...
Application "proxyapp" started and available at "14ee89fftrial-dev-proxyapp.cfapps.eu10.hana.ondemand.com"
Process finished.
```

> The `mbt` command will be automatically available to you in App Studio if you [set up your Dev Space as directed](../../usingappstudio/README.md#create-a-dev-space).

In this example, the `API_SALES_ORDER_SRV`'s service document would be available at:

`https://14ee89fftrial-dev-proxyapp.cfapps.eu10.hana.ondemand.com/sap/opu/odata/sap/API_SALES_ORDER_SRV/`


### On SAP Cloud Platform - Kyma runtime

This SANDBOX component has something in common with the [BRAIN](../../cap/brain/) and [CONVERTER](../../kyma/) components ... and that is that the Kyma runtime was where each of them was running in the actual [Developer Keynote](https://events.sapteched.com/widget/sap/sapteched2020/Catalog/session/1603314875989001AsWU). And the process for getting the component up and running in the Kyma runtime is the same each time. 

#### Build & publish, secrets and deployment

Because the process is common, you can find it described in a separate (and therefore shared) document - [Getting a component up and running on the Kyma runtime](../../kymaruntime/). Head on over to that document now, and follow the instructions, bearing in mind that you're building the SANDBOX component. Come back here when you're done.

#### Check the component is up and running

Just like before, you can check that the component has been successfully deployed and that it's now running on the Kyma runtime by requesting the API's service document. You'll need first to find out what the first part of the URL is.

Visit the Kyma console (get there from your trial subaccount overview page and use the "Link to dashboard" link), select the "default" namespace, and in the "Configuration > API Rules" section, you'll see the relevant URL:

![API Rules](images/api-rules.png)

Open up that URL. You'll noticed that you get redirected to `/sap/opu/odata/sap/API_SALES_ORDER_SRV/` - you should now see your old friend the API's service document.

## Summary

At this point, you should have your own SANDBOX component ("s4mock") built as a Docker image, stored in the GitHub Package Registry in the context of your forked repository, and that image deployed to the Kyma runtime on your SAP Cloud Platform trial account. Well done!
