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
      event.target = event.currenTarget =  this
      event.datas = datas
      for i in this.listeners
        i.listener(event) unless event.type != i.eventName
    removeListener : (eventName,listener)->
      this.listeners.splice(this.listeners.indexOf({"eventName":eventName,"listener":listener}),1)

class App.Utils.DefaultMenu
  items:[
    {label:"Empty grid",action:"emptygrid",title:"Help: \nCreate a new blank grid"}
    {label:"16x16 grid",action:"changegridsize",datas:{rows:16,columns:16}}
    {label:"32x32 grid",action:"changegridsize",datas:{rows:32,columns:32}}
    {label:"Export to png",action:"exporttopng",datas:{param:"whatever"}}
    {label:"Save to local",action:"savetolocal",title:"Save icon to local storage (not available in all browers !!) \n Click on restore to load the saved icon."}
    {label:"Restore from local",action:"restorefromlocal",title:"Info :\nRestore previously saved icon.",datas:{}}
  ]
### MODELS ###
class App.Models.Color
  constructor:(@title="Eraser",@color=null,@alpha=1)->

class App.Models.Application
  currentColor : new App.Models.Color("Black","#000000")
  favIconGridModel : null

class App.Models.Cell
  constructor:->
    @color=null
    @alpha=1

class App.Models.Grid
  constructor:(@rows=16,@columns=16)-> # crée le modèle de grille
    @grid = []
    @fillGridBlank()

  fillGridBlank:->
    for i in [0...@rows]
      @grid[i] ?= []
      for j in [0... @columns]
        console.log @grid[i][j]
        @grid[i][j]?= new  App.Models.Cell()
  emptyGrid:->
    for i in [0...@rows]
      @grid.push []
      for j in [0...@columns]
        @grid[i][j].color = ""
        @grid[i][j].alpha = 1

class App.Models.ColorSelector
  constructor:(@colors= new App.Utils.DefaultColors().colors)->

class App.Models.CanvasPreview
  constructor:(@targetId,@gridModel,@factor=4)->

class App.Models.FactorSelector
  constructor:(@targetId,@factor,@selectors=[1,2,3,4])->
    
class App.Models.Menu
  constructor:(@items=[],@targetId)->
  addItem:(item)->
    @items.push(item)
  removeItem:(item)->
    @items.splice(@items.indexOf(item),1)

### VIEWS ###
class App.Views.Cell

