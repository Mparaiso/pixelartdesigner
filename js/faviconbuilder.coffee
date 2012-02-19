###
  FAVICON BUILDER
  @version 0.1
  @author M.Paraiso

  EVENT DISPATCHER

  @description FR
  imite le system d'évenements de flash.
  Etend Object.prototype
  les objets implementent 3 méthodes : dispatch , addListener , removeListener
  l'objet Event du DOM est utilisé par défaut pour transmettre les messages.
  on peut récuperer des données de l'évenement grace au champ datas de l'objet event
  currentTarget et target permettent de savoir dans quel context l'évenement a été dispatché ( émit )

  @description EN
###

console?= #console mock object
  log:->

Array.prototype.split = (index)->
  if index < this.length
    q = this.length-index
    return this.splice(index,q)
# namespaces #
App = {
  Views:{}
  Models:{}
  Controllers:{}
  Collections:{}
  Utils:{}
  Ajax:{}
  }

### UTILITIES ###
class App.Utils.DefaultColors
  constructor:->
    @colors =
      [
        new App.Models.Color("Eraser","")
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
      ]
    @colors.sort (a,b)->  a.color< b.color

class App.Utils.Event
  constructor:(@type)->
    @datas=null
    @target=null
    @currentTarget=null

class App.Utils.EventDispatcher
    constructor:(@parent)->
    listeners : []
    addListener : (eventName,listener)->
      this.listeners.push({"eventName":eventName,"listener":listener})
    dispatch : (event,datas)->
      #throw new Error("event should be an instance of Event") unless event instanceof Event
      event.target = event.currentTarget =  @parent
      event.datas = datas
      for i in this.listeners
        i.listener(event) unless event.type != i.eventName
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
    {label:"thickbox test",action:"showthickbox",title:"Show thick box , just a javascript CSS test , no special functionalities"}
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


###
App.Utils.Iterator = do->
  Iterator = ->
    array = Array.apply(this,arguments)
    iter = 0
    return {
      getArray:->
        array
      getValue:->
        array[iter]
      next:->
        array[++iter] if iter < array.length-1
      previous:->
        array[--iter] if iter>0
      hasNext:->
        return if array[iter+1] then true else return false
      hasPrevious:->
        return  if array[iter-1]then true else return false
    }

  return Iterator


App.Utils.Iterator = do ->
  Iterator =  ->
    #Array.apply(this,arguments)
    this.push(i) for i in arguments
    iter = 0
    @reset = ->
      iter = 0
    @getIndex = ->
      iter
    @getValue= ->
      this[iter]
    @next= ->
      this[++iter] if iter < this.length-1
    @previous= ->
      this[--iter] if iter>0
    @hasNext= ->
      return if this[iter+1] then true else return false
    @hasPrevious= ->
      return  if this[iter-1]then true else return false
    return this

  Iterator.prototype = new Array()
  Iterator.prototype.constructor = Array
  return Iterator
###


### MODELS ###
class App.Models.Color
  constructor:(@title="Eraser",@color=null,@alpha=1)->

class App.Models.Application
  constructor:->
    @children=[]
  currentColor : new App.Models.Color("Black","#000000",1)
  favIconGridModel : null

class App.Models.Cell
  constructor:->
    @color=null
    @alpha=1

class App.Models.Grid
  constructor:(@rows=16,@columns=16,@version,@title)-> # crée le modèle de grille
    @grid = []
    @fillGridBlank()
  fillGridBlank:->
    for i in [0...@rows]
      @grid[i] ?= []
      for j in [0... @columns]
        #console.log @grid[i][j]
        @grid[i][j]?= new  App.Models.Cell()
  fillCell:(params)->
    @grid[params.row][params.column].color = params.color.color
    @grid[params.row][params.column].alpha = 1
  emptyGrid:->
    for i in [0...@rows]
      @grid.push []
      for j in [0...@columns]
        @grid[i][j].color = ""
        @grid[i][j].alpha = 1

class App.Models.Title
  constructor:(@value,@targetId)->

class App.Models.ColorSelector
  constructor:(@colors= new App.Utils.DefaultColors().colors)->

