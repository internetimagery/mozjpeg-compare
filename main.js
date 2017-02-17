(function() {
  var COMPARE, DIFF, QUALITY, SRC, fs, mozjpeg, path, resemble;

  mozjpeg = require('mozjpeg-stream');

  fs = require('fs-extra');

  path = require('path');

  resemble = require('node-resemble-js');

  resemble.outputSettings({
    largeImageThreshold: 0,
    transparency: true
  });

  SRC = path.join(__dirname, "source.jpg");

  COMPARE = path.join(__dirname, "comparisons");

  QUALITY = path.join(COMPARE, "quality");

  DIFF = path.join(COMPARE, "diff");

  fs.emptyDir(QUALITY, function(err) {
    if (err) {
      return console.error(err);
    }
    return fs.emptyDir(DIFF, function(err) {
      var i, j, results;
      if (err) {
        return console.error(err);
      }
      results = [];
      for (i = j = 1; j <= 10; i = ++j) {
        i = Math.pow(i, 2);
        results.push((function(i) {
          var cmp, diff, out, quality;
          diff = path.join(DIFF, "diff" + i + ".jpg");
          quality = path.join(QUALITY, "quality" + i + ".jpg");
          cmp = fs.createWriteStream(diff).on("error", function(err) {
            return console.error(err);
          }).on("close", function() {
            return console.log("Done " + i + ".");
          });
          out = fs.createWriteStream(quality).on("error", function(err) {
            return console.error(err);
          }).on("close", function() {
            console.log("Compressed " + i + ".");
            return resemble(SRC).compareTo(quality).ignoreNothing().onComplete(function(data) {
              console.log("Compared " + i + ".");
              return data.getDiffImage().pack().pipe(cmp);
            });
          });
          return fs.createReadStream(SRC).pipe(mozjpeg({
            quality: i
          })).pipe(out).on("error", function(err) {
            return console.error(err);
          });
        })(i));
      }
      return results;
    });
  });

}).call(this);