class App.Views.Grid
  constructor:(@divTargetId,@gridModel=new App.Models.Grid(),@cellStyle="cell",@emptyCellStyle="emptyCell",@pen={})->
    @drawMode = false
    @eventDispatcher = new App.Utils.EventDispatcher(this)
    @eventDispatcher.addListener("drawmodechange",@setDrawMode)
    @divTargetId.classes = @divTargetId.className
  render:->
    console.log "App.Views.Grid.render()"
    @divTargetId.innerHTML = ""
    @divTargetId.className = " #{@divTargetId.classes } _#{@gridModel.columns}"
    for row in [0...@gridModel.rows]
      for column in [0...@gridModel.columns]
        cell = document.createElement("div")
        cell.className+=" #{@cellStyle}"
        if @gridModel.grid[row][column].color != null  and @gridModel.grid[row][column].color != ""
          cell.style.backgroundColor = @gridModel.grid[row][column].color
        else
          cell.className+=" #{@emptyCellStyle}"
        cell.dataset?= {}
        cell.dataset.row = row
        cell.dataset.column = column
        @divTargetId.appendChild(cell)
        cell.onmouseover  = (e)=>
          if @drawMode == true
            @fillCell(e)
        cell.onclick = (e)=>
          @fillCell(e)
        cell.onmousedown = (e)=>
          @fillCell(e)
    @eventDispatcher.dispatch(new App.Utils.Event("faviconrender"),@)
  fillCell:(e)->
    @gridModel.grid[parseInt(e.currentTarget.dataset.row)][parseInt(e.currentTarget.dataset.column)].color = @pen.color.color # App.Models.Application::currentColor.color
    @eventDispatcher.dispatch(new App.Utils.Event("updateviews"),@)
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
    localFactor?=@model.factor
    @model.targetId.innerHTML=""
    canvas = document.createElement("canvas")
    canvas.setAttribute("width",@model.factor*@model.gridModel.rows)
    canvas.setAttribute("height",@model.factor*@model.gridModel.columns)
    @model.targetId.appendChild(canvas)
    ctx = canvas.getContext("2d")
    pointWidth = pointHeight = @model.factor
    for i in [0...@model.gridModel.rows]
      for j in [0...@model.gridModel.columns]
        x = j*@model.factor
        y = i*@model.factor
        if @model.gridModel.grid[i][j].color==null or @model.gridModel.grid[i][j].color==""
          ctx.fillStyle = "#FFFFFF"
          ctx.globalAlpha = 0
        else
          ctx.fillStyle = @model.gridModel.grid[i][j].color
          ctx.globalAlpha = @model.gridModel.grid[i][j].alpha
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
    @eventDispatcher = new App.Utils.EventDispatcher()
  render:->
    @model.targetId.innerHTML = ""
    for i in [0...@model.items.length]
      button = document.createElement("button")
      button.innerText = @model.items[i].label
      button.setAttribute("id",@model.items[i].action)
      button.setAttribute("title",@model.items[i].title)
      button.dataset?= {}
      button.dataset.id = i
      @model.targetId.appendChild(button)
      ###
      button.onclick = (e)=>
        @eventDispatcher.dispatch(new Event(@model.items[i].action),if @model.items[i].datas then @model.items[i].datas else null )
      ###
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
    $target = document.getElementById("target")
    $canvasPreview = document.getElementById("canvasPreview")
    $colorSelector = document.getElementById("colorSelector")
    $menu = document.getElementById("menu")
    $factorSelector = document.getElementById("factorSelector")
    title = "Fav icon builder"
    defaultColor = "#000000"
    ### MODELS ###
    @applicationModel = new App.Models.Application()
    @colorSelectorModel = new App.Models.ColorSelector()
    @gridModel = new App.Models.Grid()
    @canvasPreviewModel = new App.Models.CanvasPreview($canvasPreview,@gridModel)
    @factorSelectorModel = new App.Models.FactorSelector($factorSelector,@canvasPreviewModel.factor)
    @menuModel = new App.Models.Menu(new App.Utils.DefaultMenu().items,$menu)
    App.Models.Application.favIconGridModel = @gridModel
    ### CONTROLLERS ###
    #@applicationController = new App.Controllers.Application(@applicationModel)
    ### VIEWS ###
    @applicationView = new App.Views.Application($target,@applicationModel)
    @colorSelectorView = new App.Views.ColorSelector($colorSelector,@colorSelectorModel)
    @colorSelectorView.eventDispatcher.addListener("colorchange",@oncolorchange)
    @canvasPreviewView = new App.Views.CanvasPreview(@canvasPreviewModel)
    @factorSelectorView = new App.Views.FactorSelector(@factorSelectorModel)
    @gridView = new App.Views.Grid($target,@gridModel)
    @gridView.setPenColor(@applicationModel.currentColor)
    @menuView = new App.Views.Menu(@menuModel)
    @applicationView.addChild(@gridView)
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
    @factorSelectorView.eventDispatcher.addListener("selectfactor",@selecFactor)
    @gridView.divTargetId.onmousedown = (e)=>
      @gridView.eventDispatcher.dispatch(new App.Utils.Event("drawmodechange"),true)
    @gridView.divTargetId.onmouseup = (e)=>
      @gridView.eventDispatcher.dispatch(new App.Utils.Event("drawmodechange"),false)
    @gridView.eventDispatcher.addListener("faviconrender",@renderCanvasPreview)
    @gridView.eventDispatcher.addListener("updateviews",@updateViews)
  renderCanvasPreview:(e)=>
    @canvasPreviewView.render()
  oncolorchange:(e)=>
    console.log "oncolorchange" , e.datas.color , e.datas.title
    @applicationModel.currentColor.color = e.datas.color
    @applicationModel.currentColor.title = e.datas.title
  exportCanvas:(e)=>
    window.open(@canvasPreviewModel.targetId.getElementsByTagName('canvas')[0].toDataURL("image/png"))
  changegridsize:(e)=>
    console.log "changegridsize",e.datas
    @gridModel.rows = e.datas.rows
    @gridModel.columns= e.datas.columns
    @gridModel.fillGridBlank()
    @gridView.render()
  emptygrid:=>
    @gridModel.emptyGrid()
    @gridView.render()
  savetolocal:=>
    (localStorage["faviconbuilderGrid"] = JSON.stringify(@gridModel)) and alert("Icon saved to local storage")
  restoreFromLocal:=>
    if localStorage["faviconbuilderGrid"]!=null
      gridModel          = JSON.parse(localStorage["faviconbuilderGrid"])
      @gridModel.grid    = gridModel.grid
      @gridModel.rows    = gridModel.rows
      @gridModel.columns = gridModel.columns
      @updateViews()
  updateViews:=>
    @applicationView.render()
  selecFactor:(e)=>
    @canvasPreviewModel.factor = parseInt(e.datas)
    @updateViews()
window?.onload = ->
  window?.main = new Main()