class App.Models.CanvasPreview
  constructor:(@targetId,@applicationModel,@factor=4)->

class App.Models.FactorSelector
  constructor:(@targetId,@factor,@selectors=[1,2,3,4])->
    
class App.Models.Menu
  constructor:(@items=[],@targetId)->
  addItem:(item)->
    @items.push(item)
  removeItem:(item)->
    @items.splice(@items.indexOf(item),1)

class App.Models.History
  constructor:(@iterator = new App.Utils.Iterator())->

### VIEWS ###
class App.Views.Cell

class App.Views.Grid
  constructor:(@divTargetId,@applicationModel,@cellStyle="cell",@emptyCellStyle="emptyCell",@pen={})->
    @drawMode = false
    @eventDispatcher = new App.Utils.EventDispatcher(this)
    @eventDispatcher.addListener("drawmodechange",@setDrawMode)
    @divTargetId.classes = @divTargetId.className
  render:->
    gridModel = @applicationModel.gridModel
    @divTargetId.innerHTML = ""
    @divTargetId.className = " #{@divTargetId.classes } _#{gridModel.columns}"
    @el = ""
    for row in [0...gridModel.rows]
      for column in [0...gridModel.columns]
        element = " <div name='cell' "
        if gridModel.grid[row][column].color != null  and gridModel.grid[row][column].color != ""
          element+= " style='background-color:#{gridModel.grid[row][column].color}' "
        else
          element+= " class='#{@emptyCellStyle}' "
        element+= " data-row='#{row}' data-column='#{column}' "
        element+= " ></div> "
        @el += element
    @divTargetId.innerHTML += @el
    @divTargetId.onmouseup =(e)=>
      @drawMode = false
      @eventDispatcher.dispatch(new App.Utils.Event("renderpreview"),{})
      @eventDispatcher.dispatch(new App.Utils.Event("pushinhistory"),{})
    @divTargetId.onmousemove = @divTargetId.onmousedown = (e)=>
      if e.type == "mousedown" then @drawMode = true
      if e.target.getAttribute("name")=="cell" and @drawMode == true
        @eventDispatcher.dispatch(new App.Utils.Event("clickcell"),{element:e.target,tool:"pen",width:2,color:@pen.color,row:e.target.getAttribute("data-row"),column:e.target.getAttribute("data-column")})
      return false
    return this
  fillCell:(e)-> # speed up the grid rendering when filling one cell 
    console.log "fillCell",e
    color = e.datas.color.color
    if  ["",undefined].indexOf(color) < 0
      e.datas.element.style.backgroundColor = color
      e.datas.element.className  = ""
    else
      e.datas.element.style.backgroundColor = null
      e.datas.element.className  += " #{@emptyCellStyle}"



  setDrawMode:(event)=>
    @drawMode = event.datas
  setPenColor:(color)=>
    @pen.color = color # color object

class App.Views.Application
  constructor:(@divTarget,@applicationModel)->
    @children = []
  addChild:(view)->
    @children.push(view)
  removeChild:(view)->
    @children.splice(@children.indexOf(view),1)
  render:->
    for child in @children
      child.render?()

class App.Views.Color
  constructor:(@model=new App.Models.Color())->
  render:()->
    @el = document.createElement("div")
    @el.setAttribute("title",@model.title)
    @el.className+=" color "
    if @model.color !=null and @model.color!=""
      @el.style.backgroundColor = @model.color
    else
      @el.className+=" emptyCell "
    return this

class App.Views.Title
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


class App.Views.ColorSelector
  constructor:(@el,@model)->
    if not @model instanceof App.Models.ColorSelector then throw new Error("model must be an instance of ColorSelector")
    @children = []
    @eventDispatcher =new App.Utils.EventDispatcher()
  render:->
    @children = []
    @currentColor = new App.Views.Color(App.Models.Application::currentColor)
    @el.innerHTML = ""
    @h4Element = document.createElement("h4")
    @h4Element.innerHTML = "Current Color"
    @el.appendChild(@h4Element)
    @el.appendChild(@currentColor.render().el)
    @el.innerHTML+="<h4>Color swatch</h4>"
    for i in [0...@model.colors.length]
      @children[i] = new App.Views.Color(@model.colors[i])
      @el.appendChild(@children[i].render().el)
      @children[i].el.onclick = (e)=>
        @eventDispatcher.dispatch(new App.Utils.Event("colorchange"),{"color":e.target.style.backgroundColor,"title":e.target.title})
        @render()
    return this

