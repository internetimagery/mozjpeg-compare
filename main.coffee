mozjpeg = require 'mozjpeg-stream'
fs = require 'fs-extra'
path = require 'path'
resemble = require 'node-resemble-js'

SRC = path.join __dirname, "source.jpg"
COMPARE = path.join __dirname, "comparisons"
QUALITY = path.join COMPARE, "quality"
DIFF = path.join COMPARE, "diff"

fs.emptyDir QUALITY, (err)->
  return console.error err if err
  fs.emptyDir DIFF, (err)->
    return console.error err if err
    for i in [1 .. 10]
      i = i**2
      do (i)->
        diff = path.join DIFF, "diff#{i}.jpg"
        quality = path.join QUALITY, "quality#{i}.jpg"
        cmp = fs.createWriteStream diff
        .on "error", (err)-> console.error err
        .on "close", -> console.log "Done #{i}."
        out = fs.createWriteStream quality
        .on "error", (err)-> console.error err
        .on "close", ->
          console.log "Compressed #{i}."
          resemble SRC
          .compareTo quality
          .onComplete (data)->
            console.log "Compared #{i}."
            data.getDiffImage().pack().pipe cmp

        fs.createReadStream SRC
        .pipe mozjpeg {quality: i}
        .pipe out
        .on "error", (err)-> console.error err
