path = require 'path'

express = require 'express'
urlify = require('urlify').create
    spaces: '-'
    toLower: true

app = express()

app.set('port', process.env.PORT or 5000)
app.use express.static __dirname + '/public'

app.set 'views', './views'
app.set 'view engine', 'jade'

themeNames = [
    "Indigenous People",
    "The Food We Eat",
    "Mechanization",
    "Society",
    "Eames",
    "Transportation and Communication",
    "Urban Development",
    "Communism",
    "Independent People",
    "Revolution and Stuff",
    "Religion",
    "Alternative History",
    ]

themes = ({name: name, url: "/"+ urlify(name)} for name in themeNames)

app.get '/', (req, res) ->
    res.render 'index',
        themes: themes

themes.forEach (theme) ->
    app.get theme.url, (req, res) ->
        res.render path.join('themes', urlify(theme.name)),
            name: theme.name

app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'

