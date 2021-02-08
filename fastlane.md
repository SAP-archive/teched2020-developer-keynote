
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
    copy URL and create destination?
    

5. Deploy the converter service
    ```
    cd ../../converter
    cf push converter --random-route 
    ```

    copy URL and create destination?



6. Deploy the brain component

    > write destinations in some file
    install sqlite3 in prod deps
    ```
    cd ../cap/brain/
    add mta.yaml + destination +em.json
    mbt build
    cf deploy mta_archives/brain_1.0.0.mtar
    ```

    3. Create EM messageing
    ```
    cf create-service enterprise-messaging \
      dev \
      emdev \
      -c '{ "emname": "emdev", "options": { "management": true, "messagingrest": true } }'
    ```


6. Create ABAP + destination

8. Deploy the frontend
    ```
    cd ../ui
    mbt build
    cf deploy mta_archives/developer-keynote-dashboard_1.0.0.mtar
    ```

    Access <https://subaccount-id.launchpad.cfapps.eu10.hana.ondemand.com/developerkeynote.dashboard> (Substitute your subaccount ID here)


9. Run the emitter
    ```
    ```

