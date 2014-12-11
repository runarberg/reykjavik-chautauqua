path = require 'path'
fs = require 'fs'

bodyParser = require 'body-parser'
express = require 'express'
marked = require('marked').setOptions
    renderer: require './lib/marked-renderer'
    sanitize: true
pg = require 'pg'
urlify = require('urlify').create
    spaces: '-'
    toLower: true


themeNames = String(fs.readFileSync("themes.txt")).split("\n").slice(0,-1)
themes = ({
    name: name
    url: "/"+ urlify(name)
    } for name in themeNames)


handleErr = (res, err) ->    
    if not err
        return false
    else
        console.error err
        res.status(500).send "ERROR: " + err
        return true


app = express()

app.set('port', process.env.PORT or 5000)

app.use bodyParser.urlencoded { extended: false }
app.use bodyParser.json()

app.use express.static path.join __dirname, 'static'

app.set 'views', './views'
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
    res.render 'index',
        themes: themes

themes.forEach (theme) ->
    app.get theme.url, (req, res) ->
        pg.connect process.env.DATABASE_URL, (err, client, done) ->
            if err
                done client
                handleErr res, err
            else
                queryStr = 'SELECT * FROM posts WHERE theme=$1'
                query = client.query queryStr, [theme.name]
                query.on 'error', (err) ->
                    done client
                    handleErr res, err

                query.on 'row', (row, result) ->
                    result.addRow row

                query.on 'end', (result) ->
                    done()
                    res.render path.join('themes', urlify(theme.name), 'index'),
                        themes: themes
                        theme: theme
                        posts: result.rows
                        md: marked

    app.post theme.url + "/new-post", (req, res) ->
        pg.connect process.env.DATABASE_URL, (err, client, done) ->
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
                        res.redirect theme.url


app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'
