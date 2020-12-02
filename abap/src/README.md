# CHARITY

This component of the application has two responsibilities....

## Overview

The context in which it runs is shown as the highlighted section of the whiteboard:

![whiteboard, with SANDBOX highlighted](whiteboard-sandbox.png)

Cover the HTTP handler, and the RAP object here


## Prerequisites

* You have downloaded and installed ABAP Development Tools (ADT). Make sure to use the most recent version as indicated on the installation page.
* You have created an ABAP Cloud Project in ADT that allows you to access your SAP Cloud Platform ABAP Environment instance (see here for additional information). Your log-on language is English.
* You have installed the abapGit plug-in for ADT from the update site http://eclipse.abapgit.org/updatesite/.

## Installation & Configuration

Once you have installed the abapGit plug-in for ADT, you can now clone this repo to your ABAP system and create the required ABAP Objects.  

Currently abapGit does not handle the creation of the HTTP service, so you will need to create that manually and configure that service to point to the handler class ZCL_CDC_REST_SERVICE.

## Running the app

Now that all objects are activated, you can rest the RAP application by going to the service binding selecting the entity, and clicking the "Preview" button. 


