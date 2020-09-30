// Service implementation for CAP "brain"

// Basic events module - get the 'charityfund' collection
const charityfund = require('./events').charityfund

// Cloud SDK logging (reduce it overall).
const { setGlobalLogLevel } = require('@sap-cloud-sdk/util')
setGlobalLogLevel('error')

// Local service logging.
// Use e.g. 'LOG_LEVEL=info cds run' on the command line.
const log = require('console-log-level')({
  level: process.env.LOG_LEVEL || 'debug'
})

// Event detail
const topicIncoming = 'salesorder/created'
const topicOutgoing = 'Internal/Charityfund/Increased'
const eventSource = '/default/cap.brain/1'


module.exports = async srv => {

  // CONNECTIONS

  // Connect to the messaging and S/4HANA components (see package.json)
  const messaging = await cds.connect.to('messaging')
  const s4salesorders = await cds.connect.to('S4SalesOrders')

  // EVENTS

  // Handle incoming salesorder/created event:
  // ✅ Retrieve sales order details from S/4HANA system
  // ❌ Request charity fund equivalent credits for sales order amount
  // ✅ Publish an event to the 'Internal/Charityfund/Increased' topic
  messaging.on(topicIncoming, async msg => {

    // Properties to retrieve for the given sales order
    const salesOrderProperties = [
      'SalesOrder',
      'SoldToParty',
      'TotalNetAmount',
      'SalesOrganization'
    ]

    log.debug(`Message received ${JSON.stringify(msg)}`)


    // Retrieve sales order details from S/4HANA system
    // ------------------------------------------------

    // Get the sales order number from the event data
    const { SalesOrder } = msg.data
    log.info(`SalesOrder number is ${SalesOrder}`)

    // Retrieve the sales order details from the S/4HANA component
    const results = await s4salesorders.tx(msg).run(
      SELECT.from('A_SalesOrder')
        .limit(1)
        .columns(salesOrderProperties)
        .where({
          SalesOrder: SalesOrder,
        })
    )

    // Abort if we don't manage to get the details
    if (results.length === 0) {
      log.error(`Cannot retrieve details for sales order ${SalesOrder}`)
      return
    }

    log.debug(`SalesOrder details retrieved ${JSON.stringify(results)}`)


    // Request charity fund equivalent credits for sales order amount
    // --------------------------------------------------------------



    // Publish an event to the 'Internal/Charityfund/Increased' topic
    // --------------------------------------------------------------

    // Create event payload
    const eventData = charityfund.increased({
      source: eventSource,
      payload: {
        custid: results[0].SoldToParty,
        custname: '',
        credits: 0,
        salesorg: results[0].SalesOrganization
      }
    })
    log.debug(`Payload for ${topicOutgoing} topic created ${JSON.stringify(eventData)}`)

    // Emit the event
    await messaging.tx(msg).emit({
      event: topicOutgoing,
      data: eventData
    })
    log.debug(`Published event to ${topicOutgoing}`)

  })


  // Also send an event on the function invocation (test only)
  srv.on('invoke', async req => {

    await messaging.tx(req).emit({
      event: topicOutgoing,
      data: charityfund.increased({
        source: `${eventSource}-test`,
        payload: {
          custid: 4711,
          custname: 'Echt Kölnisch Wasser',
          credits: '4711'
        }
      })
    })

    // Function invocation is expecting a string as a return value
    return 'OK'
  })

}
