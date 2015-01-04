pg = require 'pg'
Q = require 'q'
urlify = require('urlify').create
    spaces: '-'
    toLower: true
    

dbUrl = process.env.DATABASE_URL


getThemeDateStr = (() ->
    months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"]
    (theme) ->
        months[theme.month - 1]
)()


getDb = (
    queryString, queryParams=[], accFn=(row, result) ->
        result.addRow row
) ->
    deferred = Q.defer()
    pg.connect dbUrl, (error, client, done) ->
        if error
            done client
            deferred.reject new Error error
        else
            query = client.query queryString, queryParams

            query.on 'error', (error) ->
                done client
                deferred.reject new Error error

            query.on 'row', accFn

            query.on 'end', (result) ->
                done()
                deferred.resolve result.rows

    return deferred.promise

getThemes = () ->
    queryStr = 'SELECT * FROM themes'
    today = new Date()
    month = today.getMonth() + 1
    year = today. getYear() + 1900
    # XXX: Remove after new years 2015
    if year == 2014
        month = 1
        year = 2015
    accFn = (theme, themes) ->
        theme.url = "/" + urlify theme.name
        theme.dateStr = getThemeDateStr theme
        theme.focus = theme.month == month and theme.year == year
        themes.addRow theme

    getDb queryStr, [], accFn


getPosts = (theme) ->
    queryStr = 'SELECT * FROM posts WHERE theme=$1'
    accFn = (post, posts) ->
        post.articleId = post.title.replace /\s/g, '-'
        posts.addRow post
    getDb queryStr, [theme], accFn
    

getComments = (theme, post) ->
    commentSql = "
    SELECT * FROM comments
    WHERE theme=$1 AND post=$2
    "
    getDb commentSql, [theme, post]


addComments = (post) ->
    deferred = Q.defer()
    getComments post.theme, post.title
    .then (comments) ->
        post.comments = comments
        deferred.resolve()
    .fail (error) ->
        deferred.reject new Error error

    return deferred.promise


saveDb = (queryStr, queryParams) ->    
    deferred = Q.defer()
    pg.connect dbUrl, (err, client, done) ->
        if err
            done client
            deferred.reject new Error err
        else
            query = client.query queryStr, queryParams
            query.on 'error', (err) ->
                done client
                deferred.reject new Error err
            query.on 'end', (result) ->
                done()
                deferred.resolve()

    return deferred.promise

savePost = (theme, post) ->
    if post.post
        # Robot fell into a honeypot
        return Q.defer().promise
        
    queryStr = "
    INSERT INTO posts
    (theme, title, content, author, datetime)
    VALUES ($1, $2, $3, $4, $5)
    "
    queryParams =  [theme, post.title, post.content,
                    post.author, new Date()]
    saveDb queryStr, queryParams

saveComment = (theme, comment) ->
    if comment.comment
        # Robot fell into a honeypot
        return Q.defer().promise
    
    queryStr = "
    INSERT INTO comments
    (theme, post, content, author, datetime)
    VALUES ($1, $2, $3, $4, $5)
    "
    queryParams = [theme, comment.post, comment.content,
                   comment.author, new Date()]
    saveDb queryStr, queryParams

module.exports =
    getThemes: getThemes
    getPosts: getPosts
    getComments: getComments
    addComments: addComments
    savePost: savePost
    saveComment: saveComment
