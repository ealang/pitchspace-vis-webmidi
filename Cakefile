{exec} = require "child_process"

listOfFiles = "coffee/scale.coffee coffee/midi.coffee coffee/view.coffee coffee/app.coffee coffee/boot.coffee"

task "watch", "Build project from coffee/*.coffee to js/pitchspace.js", ->
  child = exec " coffee -w -j pitchspace.js -c -o js/ " + listOfFiles, (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
  child.stdout.on 'data', (data) -> console.log data
  
