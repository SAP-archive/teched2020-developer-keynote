module.exports = async (srv) => {

  const extsrv = await cds.connect.to('API_SALES_ORDER_SRV')
  srv.on('READ', 'Orders', req => {
    extsrv.tx(req).run(SELECT.from(extsrv.entities.A_SalesOrder))
  })

}
