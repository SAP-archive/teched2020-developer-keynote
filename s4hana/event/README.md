# EMITTER

**Contents**

- [Overview](#overview)
- [Requirements](#requirements)
- [Usage](#usage)

## Overview

This section relates to the SAP S/4HANA Cloud event that is used to kick off the whole process, and is represented by the "EMITTER" block in the whiteboard diagram.

![The EMITTER component in context](emitter.png)

It can be found in the [`s4hana/event/`](./) directory of this repository.

This component starts off the whole flow by emitting an event message to the "salesorder/created" topic on the instance of the Enterprise Messaging service.

It is a single Bash shell script `emit`, supported by two helper libraries:

- `localutils.sh` providing basic functions for logging, access token retrieval, and so on
- `settings.sh` providing the actual names of instances, plans and service keys

> `settings.sh` is actually a symbolic link to a shared file in the root of this repository.

The EMITTER component uses the [Messaging API](https://help.sap.com/doc/3dfdf81b17b744ea921ce7ad464d1bd7/Cloud/en-US/messagingrest-api-spec.html) to publish a message to a topic on the bus provided by this project's Enterprise Messaging service instance. The specific API endpoint used is `POST /messagingrest/v1/topics/{topic-name}/messages`.

The API call is authenticated with OAuth 2.0, whereby an access token is retrieved using facilities in the `localutils.sh` library and details in the `settings.sh` library.

## Requirements

The `emit` Bash script uses some external tools, none of which are obscure, but some of which you may need to explicitly install:

- `uuidgen` (often found in the `uuid-runtime` Linux package)
- `curl` (see [the `curl` home page](https://curl.haxx.se/))
- `cf` (see the [Install Guide](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html))
- `yq` (see [the `yq` home page](https://github.com/mikefarah/yq))
- `jq` (see [the `jq` home page](https://stedolan.github.io/jq/))

> If you are using the SAP Business Application Studio (App Studio) for your development environment, and have followed the [Using the SAP Business Application Studio](../../usingappstudio/) instructions, these tools will already be installed and ready for you to use (from the [Add tools to your Dev Space](../../usingappstudio/README.md#add-tools-to-your-dev-space) step).

You'll also need a message bus, in the form of an instance of the SAP Enterprise Messaging service. Follow the [Message bus setup](../../messagebus) instructions if you haven't done already.

These instructions assume you've forked this repository (see the [Download and Installation](../../README.md#download-and-installation) instructions) and cloned it locally.

## Usage

The component itself is the `emit` script in this directory. It's designed to be used from the command line, and expects a single parameter that is mandatory - the sales order number. In order for the end-to-end process to make sense and work properly, this must be a sales order that exists in the S/4HANA mock system. Use your [SANDBOX component](../sandbox) to get a proxy running in front of the API Hub's mock service for API_SALES_ORDER_SRV, and pick a valid sales order from the `A_SalesOrder` entityset. 

For example, if you are currently running a [local version of the proxy](../sandbox#locally), look at the first 10 sales orders in the entityset at

`http://localhost:5000/sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$top=10` 

and pick one of the sales order IDs from that list (get the value from the `SalesOrder` property).

To use this EMITTER component:

1. Make sure you're in this `s4hana/event/` directory
1. Make sure you're logged into CF and connected to your organization and space where you have your message bus
1. Choose a sales order number as described above (e.g. 1)
1. Call the script, passing that sales order number (e.g. `./emit 1`)

> Before making the call to the `emit` script, you may also want to remove any existing `sk*.json` file, which may contain stale service key information - it will be regenerated when you call `emit`.

These steps should look like this - there will be a couple of log messages produced if successful:

```
user: teched2020-developer-keynote $ cd s4hana/event/
user: event $ ./emit 1
user: event $ cf login
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

API endpoint:   https://api.cf.eu10.hana.ondemand.com (API version: 3.91.0)
User:           sapdeveloper@example.com
Org:            14ee89fftrial
Space:          dev
user: event $ rm sk-emdev-sk1.json
user: event $ ./emit 1
2020-12-31 11:25:22 Publishing sales order created event for 1
2020-12-31 11:25:22 Publish message to topic salesorder%2Fcreated
```

> The `%2F` in the topic name is a URL encoded `/` which is required because the Messaging API endpoint uses the topic name in the URL path. We could have the `emit` script encode it, but that would mean an extra dependency on e.g. Python or [an npm package](https://www.npmjs.com/package/url-decode-encode-cli) for example, which is not worth it for this.
