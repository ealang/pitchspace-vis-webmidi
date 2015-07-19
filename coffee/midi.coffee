# decode a web midi api event 
decodeMidiEvent = (event) ->
    [d1, d2, d3] = event.data
    noteOn = (d1 & 0xF0) == 0x90
    noteOff = (d1 & 0xF0) == 0x80
    return {
        isNoteEvent: noteOn || noteOff
        noteOn: noteOn
        velocity: d3
        noteNum: d2 }

class MidiInstance
    constructor: (access) ->
        inputs = []
        access?.inputs.forEach((device) => inputs.push(device))

        @inputs = inputs
        @userCallback = null
        @selectedInput = null
        @isValid = access != null

        @onmidimessage = (event) =>
            note = decodeMidiEvent(event)
            if @userCallback != null and note.isNoteEvent
                @userCallback(note)
        
    selectDevice: (id) ->
        if @selectedInput != null
            @inputs[@selectedInput].onmidimessage = undefined
        @selectedInput = id
        @inputs[id].onmidimessage = @onmidimessage

    getDevicesList: ->
        input.name for input in @inputs
    
    onKeyPress: (callback) ->
        @userCallback = callback

# start web midi, receive a MidiInstance via callback
window.startMidi = (callback) ->
    onsuccesscallback = (access)->
        callback(new MidiInstance(access))

    onerrorcallback = (err) ->
        console.log("Error initializing midi: " + err.code )
        callback(new MidiInstance(null))

    navigator.requestMIDIAccess().then(onsuccesscallback, onerrorcallback)

