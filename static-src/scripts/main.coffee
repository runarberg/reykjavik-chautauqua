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
        [].forEach.call themeLis, (li) ->
            offsetLeft = li.offsetLeft - themeNav.scrollLeft
            if winMid-li.clientWidth < offsetLeft < winMid
                li.classList.add "focus"
            else
                li.classList.remove "focus"
    , 50

themeNav.addEventListener "mouseout", (e) ->
    this.removeEventListener "mousemove", setScrollFn
    if scroller
        clearInterval scroller


document.addEventListener "DOMContentLoaded", () ->
    winWidth = window.innerWidth
    liWidth = themeNav.firstChild.clientWidth
    padding = (winWidth / 2) - (liWidth / 2)
    themeNav.firstChild.style.marginLeft = "#{padding}px"
    themeNav.lastChild.style.marginRight = "#{padding}px"
