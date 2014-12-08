parser = new DOMParser()

form = document.getElementById "new-post-form"
posts = document.getElementById "posts"

form.addEventListener "submit", (e) ->
    e.preventDefault()
    req = new XMLHttpRequest()
    req.onload = (e) ->
        article = parser.parseFromString(req.response, "text/html")
        posts.appendChild article.firstChild
    req.open 'POST', form.action
    req.setRequestHeader 'Content-Type', 'application/json'
    req.send JSON.stringify
        title: form.querySelector("[name='title']").value
        content: form.querySelector("[name='content']").value
        
