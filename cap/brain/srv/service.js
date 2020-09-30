module.exports = async (srv) => {
  const { setGlobalLogLevel } = require('@sap-cloud-sdk/util')
  setGlobalLogLevel('error')

  const messaging = await cds.connect.to("messaging");

  messaging.on("salesorder/created", async (msg) => {
    console.log("SALESORDER", JSON.stringify(msg));
    let extsrv = await cds.connect.to("S4SalesOrders");

    let salesOrder = msg.data.SalesOrder;

    let salesOrderS4 = await extsrv.tx(msg).run(
      SELECT.from("A_SalesOrder")
        .limit(10)
        .columns(["SalesOrder", "SoldToParty", "TotalNetAmount"])
        .where({
          SalesOrder: salesOrder,
        })
    );
    if (salesOrderS4.length == 0) {
      console.log("NO SALESORDER FOUND");
    } else {
      console.log(salesOrderS4);
    }
  });

  /* srv.on("invoke", async (req) => {
    await messaging.tx(req).emit({
      event: "CAP/Function/Invoked",
      data: { test: "banana" },
    });

    return "OK";
  });*/
};
