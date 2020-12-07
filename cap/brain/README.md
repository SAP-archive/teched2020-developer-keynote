# BRAIN

This section relates to BRAIN component, the service that coordinates the event messages, subscribes to the "salesorder/created" topic, and publishes event messages to the "Internal/Charityfund/Increased" topic, and is represented by the "BRAIN" block in the whiteboard diagram.

![The Brain in context](brain.png)

## Overview

The brain is a basic CAP application with two of the three layers in use. In effect, a "service" more than an application:

|Layer|Description|
|-|-|
|`app`|Unused|
|`srv`|A single service `teched` is defined exposing an entity `CharityEntry`. Custom JavaScript code for managing the Brain's operations and activities|
|`db`|An entity `CharityEntry` is defined with a `SoldToParty` property as key, and a counter property. This entity is defined within the namespace `charity`|

The service, once deployed, does not require any human intervention to function. Processing follows a sequence of the following activities, each time an event published to the "salesorder/created" topic on the message bus is received; each activity is denoted by a "level" number (1 through 4):

1. Log the message details
1. Retrieve sales order header details from the OData service `API_SALES_ORDER_SRV` proxied by the SANDBOX component
1. Request a conversion of the total net amount of the sales order to the equivalent in charity fund credits, by calling the CONVERTER component\*
1. Publish a new event to the "Internal/Charityfund/Increased" topic

_\*This is as long as sold-to party is one that hasn't already been processed 10 times before_

## Controlling the processing

To aid testing and gradual component deployment (getting all components up and running and connected), an enhancement has been made since the Developer Keynote presentation to allow the control of these activities using an environment variable `BRAIN_LEVEL`.

Setting this to 0 will mean that none of the above activities are carried out. Setting this to a value equivalent to one of the activity numbers (i.e. 1, 2, 3 or 4) will mean that activities up to and including that number will be carried out. The default value (if none is set explicitly) is 1, meaning the received event message will be logged, and that's all.


## Remote services defined and used

In carrying out the activities listed above, the CAP service consumes the following services which are defined in `package.json`. Some of these employ destinations defined in the cloud (on CF - see below):

|Name|Kind|Details|
|-|-|-|
|`messaging`|`enterprise-messaging`|Connection to the message bus|
|`db`|`sqlite`|Local persistence|
|`S4SalesOrders`|`odata`|Connection to the API Hub sandbox (SAP S/4HANA Cloud mock system) OData service. Destination `apihub_mock_salesorders`|
|`ConversionService`|`rest`|Connection to the Converter (Go microservice) conversion service. Destination `charityfund_converter`|

## Setup required

