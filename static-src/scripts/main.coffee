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

scroller = null
scrollBtns = themeNav.querySelectorAll "a.scroll"
scrollFn = () ->

setScrollFn = (e) ->
    if Math.abs(e.pageX - winMid) > 200
        scrollFn = () ->
            themeUl.scrollLeft += (e.pageX - winMid) / 25
    else
        scrollFn = () ->


handleScrollEnd = (e) ->
    setDelay (e) ->
        [].forEach.call themeLis, (li) ->
            li.classList.remove "focus"
            if li.offsetLeft < themeUl.scrollLeft + winMid < li.offsetLeft + li.clientWidth
                li.classList.add "focus"
    , 20

[].forEach.call scrollBtns, (a) ->
    a.addEventListener "click", (e) ->
        liWidth = themeLis[0].clientWidth
        e.preventDefault()
        if this.classList.contains "left"
            themeUl.scrollLeft -= liWidth
        else
            themeUl.scrollLeft += liWidth
        handleScrollEnd e


document.addEventListener "DOMContentLoaded", () ->
    winWidth = window.innerWidth
    liWidth = themeUl.firstChild.clientWidth
    padding = (winWidth / 2) - (liWidth / 2)
    themeUl.firstChild.style.marginLeft = "#{padding}px"
    themeUl.lastChild.style.marginRight = "#{padding}px"
    focusCenter = themeUl.querySelector(".focus").offsetLeft + liWidth/2
    themeUl.scrollLeft = focusCenter - themeNav.clientWidth/2

    if 'ontouchstart' in window
        themeUl.addEventListener "scroll", handleScrollEnd

    unless 'ontouchstart' in window
        themeNav.addEventListener "mouseover", (e) ->
            this.addEventListener "mousemove", setScrollFn

            scroller = setInterval () ->
                scrollFn()
                if e.target in scrollBtns
                    handleScrollEnd e
            , 50


        [].forEach.call themeLis, (li) ->
            li.addEventListener "mouseover", () ->
                [].forEach.call themeLis, (li_) ->
                    li_.classList.remove "focus"
                    
                this.classList.add "focus"


        themeNav.addEventListener "mouseout", (e) ->
            this.removeEventListener "mousemove", setScrollFn
            if scroller
                clearInterval scroller
