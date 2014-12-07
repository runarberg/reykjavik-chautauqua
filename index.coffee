path = require 'path'
fs = require 'fs'

autoprefixer = require 'autoprefixer-stylus'
bodyParser = require('body-parser')
express = require 'express'
marked = require 'marked'
pg = require 'pg'
stylus = require 'stylus'
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
        res.send "ERROR: " + err
        return true

app = express()

app.set('port', process.env.PORT or 5000)
app.use express.static __dirname + '/public'

app.use bodyParser.urlencoded { extended: false }
app.use bodyParser.json()

compile = (str, path) ->
    stylus(str)
        .set('filename', path)
        .set('compress', true)
        .use(autoprefixer())

app.use stylus.middleware
    src: __dirname
    compile: compile

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
                return

            queryStr = 'SELECT * FROM posts WHERE theme=$1'
            client.query queryStr, [theme.name], (err, result) ->
                if err
                    done client
                    handleErr res, err
                    return

                done()
            
                res.render path.join('themes', urlify(theme.name)),
                    theme: theme
                    posts: result.rows
                    md: marked

    app.post theme.url + "/new-post", (req, res) ->
        pg.connect process.env.DATABASE_URL, (err, client, done) ->
            if err
                done client
                handleErr res, err
                return

            queryStr = "
            INSERT INTO posts (theme, title, content)
            VALUES ($1, $2, $3)
            "
            client.query queryStr, [
                    theme.name
                    req.body.title
                    req.body.content
                ], (err, result) ->
                if err
                    done client
                    handleErr res, err
                    return

                done()
                
            res.redirect(theme.url)


app.listen app.get('port'), ->
    console.log "Node app is running at localhost:"+ app.get 'port'
