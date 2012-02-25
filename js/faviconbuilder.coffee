
###
  Icon builder
  copyright 2010 Marc Paraiso
  license : all right reserved
  created with vim , coffeescript and chrome
  version 0.1
  contact mparaiso@online.fr
  @author  Marc Paraiso
  @version 0.1
  @description  an online icon builder in javascript.It Helps designers create pixel art icons for the web , sprites or favicons
  online.
  @link mparaiso@online.fr
###

#

Array.prototype.split = (index)->
  if index < this.length
    q = this.length-index
    return this.splice(index,q)

App ?={
  Views :{}
  Models :{}
  Controllers:{}
  Utils:{}
}

### UTILITIES ###
class App.Utils.DefaultColors
  constructor:->
    @colors =[
      new App.Models.Color("White","#FFF")
      new App.Models.Color("Gray2","#DDD")
      new App.Models.Color("Gray1","#AAA")
      new App.Models.Color("Gray2","#777")
      new App.Models.Color("Black","#000")
      new App.Models.Color("Red","#900")
      new App.Models.Color("Red","#F00")
      new App.Models.Color("Red","#F99")
      new App.Models.Color("Red","#FDD")
      new App.Models.Color("Green","#090")
      new App.Models.Color("Green","#0F0")
      new App.Models.Color("Green","#9F9")
      new App.Models.Color("Green","#DFD")
      new App.Models.Color("Blue","#009")
      new App.Models.Color("Blue","#00F")
      new App.Models.Color("Blue","#99F")
      new App.Models.Color("Blue","#DDF")
      new App.Models.Color("Yellow","#FF0")
      new App.Models.Color("Yellow","#F90")
      new App.Models.Color("Cyan","#0FF")
      new App.Models.Color("Cyan","#099")
      new App.Models.Color("Magenta","#F0F")
      new App.Models.Color("Magenta","#909")
      new App.Models.Color("Magenta","#505")
    ]

class App.Utils.Event
  constructor:(@type)->
    @datas=null
    @target=null
    @currentTarget=null

class App.Utils.EventDispatcher
  constructor:(@parent)->
    @listeners = []
  addListener : (eventName,listener)->
    this.listeners.push({"eventName":eventName,"listener":listener})
  dispatch : (event,datas)->
    event.target = event.currentTarget =  @parent
    event.datas = datas
    for i in this.listeners
      i.listener(event) unless event.type != i.eventName
    return
  removeListener : (eventName,listener)->
    this.listeners.splice(this.listeners.indexOf({"eventName":eventName,"listener":listener}),1)

class App.Utils.DefaultMenu
  items:[
    {label:"Undo",action:"undo",title:"Restore the grid to the previous state"}
    {label:"Redo",action:"redo",title:"Restore the grid to the next state"}
    {label:"Empty grid",action:"emptygrid",title:"Create a new blank grid"}
    {label:"16x16 grid",action:"changegridsize",title:'Change grid size',datas:{rows:16,columns:16}}
    {label:"32x32 grid",action:"changegridsize",title:'Change grid size',datas:{rows:32,columns:32}}
    {label:"Export to png",action:"exporttopng",title:"Export image as png in a new window (not available in Internet explorer)",datas:{param:"whatever"}}
    {label:"Save to local",action:"savetolocal",title:"Save icon to local storage (not available in all browers !!) \n Click on restore to load the saved icon."}
    {label:"Restore from local",action:"restorefromlocal",title:"Restore previously saved icon.",datas:{}}
    {label:"Switch background color",action:"switchBackground",title:"Switch background from White to Black",datas:[{backgroundColor:"#111",color:"#EEE"},{backgroundColor:"#EEE",color:"#111"}]}
    {label:"thickbox test",action:"showthickbox",title:"Show thick box , just a javascript CSS test , no special functionalities"}
  ]

class App.Utils.Toolbox
  tools:[
    {label:"pen",src:"img//pen.png",action:"drawpoint",title:"a pen tool",class:"Pen"}
    {label:"bucket",src:"img//bucket.png",action:"drawfill",title:"a bucket tool",class:"Bucket"}
    {label:"line",src:"img//line.png",action:"drawline",title:"A line drawing tool : press the mouse button , drag , and release to draw a line",class:"Line"}
    {label:"eraser",src:"img//rubber.png",action:"erase",title:"an eraser tool",class:"Eraser"}
  ]

