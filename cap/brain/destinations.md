# Destinations setup

The BRAIN component connects to a couple of remote services that can be treated as destinations. Before starting the BRAIN up, get the destinations set up in your SAP Cloud Platform trial account, specifically at the subaccount level.

You can see the destination references in the [`package.json`](package.json) file - look for the `S4SalesOrders` and `ConversionService` entries in the `cds -> requires` section.

The most straightforward way to set these up is manually, in the SAP Cloud Platform Cockpit.

## Manual setup

In your subaccount, go to the "Connectivity" -> "Destinations" section and for each of the destination columns in this table, create a new entry, using the "Blank Template" as a base:

||`S4SalesOrders`|`ConversionService`|
|-|-|-|
|Name|`apihub_mock_salesorders`|`charityfund_converter`|
|Type|HTTP|HTTP|
|URL|<the Kyma runtime endpoint for your [SANDBOX](../../s4hana/sandbox) component>|<the Kyma runtime endpoint for your [CONVERTER](../../kyma) component>|
|Proxy Type|Internet|Internet|
|Authentication|None|None|

For the **SANDBOX component** URL (for the `S4SalesOrders` service), use the scheme plus the fully qualified hostname only, i.e. don't add any of the URL's path. Here's an example (your URL will have the same pattern but different details):

`https://s4mock.c081c90.kyma.shoot.live.k8s-hana.ondemand.com`

And here's an example of what the destination definition might look like in your SAP Cloud Platform Cockpit:

![Definition of the `apihub_mock_salesorders` destination](apihub_mock_salesorders.png)
