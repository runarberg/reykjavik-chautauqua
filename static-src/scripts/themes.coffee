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
newPostAuthor = newPost.querySelector ".author"

formTitle.addEventListener "input", (e) ->
    title = this.value
    newNode = document.createTextNode title
    oldNode = newPostTitle.childNodes[0]
    oldNode.remove() if oldNode
    newPostTitle.appendChild newNode if title

formContent.addEventListener "input", (e) ->
    content = marked this.value
    newPostContent.innerHTML = content

formAuthor.addEventListener "input", (e) ->
    author = this.value
    newNode = document.createTextNode "by #{author}"
    oldNode = newPostAuthor.childNodes[0]
    oldNode.remove() if oldNode
    newPostAuthor.appendChild newNode if author

form.addEventListener "submit", (e) ->
    e.preventDefault()
    req = new XMLHttpRequest()
    
    req.onload = (e) ->
        if req.status == 200
            html = parser.parseFromString req.response, "text/html"
            article = html.getElementById formTitle.value
            posts.appendChild article

            # Clear all form and preview content
            document.getElementById("dropdown-new-post").checked = false
            
            formTitle.value = ""
            newPostTitle.childNodes[0].remove()
            
            formContent.value = ""
            newPostContent.innerHTML = ""
            
            formAuthor.value = ""
            newPostAuthor.childNodes[0].remove()
        else
            console.log req.responseText
            
    req.open 'POST', form.action
    req.setRequestHeader 'Content-Type', 'application/json'
    req.send JSON.stringify
        title: formTitle.value
        content: formContent.value
        author: formAuthor.value


posts.addEventListener 'submit', (e) ->
    form = e.target
    if form.matches '.new-comment-form'
        e.preventDefault()
        commentAuthor = form.querySelector("input[name='author']")
        commentContent = form.querySelector("textarea[name='content']")
        postTitle = form.querySelector("input[name='post']").value
        req = new XMLHttpRequest()

        req.onload = (e) ->
            if req.status == 200
                resHtml = parser.parseFromString req.response, "text/html"
                resArticle = resHtml.getElementById postTitle
                resComments = resArticle.querySelector(".comments")

                post = document.getElementById postTitle
                post.querySelector(".comment-length").innerHTML = resComments.childNodes.length
                comments = post.querySelector(".comments")
                comments.appendChild(resComments.lastChild)

                # Clear the input fields
                commentContent.value = ""
                commentAuthor.value = ""
            else
                console.log req.responseText

        req.open 'POST', form.action
        req.setRequestHeader 'Content-Type', 'application/json'
        req.send JSON.stringify
            content: commentContent.value
            author: commentAuthor.value
            post: postTitle
