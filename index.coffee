path = require 'path'
fs = require 'fs'

express = require 'express'
pg = require 'pg'

urlify = require('urlify').create
    spaces: '-'
    toLower: true


themeNames = String(fs.readFileSync("themes.txt")).split("\n").slice(0,-1)
themes = ({
    name: name
    url: "/"+ urlify(name)
    } for name in themeNames)


app = express()

app.set('port', process.env.PORT or 5000)
app.use express.static __dirname + '/public'

app.set 'views', './views'
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
    res.render 'index',
        themes: themes

themes.forEach (theme) ->
    app.get theme.url, (req, res) ->
        res.render path.join('themes', urlify(theme.name)),
            name: theme.name

app.get '/db', (req, res) ->
    pg.connect process.env.DATABASE_URL, (err, client, done) ->
        
        handleErr = (err) ->    
            if not err
                return false
            else
                done client
                console.error err
                res.send "ERROR: " + err
                return true
                
        if handleErr err
            return
            
        client.query 'SELECT * FROM themes', (err, result) ->
            if handleErr err
                return
            else
                done()
                res.send result.rows

app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'
