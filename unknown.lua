import express from 'express'
import bodyParser from 'body-parser'
import { MongoClient, ObjectId } from "mongodb"

const port = 8080
const uri = "mongodb+srv://admin:1234@cluster0.vo85qr1.mongodb.net/?retryWrites=true&w=majority"

const app = express()
app.use(express.json())
app.use(bodyParser.json())
const client = new MongoClient(uri)
const database = client.db('rollin_hub')
const accounts = database.collection('accounts')
const config = database.collection('config')
const ticket = database.collection('ticket')


app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.post('/account', async (req, res) => {
  try {
    const { name } = req.body
    if (!name) {
      throw new Error("Name is not defined")
    }
  
    const account = await accounts.findOne({ name })
    if (!account) {
      const newAccount = await accounts.insertOne({
        name,
        auto_farm: false,
        farm_mode: "Manual",
        sell_at_wave: 0,
        gems_amount_to_farm: 0,
        ic_room_reach: 0,
        battlepass_target_level: 0,
        battlepass_current_level: 0,
        gems_received: 0,
        level_id_target_level: 0,
        waiting_time: 30,
        white_screen: false,
        portal_amount_to_farm: 0,
        portal_farm_limit: false,
        lag_delay: 0.4,
        lag_tries: 1,
        lag_table: 250,
        auto_buy_special_unit: false,
        auto_sell_rarity_units: false,
        item_limit_amount_to_farm: 0,
        item_limit_received: 0,
        fps_limit: true,
        auto_claim_quests: true,
        auto_remove_map: true,
        auto_remove_units_name: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      const account = await accounts.findOne({ _id: newAccount.insertedId })
      res.status(200).json(account)
      return
    }
    res.status(200).json(account)
  } catch (error) {
    res.status(500).json(error.message)
  }
})
app.put('/account', async (req, res) => {
  try {
    const { name, data } = req.body
    if (!name) {
      throw new Error("Name is not defined")
    }

    const account = await accounts.findOne({ name })
    if (!account) {
      await accounts.insertOne({
        name,
        auto_farm: false,
        farm_mode: "Manual",
        sell_at_wave: 0,
        gems_amount_to_farm: 0,
        ic_room_reach: 0,
        battlepass_target_level: 0,
        battlepass_current_level: 0,
        gems_received: 0,
        level_id_target_level: 0,
        waiting_time: 30,
        white_screen: false,
        portal_amount_to_farm: 0,
        portal_farm_limit: false,
        lag_delay: 0.4,
        lag_tries: 1,
        lag_table: 250,
        auto_buy_special_unit: false,
        auto_sell_rarity_units: false,
        item_limit_amount_to_farm: 0,
        item_limit_received: 0,
        fps_limit: true,
        auto_claim_quests: true,
        auto_remove_map: true,
        auto_remove_units_name: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
    }

    if (data && data._id) {
      delete data._id
    }

    await accounts.updateOne({ name }, {
      $set: {
        updated_at: new Date(),
        ...data
      }
    })

    res.status(200).json('success')
  } catch (error) {
    console.error(error)
    res.status(500).json(error.message)
  }
})
app.delete('/account', async (req, res) => {
  try {
    const { name } = req.body
    if (!name) {
      throw new Error("Name is not defined")
    }

    await accounts.deleteOne({ name })

    res.status(200).json('success')
  } catch (error) {
    console.error(error)
    res.status(500).json(error.message)
  }
})

app.get('/config', async (req, res) => {
  try {
    const configData = await config.findOne()
    res.status(200).json(configData)
  } catch (error) {
    console.error(error)
    res.status(500).json(error.message)
  }
})
app.put('/config', async (req, res) => {
  try {
    const { data } = req.body
    if (!data) {
      throw new Error("Data is not defined")
    }

    delete data._id
    await config.updateOne({}, {
      $set: {
        ...data
      }
    })

    res.status(200).json('success')
  } catch (error) {
    console.error(error)
    res.status(500).json(error.message)
  }
})

app.get('/ticket', async (req, res) => {
  try {
    const { id } = req.query
    if (!id) {
      throw new Error("ID is not defined")
    }
    const ticket_data = await ticket.findOneAndUpdate({ _id: new ObjectId(id) }, {
      $set: {
        status: "succeeded"
      },
    }, {
      returnNewDocument : true
    })
    res.status(200).json(ticket_data)
    return
  } catch (error) {
    res.status(500).json(error.message)
  }
})
app.post('/ticket', async (req, res) => {
  try {
    const { data } = req.body
    if (!data) {
      throw new Error("Data is not defined")
    }
    const ticket_data = await ticket.insertOne(data)
    res.status(200).json(ticket_data)
    return
  } catch (error) {
    res.status(500).json(error.message)
  }
})

app.get('/dashboard', async (req, res) => {
  try {
    const ticket_data = await ticket.find({ status: "succeeded" }).toArray()
    res.status(200).json(ticket_data.map(e => parseInt(e.package.split("_")[2])).reduce((a, b) => a + b, 0))
    return
  } catch (error) {
    res.status(500).json(error.message)
  }
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
