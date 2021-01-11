# Service instances setup

**Contents**
- [Overview](#overview)
- [Using the command line](#using-the-command-line)
  - [Destination service](#destination-service)
  - [Authorization & Trust Management service](#authorization--trust-management-service)
  
## Overview

In addition to the message bus provided by an instance of the SAP Enterprise Messaging service, the BRAIN component requires a couple of additional services, relating to the need to read destination definitions in your SAP Cloud Platform subaccount.

They can be set up easily from the command line in your App Studio's Dev Space, or in any other command line environment, providing that you've authenticated with and connected to your Cloud Foundry (CF) organization and space. They can also be set up using the SAP Cloud Platform Cockpit, which you can do yourself instead if you wish.

The naming convention for service instances used here is to combine the (short) service name and the plan name. You will see this in action in the `cf create-service` invocations coming up; remember that the invocation follows this pattern: `cf create-service <service name> <plan> <instance name>`.

## Using the command line

At the command line (start one up in your Dev Space by following the instructions in [Open up a terminal](../../usingappstudio#open-up-a-terminal), start by listing your existing service instances. You'll see something like this:

```
user: brain $ cf services
Getting services in org 14ee89fftrial / space dev as sapdeveloper@example.com...

name    service                plan   bound apps   last operation     broker                                                     
emdev   enterprise-messaging   dev                 create succeeded   sm-enterprise-messaging-service-broker-eeb...
```

> At this initial point, if you're not authenticated and connected to your CF organization and space, you'll be prompted to use `cf login` first.

### Destination service

Set up an instance of the Destination service like this:

```
user: brain $ cf create-service destination lite destination-lite
Creating service instance destination-lite in org 14ee89fftrial / space dev as sapdeveloper@example.com...
OK
```

### Authorization & Trust Management service

Set up an instance of the Authorization & Trust Management service (XSUAA) like this:

```
user: brain $ cf create-service xsuaa application xsuaa-application
Creating service instance xsuaa-application in org 14ee89fftrial / space dev as sapdeveloper@example.com...
OK
```

You can double check that you have these service instances now by re-invoking `cf services` (output shown is truncated for readability):

```
user: brain $ cf services
Getting services in org 14ee89fftrial / space dev as sapdeveloper@example.com...

name                service                plan          bound apps   last operation     broker                           
destination-lite    destination            lite                       create succeeded   sm-destination-service-broker-406
emdev               enterprise-messaging   dev                        create succeeded   sm-enterprise-messaging-service-b
xsuaa-application   xsuaa                  application                create succeeded   sm-xsuaa-9ef36350-f975-4194-a399-
```