class App.Utils.Iterator extends Array
  constructor:->
    @push i for i in arguments
    @iter = 0
  next:->
    @[++@iter] if @iter < @length-1
  previous:->
    @[--@iter] if @iter>0
  hasNext:->
    if @[@iter+1]
      true
    else
      false
  hasPrevious:->
    if @[@iter-1]
      true
    else
      false

### DRAWING TOOLS ###
class DrawingTool
  eventDispatcher:new App.Utils.EventDispatcher(@)
  supportMouseMove:false
  constructor:(@target)->
  factor:1
  draw:(ctx,point,colCible)->
  isInCanvas : (ctx,pixel)->
    result = ((0 <= pixel.x < ctx.rows) and (0 <= pixel.y <ctx.columns))
    return result
  
class App.Utils.Pen extends DrawingTool
  draw:(ctx,point,newColor)->
    ctx.fillCell({row:point.x,column:point.y,color:{value:newColor},factor:@factor})
  supportMouseMove:true
class App.Utils.Eraser extends DrawingTool
  draw:(ctx,point)->
    ctx.emptyCell({row:point.x,column:point.y})
  supportMouseMove:true
class App.Utils.Bucket extends DrawingTool
  constructor:(eventListener)->
    console.log eventListener
  MAXITERATION:1000
  factor:1
  draw : (ctx,pixel, colRep, colCible)->
    P = []
    max = @MAXITERATION
    if @getColorAtPixel(ctx,pixel)!=colCible then return null
    P.push(pixel)
    while  P.length > 0 and max >=0
      --max
      currentpixel = P.pop()
      @fillRect(ctx,currentpixel.x,currentpixel.y,colRep,@factor)
      if @isInCanvas(ctx,currentpixel)
        if @getColorAtPixel(ctx,@up(currentpixel)) == colCible then P.push(@up(currentpixel))
        if @getColorAtPixel(ctx,@down(currentpixel)) == colCible then P.push(@down(currentpixel))
        if @getColorAtPixel(ctx,@right(currentpixel)) == colCible then P.push(@right(currentpixel))
        if @getColorAtPixel(ctx,@left(currentpixel)) == colCible then P.push(@left(currentpixel))
    return

  fillRect:(ctx,x,y,_color,_factor)->
    ctx.fillCell({row:x,column:y,color:{value:_color},factor:_factor})
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
    if @isInCanvas(ctx,pixel) and ctx.grid[pixel.x][pixel.y]?
      result = ctx.grid[pixel.x][pixel.y].color.value
    return result

  rgbArrayToCssColorString:(array)->
    result = "rgb(#{array[0]},#{array[1]},#{array[2]})"
    return result

class App.Utils.Line extends DrawingTool
  constructor:(@target)->
    super(@targer)
    @eventDispatcher.addListener("begin",@onbegin)
  onbegin:(e)->
    @eventDispatcher.removeListener("begin",@onbegin)
    @eventDispatcher.addListener("end",@onend)
    {@beginPoint,@endPoint,@lineColor} = e.datas
  onend:(e)->
    @eventDispatcher.removeListener("end",@onend)

#

### MODELS ###

class App.Models.Color
  constructor:(@title="Eraser",@value="",@alpha=1)->

class App.Models.Application
  constructor:->
    @children=[]
    @eventDispatcher = new App.Utils.EventDispatcher(this)
    @eventDispatcher.addListener("modelupdate",@update)
  update:(e)=>
    @eventDispatcher.dispatch(new App.Utils.Event("update"),@)
  currentColor : new App.Models.Color("Black","rgb(0,0,0)",1)
  favIconGridModel : null

class App.Models.Cell
  constructor:(@color=new App.Models.Color("empty",""),@row,@column)->

class App.Models.Grid
  constructor:(@rows=16,@columns=16,@version,@title)-> # crée le modèle de grille
    @grid = []
    @fillGridBlank()
  fillGridBlank:->
    for i in [0...@rows]
      @grid[i] ?= []
      for j in [0... @columns]
        @grid[i][j]?= new  App.Models.Cell()
  fillCell:(params)->
    @grid[params.row][params.column].color.value = params.color.value
    @grid[params.row][params.column].alpha = 1
  emptyCell:(params)->
    @grid[params.row][params.column].color.value = ""
  emptyGrid:->
    for i in [0...@rows]
      @grid.push []
      for j in [0...@columns]
        @grid[i][j].color.value = ""
        @grid[i][j].alpha = 1

