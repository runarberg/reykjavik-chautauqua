parser = new DOMParser()

form = document.getElementById "new-post-form"
posts = document.getElementById "posts"

formTitle = form.querySelector("[name='title']")
formContent = form.querySelector("[name='content']")

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
        article = parser.parseFromString(req.response, "text/html")
        posts.appendChild article.firstChild
    req.open 'POST', form.action
    req.setRequestHeader 'Content-Type', 'application/json'
    req.send JSON.stringify
        title: formTitle.value
        content: formContent.value
        
