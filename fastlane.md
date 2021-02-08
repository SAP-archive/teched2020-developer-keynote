# Needed tools

- [Install CLI tooling](https://developers.sap.com/group.scp-local-tools.html)
- [Install Node.js-based tooling](https://developers.sap.com/tutorials/cp-cf-sapui5-local-setup.html)
- [Install ABAP Development Tools(ADT)](https://tools.hana.ondemand.com/#abap)


Local tools or App Studio?
1. Clone the repo

2. Login to CF org
    ```
    cf login -a https://api.cf.eu10.hana.ondemand.com
    ```

2. Access the [SAP API Business Hub](https://api.sap.com/preferences) and copy your API Key. It will look similar to this one:
uqrg...

4. Deploy the sandbox
    ```
    cd s4hana/sandbox
    mbt build
    cf deploy mta_archives/s4-mock_1.0.0.mtar 
    cf set-env proxyapp API_KEY uqrg...
    cf restage proxyapp 
    ```
    => Save the URL to use it later in step 6.
    

5. Deploy the converter service
    ```
    cd ../../converter
    cf push converter --random-route 
    ```
    => Save the URL to use it later in step 6.



6. Deploy the brain component

    Add the saved URLs from the previous two steps to `cap/brain/destinations.json`. You can also run `cf apps` in case you didn't save the URL of the apps.


    install sqlite3 in prod deps
    ```
    cd ../cap/brain/
    mbt build
    cf deploy mta_archives/developer-keynote-brain_1.0.0.mtar 
    ```


6. Deploy to Steampunk + create destination
  
   Install abapGit in ABAP Development Tools(ADT), import the ABAP objects and activate them.
   
   Create HTTP Service object, and point it to the handler class ZCL_CDC_REST_SERVICE
   
   Grab the service URL from the service binding Z_UI_C_CSTDONCREDITS_R and save the URL to use it later in step 8.
   

8. Deploy the frontend

    Add the saved URLs from the previous step to `ui/destinations.json`.

    ```
    cd ../ui
    mbt build
    cf deploy mta_archives/developer-keynote-dashboard_1.0.0.mtar
    cf html5-list -d -u 
    ```

    Access the printed URL. The URL should follow this pattern `https://<subaccount-id>.launchpad.cfapps.eu10.hana.ondemand.com/developerkeynote.dashboard`.


9. Run the emitter
   > @DJ I think I need your help here