class App.Models.Title
  constructor:(@value,@targetId)->

class App.Models.ColorSelector
  constructor:(@colors= new App.Utils.DefaultColors().colors,@currentColor=new App.Models.Color("Black","rgb(0,0,0)"))->

class App.Models.CanvasPreview
  constructor:(@targetId,@model,@factor=4)->

class App.Models.FactorSelector
  constructor:(@targetId,@factor,@selectors=[1,2,3,4,8])->

class App.Models.Menu
  constructor:(@items=[],@targetId)->
  addItem:(item)->
    @items.push(item)
  removeItem:(item)->
    @items.splice(@items.indexOf(item),1)

class App.Models.History
  constructor:(@iterator = new App.Utils.Iterator())->

class App.Models.Toolbox
  constructor:(@tools)->
    @currentTool = @tools[0]

### VIEWS ###
class View
  eventDispatcher:new App.Utils.EventDispatcher(@)
  render:->
    for child of this
      @[child].render?()

class App.Views.Cell extends View
  constructor:(@model,@targetId)->
  render:->
    @el = "<div name ='cell' "
    if ["",null].indexOf(@model.color.value) >= 0
      @el+= " class='emptyCell ' "
    else
      @el+= " style='background-color:#{@model.color.value};' "
    @el+= " data-row='#{@model.row}' data-column='#{@model.column}' "
    @el+= " ></div>"
    if targetId?
      @targetId.innerHTML = @el
    return this

class App.Views.Grid extends View
  constructor:(@divTargetId,@model,@cellStyle="cell",@emptyCellStyle="emptyCell",@pen={})->
    @eventDispatcher = new App.Utils.EventDispatcher(this)
    @eventDispatcher.addListener("drawmodechange",@setDrawMode)
    @divTargetId.classes = @divTargetId.className
  render:->
    gridModel = @model.grid
    @divTargetId.innerHTML = ""
    @divTargetId.className = " #{@divTargetId.classes } _#{gridModel.columns}"
    @el = ""
    for row in [0...gridModel.rows]
      for column in [0...gridModel.columns]
        cell = new App.Views.Cell(new App.Models.Cell(gridModel.grid[row][column].color,row,column))
        element = cell.render().el
        @el += element
    @divTargetId.innerHTML += @el
    @divTargetId.onmouseup =(e)=>
      @drawMode = false
      @eventDispatcher.dispatch(new App.Utils.Event("renderpreview"),{})
      @eventDispatcher.dispatch(new App.Utils.Event("pushinhistory"),{})
    #@divTargetId.onmousemove =
    @divTargetId.onmousedown = (e)=>
      if e.target.getAttribute("name")=="cell"
        @eventDispatcher.dispatch(new App.Utils.Event("clickcell"),{el:e.currentTarget,element:e.target,tool:"pen",width:2,color:@pen.color,row:e.target.getAttribute("data-row"),column:e.target.getAttribute("data-column")})
      return false
    return this
  fillCell:(e)-> # speed up the grid rendering when filling one cell
    #tool = @model.toolbox.currentTool.value
    color = e.color.value
    if  ["",undefined].indexOf(color) < 0
      e.element.style.backgroundColor = color
      e.element.className  = ""
    else
      e.element.style.backgroundColor = null
      e.element.className  += " #{@emptyCellStyle}"



  setDrawMode:(event)=>
    @drawMode = event.datas
  setPenColor:(color)=>
    @pen.color = color # color object

class App.Views.Application extends View
  constructor:(@controller,@targetId)->
    @controller.view = @
    @children = []
  addChild:(view)->
    @children.push(view)
  removeChild:(view)->
    @children.splice(@children.indexOf(view),1)

class App.Views.Title extends View
  constructor:(@model)->
    @eventDispatcher = new App.Utils.EventDispatcher(this)
  render:->
    @el= @model.value.italics()
    @model.targetId.innerHTML  = @el
    @model.targetId.setAttribute("title","Click here to change the grid title")
    @model.targetId.onclick = (e)=>
      e.currentTarget.setAttribute("contenteditable",true)
      e.currentTarget.style.border = "1px solid #00EEFF"
      e.currentTarget.style.borderRadius = "2px"
      e.currentTarget.style.padding= "2px 5px 2px 5px"
      return false
    @model.targetId.onblur =@model.targetId.onkeypress = (e)=>
      if (e.type == "keypress" and e.which != 13)
        return
      e.currentTarget.setAttribute("contenteditable",false)
      e.currentTarget.style.border = ""
      @model.value = if e.currentTarget.innerText.trim() != "" then  e.currentTarget.innerText.trim() else @model.value
      @eventDispatcher.dispatch(new App.Utils.Event("titlechanged"),@model.value)

    @model.onkeypress
    return this

