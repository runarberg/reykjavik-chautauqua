crel = require 'crel'

marked = require('marked').setOptions
    renderer: require './marked-renderer'
    sanitize: true


# ChildNode.prototype.remove() polyfill
unless Element.prototype.remove
    Object.defineProperty Element.prototype, "remove",
        value: () ->
            this.parentNode.removeChild this


surround = (textbox, a, b, defaultText) ->
    oldText = textbox.value
    selStart = textbox.selectionStart
    selEnd = textbox.selectionEnd
    startText = oldText.substring 0, selStart
    endText = oldText.substring selEnd

    if selStart != selEnd
        selText = oldText.substring selStart, selEnd
    else
        selText = defaultText
        selEnd += defaultText.length

    newText = startText + a + selText + b + endText

    textbox.value = newText
    textbox.setSelectionRange selStart + a.length, selEnd + a.length
    textbox.focus()
    textbox.dispatchEvent new Event 'input'


commands = (textbox) ->
    h2: () ->
        surround textbox, "", "\n-------\n", "heading"
    h3: () ->
        surround textbox, "\n###", "###\n", "heading"
    em: () ->
        surround textbox, "*", "*", "emphasized text"
    strong: () ->
        surround textbox, "**", "**", "strong text"
    a: () ->
        url = prompt "Enter a URL"
        surround textbox, "[", "](#{url})", "link description"
    img: () ->
        url = prompt "Enter an image URL"
        surround textbox, "![", "](#{url})", "image description"
    yt: () ->
        url = prompt "Enter the URL to the You Tube video"
        surround textbox, "", "![yt](#{url})", ""
    vimeo: () ->
        url = prompt "Enter the URL to the vimeo video"
        surround textbox, "", "![vimeo](#{url})", ""


Editor = (form, output) ->

    commander = commands form.inputs.content
    form.menu.addEventListener "click", (e) ->
        button = e.target
        if e.target.matches "button[value]"
            e.preventDefault()
            commander[button.value]()

    form.inputs.title.addEventListener "input", (e) ->
        title = this.value
        oldNode = output.title.firstChild
        oldNode.remove() if oldNode
        crel output.title, title if title

    form.inputs.title.addEventListener "keydown", (e) ->
        if e.keyCode == 13
            e.preventDefault()
            e.stopPropagation()
            form.inputs.author.focus()

    form.inputs.author.addEventListener "keydown", (e) ->
        if e.keyCode == 13
            e.preventDefault()
            e.stopPropagation()
            form.inputs.content.focus()

    form.inputs.content.addEventListener "input", (e) ->
        content = marked this.value
        output.content.innerHTML = content

    form.inputs.author.addEventListener "input", (e) ->
        author = this.value
        oldNode = output.author.firstChild
        oldNode.remove() if oldNode
        crel output.author, "by #{author}" if author


    this.clear = () ->
        document.getElementById("dropdown-new-post").checked = false
        form.inputs.title.value = ""
        output.title.firstChild.remove() if output.title.firstChild
        form.inputs.content.value = ""
        output.content.innerHTML = ""
        form.inputs.author.value = ""
        output.author.firstChild.remove() if output.author.firstChild

    return this


module.exports = Editor
