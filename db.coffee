pg = require 'pg'
Q = require 'q'
urlify = require('urlify').create
    spaces: '-'
    toLower: true
    

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
                result.addRow
                    name: row.name
                    url: "/" + urlify row.name
                    month: getThemeMonth row

            query.on 'end', (result) ->
                done()
                deferred.resolve result.rows

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


savePost = (theme, post) ->
    deferred = Q.defer()
    pg.connect dbUrl, (err, client, done) ->
        if err
            done client
            deferred.reject new Error err
        else
            queryStr = "
            INSERT INTO posts
            (theme, title, content, author, datetime)
            VALUES ($1, $2, $3, $4, $5)
            "
            query = client.query queryStr, [
                    theme
                    post.title
                    post.content
                    post.author
                    new Date()
                ]
            query.on 'error', (err) ->
                done client
                deferred.reject new Error err
            query.on 'end', (result) ->
                done()
                deferred.resolve()

    return deferred.promise


module.exports =
    getThemes: getThemes
    getPosts: getPosts
    savePost: savePost
