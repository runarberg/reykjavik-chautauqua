fs = require 'fs'
path = require 'path'

bodyParser = require 'body-parser'
express = require 'express'
marked = require('marked').setOptions
    renderer: require './lib/marked-renderer'
    sanitize: true
morgan = require 'morgan'
Q = require 'q'

db = require './db'


accessLogStream = fs.createWriteStream __dirname + '/access.log',
    flags: 'a'

handleErr = (err, res) ->    
    console.error err
    res.status(500).send "ERROR: " + err


app = express()

app.set('port', process.env.PORT or 5000)

app.use morgan 'combined', stream: accessLogStream

app.use bodyParser.urlencoded extended: false
app.use bodyParser.json()

app.use express.static path.join __dirname, 'static'

app.set 'views', './views'
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
    Q.all [db.getThemes(), db.getEvents()]
    .then ([themes, events]) ->
        res.render 'index',
            themes: themes
            events: events
    .fail (err) ->
        handleErr err, res


app.get '/events', (req, res) ->
    db.getEvents()
    .then (events) ->
        res.render 'events',
            events: events
            md: marked
    .fail (err) ->
        handleErr err, res


app.get '/about', (req, res) ->
    res.render 'about',
        md: marked


db.getThemes()

.then (themes) ->
    themes.forEach (theme) ->

        app.get theme.url, (req, res) ->
            db.getPosts(theme.name)
            .then (posts) ->
                
                # reverse the chronological order of the current month
                if theme.focus
                    posts = posts.reverse()
                    
                Q.all posts.map (post) ->
                    db.addComments post
                .then () ->
                    res.render 'themes' + theme.url + '/index',
                        themes: themes
                        theme: theme
                        posts: posts
                        md: marked
            .fail (error) ->
                handleErr error, res

        app.post theme.url + "/new-post", (req, res) ->
            db.savePost theme.name, req.body
            .then () ->
                res.redirect theme.url
            .fail (error) ->
                handleErr error, res

        app.post theme.url + "/new-comment", (req, res) ->
            db.saveComment theme.name, req.body
            .then () ->
                res.redirect theme.url
            .fail (error) ->
                handleErr error, res

.fail (err) ->
    handleErr err, res
    

app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'
