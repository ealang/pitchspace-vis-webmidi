# get color for midi note number
colorGen = (note_num) ->
    sat = 0.6
    val = 0.7
    hue = ((note_num*7) % 12)/12 * 360
    c = val * sat
    x = c * (1-Math.abs((hue/60) % 2 - 1))
    m = val - c
    comp = if 0 <= hue < 60 then [c, x, 0]
    else if 60 <= hue < 120 then [x, c, 0]
    else if 120 <= hue < 180 then [0, c, x]
    else if 180 <= hue < 240 then [0, x, c]
    else if 240 <= hue < 300 then [x, 0, c]
    else if 300 <= hue < 360 then [c, 0, x]
    "#" + (for c in comp
        digit = Math.floor(((c+m)*255)).toString(16)
        if digit.length == 2 then digit else "0" + digit).join("")

startMidi (midi) ->
    view = new View(colorGen)
    view.init()
    if !midi.isValid
        view.showError()
    new App(view, midi)
    
