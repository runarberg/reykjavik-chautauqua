bean = require 'bean'
crel = require 'crel'
Entities = require('html-entities').AllHtmlEntities
entities = new Entities()
md = require('markdown-it')
        linkify: true
        typographer: true
.use require 'markdown-it-classy'
.use require 'markdown-it-footnote'
.use require 'markdown-it-sup'
.use require 'markdown-it-sub'
typogr = require 'typogr'


smartypants = (text) ->
    entities.decode typogr.smartypants text

# our custom markdown image renderer
md.renderer.rules.image = require './markdown-it-image-renderer'


# ChildNode.prototype.remove() polyfill
unless Node.prototype.remove
    Object.defineProperty Node.prototype, "remove",
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
    bean.fire textbox, 'input'


commands = (textbox) ->
    h2: () ->
        surround textbox, "", "\n-------\n", "heading"
    h3: () ->
        surround textbox, "\n### ", " ###\n", "heading"
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
    bean.on form.menu, "click", "button[value]", (e) ->
        e.preventDefault()
        commander[this.value]()

    bean.on form.inputs.title, "input", (e) ->
        title = smartypants this.value
        oldNode = output.title.firstChild
        oldNode.remove() if oldNode
        crel output.title, title if title

    bean.on form.inputs.title, "keydown", (e) ->
        if e.keyCode == 13
            e.preventDefault()
            e.stopPropagation()
            form.inputs.author.focus()

    bean.on form.inputs.author, "input", (e) ->
        author = this.value
        oldNode = output.author.firstChild
        oldNode.remove() if oldNode
        crel output.author, "by #{author}" if author
        
    bean.on form.inputs.author, "keydown", (e) ->
        if e.keyCode == 13
            e.preventDefault()
            e.stopPropagation()
            form.inputs.content.focus()

    bean.on form.inputs.content, "input", (e) ->
        content = typogr.typogrify md.render this.value
        output.content.innerHTML = content


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