class App.Views.ColorSelector extends View
  constructor:(@model,@targetId)->
    if not @model instanceof App.Models.ColorSelector then throw new Error("model must be an instance of ColorSelector")
    @children = []
    @eventDispatcher =new App.Utils.EventDispatcher()
  render:->
    @children = []
    currentColor = new App.Views.Cell(new App.Models.Cell(new App.Models.Color("",@model.currentColor.value)))
    @el = ""
    @el +="<h4>Current Color</h4>"
    @el +=currentColor.render().el
    @el +="<h4>Color swatch</h4>"
    for i in [0...@model.colors.length]
      @children[i] = new App.Views.Cell(new App.Models.Cell(@model.colors[i]))
      @el +=@children[i].render().el
    @targetId.innerHTML = @el
    @targetId.onclick = (e)=>
      if e.target.getAttribute("name") != "cell" then return
      @eventDispatcher.dispatch(new App.Utils.Event("colorchange"),{"color":e.target.style.backgroundColor,"title":e.target.title})
    return this

class App.Views.CanvasPreview extends View
  constructor:(@model)->
  render:(localFactor)->
    gridModel = @model.model.grid
    localFactor?=@model.factor
    @model.targetId.innerHTML=""
    canvas = document.createElement("canvas")
    canvas.setAttribute("width",@model.factor*gridModel.rows)
    canvas.setAttribute("height",@model.factor*gridModel.columns)
    @model.targetId.appendChild(canvas)
    ctx = canvas.getContext("2d")
    pointWidth = pointHeight = @model.factor
    for i in [0...gridModel.rows]
      for j in [0...gridModel.columns]
        x = j*@model.factor
        y = i*@model.factor
        if gridModel.grid[i][j].color.value==null or gridModel.grid[i][j].color.value==""
          ctx.fillStyle = "#FFFFFF"
          ctx.globalAlpha = 0
        else
          ctx.fillStyle = gridModel.grid[i][j].color.value
          ctx.globalAlpha = gridModel.grid[i][j].alpha
        ctx.fillRect(x,y,@model.factor,@model.factor)

    @el=@model.targetId.innerHTML
    return this

class App.Views.FactorSelector extends View
  constructor:(@model)->
    @eventDispatcher = new App.Utils.EventDispatcher(this)
  render:->
    @el = "<p>Zoom preview by :</p>"
    for i in @model.selectors
      @el+="<input type='radio' name='factor' #{"checked" unless i!= @model.factor}  value='#{i}' /> x #{i} <br/>"
    @model.targetId.innerHTML = @el
    @model.targetId.onclick = (e)=>
      unless e.target.name != "factor"
        @model.factor = parseInt(e.target.value)
        @eventDispatcher.dispatch(new App.Utils.Event("selectfactor"),e.target.value )
    return this

class App.Views.Menu extends View
  constructor:(@model)->
    @eventDispatcher = new App.Utils.EventDispatcher(this)
  render:->
    @model.targetId.innerHTML = ""
    for i in [0...@model.items.length]
      button = document.createElement("input")
      #button.innerText = @model.items[i].label
      button.setAttribute("value",@model.items[i].label)
      button.setAttribute("type","button")
      button.setAttribute("id",@model.items[i].action)
      button.setAttribute("title",@model.items[i].title)
      button.dataset?= {}
      button.dataset.id = i
      @model.targetId.appendChild(button)
      button.onclick = ((e)=>
        action = @model.items[i].action
        datas = @model.items[i].datas
        return (e)=>
          @eventDispatcher.dispatch(new App.Utils.Event(action),datas)
      )()
      @el = @model.targetId.innerHTML
    return this

