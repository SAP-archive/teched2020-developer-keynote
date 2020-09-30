const { v4: uuidv4 } = require('uuid')

module.exports = {

  charityfund: {

    increased: ({ source, payload }) => ({
      data: {
        specversion: "1.0",
        type: "z.internal.charityfund.increased.v1",
        datacontenttype: "application/json",
        id: uuidv4(),
        time: new Date(),
        source: source,
        data: payload
      }
    })

  }

}
