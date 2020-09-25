# Mock Router

This mock application redirects all incoming traffic to the SAP API Business Hub sandbox system. The application router will attach the required API key to all requests during transit.

## Prerequisites

1. [Configure Essential Local Development Tools](https://developers.sap.com/group.scp-local-tools.html)
2. Clone this repository
    ```
    git clone https://github.com/SAP-samples/teched2020-developer-keynote
    ```

## Configuration

1. Create a destination in the SAP Cloud Platform cockpit with the following configuration:
    ![Destination](destination.png)
    
    Additional properties are:
    
    ```
    HTML5.DynamicDestination: true
    WebIDEEnabled: true
    WebIDEUsage: apihub_sandbox
    ```

2. Get your API key from [SAP API Business Hub](https://api.sap.com) and copy the value.
3. Insert the value in the `API_KEY` property in `default-env.json`.

If needed, you can also adjust parameters such as the timeout for all redirects.

## Deployment

1. Build the project
    ```
    mbt build
    ```
2. Deploy
    ```
    cf deploy mta_archives/s4-mock_1.0.0.mtar
    ```
3. Access <https://YOUR-APP.hana.ondemand.com/sap/opu/odata/sap/API_SALES_ORDER_SRV/$metadata> to see that in action.

## Local run 

You can also run the application router locally for testing purposes. To do this, change 

Change in `default-env.json`:
```
  "destinations": [ 
    {
      "name": "apihub_sandbox",
      "url": "https://sandbox.api.sap.com"
    }
  ]
```
