var MAXSTACK, bucketFill, getColorAtPixel, isInCanvas, log, main, pixels, rgbArrayToCssColorString;

log = function() {
  return console.log(arguments);
};

pixels = [];

MAXSTACK = 0;

isInCanvas = function(ctx, pixel) {
  var result, _ref, _ref2;
  result = ((0 <= (_ref = pixel.x) && _ref <= ctx.canvas.width)) && ((0 <= (_ref2 = pixel.y) && _ref2 <= ctx.canvas.height));
  return result;
};

bucketFill = function(ctx, pixel, colcible, colrep) {
  var down, left, right, up;
  MAXSTACK += 1;
  if (!isInCanvas(ctx, pixel)) return null;
  if (getColorAtPixel(ctx, pixel) === colcible) {
    ctx.fillStyle = colrep;
    ctx.fillRect(pixel.x, pixel.y, 1, 1);
    pixels.push(pixel);
    left = {
      x: pixel.x,
      y: pixel.y - 1
    };
    right = {
      x: pixel.x,
      y: pixel.y + 1
    };
    up = {
      x: pixel.x + 1,
      y: pixel.y
    };
    down = {
      x: pixel.x - 1,
      y: pixel.y
    };
    if (!(!isInCanvas(ctx, left) || getColorAtPixel(ctx, left) !== colcible)) {
      bucketFill(ctx, left, colcible, colrep);
    }
    if (!(!isInCanvas(ctx, right) || getColorAtPixel(ctx, right) !== colcible)) {
      bucketFill(ctx, right, colcible, colrep);
    }
    if (!(!isInCanvas(ctx, up) || getColorAtPixel(ctx, up) !== colcible)) {
      bucketFill(ctx, up, colcible, colrep);
    }
    if (!(!isInCanvas(clx, down) || getColorAtPixel(ctx, up) !== colCible)) {
      bucketFill(ctx, down, colcible, colrep);
    }
  }
};

getColorAtPixel = function(ctx, pixel) {
  var imageData;
  imageData = ctx.getImageData(pixel.x, pixel.y, 1, 1);
  return rgbArrayToCssColorString(imageData.data);
};

rgbArrayToCssColorString = function(array) {
  var i, result;
  result = "#";
  for (i = 0; i <= 2; i++) {
    result += array[i];
  }
  return result;
};

main = function() {
  var canvas, colCible, ctx, fillColor, penPosition;
  log("début du script");
  canvas = document.getElementById("canvas");
  ctx = canvas.getContext("2d");
  ctx.fillStyle = "#0FF";
  ctx.fillRect(10, 10, 40, 40);
  penPosition = {
    x: 1,
    y: 1
  };
  fillColor = "#FF0000";
  colCible = getColorAtPixel(ctx, penPosition);
  try {
    bucketFill(ctx, penPosition, colCible, fillColor);
  } catch (e) {
    log(e, MAXSTACK);
  }
  log(colCible);
  return log(MAXSTACK);
};

window.onload = function() {
  return main();
};
