module.exports = async (srv) => {
  const messaging = await cds.connect.to("messaging");

  messaging.on("salesorder/created", (msg) => {
    console.log("SALESORDER", JSON.stringify(msg));
  });

  srv.on("invoke", async (req) => {

    await messaging.tx(req).emit({
      event: "CAP/Function/Invoked",
      data: { test: "banana" },
    });

    return "OK";
  });
};
