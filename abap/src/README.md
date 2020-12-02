# CHARITY

This is a small app that acts as a proxy in front of the SAP API Business Hub (API Hub) sandbox system. Because the app itself is small, we'll take the opportunity to explore different ways of running it, without having to worry too much about _what_ we're running. So here we'll explore running locally, in Docker, on Cloud Foundry (CF) and on Kubernetes (k8s) with Kyma.

## Overview

The context in which it runs is shown as the highlighted section of the whiteboard:

![whiteboard, with SANDBOX highlighted](whiteboard-sandbox.png)

Access to the API Hub sandbox system is protected; each and every call to it needs to have an API key specified in an HTTP header. That is what this app does - attach the API key to all requests during transit.



## Prerequisites

1. You will need to install ABAP Development Tools for Eclipse. For more information on this topic, please go [here](https://tools.hana.ondemand.com/#abap). If you already have ABAP Development Tools installed, please make sure that you have the latest version.   Also, we will leverage the SAP Cloud Platorm, ABAP Environment Trial system. Follow the directions outlined in this [tutorial](https://developers.sap.com/tutorials/abap-environment-trial-onboarding.html).



## Configuration

The API key is unique to you and is available in the [preferences section](https://api.sap.com/preferences) of the API Hub. You'll need to specify it in two places, one for the Kyma runtime (Kubernetes deployment) and one for the other environments.

1. Log on to the API Hub and grab your API key from the [preferences section](https://api.sap.com/preferences).


## Running the app


