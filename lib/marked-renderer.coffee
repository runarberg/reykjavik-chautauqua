marked = require 'marked'
renderer = new marked.Renderer()

renderer.image = (href, title, text) ->
    if text in ["youtube", "yt"]
        ytCode = href.split("/").slice(-1)[0]
        if ytCode.slice(0, 6) == "watch?"
            ytCode = ytCode.match(/v=([^;]+)/)[1]
            
        out = '<iframe width="560" height="315"' +
                " src=\"//www.youtube.com/embed/#{ytCode}\"" +
                " allowfullscreen></iframe>"

    else if text == "vimeo"
        code = href.split("/").slice(-1)[0]
        out = "<iframe src=\"//player.vimeo.com/video/#{code}\"" +
                ' width="500" height="281" frameborder="0"' +
                ' webkitallowfullscreen mozallowfullscreen allowfullscreen>' +
                '</iframe>'

    else
        out = "<img src=\"#{href}\" alt=\"#{text}\"" +
                (if title then " title=\"#{title}\"" else "") +
                ">"

    return out

module.exports = renderer
