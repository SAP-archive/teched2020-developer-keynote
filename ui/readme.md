# Instructions

- Install deps `npm install` 
- Run Approuter `npm start` (or yarn)
- Access <http://localhost:5000/> to test the integration cards


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

