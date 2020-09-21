module.exports = async (srv) => {
  const messaging = await cds.connect.to("messaging");

  messaging.on("salesorder/created", (msg) => {
    console.log("SALESORDER", JSON.stringify(msg));
  });

  srv.on("invoke", async (req) => {
    let tx = messaging.tx(req);
    tx.emit("CAP/FunctionInvoked", { customerID: "TestCustomer" });

    await messaging.tx(req).emit({
      event: "CAP/Function/Invoked",
      data: { test: "banana" },
    });

    return "OK";
  });
};
