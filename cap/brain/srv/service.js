// Service implementation for CAP "brain"

// Basic events module - get the 'charityfund' collection
const charityfund = require("./events").charityfund;

// Cloud SDK logging (reduce it overall).
const { setGlobalLogLevel } = require("@sap-cloud-sdk/util");
setGlobalLogLevel("error");

// Local service logging.
// Use e.g. 'LOG_LEVEL=info cds run' on the command line.
const log = require("console-log-level")({
  level: process.env.LOG_LEVEL || "debug",
});

// Event detail
const topicIncoming = "salesorder/created";
const topicOutgoing = "Internal/Charityfund/Increased";
const eventSource = "/default/cap.brain/1";

module.exports = async (srv) => {
  // CONNECTIONS

  // Connect to the various components (see package.json)
  const messaging = await cds.connect.to("messaging");
  const s4salesorders = await cds.connect.to("S4SalesOrders");
  const converter = await cds.connect.to("ConversionService");

  // EVENTS

  // Handle incoming salesorder/created event:
  // - Retrieve sales order details from S/4HANA system
  // - Request charity fund equivalent credits for sales order amount
  // - Publish an event to the 'Internal/Charityfund/Increased' topic
  messaging.on(topicIncoming, async (msg) => {
    // Properties to retrieve for the given sales order
    const salesOrderProperties = [
      "SalesOrder",
      "CreationDate",
      "SoldToParty",
      "TotalNetAmount",
      "SalesOrganization",
    ];

    log.debug(`Message received ${JSON.stringify(msg)}`);

    // Retrieve sales order details from S/4HANA system
    // ------------------------------------------------

    // Get the sales order number from the event data
    const { SalesOrder } = msg.data;
    log.info(`SalesOrder number is ${SalesOrder}`);

    // Retrieve the sales order details from the S/4HANA component
    const result = await s4salesorders.tx(msg).run(
      SELECT.one("A_SalesOrder").columns(salesOrderProperties).where({
        SalesOrder: SalesOrder,
      })
    );

    // Abort if we don't manage to get the details
    if (result === undefined) {
      log.error(`Cannot retrieve details for sales order ${SalesOrder}`);
      return;
    }

    log.debug(`SalesOrder details retrieved ${JSON.stringify(result)}`);

    // Was the SoldToParty already cached or processed 10 times?
    if (!(await continueProcessing(result.SoldToParty, msg))) return;

    // Request charity fund equivalent credits for sales order amount
    // --------------------------------------------------------------
    const converted = await converter.get(
      `/conversion?salesAmount=${result.TotalNetAmount}`
    );
    log.debug(`Conversion result is ${JSON.stringify(converted)}`);

    // Publish an event to the 'Internal/Charityfund/Increased' topic
    // --------------------------------------------------------------

    // Convert creation date from OData v2 wrapped epoch to yyyy-mm-dd
    const creationYyyyMmDd =
      new Date(Number(result.CreationDate.replace(/[^\d]/g, '')))
        .toISOString()
        .slice(0,10)

    // Create event payload
    const eventData = charityfund.increased({
      source: eventSource,
      payload: {
        custid: result.SoldToParty,
        creationdate: creationYyyyMmDd,
        credits: converted.Credits.toString(),
        salesorg: result.SalesOrganization,
      },
    });
    log.debug(
      `Payload for ${topicOutgoing} topic created ${JSON.stringify(eventData)}`
    );

    // Emit the event
    await messaging.tx(msg).emit({
      event: topicOutgoing,
      data: eventData,
    });
    log.debug(`Published event to ${topicOutgoing}`);
  });

  // Also send an event on the function invocation (test only)
  srv.on("invoke", async (req) => {
    await messaging.tx(req).emit({
      event: topicOutgoing,
      data: charityfund.increased({
        source: `${eventSource}-test`,
        payload: {
          custid: 4711,
          custname: "Echt Kölnisch Wasser",
          credits: "4711",
        },
      }),
    });

    // Function invocation is expecting a string as a return value
    return "OK";
  });

  // Also convert  on the function invocation (test only)
  srv.on("convert", async (req) => {
    const converted = await converter.get(`/?salesAmount=48.5`);
    log.debug(`Conversion result is ${JSON.stringify(converted)}`);

    // Function invocation is expecting a string as a return value
    return "OK";
  });

  // Also convert  on the function invocation (test only)
  srv.on("readEntry", async (req) => {
    if (!(await continueProcessing(req.data.party, req)))
      // Function invocation is expecting a string as a return value
      return "OK";
  });
};

async function continueProcessing(party, req) {
  const db = await cds.connect.to("db");
  const { CharityEntry } = db.entities; // get reflected definitions
  let count;

  const data = await cds.transaction(req).run(
    SELECT.one(CharityEntry).where({
      SoldToParty: party,
    })
  );

  if (data == undefined) {
    count = 0;
    await cds.transaction(req).run(
      INSERT.into(CharityEntry).entries({
        SoldToParty: party,
        count: count,
      })
    );
  } else {
    count = data.count;
    if (count == 10) {
      console.info("SoldToParty was already processed 10 times");
      return false;
    }
  }

  try {
    await cds.transaction(req).run(
      UPDATE(CharityEntry)
        .set({
          count: count + 1,
        })
        .where({ SoldToParty: party })
    );
  } catch (error) {
    console.error(error);
  }

  return true;
}