You'll need to set a few things up in preparation for getting this component up and running. These instructions assume you've cloned your forked copy of this repository, as described in the [Download and installation section](../../README.md#download-and-installation) of the main repository README.

### Destinations

As mentioned above, there are some destinations at play here, destinations that point to the `S4SalesOrders` and `ConversionService` endpoints. Set those up now, following the [Destinations setup](destinations.md) instructions.

### Local service setup

The best way to get this component up and running is to start locally. So now is a good point to set things up for local execution. This is a CAP based service, which relies on certain NPM modules (see the `dependencies` and `devDependencies` nodes in [`package.json`](package.json) and a local SQLite-powered persistence layer (see the `cds -> requires -> db` node in the same file).

In this (`cap/brain/`) directory, first get the modules installed by running `npm install`. This is the sort of thing you should see:

```
$ npm install

> @sap/hana-client@2.6.54 install /private/tmp/teched2020-developer-keynote/cap/brain/node_modules/@sap/hana-client
> node checkbuild.js

> sqlite3@4.2.0 install /private/tmp/teched2020-developer-keynote/cap/brain/node_modules/sqlite3
> node-pre-gyp install --fallback-to-build

node-pre-gyp WARN Using needle for node-pre-gyp https download
[sqlite3] Success: "/private/tmp/teched2020-developer-keynote/cap/brain/node_modules/sqlite3/lib/binding/node-v72-darwin-x64/node_sqlite3.node" is installed via remote

> @sap-cloud-sdk/core@1.28.1 postinstall /private/tmp/teched2020-developer-keynote/cap/brain/node_modules/@sap-cloud-sdk/core
> node usage-analytics.js

added 224 packages from 153 contributors and audited 224 packages in 6.956s

4 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

Now run `cds deploy` to cause the persistence layer artifact (the SQLite database file) to be summoned into existence (note that there are a few test records in the CSV file):

```
$ cds deploy
 > filling charity.CharityEntry from db/csv/charity-CharityEntry.csv
/> successfully deployed to ./brain.db
```

At this stage you're ready to embark upon running this component locally.


## Running it

In a similar way to the [SANDBOX](../../s4hana/sandbox) component, you can get this component up and running at different levels - locally, on CF and on Kyma.


### Locally

It's straightforward to run CAP applications and services locally, but when they consume to cloud-based services, connection and credential information is required, and for local execution, this information is traditionally stored in a file called `default-env.json`.

Because of what this contains, it is not normally included in any repository for security reasons, so you should [generate this yourself now](default-env-gen.md).

At this point, you can start the service running locally with `cds run`, shown here with typical output (with some lines removed for readability):

```
$ cds run

[cds] - model loaded from 3 file(s):

  db/schema.cds
  srv/service.cds
  srv/external/API_SALES_ORDER_SRV.csn

[cds] - connect to db > sqlite { database: 'brain.db' }
[cds] - connect to messaging > enterprise-messaging {
  management: [
    {
      oa2: {
        clientid: 'sb-clone-xbem-service-broker-aec3bfac91f84d61841ef28efb7fa235-clone!b68527|xbem-service-broker-!b2436'
      },
      uri: 'https://enterprise-messaging-hub-backend.cfapps.eu10.hana.ondemand.com'
    }
  ],
  messaging: [
    {
      broker: { type: 'sapmgw' },
      oa2: {
        client: 'sb-clone-xbem-service-broker-aec3bfac91f84d61841ef28efb7fa235-clone!b68527|xbem-service-broker-!b2436'
      },
      protocol: [ 'amqp10ws' ],
      uri: 'wss://enterprise-messaging-messaging-gateway.cfapps.eu10.hana.ondemand.com/protocols/amqp10ws'
    },
    {
      broker: { type: 'sapmgw' },
      oa2: {
        clientid: 'sb-clone-xbem-service-broker-aec3bfac91f84d61841ef28efb7fa235-clone!b68527|xbem-service-broker-!b2436'
      },
      protocol: [ 'mqtt311ws' ],
      uri: 'wss://enterprise-messaging-messaging-gateway.cfapps.eu10.hana.ondemand.com/protocols/mqtt311ws'
    },
    {
      broker: { type: 'saprestmgw' },
      oa2: {
        clientid: 'sb-clone-xbem-service-broker-aec3bfac91f84d61841ef28efb7fa235-clone!b68527|xbem-service-broker-!b2436'
      },
      protocol: [ 'httprest' ],
      uri: 'https://enterprise-messaging-pubsub.cfapps.eu10.hana.ondemand.com'
    }
  ],
  serviceinstanceid: 'aec3bfac-91f8-4d61-841e-f28efb7fa235',
  xsappname: 'clone-xbem-service-broker-aec3bfac91f84d61841ef28efb7fa235-clone!b68527|xbem-service-broker-!b2436'
}
BRAIN_LEVEL set to 1
[cds] - Put queue { queue: 'CAP/0000' }
[cds] - serving API_SALES_ORDER_SRV { at: '/api-sales-order-srv' }
[cds] - serving teched { at: '/teched', impl: 'srv/service.js' }

[cds] - launched in: 1258.575ms
[cds] - server listening on { url: 'http://localhost:4004' }
[ terminate with ^C ]

[cds] - Add subscription { topic: 'salesorder/created', queue: 'CAP/0000' }
```

In that output, observe how the CAP messaging support automatically connects to the message bus (the instance of the SAP Enterprise Messaging service) and, in order to subscribe to the "salesorder/created" topic, creates a queue "CAP/0000" and a queue subscription, connecting that "CAP/0000" queue to the "salesorder/created" topic:

```
[cds] - Put queue { queue: 'CAP/0000' }
...
[cds] - Add subscription { topic: 'salesorder/created', queue: 'CAP/0000' }
```

> See the [Diving into messaging on SAP Cloud Platform](https://www.youtube.com/playlist?list=PL6RpkC85SLQCf--P9o7DtfjEcucimapUf) series on the SAP Developers YouTube channel for explainations of how queues, topics and queue subscriptions work, and plenty more besides.

Observe also this message:

```
BRAIN_LEVEL set to 1
```

This is directly related to the activity level described earlier in the [Controlling the process](#controlling-the-process) section, and the value of 1 (for logging the message details only) is the default value.

**Testing BRAIN_LEVEL 1**

At this point, you should leave this CAP service running, and (say, in a new terminal window) jump over to your [EMITTER](../../s4hana/event) component, set that up (if you haven't got it set up already) and emit a "salesorder/created" event message. Look in particular at the [Usage](../../s4hana/event/README.md#usage) section for hints on how to do this. Emit an event message for a sales order (e.g. 1) - the invocation and output should look something like this:

```
$ ./emit 1
2020-12-07 13:48:59 Publishing sales order created event for 1
2020-12-07 13:48:59 Publish message to topic salesorder%2Fcreated
```

More importantly, if you look back at the log output of your BRAIN component, you should see some extra log output, similar to this:

```
Message received {"_events":{},"_eventsCount":0,"_":{"event":"salesorder/created","data":{"SalesOrder":"1"},"headers":{"type":"sap.s4.beh.salesorder.v1.SalesOrder.Created.v1","specversion":"1.0","source":"/default/sap.s4.beh/DEVCLNT001","id":"ABFAF2F3-931F-49A8-86E8-876C295D9FAD","time":"2020-12-07T13:48:59Z","datacontenttype":"application/json"},"inbound":true},"event":"salesorder/created","data":{"SalesOrder":"1"},"headers":{"type":"sap.s4.beh.salesorder.v1.SalesOrder.Created.v1","specversion":"1.0","source":"/default/sap.s4.beh/DEVCLNT001","id":"ABFAF2F3-931F-49A8-86E8-876C295D9FAD","time":"2020-12-07T13:48:59Z","datacontenttype":"application/json"},"inbound":true}
```

This is the event message that the CAP service received from the message bus, because of its subscription to the "salesorder/created" topic. If we strip away the "Message received" text, it's JSON, and neatly formatted, we have:

```json
{
  "_events": {},
  "_eventsCount": 0,
  "_": {
    "event": "salesorder/created",
    "data": {
      "SalesOrder": "1"
    },
    "headers": {
      "type": "sap.s4.beh.salesorder.v1.SalesOrder.Created.v1",
      "specversion": "1.0",
      "source": "/default/sap.s4.beh/DEVCLNT001",
      "id": "ABFAF2F3-931F-49A8-86E8-876C295D9FAD",
      "time": "2020-12-07T13:48:59Z",
      "datacontenttype": "application/json"
    },
    "inbound": true
  },
  "event": "salesorder/created",
  "data": {
    "SalesOrder": "1"
  },
  "headers": {
    "type": "sap.s4.beh.salesorder.v1.SalesOrder.Created.v1",
    "specversion": "1.0",
    "source": "/default/sap.s4.beh/DEVCLNT001",
    "id": "ABFAF2F3-931F-49A8-86E8-876C295D9FAD",
    "time": "2020-12-07T13:48:59Z",
    "datacontenttype": "application/json"
  },
  "inbound": true
}
```

Nice!

**Testing BRAIN_LEVEL 2**

Depending on how far you've got with the setup of the other components in this repository, specifically those two that this component interact with - the [SANDBOX](../../s4hana/sandbox) and the [CONVERTER](../../kyma) components - you may want to set the value for the `BRAIN_LEVEL` accordingly.

For example, if you've got the [SANDBOX](../../s4hana/sandbox) component set up (including a [destination](destinations.md) for it), you can increase the `BRAIN_LEVEL` to 2, to have the sales order header details retrieved from the OData service API_SALES_ORDER_SRV proxied by the that component.

This is how you'd do that - basically you can specify the value for `BRAIN_LEVEL`, while restarting the service, this time giving an explicit value for the variable, like this:

```sh
$ BRAIN_LEVEL=2 cds run
```

In the other terminal window, emitting another event message in the same way (`./emit 1`) should result in not only the logging of the event message received, but also the results of the sales order information retrieval described (in the [overview](#overview)) as what happens at BRAIN_LEVEL 2.

This is the sort of thing you should see (note the log output shown here starts with `BRAIN_LEVEL set to 2`):

```
BRAIN_LEVEL set to 2
[cds] - Put queue { queue: 'CAP/0000' }
[cds] - serving API_SALES_ORDER_SRV { at: '/api-sales-order-srv' }
[cds] - serving teched { at: '/teched', impl: 'srv/service.js' }

[cds] - launched in: 1419.140ms
[cds] - server listening on { url: 'http://localhost:4004' }
[ terminate with ^C ]

[cds] - Add subscription { topic: 'salesorder/created', queue: 'CAP/0000' }
Message received {"_events":{},"_eventsCount":0,"_":{"event":"salesorder/created","data":{"SalesOrder":"1"},"headers":{"type":"sap.s4.beh.salesorder.v1.SalesOrder.Created.v1","specversion":"1.0","source":"/default/sap.s4.beh/DEVCLNT001","id":"016BD60E-63A7-4FE4-BEC6-9C2D6D5CCD3C","time":"2020-12-07T13:58:40Z","datacontenttype":"application/json"},"inbound":true},"event":"salesorder/created","data":{"SalesOrder":"1"},"headers":{"type":"sap.s4.beh.salesorder.v1.SalesOrder.Created.v1","specversion":"1.0","source":"/default/sap.s4.beh/DEVCLNT001","id":"016BD60E-63A7-4FE4-BEC6-9C2D6D5CCD3C","time":"2020-12-07T13:58:40Z","datacontenttype":"application/json"},"inbound":true}
SalesOrder number is 1
[cds] - connect to S4SalesOrders > odata {
  destination: 'apihub_mock_salesorders',
  path: '/sap/opu/odata/sap/API_SALES_ORDER_SRV'
}
SalesOrder details retrieved {"SalesOrder":"1","SalesOrganization":"1710","SoldToParty":"17100001","CreationDate":"/Date(1471392000000)/","TotalNetAmount":"52.65"}
```

Observe that this time, not only is the event message logged ("Message received { ... }") but also a connection is made to the `S4SalesOrders` endpoint and header data is retrieved for the sales order number sent in the event message (1).









## On Kyma

The CAP service has been deployed to the default namesapce as app [`brain`](brain.c210ab1.kyma.shoot.live.k8s-hana.ondemand.com) and has bindings to the following service instances in that same space:

|Name|Service|
|-|-|
|`destination-lite`|Destination service instance with 'lite' plan, to enable the CAP service to access destinations|
|`emdev`|Enterprise Messaging service instance with 'dev' plan (note this is a deprecated plan but the only one available in trial)|
|`xsuaa-application`|Auth & Trust Management service instance with 'application' plan, to enable the CAP service to access the other instances|

Deployment was done using the following steps:
1. Create a secret for docker deployment from Github

``` shell
kubectl create secret docker-registry regcred --docker-server=https://docker.pkg.github.com --docker-username=<Github.com User> --docker-password=<Github password or token> --docker-email=<github email>
```

2. Create a file named secret.yaml and supply the VCAP_SERVICES for service bindings as such
``` yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: appconfigcap
data:
  VCAP_SERVICES: |
  { "content_here" }
```

3. Run [k8s_deploy](./k8s_deploy)

4. Return to the Kyma Console and the API Rules. You should see a new API Rule named brain and the URL for this endpoint.

## Local execution

A `default-env.json` file is available (not in the repo) for local execution. Run from the CAP service directory with `cds run`.
