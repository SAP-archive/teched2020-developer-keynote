# SAP Enterprise Messaging - Setup

To get a a message bus component of your own, as shown in the whiteboard diagram, follow these instructions to set up an instance of the SAP Enterprise Messaging service in your trial account.

![Whiteboard diagram](images/whiteboard.jpg)

You can set up an instance of the SAP Enterprise Messaging service (specifically a 'dev' plan instance) in one of two ways:

- [Using the SAP Cloud Platform Cockpit](#using-the-cockpit)
- [Using a script](#using-a-script)

Whatever way you choose, the name of the instance should be the same - please use "emdev", and you should ensure that specific instance parameters are specified during creation. These instance parameters are in JSON format and are as follows:

```json
{
  "emname": "emdev",
  "options": {
    "management": true,
    "messagingrest": true
  }
}
```

For consistency throughout this repository, please also use "emdev" as the name of the instance you create.


## Using the cockpit

You can set up an instance of the SAP Enterprise Messaging service (a 'dev' plan instance) in your trial account using the SAP Cloud Platform Cockpit using the Create Instance button shown in this screenshot.

![the Create Instance button](images/messaging-dev-plan.png)

Be sure to specify the name "emdev" as the name of the instance, and use the JSON above for the instance parameters when asked - you can see where in this screenshot:

![specifying instance parameters](images/instance-parameters.png)

## Using a script

If you prefer to set things up from the command line, you can do so. An environment available to us all is provided by the SAP Business Application Studio (App Studio), to which you'll now have access since setting up your trial account (see the link on your [trial home page](https://account.hanatrial.ondemand.com/trial/#/home/trial)). These instructions assume you want to use the command line in the App Studio.

Once you've set up a dev space in the App Studio, check out the [Cloud - Messaging - Hands-on SAP Dev](https://github.com/SAP-samples/cloud-messaging-handsonsapdev) repository. This repository has all sorts of scripts for interacting with the Management and Messaging APIs of SAP Enterprise Messaging, and also contains a simple [`service-setup`](https://github.com/SAP-samples/cloud-messaging-handsonsapdev/blob/main/service-setup) script.

If you want to use this in your App Studio dev space, first follow the instructions in the repository's README section titled [Using the SAP Business Application Studio](https://github.com/SAP-samples/cloud-messaging-handsonsapdev#using-the-sap-business-application-studio), then you'll be ready to run that script from there.

You can also invoke the `cf create-service` command directly, but be sure to specify the appropriate values - the same ones that the [`service-setup`](https://github.com/SAP-samples/cloud-messaging-handsonsapdev/blob/main/service-setup) script uses. Here's what you'd need to do:

```sh
cf create-service enterprise-messaging \
  dev \
  emdev \
  -c '{ "emname": "emdev", "options": { "management": true, "messagingrest": true } }'
```

