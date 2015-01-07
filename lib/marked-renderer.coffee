marked = require 'marked'
renderer = new marked.Renderer()

renderer.image = (href, title, text) ->
    if text in ["youtube", "yt"]
        ytCode = href.split("/").slice(-1)[0]
        if ytCode.slice(0, 6) == "watch?"
            ytCode = ytCode.match(/v=([^;]+)/)[1]
            
        out = '<figure class="video yt">'+
                '<iframe width="560" height="315"' +
                " src=\"//www.youtube.com/embed/#{ytCode}\"" +
                " allowfullscreen></iframe></figure>"

    else if text == "vimeo"
        code = href.split("/").slice(-1)[0]
        out = '<figure class="video vimeo">'+
                "<iframe src=\"//player.vimeo.com/video/#{code}\"" +
                ' width="500" height="281" frameborder="0"' +
                ' webkitallowfullscreen mozallowfullscreen allowfullscreen>' +
                '</iframe></figure>'

    else
        out = '<figure class="image">'+
                "<img src=\"#{href}\" alt=\"#{text}\"" +
                (if title then " title=\"#{title}\"" else "") +
                "></figure>"

    return out

module.exports = renderer
