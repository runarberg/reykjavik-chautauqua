bean = require 'bean'
crel = require 'crel'
qwery = require 'qwery'
qwest = require 'qwest'
bean.setSelectorEngine qwery

Editor = require '../../lib/editor'


head = (arr) ->
    arr[0]

parser = new DOMParser()

newPostForm = document.getElementById "new-post-form"
preview = head qwery ".new-post .preview"
posts = document.getElementById "posts"        

editor = new Editor
    container: newPostForm
    menu: head qwery ".editmenu", newPostForm
    inputs:
        title: head qwery "[name='title']", newPostForm
        content: head qwery "[name='content']", newPostForm
        author: head qwery "[name='author']", newPostForm
,
    container: preview
    title: head qwery ".title", preview
    author: head qwery ".author", preview
    content: head qwery ".content", preview


bean.on newPostForm, "submit", (e) ->
    e.preventDefault()

    title = head qwery "[name='title']", newPostForm
    author = head qwery "[name='author']", newPostForm
    content = head qwery "[name='content']", newPostForm

    unless title and content
        # You have to have a title and a content to your post
        return

    qwest.post newPostForm.action,
        title: title.value
        author: author.value
        content: content.value
    .then (response) ->
        html = parser.parseFromString response, "text/html"
        articleId = title.value.replace /\s/g, '-'
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

bean.on posts, 'submit', '.new-comment-form', (e) ->
    e.preventDefault()
    commentAuthor = head qwery "input[name='author']", this
    commentContent = head qwery "textarea[name='content']", this
    postTitle = head qwery "input[name='post']", this

    unless commentContent.value
        # No sending in an empty comment
        return

    qwest.post this.action,
        content: commentContent.value
        author: commentAuthor.value
        post: postTitle.value
    .then (response) ->
        resHtml = parser.parseFromString response, "text/html"
        resArticle = resHtml.getElementById postTitle.value.replace /\s/g, "-"
        resComments = resArticle.querySelector(".comments")

        post = document.getElementById postTitle.value.replace /\s/g, "-"
        head qwery ".comment-length", post
        .innerHTML = resComments.childNodes.length
        comments = head qwery ".comments", post
        comments.parentNode.replaceChild resComments, comments

        # Clear the input fields
        commentContent.value = ""
        commentAuthor.value = ""

    .catch (error) ->
        console.log error


bean.on document, "DOMContentLoaded", () ->
    videos = qwery ".video", posts

    videos.forEach (video) ->
        video.dataset.src = video.firstChild.src
        offset = video.getBoundingClientRect()
        unless 0 <= offset.bottom and offset.top <= window.innerHeight
            video.firstChild.src = ""

    loadIframeIfScrolledTo = () ->
        videos.forEach (video) ->
            offset = video.getBoundingClientRect()
            if 0 <= offset.bottom and offset.top <= window.innerHeight
                video.firstChild.src = video.dataset.src unless  video.dataset.loaded
                video.dataset.loaded = true

    bean.on window, "scroll", loadIframeIfScrolledTo
