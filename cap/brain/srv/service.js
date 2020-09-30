module.exports = async (srv) => {


  const { v4: uuidv4 } = require('uuid')
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

  srv.on("invoke", async (req) => {
    await messaging.tx(req).emit({
      event: "Internal/Charityfund/Increased",
      data: {
        specversion: "1.0",
        type: "z.internal.charityfund.increased.v1",
        source: "/default/cap.brain/1",
        id: uuidv4(),
        time: new Date(),
        datacontenttype: "application/json",
        data: {
          custid: 1,
          custname: 'name1',
          credits: '4711'
        }
      }
    });

    return "OK";
  });
};
