marked = require('marked').setOptions
    renderer: require '../../lib/marked-renderer'
    sanitize: true

parser = new DOMParser()

postForm = document.getElementById "new-post-form"
posts = document.getElementById "posts"        

formTitle = postForm.querySelector("[name='title']")
formContent = postForm.querySelector("[name='content']")
formAuthor = postForm.querySelector("[name='author']")

newPost = document.getElementById "new-post"
newPostTitle = newPost.querySelector ".title"
newPostContent = newPost.querySelector ".content"
newPostAuthor = newPost.querySelector ".author"

surround = (a, b, defaultText) ->
    oldText = formContent.value
    selStart = formContent.selectionStart
    selEnd = formContent.selectionEnd
    startText = oldText.substring(0, selStart)
    endText = oldText.substring(selEnd)

    if selStart != selEnd
        selText = oldText.substring(selStart, selEnd)
    else
        selText = defaultText
        selEnd += defaultText.length

    newText = startText + a + selText + b + endText

    formContent.value = newText
    newPostContent.innerHTML = marked newText
    formContent.setSelectionRange(selStart + a.length, selEnd + a.length)
    formContent.focus()

editor =
    h2: () ->
        surround "", "\n-------\n", "heading"
    h3: () ->
        surround "\n###", "###\n", "heading"
    em: () ->
        surround "*", "*", "emphasized text"
    strong: () ->
        surround "**", "**", "strong text"
    a: () ->
        url = prompt "Enter a URL"
        surround "[", "](#{url})", "link description"
    img: () ->
        url = prompt "Enter an image URL"
        surround "![", "](#{url})", "image description"
    yt: () ->
        url = prompt "Enter the URL to the You Tube video"
        surround "", "![yt](#{url})", ""
    vimeo: () ->
        url = prompt "Enter the URL to the vimeo video"
        surround "", "![vimeo](#{url})", ""


postForm.querySelector ".editmenu"
.addEventListener "click", (e) ->
    button = e.target
    unless e.target.matches "button[value]"
        return

    e.preventDefault()
    editor[button.value]()

formTitle.addEventListener "input", (e) ->
    title = this.value
    newNode = document.createTextNode title
    oldNode = newPostTitle.childNodes[0]
    oldNode.remove() if oldNode
    newPostTitle.appendChild newNode if title

formTitle.addEventListener "keydown", (e) ->
    if e.keyCode == 13
        e.preventDefault()
        e.stopPropagation()
        formContent.focus()

formContent.addEventListener "input", (e) ->
    content = marked this.value
    newPostContent.innerHTML = content

formContent.addEventListener "keydown", (e) ->
    if e.keyCode == 9 and not e.shiftKey
        e.preventDefault()
        e.stopPropagation()
        formAuthor.focus()

formAuthor.addEventListener "input", (e) ->
    author = this.value
    newNode = document.createTextNode "by #{author}"
    oldNode = newPostAuthor.childNodes[0]
    oldNode.remove() if oldNode
    newPostAuthor.appendChild newNode if author

formAuthor.addEventListener "keydown", (e) ->
    if e.keyCode == 13
        e.preventDefault()
        e.stopPropagation()
        this.form.submit()

postForm.addEventListener "submit", (e) ->
    e.preventDefault()
    
    unless formTitle.value and formContent.value
        # You have to have a title and a content to your post
        return
    
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
            
    req.open 'POST', postForm.action
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

        unless commentContent.value
            # No sending in an empty comment
            return
        
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


document.querySelector "a[href='#new-post']"
.addEventListener "click", (e) ->
    console.log "click"
    e.preventDefault()
    document.getElementById("dropdown-new-post").checked = true
    window.location.hash = "new-post"
