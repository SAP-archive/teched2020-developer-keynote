module.exports = async (srv) => {
  const extsrv = await cds.connect.to("myTestService");
  srv.on("READ", "Orders", async (req) => {
    let test = await extsrv
      .tx(req)
      .run(
        SELECT.from("A_SalesOrder")
          .limit(10)
          .columns(["SoldToParty", "TotalNetAmount"])
      );
    console.log(test);
  });
};
