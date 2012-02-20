log = ->
  console.log arguments
pixels = []
MAXSTACK = 0
isInCanvas = (ctx,pixel)->
  result = ((0 <= pixel.x <= ctx.canvas.width) and (0 <= pixel.y <= ctx.canvas.height))
  return result

bucketFill = (ctx,pixel, colcible, colrep)->
    #console.log("bucketFill",ctx,pixel.x,pixel.y,colcible,colrep)
    MAXSTACK+=1
    #if MAXSTACK < 50000 then log MAXSTACK
    if !isInCanvas(ctx,pixel) then return null
    #if pixels.indexOf(pixel)!=-1 then return null
    if getColorAtPixel(ctx,pixel) == colcible
      ctx.fillStyle = colrep
      ctx.fillRect(pixel.x,pixel.y,1,1)
      pixels.push(pixel)
      left = {x:pixel.x,y:pixel.y-1}
      right = {x:pixel.x,y:pixel.y+1}
      up = {x:pixel.x+1,y:pixel.y}
      down = {x:pixel.x-1,y:pixel.y}
      bucketFill(ctx,left,colcible,colrep) unless (!isInCanvas(ctx,left) or getColorAtPixel(ctx,left)!=colcible)
      bucketFill(ctx,right,colcible,colrep) unless (!isInCanvas(ctx,right) or getColorAtPixel(ctx,right)!=colcible)
      bucketFill(ctx,up,colcible,colrep) unless (!isInCanvas(ctx,up) or getColorAtPixel(ctx,up)!=colcible)
      bucketFill(ctx,down,colcible,colrep) unless( !isInCanvas(clx,down) or getColorAtPixel(ctx,up)!=colCible)
    return
    
getColorAtPixel=(ctx,pixel)->
    imageData = ctx.getImageData(pixel.x,pixel.y,1,1)
    return rgbArrayToCssColorString(imageData.data)
    
rgbArrayToCssColorString=(array)->
    #log(["rgbArrayToCssColorString",array])
    result = "#"
    result+=array[i] for i in [0..2]
    return result

main=->
    
    log("début du script")
    canvas  = document.getElementById("canvas")
    ctx = canvas.getContext("2d")
    ctx.fillStyle = "#0FF"
    ctx.fillRect(10,10,40,40)
    penPosition = {x:1,y:1}
    fillColor = "#FF0000"
    colCible = getColorAtPixel(ctx,penPosition)
    try
      bucketFill(ctx,penPosition,colCible,fillColor)
    catch e
      log e,MAXSTACK
    log(colCible)
    log(MAXSTACK)
window.onload=->
  main()
