module.exports = async srv => {

  const messaging = await cds.connect.to('messaging')

  messaging.on('salesorder/created', msg => {
    console.log('SALESORDER', JSON.stringify(msg))
  })

}
