bean = require 'bean'
crel = require 'crel'
tween = require 'tween.js'

themeNav = document.querySelector ".theme-nav"
themeUl = document.querySelector "ul"
themeLis = themeNav.querySelectorAll "li"
winMid = window.innerWidth/2

setDelay = ( () ->
    timer = 0
    return (callback, ms) ->
        clearTimeout timer
        timer = setTimeout callback, ms
)()


scrollBtns = themeNav.querySelectorAll "a.scroll"


setCenterLiFocus = () ->
    [].forEach.call themeLis, (li) ->
        li.classList.remove "focus"
        if li.offsetLeft < themeUl.scrollLeft + winMid < li.offsetLeft + li.clientWidth
            li.classList.add "focus"


setScrollPos = () ->
    scrollDiv = themeNav.querySelector ".scroll-bar"
    scrollA = scrollDiv.querySelector "a.scroll-bar-center"
    scrollProp = themeUl.scrollLeft/themeUl.scrollWidth
    scrollLeft = scrollProp * scrollDiv.clientWidth

    scrollA.style.left = scrollLeft + "px"

handleScrollEnd = (e) ->
    setDelay () ->
        setCenterLiFocus()
        setScrollPos()
    , 20

[].forEach.call scrollBtns, (a) ->
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
    focusCenter = themeUl.querySelector(".focus").offsetLeft + liWidth/2
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

    [].forEach.call themeLis, (li) ->
        bean.on li, "mouseover", (e) ->
            [].forEach.call themeLis, (li_) ->
                li_.classList.remove "focus"
            this.classList.add "focus"
