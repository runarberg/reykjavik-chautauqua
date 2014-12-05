express = require 'express'
app = express()

app.set('port', process.env.PORT or 5000)
app.use express.static __dirname + '/public'

app.set 'views', './views'
app.set 'view engine', 'jade'

themes = [
    "Indigenous People",
    "The Food We Eat",
    "Mechanization",
    "Society",
    "Eames",
    "Transportation and Communication",
    "Urban Development",
    "Communism",
    "Independent Peoples",
    "Revolution and Stuff",
    "Religion",
    "Alternative History",
    ]

app.get '/', (req, res) ->
    res.render 'index'

app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'

