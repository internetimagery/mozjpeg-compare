mozjpeg = require 'mozjpeg-stream'
fs = require 'fs'
path = require 'path'
resemble = require 'node-resemble-js'

COMPARE = path.join __dirname, "comparisons"
SRC = path.join COMPARE, "source.jpg"
QUALITY = path.join COMPARE, "quality"
DIFF = path.join COMPARE, "diff"

for i in [0 .. 10]
  i *= 10
  do (i)->
    diff = path.join COMPARE, "diff#{i}.jpg"
    quality = path.join COMPARE, "quality#{i}.jpg"
    cmp = fs.createWriteStream diff
    out = fs.createWriteStream quality
    .on "error", (err)->
      console.error err
    .on "close", ->
      console.log "Comparing #{i}."
      resemble SRC
      .compareTo quality
      .onComplete (data)->
        data.getDiffImage().pack().pipe cmp

    fs.createReadStream SRC
    .pipe mozjpeg {quality: i}
    .pipe out
    .on "error", (err)->
      console.error err
