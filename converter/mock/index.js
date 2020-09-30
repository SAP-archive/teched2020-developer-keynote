// Mock converter service
// Test with e.g. http://localhost:5000/conversion/123.45

const PORT = process.env.PORT || 5000

require('express')()
  .get('/conversion/:amount', (req, res) => {
    console.log('☞', req.path)
    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify({
      value: Number(req.params.amount) + 42
    }))
  })
  .listen(
    PORT,
    _ => console.log(`🚀 Listening on port ${PORT}`)
  )
