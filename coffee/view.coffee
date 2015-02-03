class window.View
    PI = 3.1416
    RELEASE_TIME = 1000

    scaling = do ->
        INNERR = 100/3.7
        OUTERR = 100/2.3
        MIDDLER = (INNERR + OUTERR) / 2
        SEGPADDING = 0.7
        return {
            segPadding: SEGPADDING
            size: 100
            innerR: INNERR
            outerR: OUTERR
            middleR: MIDDLER
            segPaddingR: SEGPADDING / MIDDLER
        }

    getNoteAngle = (i) -> ((i + 9) % 12 ) * 2 * PI / 12

    makeNoteArc = (i) ->
        note = (i + 12) % 12
        offsetR = 2*PI / 24
        startAngle = i/12 * 2*PI - 1/12*PI
        endAngle = startAngle + 1/12 * 2*PI

        d3.svg.arc()
          .innerRadius(scaling.innerR+scaling.segPadding)
          .outerRadius(scaling.outerR-scaling.segPadding)
          .startAngle(startAngle + scaling.segPaddingR/2)
          .endAngle(endAngle - scaling.segPaddingR/2)()

    layers = do -> # initialize SVG
        svg = d3.select("#circle")
                .attr("width", "100%")
                .attr("height", "100%")
                .attr("viewBox", "0 0 100 100")
                .attr("preserveAspectRatio", "xMidYMid")
        svgRoot = svg.append("g")
                     .attr("transform","translate(50,50)")
        svgApp = svgRoot.append("g")
        tonicLists = d3.selectAll("ul.settings-tonic")[0]
        return {
            root: svg
            background: svgApp.append("g")
            sustain: svgApp.append("g")
            release: svgApp.append("g")
            attack: svgApp.append("g")
            noteLabels: svgApp.append("g").attr("id", "ring-note-labels")
            degreeLabels: svgApp.append("g").attr("id", "ring-degree-labels")
            keyName: svgApp.append("g").attr("id", "selected-key")
            settingsTonics: (d3.select(l) for l in tonicLists)
            settingsMode: d3.select("#settings-mode")
            settingsDevices: d3.select("#settings-devices-list")
            settingsBackground: d3.select("#settings-background")
            errorMsg: d3.select("#midi-error-msg")
        }

    toggleSettingsPage = ->
        settings = d3.select("#settings")
        curDisp = settings.style("display")
        settings.style("display", if curDisp != "none" then "none" else "block")

    constructor: (@noteColors) ->
        @onClickSettings = null

    init: () -> # draw circle
        ring = d3.svg.arc().innerRadius(scaling.innerR).outerRadius(scaling.outerR).startAngle(0).endAngle(2 * PI)
        buttonR = scaling.size * 0.07

        layers.root.on("click", -> toggleSettingsPage())

        # current key
        layers.keyName.append("text")
              .text("")
              .attr("dy", "0.1em")

        # ring
        layers.background.append("g")
              .attr("id", "ring-background")
              .append("path")
              .attr("d", ring)
        layers.background.append("g")
              .attr("id", "ring-segments")
              .selectAll("path")
              .data(d3.range(0, 12))
              .enter()
              .append("path")
              .attr("d", makeNoteArc)

    drawSettingsPage: (modeList, tonicList, devicesList, selectedMode, selectedTonic, selectedDev) ->
        listsize = tonicList.length / 2
        ulify = (data) ->
            return (sel) ->
                context = sel.selectAll("li").data(data)
                context.enter()
                       .append("li")
                context.text((label) -> label)
                       .attr("class", "list-item")

        drawSelection = (selectors, index) ->
            selectors.forEach (selector, i) ->
                lis = selector.selectAll("li")
                lis.attr("class", "list-item")
                if index >= (i * listsize) and index < ((i + 1) * listsize)
                    d3.select(lis[0][index%listsize]).attr("class", "selected list-item")

        attachClickHandler = (selectors, label, handler) ->
            selectors.forEach (selector, selIndex) ->
                selector.selectAll(".list-item").on("click", (text, i) ->
                    item = selIndex * listsize + i
                    drawSelection(selectors, item)
                    handler(label, item))

        layers.settingsTonics[0].call(ulify(tonicList.slice(0, listsize)))
        layers.settingsTonics[1].call(ulify(tonicList.slice(listsize, listsize * 2)))
        layers.settingsMode.call(ulify(modeList))
        layers.settingsDevices.call(ulify(devicesList))

        drawSelection([layers.settingsDevices], selectedDev)
        drawSelection([layers.settingsMode], selectedMode)
        drawSelection(layers.settingsTonics, selectedTonic)

        attachClickHandler([layers.settingsDevices], "device", @onClickSettings)
        attachClickHandler([layers.settingsMode], "mode", @onClickSettings)
        attachClickHandler(layers.settingsTonics, "tonic", @onClickSettings)

        layers.settingsBackground.on("click", ->
            toggleSettingsPage())

    drawAppPage: (modeLabel, tonicLabel, scale) ->
        degLabelR = scaling.innerR * 0.9

        layers.attack.selectAll("path").remove()
        layers.release.selectAll("path").remove()
        layers.sustain.selectAll("path").remove()

        # key in center
        layers.keyName.select("text")
              .text(modeLabel)
              .style("fill", @noteColors(scale[0].step))

        # degree labels
        do =>
            degreeName = (note, i) ->
                degree = ['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii'][i]
                return switch note.triad
                    when "major" then degree.toUpperCase()
                    when "dim" then degree + "\u00B0"
                    when "aug" then degree.toUpperCase() + "+"
                    when "minor" then degree
                    else "?"

            sel = layers.degreeLabels.selectAll("text")
                        .data(scale, (note, i) -> i)
            sel.enter()
               .append("text")
               .attr("dy", "0.3em")
            sel.text((note) -> note.triad)
               .transition()
               .attr("x", (note) -> degLabelR * Math.cos(getNoteAngle(note.step)))
               .attr("y", (note) -> degLabelR * Math.sin(getNoteAngle(note.step)))
               .style("fill", (note) => @noteColors(note.step))
            sel.exit().remove()

        # note labels
        do ->
            scale = getScale(modeLabel, tonicLabel)
            sel = layers.noteLabels.selectAll("text")
                        .data(scale)
            sel.enter()
               .append("text")
               .attr("dy", "0.3em")
            sel.text( (note, i) -> note.label )
               .attr("x", (note) -> scaling.middleR * Math.cos(getNoteAngle(note.step)))
               .attr("y", (note) -> scaling.middleR * Math.sin(getNoteAngle(note.step)))
            sel.exit().remove()

    drawActiveNotes: (notes) ->
        sel = layers.sustain.selectAll("path")
                    .data(notes, (note) -> note)
        sel.enter()
           .append("path")
           .attr("d", (note) -> makeNoteArc(note))
           .attr("fill", (note) => @noteColors(note))
        sel.exit().remove()
    
    drawNoteRelease: (note) ->
        layers.release.append("path")
              .attr("d", makeNoteArc(note))
              .attr("fill", @noteColors(note))
              .style("opacity", 1)
              .transition().duration(RELEASE_TIME)
              .ease((t) -> 1-Math.pow(1-t, 3))
              .style("opacity", "0")
              .remove()

    drawNoteAttack: (note, velocity) ->
        layers.attack.append("path")
              .attr("d", makeNoteArc(note))
              .style("opacity", 0.1+(velocity/127)*0.9)
              .style("fill", "white")
              .transition().duration("300")
              .style("opacity", "0")
              .remove()

    showError: ->
        layers.errorMsg.style("display", "block")
