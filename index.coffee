path = require 'path'
fs = require 'fs'

Q = require 'q'

bodyParser = require 'body-parser'
express = require 'express'
marked = require('marked').setOptions
    renderer: require './lib/marked-renderer'
    sanitize: true
pg = require 'pg'
urlify = require('urlify').create
    spaces: '-'
    toLower: true

handleErr = (res, err) ->    
    if not err
        return false
    else
        console.error err
        res.status(500).send "ERROR: " + err
        return true



dbUrl = process.env.DATABASE_URL


getThemeMonth = (() ->
    months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"]
    (theme) ->
        months[theme.month - 1]
)()

getThemes = () ->
    deferred = Q.defer()
    pg.connect dbUrl, (err, client, done) ->
        if err
            done client
            deferred.reject new Error err
        else
            queryStr = 'SELECT * FROM themes'
            query = client.query queryStr

            query.on 'error', (err) ->
                done client
                deferred.reject new Error err

            query.on 'row', (row, result) ->
                result.addRow row

            query.on 'end', (result) ->
                done()
                themes = ({
                    name: theme.name
                    url: "/" + urlify theme.name
                    month: getThemeMonth theme
                } for theme in result.rows)

                deferred.resolve themes

    return deferred.promise


getPosts = (theme) ->
    deferred = Q.defer()
    pg.connect dbUrl, (err, client, done) ->
        if err
            done client
            deferred.reject new Error err
        else
            queryStr = 'SELECT * FROM posts WHERE theme=$1'
            query = client.query queryStr, [theme]
            
            query.on 'error', (err) ->
                done client
                deferred.reject new Error err

            query.on 'row', (row, result) ->
                result.addRow row

            query.on 'end', (result) ->
                done()
                deferred.resolve result.rows
                
    return deferred.promise


app = express()

app.set('port', process.env.PORT or 5000)

app.use bodyParser.urlencoded { extended: false }
app.use bodyParser.json()

app.use express.static path.join __dirname, 'static'

app.set 'views', './views'
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
    getThemes()
    .then (themes) ->
        res.render 'index',
            themes: themes
            urlify: urlify
    , (err) ->
        handleErr res, err

getThemes().then (themes) ->
    
    themes.forEach (theme) ->
        app.get '/' + urlify(theme.name), (req, res) ->
            getPosts(theme.name)
            .then (posts) ->
                res.render path.join('themes', urlify(theme.name), 'index'),
                    themes: themes
                    theme: theme
                    posts: posts
                    urlify: urlify
                    md: marked
            , (err) ->
                handleErr res err

        app.post '/' + urlify(theme.name) + "/new-post", (req, res) ->
            pg.connect dbUrl, (err, client, done) ->
                if err
                    done client
                    handleErr res, err
                else
                    queryStr = "
                    INSERT INTO posts
                    (theme, title, content, author, datetime)
                    VALUES ($1, $2, $3, $4, $5)
                    "
                    client.query queryStr, [
                            theme.name
                            req.body.title
                            req.body.content
                            req.body.author
                            new Date()
                        ], (err, result) ->
                        if err
                            done client
                            handleErr res, err
                        else
                            done()
                            res.redirect '/' + urlify(theme.name)


app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'
