### namespace ###

log = ->
  console.log arguments

isInCanvas = (ctx,pixel)->
  result = ((0 <= pixel.x <= ctx.canvas.width) and (0 <= pixel.y <= ctx.canvas.height))
  return result

class Point
  constructor:(@x,@y)->

class BucketFiller
  MAXITERATION:100000
  factor:1
  fill : (ctx,pixel, colCible, colRep)->
    P = []
    max = @MAXITERATION
    if @getColorAtPixel(ctx,pixel)!=colCible then return null
    P.push(pixel)
    while  P.length > 0 and max >=0
      --max
      currentpixel = P.pop()
      @fillRect(ctx,currentpixel.x,currentpixel.y,@factor,@factor,colRep)
      if @isInCanvas(ctx,currentpixel)
        if @getColorAtPixel(ctx,@up(currentpixel)) == colCible then P.push(@up(currentpixel))
        if @getColorAtPixel(ctx,@down(currentpixel)) == colCible then P.push(@down(currentpixel))
        if @getColorAtPixel(ctx,@right(currentpixel)) == colCible then P.push(@right(currentpixel))
        if @getColorAtPixel(ctx,@left(currentpixel)) == colCible then P.push(@left(currentpixel))
    return

  fillRect:(ctx,x,y,width,height,color)->
    ctx.fillStyle = color
    ctx.fillRect(x,y,width,height)
    return
  down :(pixel)->
    return {x:pixel.x,y:pixel.y-@factor}

  up:(pixel)->
    return {x:pixel.x,y:pixel.y+@factor}

  right :(pixel)->
    return {x:pixel.x+@factor,y:pixel.y}

  left :(pixel)->
    return {x:pixel.x-@factor,y:pixel.y}

  getColorAtPixel:(ctx,pixel)->
    try
      imageData = ctx.getImageData(pixel.x,pixel.y,1,1)
    catch e
      return null
    return @rgbArrayToCssColorString(imageData.data)
      
  rgbArrayToCssColorString:(array)->
    result = "rgb(#{array[0]},#{array[1]},#{array[2]})"
    return result

  isInCanvas : (ctx,pixel)->
    result = ((0 <= pixel.x <= ctx.canvas.width) and (0 <= pixel.y <= ctx.canvas.height))
    return result

main=->
    buckfiller = new BucketFiller()
    log("début du script")
    canvas  = document.getElementById("canvas")
    ctx = canvas.getContext("2d")
    ctx.fillStyle = "0F0"
    ctx.fillRect(0,0,ctx.canvas.width,ctx.canvas.height)
    ctx.fillStyle = "#0FF"
    ctx.fillRect(10,10,40,40)
    ctx.fillStyle = "#F0F"
    ctx.save()
    ctx.rotate(50)
    ctx.fillRect(50,30,40,40)
    ctx.restore()
    penPosition = new Point(2,10)
    fillColor = "rgb(255,0,0)"
    colCible = buckfiller.getColorAtPixel(ctx,penPosition)
    try
      buckfiller.fill(ctx,penPosition,colCible,fillColor)
    catch e
      log e

window.onload=->
  main()
