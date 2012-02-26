/* namespace
*/
var BucketFiller, Point, isInCanvas, log, main;

log = function() {
  return console.log(arguments);
};

isInCanvas = function(ctx, pixel) {
  var result, _ref, _ref2;
  result = ((0 <= (_ref = pixel.x) && _ref <= ctx.canvas.width)) && ((0 <= (_ref2 = pixel.y) && _ref2 <= ctx.canvas.height));
  return result;
};

Point = (function() {

  function Point(x, y) {
    this.x = x;
    this.y = y;
  }

  return Point;

})();

BucketFiller = (function() {

  function BucketFiller() {}

  BucketFiller.prototype.MAXITERATION = 100000;

  BucketFiller.prototype.factor = 1;

  BucketFiller.prototype.fill = function(ctx, pixel, colCible, colRep) {
    var P, currentpixel, max;
    P = [];
    max = this.MAXITERATION;
    if (this.getColorAtPixel(ctx, pixel) !== colCible) return null;
    P.push(pixel);
    while (P.length > 0 && max >= 0) {
      --max;
      currentpixel = P.pop();
      this.fillRect(ctx, currentpixel.x, currentpixel.y, this.factor, this.factor, colRep);
      if (this.isInCanvas(ctx, currentpixel)) {
        if (this.getColorAtPixel(ctx, this.up(currentpixel)) === colCible) {
          P.push(this.up(currentpixel));
        }
        if (this.getColorAtPixel(ctx, this.down(currentpixel)) === colCible) {
          P.push(this.down(currentpixel));
        }
        if (this.getColorAtPixel(ctx, this.right(currentpixel)) === colCible) {
          P.push(this.right(currentpixel));
        }
        if (this.getColorAtPixel(ctx, this.left(currentpixel)) === colCible) {
          P.push(this.left(currentpixel));
        }
      }
    }
  };

  BucketFiller.prototype.fillRect = function(ctx, x, y, width, height, color) {
    ctx.fillStyle = color;
    ctx.fillRect(x, y, width, height);
  };

  BucketFiller.prototype.down = function(pixel) {
    return {
      x: pixel.x,
      y: pixel.y - this.factor
    };
  };

  BucketFiller.prototype.up = function(pixel) {
    return {
      x: pixel.x,
      y: pixel.y + this.factor
    };
  };

  BucketFiller.prototype.right = function(pixel) {
    return {
      x: pixel.x + this.factor,
      y: pixel.y
    };
  };

  BucketFiller.prototype.left = function(pixel) {
    return {
      x: pixel.x - this.factor,
      y: pixel.y
    };
  };

  BucketFiller.prototype.getColorAtPixel = function(ctx, pixel) {
    var imageData;
    try {
      imageData = ctx.getImageData(pixel.x, pixel.y, 1, 1);
    } catch (e) {
      return null;
    }
    return this.rgbArrayToCssColorString(imageData.data);
  };

  BucketFiller.prototype.rgbArrayToCssColorString = function(array) {
    var result;
    result = "rgb(" + array[0] + "," + array[1] + "," + array[2] + ")";
    return result;
  };

  BucketFiller.prototype.isInCanvas = function(ctx, pixel) {
    var result, _ref, _ref2;
    result = ((0 <= (_ref = pixel.x) && _ref <= ctx.canvas.width)) && ((0 <= (_ref2 = pixel.y) && _ref2 <= ctx.canvas.height));
    return result;
  };

  return BucketFiller;

})();

main = function() {
  var buckfiller, canvas, colCible, ctx, fillColor, penPosition;
  buckfiller = new BucketFiller();
  log("début du script");
  canvas = document.getElementById("canvas");
  ctx = canvas.getContext("2d");
  ctx.fillStyle = "0F0";
  ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  ctx.fillStyle = "#0FF";
  ctx.fillRect(10, 10, 40, 40);
  ctx.fillStyle = "#F0F";
  ctx.save();
  ctx.rotate(50);
  ctx.fillRect(50, 30, 40, 40);
  ctx.restore();
  penPosition = new Point(2, 10);
  fillColor = "rgb(255,0,0)";
  colCible = buckfiller.getColorAtPixel(ctx, penPosition);
  try {
    return buckfiller.fill(ctx, penPosition, colCible, fillColor);
  } catch (e) {
    return log(e);
  }
};

window.onload = function() {
  return main();
};
