# Local run

- Install deps `npm install` 
- Run Approuter `npm start` (or yarn)
- Access <http://localhost:5000/> to test the integration cards

# Deployment

## Serverless deployment

0. Enable the Launchpad subscription
1. `mbt install`
2. `cf deploy mta_archives/developer-keynote-dashboard_1.0.0.mtar`
3.  Access <https://your-id.launchpad.cfapps.eu10.hana.ondemand.com/developerkeynote.dashboard>


## Standalone approuter deployment

1. `cf push keynote-cards -m 256M -k 512M --random-route` 
2. Access the URL of the app


# Dev Notes

## Switch to mock data

Replace props first route in `xs-app.json`:

```
			"target": "/credits.json",
			"localDir": "sample"
```

## Shorten numbers in axis

Execute this in the Chrome console after rendering:

```
f=sap.ui.getCore().byId("__frame1")
f.setVizProperties({valueAxis: {label: {	"formatString": "u"}}})
```

