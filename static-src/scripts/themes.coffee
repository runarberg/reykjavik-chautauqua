marked = require('marked').setOptions
    renderer: require '../../lib/marked-renderer'
    sanitize: true

parser = new DOMParser()

form = document.getElementById "new-post-form"
posts = document.getElementById "posts"

formTitle = form.querySelector("[name='title']")
formContent = form.querySelector("[name='content']")
formAuthor = form.querySelector("[name='author']")

newPost = document.getElementById "new-post"
newPostTitle = newPost.querySelector ".title"
newPostContent = newPost.querySelector ".content"

formTitle.addEventListener "input", (e) ->
    title = document.createTextNode this.value
    oldTitle = newPostTitle.childNodes[0]
    newPostTitle.replaceChild title, oldTitle

formContent.addEventListener "input", (e) ->
    content = marked this.value
    newPostContent.innerHTML = content

form.addEventListener "submit", (e) ->
    e.preventDefault()
    req = new XMLHttpRequest()
    
    req.onload = (e) ->
        if req.status == 200
            html = parser.parseFromString req.response, "text/html"
            article = html.getElementById formTitle.value
            posts.appendChild article
        else
            console.log req.responseText
            
    req.open 'POST', form.action
    req.setRequestHeader 'Content-Type', 'application/json'
    req.send JSON.stringify
        title: formTitle.value
        content: formContent.value
        author: formAuthor.value
