themeNav = document.querySelector ".theme-nav ul"
themeLis = themeNav.querySelectorAll "li"
winMid = window.innerWidth/2

scroller = null
scrollFn = () ->

setScrollFn = (e) ->
    if Math.abs(e.pageX - winMid) > 200
        scrollFn = () ->
            themeNav.scrollLeft += (e.pageX - winMid) / 25
    else
        scrollFn = () ->

themeNav.addEventListener "mouseover", (e) ->
    this.addEventListener "mousemove", setScrollFn

    scroller = setInterval () ->
        scrollFn()
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


themeNav.addEventListener "touchmove", (e) ->
    [].forEach.call themeLis, (li) ->
        li.classList.remove "focus"
        if li.offsetLeft < themeNav.scrollLeft + winMid < li.offsetLeft + li.clientWidth
            li.classList.add "focus"


document.addEventListener "DOMContentLoaded", () ->
    winWidth = window.innerWidth
    liWidth = themeNav.firstChild.clientWidth
    padding = (winWidth / 2) - (liWidth / 2)
    themeNav.firstChild.style.marginLeft = "#{padding}px"
    themeNav.lastChild.style.marginRight = "#{padding}px"
