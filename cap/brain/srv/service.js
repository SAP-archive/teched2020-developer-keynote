const os = require('os')

// Service implementation for CAP "brain"

// Basic events module - get the 'charityfund' collection
const charityfund = require('./events').charityfund

// Cloud SDK logging (reduce it overall).
const { setGlobalLogLevel } = require('@sap-cloud-sdk/util')
setGlobalLogLevel('error')

// Local service logging.
// Use e.g. 'LOG_LEVEL=info cds run' on the command line.
const log = require('console-log-level')({
  level: process.env.LOG_LEVEL || 'debug',
})

// Event detail
const topicIncoming = 'salesorder/created'
const topicOutgoing = 'Internal/Charityfund/Increased'
const eventSource = `/default/cap.brain/${os.hostname() || 'unknown'}`

module.exports = async (srv) => {
  // EVENTS

  // Handle incoming salesorder/created event - different levels:
  // 1 - Log event message received
  // 2 - Retrieve sales order details from S/4HANA system
  // 3 - Request charity fund equivalent credits for sales order amount
  // 4 - Publish an event to the 'Internal/Charityfund/Increased' topic

  // Check env var for how far through this list we should go (default to
  // just logging the received event messages)
  const level = process.env.BRAIN_LEVEL || 1
  log.info(`BRAIN_LEVEL set to ${level}`)

  if (level == 0) return

  const messaging = await cds.connect.to('messaging')

  messaging.on(topicIncoming, async (msg) => {
    // Properties to retrieve for the given sales order
    const salesOrderProperties = [
      'SalesOrder',
      'CreationDate',
      'SoldToParty',
      'TotalNetAmount',
      'SalesOrganization',
    ]

    if (level < 1) return

    log.debug(`Message received ${JSON.stringify(msg)}`)

    if (level < 2) return

    // Retrieve sales order details from S/4HANA system
    // ------------------------------------------------

    // Get the sales order number from the event data
    const { SalesOrder } = msg.data
    log.info(`SalesOrder number is ${SalesOrder}`)

    const s4salesorders = await cds.connect.to('S4SalesOrders')

    // Retrieve the sales order details from the S/4HANA component
    const result = await s4salesorders.tx(msg).run(
      SELECT.one('A_SalesOrder').columns(salesOrderProperties).where({
        SalesOrder: SalesOrder,
      })
    )

    // Abort if we don't manage to get the details
    if (result === undefined) {
      log.error(`Cannot retrieve details for sales order ${SalesOrder}`)
      return
    }

    log.debug(`SalesOrder details retrieved ${JSON.stringify(result)}`)

    // Was the SoldToParty already cached or processed 10 times?
    if (!(await continueProcessing(result.SoldToParty, msg))) return

    if (level < 3) return

    // Request charity fund equivalent credits for sales order amount
    // --------------------------------------------------------------
    const converter = await cds.connect.to('ConversionService')
    const converted = await converter.get(
      `/conversion?salesAmount=${result.TotalNetAmount}`
    )
    log.debug(`Conversion result is ${JSON.stringify(converted)}`)

    if (level < 4) return

    // Publish an event to the 'Internal/Charityfund/Increased' topic
    // --------------------------------------------------------------

    // Convert creation date from OData v2 wrapped epoch to yyyy-mm-dd
    /*const creationYyyyMmDd =
      new Date(Number(result.CreationDate.replace(/[^\d]/g, '')))
        .toISOString()
        .slice(0,10)*/

    //keynote Date simulation
    const creationYyyyMmDd = new Date('2020-12-08').toISOString().slice(0, 10)

    // Create event payload
    const eventData = charityfund.increased({
      source: eventSource,
      payload: {
        salesorder: result.SalesOrder,
        custid: result.SoldToParty,
        creationdate: creationYyyyMmDd,
        credits: converted.Credits.toString(),
        salesorg: result.SalesOrganization,
      },
    })
    log.debug(
      `Payload for ${topicOutgoing} topic created ${JSON.stringify(eventData)}`
    )

    // Emit the event
    await messaging.tx(msg).emit({
      event: topicOutgoing,
      data: eventData,
    })
    log.debug(`Published event to ${topicOutgoing}`)
  })
}

async function continueProcessing(party, req) {
  const db = await cds.connect.to('db')
  const { CharityEntry } = db.entities // get reflected definitions
  let count

  const data = await cds.transaction(req).run(
    SELECT.one(CharityEntry).where({
      SoldToParty: party,
    })
  )

  if (data == undefined) {
    count = 0
    await cds.transaction(req).run(
      INSERT.into(CharityEntry).entries({
        SoldToParty: party,
        count: count,
      })
    )
  } else {
    count = data.count
    if (count == 10) {
      console.info('SoldToParty was already processed 10 times')
      return false
    }
  }

  try {
    await cds.transaction(req).run(
      UPDATE(CharityEntry)
        .set({
          count: count + 1,
        })
        .where({ SoldToParty: party })
    )
  } catch (error) {
    console.error(error)
  }

  return true
}
