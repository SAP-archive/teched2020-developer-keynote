# Introduction

* Voice over introduction - what are we about to see
* describe business story
* describe our three developers on the team 

# Demo App End to End 

* Have one of the developers demo the complete end to end
* Show the system flow diagram - how best to present this without PowerPoint?
* Trigger event in S/4, show the data impacting the dashboard
* Now lets see how the event flows through all the services 

# S/4 Mock

* Tell event story
* Show Sales Order API in API Hub
* Talk about On Prem vs. Cloud API
* App Router to Sandbox on the API Hub 
  * Mock the Event by running the script
  * Show Enterprise Messaging Dashboard
* Why use the App Router - talk about injecting the API key into all service calls automatically

# CAP 

* How is the CAP service configured to use Enterprise Messaging and other services (package.json)
* Eventing Configuration  in package.json
* Then to coding of the event processor in JavaScript
* SELECT to call S/4 Service - removes all the technical details of calling a remote service and translates it to what developers already know - a SELECT statement
* Call a REST Service - one line of code - similiar to S/4 Call

# GO service

* Existing Cloud Native Service
* Little overview of the Go code but it isn't the main story here
* Docker - explain
* Deployment 
* Value of Kyma
  * Side Car 
  * Auto Scaling 
  * Auto restart

# Back to CAP (Briefly)

* Enrich the original Business Object from S/4 with custom logic and then pass that along to ABAP
* But not a direct call to ABAP but instead raising custom message on Enterprise Messaging - loosely couple these two services

# ABAP

* Start in Enterprise Message and show configuration of Web Hook
* Then the HTTP handler implementation of the Web Hook to accept the message
* RAP portion - we don't duplicate any data beyond the keys of the original S/4 Business Object - Only process and persist the extension specific data and logic
* Virtual Element
  * Generated Proxy for S/4 API - very similiar to what CAP gave us earlier but for ABAP developers
* OData service directly generated from RAP View

# UI

* Service consumption
* Destinations
* Serverless deployment


