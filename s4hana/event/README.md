# EMITTER

This section relates to the SAP S/4HANA Cloud event that is used to kick off the whole process, and is represented by the "EMITTER" block in the whiteboard diagram.

![The Emitter in context](emitter.png)

It can be found in the [`s4hana/event/`](https://github.com/SAP-samples/teched2020-developer-keynote/tree/master/s4hana/event) directory of this repository.

## Overview

This component starts off the whole flow by emitting an event message to the "salesorder/created" topic on the instance of the Enterprise Messaging service.

It is a single Bash shell script `emit`, supported by two helper libraries:

- `localutils.sh` providing basic functions for logging, access token retrieval, and so on
- `settings.sh` providing the actual names of instances, plans and service keys

The Emitter uses the [Messaging API](https://help.sap.com/doc/3dfdf81b17b744ea921ce7ad464d1bd7/Cloud/en-US/messagingrest-api-spec.html) to publish a message to a topic on the bus provided by this project's Enterprise Messaging service instance. The specific API endpoint used is `POST /messagingrest/v1/topics/{topic-name}/messages`.

The API call is authenticated with OAuth 2.0, whereby an access token is retrieved using details in the `emdev` service instance's service key `sk1` - the specifics which are from the `settings` helper library.

## Requirements

The `emit` Bash script uses some external commands, none of which are obscure, but some of which you may need to explicitly install:

- `uuidgen` (often found in the `uuid-runtime` Linux package)
- `curl` (see [the `curl` home page](https://curl.haxx.se/))
- `cf` (see the [Install Guide](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html))
- `yq` (see [the `yq` home page](https://github.com/mikefarah/yq))
- `jq` (see [the `jq` home page](https://stedolan.github.io/jq/))

You'll also need your SAP Enterprise Messaging service instance, as mentioned in the [Message Bus section of the main repository README](../../README.md#message-bus) - follow the [instructions](../../messaging-setup.md) to get it set up if you haven't already.

These instructions assume you've forked this repository (see the [Download and Installation](../../README.md#download-and-installation) instructions) and cloned it locally.

## Usage

The Emitter (the `emit` script) is designed to be used from the command line, and expects a single parameter that is mandatory - the sales order number. This must be a sales order that exists in the Sandbox (S/4HANA mock system). Use your [SANDBOX component](../sandbox) to get a proxy running in front of the API Hub's mock service, and pick a valid sales order from the entityset. Assuming you go for a version of the proxy that you run [locally](../sandbox#locally), use the Sales Orders entityset at http://localhost:5000/sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$top=10 look for and pick a valid sales order number.

To use this Emitter:

1. Move into this `s4hana/event/` directory
1. Make sure you're logged into CF and connected to your organization and space where you have your message bus
1. Choose a sales order number (e.g. 1)
1. Call the Emitter: `./emit <salesordernumber>` (e.g. `./emit 1`)

Invoking the emitter should look like this - there will be a couple of log messages produced:

```
$ ./emit 1
2020-10-07 12:50:56 Publishing sales order created event for 1
2020-10-07 12:50:56 Publish message to topic salesorder%2Fcreated
```

> The `%2F` in the topic name is a URL encoded `/` which is required because the Messaging API endpoint uses the topic name in the URL path. We could have the `emit` script encode it, but that would mean an extra dependency on e.g. Python or [an npm package](https://www.npmjs.com/package/url-decode-encode-cli) for example, which is not worth it for this.
