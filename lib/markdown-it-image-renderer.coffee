md = require('markdown-it')()

defaultRenderer = md.renderer.rules.image
vimeoRE =  /^https?:\/\/(www\.)?vimeo.com\/(\d+)($|\/)/i
ytRE = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/ ]{11})/i
nzonscreenRE = /^https?:\/\/?(?:www\.)?nzonscreen.com\/embed\/([0-9A-Fa-f]{16})(?:$|\/)/i
nfbRE = /^https?:\/\/(?:www\.)?nfb.ca\/film\/(\w+)(?:$|\/)/i

module.exports = (tokens, idx, options, env, self) ->
    if vimeoRE.test tokens[idx].src
        id = tokens[idx].src.match(vimeoRE)[2]
        out = '<figure class="video vimeo">'+
                "<iframe src=\"//player.vimeo.com/video/#{id}\"" +
                ' width="500" height="281" allowfullscreen>' +
                '</iframe></figure>'

    else if ytRE.test tokens[idx].src
        id = tokens[idx].src.match(ytRE)[1]
        out = '<figure class="video yt">'+
                '<iframe width="560" height="315"' +
                " src=\"//www.youtube.com/embed/#{id}\"" +
                " allowfullscreen></iframe></figure>"

    else if nzonscreenRE.test tokens[idx].src
        id = tokens[idx].src.match(nzonscreenRE)[1]
        out = '<figure class="video nzonscreen">'+
                "<iframe src=\"//www.nzonscreen.com/embed/#{id}/\"" +
                ' width="585" height="410" allowfullscreen>' +
                '</iframe></figure>'

    else if nfbRE.test tokens[idx].src
        id = tokens[idx].src.match(nfbRE)[1]
        out = '<figure class="video nfbcanada">'+
                "<iframe src=\"//www.nfb.ca/film/#{id}/embed/player\"" +
                ' width="516" height="320" allowfullscreen>' +
                '</iframe></figure>'

    else
        out = '<figure class="image">' +
                defaultRenderer(tokens, idx, options, env, self) +
                '</figure>'

    # Make figures block level
    out = "</p>#{out}<p>"

    return out
