crel = require 'crel'
qwest = require 'qwest'

marked = require('marked').setOptions
    renderer: require '../../lib/marked-renderer'
    sanitize: true

Editor = require '../../lib/editor'


# Element.matches() selector
Element.prototype.matches = Element.prototype.matches or
        Element.prototype.webkitMatchesSelector or
        Element.prototype.mozMatchesSelector or
        Element.prototype.msMatchesSelector

parser = new DOMParser()

postForm = document.getElementById "new-post-form"
posts = document.getElementById "posts"        
newPost = document.getElementById "new-post"

editor = new Editor
    container: postForm
    menu: postForm.querySelector ".editmenu"
    inputs:
        title: postForm.querySelector "[name='title']"
        content: postForm.querySelector "[name='content']"
        author: postForm.querySelector "[name='author']"
,
    container: newPost
    title: newPost.querySelector ".title"
    content: newPost.querySelector ".content"
    author: newPost.querySelector ".author"


postForm.addEventListener "submit", (e) ->
    e.preventDefault()

    title = postForm.querySelector("[name='title']").value
    author = postForm.querySelector("[name='author']").value
    content = postForm.querySelector("[name='content']").value

    unless title and content
        # You have to have a title and a content to your post
        return

    qwest.post postForm.action,
        title: title
        author: author
        content: content
    .then (response) ->
        html = parser.parseFromString response, "text/html"
        articleId = title.replace /\s/g, '-'
        newPosts = html.getElementById "posts"
        newArticle = html.getElementById articleId
        newToc = newPosts.querySelector ".toc"
        oldToc = posts.querySelector ".toc"

        # Clear old values from the editor
        editor.clear()

        posts.replaceChild newToc, oldToc
        posts.insertBefore newArticle, posts.querySelector ".post"

        window.location.hash = "#"+ articleId

    .catch (error) ->
        console.error error

submitComment = (e) ->
    e.preventDefault()
    commentAuthor = form.querySelector("input[name='author']")
    commentContent = form.querySelector("textarea[name='content']")
    postTitle = form.querySelector("input[name='post']").value

    unless commentContent.value
        # No sending in an empty comment
        return

    qwest.post form.action,
        content: commentContent.value
        author: commentAuthor.value
        post: postTitle
    .then (response) ->
        resHtml = parser.parseFromString response, "text/html"
        resArticle = resHtml.getElementById postTitle.replace /\s/g, "-"
        resComments = resArticle.querySelector(".comments")

        post = document.getElementById postTitle.replace /\s/g, "-"
        post.querySelector(".comment-length").innerHTML = resComments.childNodes.length
        comments = post.querySelector(".comments")
        comments.appendChild(resComments.lastChild)

        # Clear the input fields
        commentContent.value = ""
        commentAuthor.value = ""

    .catch (error) ->
        console.log error


posts.addEventListener 'submit', (e) ->
    form = e.target
    if form.matches '.new-comment-form'
        submitComment e
