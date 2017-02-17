mozjpeg = require 'mozjpeg-stream'
fs = require 'fs'
path = require 'path'
resemble = require 'node-resemble-js'

COMPARE = path.join __dirname, "comparisons"
SRC = path.join COMPARE, "source.jpg"
QUALITY = path.join COMPARE, "quality"
DIFF = path.join COMPARE, "diff"

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
