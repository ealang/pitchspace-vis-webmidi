S = "\u266F"
F = "\u266D"

noteLabelToInt =
    "c": 0
    "d": 2
    "e": 4
    "f": 5
    "g": 7
    "a": 9
    "b": 11

getNoteName = (noteLabel, accidentalStep) ->
    noteLabel.toUpperCase() + switch (accidentalStep)
        when 0 then ''
        when 1 then S
        when 2 then S+S
        when -1 then F
        when -2 then F+F
        else '?'

getTeoriaScale = (modeLabel, tonicLabel) ->
    teoriaLabel = (str) ->
        str.toLowerCase()
           .replace(/\u266F/g,'#')
           .replace(/\u266D/g,'b')
    teoria.scale(teoriaLabel(tonicLabel), teoriaLabel(modeLabel))

window.getScale = (modeLabel, tonicLabel) ->
    scale = getTeoriaScale(modeLabel, tonicLabel)
    return scale.notes.map (n, i) ->
        return {
            label: getNoteName(n.name, n.accidental.value)
            step: (noteLabelToInt[n.name] + 12 + n.accidental.value) % 12
            triad: scale.scale[i]
        }
