S = "\u266F"
F = "\u266D"

INITMODE = 1
INITTONIC = 0

MODES = [
    "Lydian",
    "Ionian",
    "Mixolydian",
    "Dorian",
    "Aeolian",
    "Phrygian",
    "Locrian"]

TONICS = ["C", "C" + S, "D", "D" + S, "E", "F", "F" + S, "G", "G" + S, "A", "A" + S, "B",
          "C", "D" + F, "D", "E" + F, "E", "F", "G" + F, "G", "A" + F, "A", "B" + F, "B"]

class App
    constructor: (view, midi) ->
        activeNotes = []
        selected =
            mode: INITMODE
            tonic: INITTONIC
            device: 0

        devices = midi.getDevicesList()
        midi.selectDevice(0) if devices.length >= 1
    
        drawApp = ->
            view.drawAppPage(MODES[selected.mode], TONICS[selected.tonic], getScale(MODES[selected.mode], TONICS[selected.tonic]))

        view.onClickSettings = (option, val) ->
            switch (option)
                when "mode" then selected.mode = val
                when "tonic" then selected.tonic = val
                when "device"
                    selected.device = val
                    midi.selectDevice(val)
                    activeNodes = []
            drawApp()

        view.drawSettingsPage(MODES, TONICS, devices, selected.mode, selected.tonic, selected.device)
        drawApp()

        midi.onKeyPress (event) ->
            if event.noteOn == on and (event.noteNum in activeNotes) == no
                activeNotes.push(event.noteNum)
                view.drawNoteAttack(event.noteNum, event.velocity)
            else if event.noteOn == off and (event.noteNum in activeNotes)
                activeNotes.splice(activeNotes.indexOf(event.noteNum), 1)
                view.drawNoteRelease(event.noteNum)
            view.drawActiveNotes(activeNotes)
