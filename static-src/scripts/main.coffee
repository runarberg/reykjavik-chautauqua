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


handleScrollEnd = (e, focus=true) ->
    setDelay () ->
        setCenterLiFocus() if focus
        scrollDiv = themeNav.querySelector ".scroll-bar"
        scrollA = scrollDiv.querySelector "a.scroll-bar-center"
        scrollProp = themeUl.scrollLeft/themeUl.scrollWidth
        scrollLeft = scrollProp * scrollDiv.clientWidth

        scrollA.style.left = scrollLeft + "px"
    , 20

[].forEach.call scrollBtns, (a) ->
    a.addEventListener "click", (e) ->
        liWidth = themeLis[0].clientWidth
        e.preventDefault()
        if this.classList.contains "left"
            stop = Math.max(themeUl.scrollLeft - liWidth, 0)
            scrolling = window.setInterval () ->
                if themeUl.scrollLeft <= stop
                    window.clearInterval scrolling
                    handleScrollEnd e
                else
                    themeUl.scrollLeft -= if themeUl.scrollLeft - stop < 50 then 5 else 25
            , 10
        else
            stop = Math.min(themeUl.scrollLeft + liWidth, themeUl.scrollWidth)
            scrolling = window.setInterval () ->
                if themeUl.scrollLeft >= stop
                    window.clearInterval scrolling
                    handleScrollEnd e
                else
                    themeUl.scrollLeft += if stop - themeUl.scrollLeft < 50 then 5 else 25
            , 10


document.addEventListener "DOMContentLoaded", () ->
    winWidth = window.innerWidth
    liWidth = themeUl.firstChild.clientWidth
    padding = (winWidth / 2) - (liWidth / 2)
    themeUl.firstChild.style.marginLeft = "#{padding}px"
    themeUl.lastChild.style.marginRight = "#{padding}px"
    focusCenter = themeUl.querySelector(".focus").offsetLeft + liWidth/2
    themeUl.scrollLeft = focusCenter - themeNav.clientWidth/2

    # add scroll bar at bottom
    (() ->
        div = document.createElement "div"
        div.className = "scroll-bar"
        
        a = document.createElement "a"
        a.className = "scroll-bar-center"
        a.href = "#"

        div.appendChild a
        themeNav.appendChild div

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

        a.addEventListener "click", (e) ->
            e.preventDefault()

        a.addEventListener "mousedown", (e) ->
            e.preventDefault()
            document.body.addEventListener "mousemove", doScrollThemes
            document.body.addEventListener "mouseup", (e) ->
                document.body.removeEventListener "mousemove", doScrollThemes
    )()

    themeUl.addEventListener "scroll", (e) ->
        handleScrollEnd(e)

    [].forEach.call themeLis, (li) ->
        li.addEventListener "mouseover", (e) ->
            [].forEach.call themeLis, (li_) ->
                li_.classList.remove "focus"
            this.classList.add "focus"
