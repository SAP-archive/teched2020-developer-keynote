// Simple webhook - emits JSON received

const express = require("express")
const bodyParser = require("body-parser")

const app = express()
const PORT = process.env.PORT || 8080

app.use(bodyParser.json())

app.post('/*', (req, res) => {
  console.log('💥', JSON.stringify(req.body))
  res.status(200).end()
})

app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`))