class App.Views.Toolbox extends View
  constructor:(@model,@targetId)->
    @eventDispatcher = new App.Utils.EventDispatcher(this)
  render:->
    @el = ""
    for tool in @model.tools
      @el += "<span data-class=#{tool.class} title='#{tool.title}' name='#{tool.label}' #{if tool.label == @model.currentTool.label then "class='selected'" else "" } style='background:url(#{tool.src})'></span>"
    @el+="<br/><h5>#{@model.currentTool.title}</h5>"
    @targetId.innerHTML = @el
    @targetId.onclick =(e)=>
      name = e.target.getAttribute("name")
      tagName = e.target.tagName
      @eventDispatcher.dispatch(new App.Utils.Event("changetool"),name) unless not name? and tagName != "IMG"
      return false
    return this

### CONTROLLERS ###
class Controller
class App.Controllers.Application extends Controller
  constructor:(@model)->
    @view = null

### MAIN ###
class Main
  constructor:->
    console.log "favicon builder at #{new Date()}"
    @version = 0.1
    # DOM
    @thickbox = document.getElementById("thickbox")
    $app = document.getElementById("app")
    $target = document.getElementById("target")
    $canvasPreview = document.getElementById("canvasPreview")
    $colorSelector = document.getElementById("colorSelector")
    $menu = document.getElementById("menu")
    $factorSelector = document.getElementById("factorSelector")
    $title = document.getElementById "title"
    $toolbox = document.getElementById "toolSelector"
    title = "Fav icon builder"

    ### MODELS ###
    @model = new App.Models.Application()
    @model.defaultColor = {value:"rgb(0,0,0)"}
    @model.history = new App.Models.History()
    @model.toolbox = new App.Models.Toolbox(App.Utils.Toolbox::tools)
    @model.colorSelector = new App.Models.ColorSelector(App.Utils.DefaultColors::colors,@model.defaultColor)
    @model.grid = new App.Models.Grid(16,16,0.1,"new grid")
    @model.title = new App.Models.Title("new grid",$title)
    @model.canvasPreview = new App.Models.CanvasPreview($canvasPreview,@model)
    @model.factorSelector = new App.Models.FactorSelector($factorSelector,@model.canvasPreview.factor)
    @model.menu = new App.Models.Menu(new App.Utils.DefaultMenu().items,$menu)
    ### CONTROLLERS ###
    @applicationController = new App.Controllers.Application(@model)
    ### VIEWS ###
    @view = new App.Views.Application(@applicationController,$app)
    @view.toolbox = new App.Views.Toolbox(@model.toolbox,$toolbox)
    @view.colorSelector = new App.Views.ColorSelector(@model.colorSelector,$colorSelector)
    @view.colorSelector.eventDispatcher.addListener("colorchange",@oncolorchange)
    @view.canvasPreview = new App.Views.CanvasPreview(@model.canvasPreview)
    @view.factorSelector = new App.Views.FactorSelector(@model.factorSelector)
    @view.grid = new App.Views.Grid($target,@model)
    @view.title = new App.Views.Title(@model.title)
    @view.grid.setPenColor(@model.currentColor)
    @view.menu = new App.Views.Menu(@model.menu)
    @updateViews() # render all child views
    ### EVENTS ###
    @view.toolbox.eventDispatcher.addListener("changetool",@changeTool)
    @view.menu.eventDispatcher.addListener("exporttopng",@exportCanvas)
    @view.menu.eventDispatcher.addListener("changegridsize",@changegridsize)
    @view.menu.eventDispatcher.addListener("emptygrid",@emptygrid)
    @view.menu.eventDispatcher.addListener("savetolocal",@savetolocal)
    @view.menu.eventDispatcher.addListener("restorefromlocal",@restoreFromLocal)
    @view.menu.eventDispatcher.addListener("showthickbox",@showThickbox)
    @view.menu.eventDispatcher.addListener("undo",@undo)
    @view.menu.eventDispatcher.addListener("redo",@redo)
    @view.menu.eventDispatcher.addListener("switchBackground",@switchBackground)
    @view.factorSelector.eventDispatcher.addListener("selectfactor",@selecFactor)
    @view.grid.eventDispatcher.addListener("renderpreview",@renderPreview) # rendercanvas preview
    @view.grid.eventDispatcher.addListener("updateViews",@updateViews)
    @view.grid.eventDispatcher.addListener("clickcell",@clickcell) # user draw on a cell in the grid
    @view.grid.eventDispatcher.addListener("pushinhistory",@pushInHistory) # push grid state in history
    @view.title.eventDispatcher.addListener("titlechanged",@titleChange) # title of grid edited
    @pushInHistory()

  changeTool:(e)=>
    label = e.datas #recupere les donnees de l'evenement
    tool = @model.toolbox.tools.filter( (o)=>(o.label == label) ) # filtre le tableau des tools
    @model.toolbox.currentTool = tool[0] # met a jour l'outil courant
    @updateViews()
  pushInHistory:(e)=>
    if  @model.history.iterator.hasNext()
      @model.history.iterator.split(@model.history.iterator)
    @model.history.iterator.push(JSON.parse(JSON.stringify(@model.grid)))
    @model.history.iterator.iter = @model.history.iterator.length-1
  undo:(e)=>
    if @model.history.iterator.hasPrevious()
      @model.grid.grid =  @model.history.iterator.previous().grid
      @updateViews()
  redo:(e)=>
    if @model.history.iterator.hasNext()
      @model.grid.grid =  @model.history.iterator.next().grid
      @view.render()
  clickcell:(e)=>
    @isDrawing = true
    tool = new App.Utils[@model.toolbox.currentTool.class](e.target)
    tool.context = @model.grid
    tool.currentColor = e.datas.element.style.backgroundColor
    tool.newColor = @model.colorSelector.currentColor.value
    tool.point = {x:parseInt(e.datas.row,10),y:parseInt(e.datas.column,10)}
    tool.draw(tool.context,tool.point,tool.newColor,tool.currentColor)
    e.datas.el.onmouseup=(e)=>
      console.log "mouse up"
      @isDrawing = false
      tool = null
      @pushInHistory()
      @updateViews()
      return false
    if tool.supportMouseMove == true
      e.datas.el.onmousemove=(e)=>
        console.log "mouse down"
        console.log(e)
        if e.target.getAttribute('name')=="cell" and @isDrawing == true
          tool.draw(tool.context,{x:parseInt(e.target.getAttribute("data-row")),y:parseInt(e.target.getAttribute("data-column"))},tool.newColor,tool.currentColor)
          color  = {value:tool.newColor}
          @view.grid.fillCell({element:e.target,color:color})
        return false
  titleChange:(e)=>
    @model.grid.title = e.datas
    @updateViews()
  renderPreview:(e)=>
    @view.canvasPreview.render()
  oncolorchange:(e)=>
    @model.colorSelector.currentColor.value = e.datas.color
    @updateViews()
  exportCanvas:(e)=>
    window.open(@model.canvasPreview.targetId.getElementsByTagName('canvas')[0].toDataURL("image/png"))
  changegridsize:(e)=>
    @model.grid.rows = e.datas.rows
    @model.grid.columns= e.datas.columns
    @model.grid.fillGridBlank()
    @view.render()
  emptygrid:=>
    @model.grid.emptyGrid()
    @view.render()
  savetolocal:=>
    backups = []
    if localStorage["faviconbuilderGrid"]
      backups = JSON.parse(localStorage["faviconbuilderGrid"])
    backups.push(@model.grid)
    backups.version = @version
    (localStorage["faviconbuilderGrid"] = JSON.stringify(backups)) and alert("Icon saved to local storage")
  restoreFromLocal:=>
    if localStorage["faviconbuilderGrid"]!=null
      backups       = JSON.parse(localStorage["faviconbuilderGrid"])
      gridModel           = backups[backups.length-1]
      @model.grid.grid    = gridModel.grid
      @model.grid.rows    = gridModel.rows
      @model.grid.columns = gridModel.columns
      @model.grid.version = gridModel.version
      @model.title.value  = gridModel.title
      @updateViews()
  updateViews:=>
    @view.render()
  selecFactor:(e)=>
    @model.canvasPreview.factor = parseInt(e.datas)
    @updateViews()
  showThickbox:(e)=>
    @thickbox.style.visibility = if @thickbox.style.visibility == "hidden" then "visible" else "hidden"
    @thickbox.style.opacity = if parseInt(@thickbox.style.opacity)<1 then 1 else 0
    @thickbox.onclick= (e)=>
      @showThickbox(e)
  switchBackground:(e)=>
    @defaultclass?=document.body.className
    document.body.className = if document.body.className==@defaultclass then @defaultclass+" black" else @defaultclass
window?.onload = ->
  window.main = new Main()
