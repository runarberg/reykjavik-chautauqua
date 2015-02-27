fs = require 'fs'
path = require 'path'

bodyParser = require 'body-parser'
Entities = require('html-entities').AllHtmlEntities
entities = new Entities()
express = require 'express'
jade = require 'jade'
md = require('markdown-it')
        linkify: true
        typographer: true
.use require 'markdown-it-footnote'
.use require 'markdown-it-sup'
.use require 'markdown-it-sub'
morgan = require 'morgan'
Q = require 'q'
typogr = require 'typogr'

db = require './db'


# our custom markdown image renderer
md.renderer.rules.image = require './lib/markdown-it-image-renderer'

# wrap markdown in typogrify and sanitize
smartypants = (text) ->
    entities.decode typogr.smartypants text

renderMd = (text) ->
    typogr.typogrify md.render text

accessLogStream = fs.createWriteStream __dirname + '/access.log',
    flags: 'a'

handleErr = (err, res) ->
    console.error err
    res.status(500).send "ERROR: " + err


app = express()

# my customized jade engine
jade.filters.md = renderMd
app.engine('jade', jade.renderFile)

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
            md: renderMd
            typogrify: typogr.typogrify
            smartypants: smartypants
    .fail (err) ->
        handleErr err, res


app.get '/about', (req, res) ->
    res.render 'about',
        md: renderMd


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
                        md: renderMd
                        typogrify: typogr.typogrify
                        smartypants: smartypants
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

.then () ->
    # 404 handler
    app.use (req, res) ->
        res.status 404
        res.render 'not-found.jade'


.fail (err) ->
    handleErr err, res
    

app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'
