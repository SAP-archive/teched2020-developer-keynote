# CHARITY

This is a small app that acts as a proxy in front of the SAP API Business Hub (API Hub) sandbox system. Because the app itself is small, we'll take the opportunity to explore different ways of running it, without having to worry too much about _what_ we're running. So here we'll explore running locally, in Docker, on Cloud Foundry (CF) and on Kubernetes (k8s) with Kyma.

## Overview

The context in which it runs is shown as the highlighted section of the whiteboard:

![whiteboard, with SANDBOX highlighted](whiteboard-sandbox.png)

Access to the API Hub sandbox system is protected; each and every call to it needs to have an API key specified in an HTTP header. That is what this app does - attach the API key to all requests during transit.

There are two APIs that are used on the sandbox system that the API Hub makes available. Both are SAP S/4HANA Cloud APIs: [Sales Order (A2X)](https://api.sap.com/api/API_SALES_ORDER_SRV/resource) and [Business Partner (A2X)](https://api.sap.com/api/API_BUSINESS_PARTNER/resource).

In the developer keynote, this app is running in the Kyma runtime, but you can run it locally, locally in a Docker container, and also in CF. This README will show you how to get this app running in all four environments so you can compare and contrast them.

> This entire procedure assumes you have cloned this repository to your own space on GitHub, and that you are therefore aware of the values for OWNER (your GitHub org or username) and REPOSITORY (where you've cloned this) throughout the rest of this document. All the examples (of output, and so on) will be given based on the home org and repository for this content, i.e. `sap-samples/teched2020-developer-keynote`.

There are two helper scripts in this directory that have been written to help you through the steps, they are:

- `d` for Docker related activities
- `k` for Kyma / Kubernetes (k8s) related activities

We'll refer to the use of these scripts throughout the steps. You can of course run the actual commands directly if you wish, instead.


## Prerequisites

1. [Configure Essential Local Development Tools](https://developers.sap.com/group.scp-local-tools.html)

2. If you haven't done so already (see the "Download and Installation" instructions in the repository's [main README](../README.md)), clone *your fork* of this this repository, like this:
    ```
    $ git clone https://github.com/OWNER/REPOSITORY
    ```

3. Modify the `d` script in this directory and change the OWNER and REPOSITORY values in the `tag` variable (towards the top of the file) to reflect your own GitHub org or username and repository name. This is what the line looks like *before* modification, so you know what you're looking for:

    ```
    tag=docker.pkg.github.com/OWNER/REPOSITORY/s4mock:latest
    ```

## Configuration

The API key is unique to you and is available in the [preferences section](https://api.sap.com/preferences) of the API Hub. You'll need to specify it in two places, one for the Kyma runtime (Kubernetes deployment) and one for the other environments.

1. Log on to the API Hub and grab your API key from the [preferences section](https://api.sap.com/preferences).

2. Replace `YOUR-API-KEY` in [`deployment.yaml`](deployment.yaml) with your API key - this is for the Kyma deployment

3. Replace `YOUR-API-KEY` in [`router/default-env.json`](router/default-env.json) with your API key - this is for the other environments

Note that you will see another environment variable `destinations` specified in both places - this is a quick way of defining simple destinations instead of setting them up at the subaccount or service instance level on SAP Cloud Platform. (The `destinations.json` file is an unused configuration file used when having a destination automatically defined on SAP Cloud Platform, and has been kept in this repo for reference.)

## Running the app

As mentioned earlier, you can run this app in a number of different contexts. It's useful to go through each of these contexts to gain some familiarity and also to understand what's similar and what's different.

> For everything that follows, the assumption is that you're in this directory (i.e. where this `README.md` file is) when invoking commands, unless otherwise explicitly stated.
