// Mock converter service; returns given (stringified) number
// with 42 added to it. Returned with two decimal places.

// Example:
// > GET http://localhost:5000/conversion/100.95
// < {"value":"142.95"}

const PORT = process.env.PORT || 5000

require('express')()
  .get('/conversion/:amount', (req, res) => {
    console.log('☞', req.path)
    const converted = Number(req.params.amount) + 42
    const formatted = (Math.round(converted * 100) / 100).toFixed(2)
    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify({
      value: formatted
    }))
  })
  .listen(
    PORT,
    _ => console.log(`🚀 Listening on port ${PORT}`)
  )
