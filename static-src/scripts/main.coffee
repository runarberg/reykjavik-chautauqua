bean = require 'bean'
crel = require 'crel'
qwery = require 'qwery'
tween = require 'tween.js'

head = (arr) ->
    arr[0]


themeNav = head qwery ".theme-nav"
themeUl = head qwery "ul"
themeLis = qwery "li", themeNav
winMid = window.innerWidth/2
bean.on window, "resize", (e) ->
    winMid = window.innerWidth/2

setDelay = ( () ->
    timer = 0
    return (callback, ms) ->
        clearTimeout timer
        timer = setTimeout callback, ms
)()


scrollBtns = qwery "a.scroll", themeNav


setCenterLiFocus = () ->
    ulMid = themeUl.scrollLeft + winMid
    themeLis.forEach (li) ->
        liLeft = li.offsetLeft
        liRight = liLeft + li.clientWidth
        li.classList.remove "focus"
        if liLeft < ulMid < liRight
            li.classList.add "focus"


setScrollPos = () ->
    scrollDiv = head qwery ".scroll-bar", themeNav
    scrollA = head qwery "a.scroll-bar-center", scrollDiv
    scrollProp = themeUl.scrollLeft/themeUl.scrollWidth
    scrollLeft = scrollProp * scrollDiv.clientWidth

    scrollA.style.left = scrollLeft + "px"

handleScrollEnd = (e) ->
    setDelay () ->
        setCenterLiFocus()
        setScrollPos()
    , 20

scrollBtns.forEach (a) ->
    bean.on a, "click", (e) ->
        liWidth = themeLis[0].clientWidth
        e.preventDefault()
        if this.classList.contains "left"
            stop = Math.max(themeUl.scrollLeft - liWidth, 0)
        else
            stop = Math.min(themeUl.scrollLeft + liWidth, themeUl.scrollWidth)
        pos = {x: themeUl.scrollLeft}
        scrolling = new tween.Tween pos
        .to {x: stop}, 500
        .onUpdate () ->
            themeUl.scrollLeft = pos.x
            setScrollPos()
        .easing tween.Easing.Quadratic.Out
        .start()
        animation = () ->
            requestAnimationFrame animation
            tween.update()
        animation()
        

bean.on document, "DOMContentLoaded", () ->
    winWidth = window.innerWidth
    liWidth = themeUl.firstChild.clientWidth
    padding = (winWidth / 2) - (liWidth / 2)
    themeUl.firstChild.style.marginLeft = "#{padding}px"
    themeUl.lastChild.style.marginRight = "#{padding}px"
    focusCenter = head(qwery ".focus", themeUl).offsetLeft + liWidth/2
    themeUl.scrollLeft = focusCenter - themeNav.clientWidth/2


    # add scroll bar at bottom
    (() ->
        div = crel "div",
            class: "scroll-bar"
        
        a = crel "a",
            class: "scroll-bar-center"
            href: "#"

        crel themeNav, crel div, a

        doScrollThemes = (e) ->
            offset = div.getBoundingClientRect().left + a.clientWidth/2
            left = e.pageX - offset
            left = Math.max left, 0
            left = Math.min left, div.clientWidth
            a.style.left = left + "px"

            scrollProp = left/div.clientWidth
            scrollLeft = themeUl.scrollWidth * scrollProp
            themeUl.scrollLeft = scrollLeft

            setCenterLiFocus()

        bean.on a, "click", (e) ->
            e.preventDefault()

        bean.on a, "mousedown", (e) ->
            e.preventDefault()
            bean.on document.body, "mousemove", doScrollThemes
            bean.on document.body, "mouseup", (e) ->
                bean.off document.body, "mousemove", doScrollThemes
    )()

    bean.on themeUl, "scroll", handleScrollEnd

    themeLis.forEach (li) ->
        bean.on li, "mouseover", (e) ->
            themeLis.forEach (li_) ->
                li_.classList.remove "focus"
            this.classList.add "focus"