class App.Views.CanvasPreview
  constructor:(@model)->
  render:(localFactor)->
    gridModel = @model.applicationModel.gridModel
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
        if gridModel.grid[i][j].color==null or gridModel.grid[i][j].color==""
          ctx.fillStyle = "#FFFFFF"
          ctx.globalAlpha = 0
        else
          ctx.fillStyle = gridModel.grid[i][j].color
          ctx.globalAlpha = gridModel.grid[i][j].alpha
        ctx.fillRect(x,y,@model.factor,@model.factor)

    @el=@model.targetId.innerHTML
    return this

class App.Views.FactorSelector
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

class App.Views.Menu
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

  ### CONTROLLERS ###
class App.Controllers.Application
  constructor:(@model)->

### MAIN ###
class Main
  constructor:->
    @version = 0.1
    @thickbox = document.getElementById("thickbox")
    $target = document.getElementById("target")
    $canvasPreview = document.getElementById("canvasPreview")
    $colorSelector = document.getElementById("colorSelector")
    $menu = document.getElementById("menu")
    $factorSelector = document.getElementById("factorSelector")
    $title = document.getElementById "title"
    title = "Fav icon builder"
    defaultColor = "#000000"
    ### MODELS ###
    @applicationModel = new App.Models.Application()
    @historyModel = new App.Models.History()
    @colorSelectorModel = new App.Models.ColorSelector()
    @applicationModel.gridModel = new App.Models.Grid(16,16,0.1,"new grid")
    @titleModel = new App.Models.Title("new grid",$title)
    @canvasPreviewModel = new App.Models.CanvasPreview($canvasPreview,@applicationModel)
    @factorSelectorModel = new App.Models.FactorSelector($factorSelector,@canvasPreviewModel.factor)
    @menuModel = new App.Models.Menu(new App.Utils.DefaultMenu().items,$menu)
    @applicationModel.historyModel = @historyModel
    @applicationModel.colorSelectorModel = @colorSelectorModel
    @applicationModel.titleModel = @titleModel
    @applicationModel.canvasPreviewModel = @canvasPreviewModel
    @applicationModel.factorSelectorModel = @factorSelectorModel
    @applicationModel.menuModel = @menuModel
    ### VIEWS ###
    @applicationView = new App.Views.Application($target,@applicationModel)
    @colorSelectorView = new App.Views.ColorSelector($colorSelector,@colorSelectorModel)
    @colorSelectorView.eventDispatcher.addListener("colorchange",@oncolorchange)
    @canvasPreviewView = new App.Views.CanvasPreview(@canvasPreviewModel)
    @factorSelectorView = new App.Views.FactorSelector(@factorSelectorModel)
    @gridView = new App.Views.Grid($target,@applicationModel)
    @titleView = new App.Views.Title(@titleModel)
    @gridView.setPenColor(@applicationModel.currentColor)
    @menuView = new App.Views.Menu(@menuModel)
    @applicationView.addChild(@gridView)
    @applicationView.addChild(@titleView)
    @applicationView.addChild(@colorSelectorView)
    @applicationView.addChild(@canvasPreviewView)
    @applicationView.addChild(@factorSelectorView)
    @applicationView.addChild(@menuView)
    @applicationView.render() # render all child views
    ### EVENTS ###
    @menuView.eventDispatcher.addListener("exporttopng",@exportCanvas)
    @menuView.eventDispatcher.addListener("changegridsize",@changegridsize)
    @menuView.eventDispatcher.addListener("emptygrid",@emptygrid)
    @menuView.eventDispatcher.addListener("savetolocal",@savetolocal)
    @menuView.eventDispatcher.addListener("restorefromlocal",@restoreFromLocal)
    @menuView.eventDispatcher.addListener("showthickbox",@showThickbox)
    @menuView.eventDispatcher.addListener("undo",@undo)
    @menuView.eventDispatcher.addListener("redo",@redo)
    @factorSelectorView.eventDispatcher.addListener("selectfactor",@selecFactor)
    @gridView.eventDispatcher.addListener("renderpreview",@renderPreview) # rendercanvas preview
    @gridView.eventDispatcher.addListener("updateviews",@updateViews)
    @gridView.eventDispatcher.addListener("clickcell",@clickcell) # user draw on a cell in the grid
    @gridView.eventDispatcher.addListener("pushinhistory",@pushInHistory) # push grid state in history
    @titleView.eventDispatcher.addListener("titlechanged",@titleChange) # title of grid edited 

    @pushInHistory()

  pushInHistory:(e)=>
    console.log "push in history","iter = ",@historyModel.iterator.iter,"length = ",@historyModel.iterator.length
    
    if  @historyModel.iterator.hasNext()
      console.log "iterator has next"
      console.log @historyModel.iterator.split()
    @historyModel.iterator.push(JSON.parse(JSON.stringify(@applicationModel.gridModel)))
    @historyModel.iterator.iter = @historyModel.iterator.length-1
     
    console.log "pushed in history","iter = ",@historyModel.iterator.iter,"length = ",@historyModel.iterator.length
  undo:(e)=>
    console.log "undo"
    if @historyModel.iterator.hasPrevious()
      @applicationModel.gridModel.grid =  @historyModel.iterator.previous().grid
      @updateViews()
  redo:(e)=>
    console.log "redo"
    if @historyModel.iterator.hasNext()
      @applicationModel.gridModel.grid =  @historyModel.iterator.next().grid
      @applicationView.render()
  clickcell:(e)=>
    @applicationModel.gridModel.fillCell(e.datas)
    @gridView.fillCell(e)
  titleChange:(e)=>
    @applicationModel.gridModel.title = e.datas
    @updateViews()
  renderPreview:(e)=>
    @canvasPreviewView.render()
  oncolorchange:(e)=>
    console.log "oncolorchange" , e.datas.color , e.datas.title
    @applicationModel.currentColor.color = e.datas.color
    @applicationModel.currentColor.title = e.datas.title
  exportCanvas:(e)=>
    window.open(@canvasPreviewModel.targetId.getElementsByTagName('canvas')[0].toDataURL("image/png"))
  changegridsize:(e)=>
    console.log "changegridsize",e.datas
    @applicationModel.gridModel.rows = e.datas.rows
    @applicationModel.gridModel.columns= e.datas.columns
    @applicationModel.gridModel.fillGridBlank()
    @applicationView.render()
  emptygrid:=>
    @applicationModel.gridModel.emptyGrid()
    @applicationView.render()
  savetolocal:=>
    backups = []
    if localStorage["faviconbuilderGrid"]
      backups = JSON.parse(localStorage["faviconbuilderGrid"])
    backups.push(@applicationModel.gridModel)
    backups.version = @version
    (localStorage["faviconbuilderGrid"] = JSON.stringify(backups)) and alert("Icon saved to local storage")
  restoreFromLocal:=>
    if localStorage["faviconbuilderGrid"]!=null
      backups       = JSON.parse(localStorage["faviconbuilderGrid"])
      gridModel          = backups[backups.length-1]
      @applicationModel.gridModel.grid    = gridModel.grid
      @applicationModel.gridModel.rows    = gridModel.rows
      @applicationModel.gridModel.columns = gridModel.columns
      @applicationModel.gridModel.version = gridModel.version
      @applicationModel.titleModel.value       = gridModel.title
      @updateViews()
  updateViews:=>
    @applicationView.render()
  selecFactor:(e)=>
    @canvasPreviewModel.factor = parseInt(e.datas)
    @updateViews()
  showThickbox:(e)=>
    console.log e,"show thickbox"
    @thickbox.style.visibility = if @thickbox.style.visibility == "hidden" then "visible" else "hidden"
    @thickbox.style.opacity = if parseInt(@thickbox.style.opacity)<1 then 1 else 0
    @thickbox.onclick= (e)=>
      @showThickbox(e)
window?.onload = ->
  window?.main = new Main()
