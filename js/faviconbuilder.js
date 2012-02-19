/*
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
*/
var App, Main,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

if (typeof console === "undefined" || console === null) {
  console = {
    log: function() {}
  };
}

App = {
  Views: {},
  Models: {},
  Controllers: {},
  Collections: {},
  Utils: {},
  Ajax: {}
};

/* UTILITIES
*/

App.Utils.DefaultColors = (function() {

  function DefaultColors() {
    this.colors = [new App.Models.Color("Eraser", ""), new App.Models.Color("White", "#FFF"), new App.Models.Color("Gray2", "#DDD"), new App.Models.Color("Gray1", "#AAA"), new App.Models.Color("Gray2", "#777"), new App.Models.Color("Black", "#000"), new App.Models.Color("Red", "#900"), new App.Models.Color("Red", "#F00"), new App.Models.Color("Red", "#F99"), new App.Models.Color("Red", "#FDD"), new App.Models.Color("Green", "#090"), new App.Models.Color("Green", "#0F0"), new App.Models.Color("Green", "#9F9"), new App.Models.Color("Green", "#DFD"), new App.Models.Color("Blue", "#009"), new App.Models.Color("Blue", "#00F"), new App.Models.Color("Blue", "#99F"), new App.Models.Color("Blue", "#DDF"), new App.Models.Color("Yellow", "#FF0"), new App.Models.Color("Yellow", "#F90"), new App.Models.Color("Cyan", "#0FF"), new App.Models.Color("Cyan", "#099"), new App.Models.Color("Magenta", "#F0F"), new App.Models.Color("Magenta", "#909")];
    this.colors.sort(function(a, b) {
      return a.color < b.color;
    });
  }

  return DefaultColors;

})();

App.Utils.Event = (function() {

  function Event(type) {
    this.type = type;
    this.datas = null;
    this.target = null;
    this.currentTarget = null;
  }

  return Event;

})();

App.Utils.EventDispatcher = (function() {

  function EventDispatcher(parent) {
    this.parent = parent;
  }

  EventDispatcher.prototype.listeners = [];

  EventDispatcher.prototype.addListener = function(eventName, listener) {
    return this.listeners.push({
      "eventName": eventName,
      "listener": listener
    });
  };

  EventDispatcher.prototype.dispatch = function(event, datas) {
    var i, _i, _len, _ref, _results;
    event.target = event.currentTarget = this.parent;
    event.datas = datas;
    _ref = this.listeners;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      if (event.type === i.eventName) {
        _results.push(i.listener(event));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  EventDispatcher.prototype.removeListener = function(eventName, listener) {
    return this.listeners.splice(this.listeners.indexOf({
      "eventName": eventName,
      "listener": listener
    }), 1);
  };

  return EventDispatcher;

})();

App.Utils.DefaultMenu = (function() {

  function DefaultMenu() {}

  DefaultMenu.prototype.items = [
    {
      label: "Undo",
      action: "undo",
      title: "Restore the grid to the previous state"
    }, {
      label: "Redo",
      action: "redo",
      title: "Restore the grid to the next state"
    }, {
      label: "Empty grid",
      action: "emptygrid",
      title: "Create a new blank grid"
    }, {
      label: "16x16 grid",
      action: "changegridsize",
      title: 'Change grid size',
      datas: {
        rows: 16,
        columns: 16
      }
    }, {
      label: "32x32 grid",
      action: "changegridsize",
      title: 'Change grid size',
      datas: {
        rows: 32,
        columns: 32
      }
    }, {
      label: "Export to png",
      action: "exporttopng",
      title: "Export image as png in a new window (not available in Internet explorer)",
      datas: {
        param: "whatever"
      }
    }, {
      label: "Save to local",
      action: "savetolocal",
      title: "Save icon to local storage (not available in all browers !!) \n Click on restore to load the saved icon."
    }, {
      label: "Restore from local",
      action: "restorefromlocal",
      title: "Restore previously saved icon.",
      datas: {}
    }, {
      label: "thickbox test",
      action: "showthickbox",
      title: "Show thick box , just a javascript CSS test , no special functionalities"
    }
  ];

  return DefaultMenu;

})();

/* 
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
*/

App.Utils.Iterator = (function() {
  var Iterator;
  Iterator = function() {
    var array, iter;
    array = Array.apply(this, arguments);
    iter = 0;
    return {
      getArray: function() {
        return array;
      },
      getValue: function() {
        return array[iter];
      },
      next: function() {
        if (iter < array.length - 1) return array[++iter];
      },
      previous: function() {
        if (iter > 0) return array[--iter];
      },
      hasNext: function() {
        if (array[iter + 1]) {
          return true;
        } else {
          return false;
        }
      },
      hasPrevious: function() {
        if (array[iter - 1]) {
          return true;
        } else {
          return false;
        }
      }
    };
  };
  return Iterator;
})();

/* MODELS
*/

App.Models.Color = (function() {

  function Color(title, color, alpha) {
    this.title = title != null ? title : "Eraser";
    this.color = color != null ? color : null;
    this.alpha = alpha != null ? alpha : 1;
  }

  return Color;

})();

App.Models.Application = (function() {

  function Application() {
    this.children = [];
  }

  Application.prototype.currentColor = new App.Models.Color("Black", "#000000", 1);

  Application.prototype.favIconGridModel = null;

  return Application;

})();

App.Models.Cell = (function() {

  function Cell() {
    this.color = null;
    this.alpha = 1;
  }

  return Cell;

})();

App.Models.Grid = (function() {

  function Grid(rows, columns, version, title) {
    this.rows = rows != null ? rows : 16;
    this.columns = columns != null ? columns : 16;
    this.version = version;
    this.title = title;
    this.grid = [];
    this.fillGridBlank();
  }

  Grid.prototype.fillGridBlank = function() {
    var i, j, _base, _ref, _results;
    _results = [];
    for (i = 0, _ref = this.rows; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      if ((_base = this.grid)[i] == null) _base[i] = [];
      _results.push((function() {
        var _base2, _ref2, _ref3, _results2;
        _results2 = [];
        for (j = 0, _ref2 = this.columns; 0 <= _ref2 ? j < _ref2 : j > _ref2; 0 <= _ref2 ? j++ : j--) {
          console.log(this.grid[i][j]);
          _results2.push((_ref3 = (_base2 = this.grid[i])[j]) != null ? _ref3 : _base2[j] = new App.Models.Cell());
        }
        return _results2;
      }).call(this));
    }
    return _results;
  };

  Grid.prototype.fillCell = function(params) {
    this.grid[params.row][params.column].color = params.color.color;
    return this.grid[params.row][params.column].alpha = 1;
  };

  Grid.prototype.emptyGrid = function() {
    var i, j, _ref, _results;
    _results = [];
    for (i = 0, _ref = this.rows; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      this.grid.push([]);
      _results.push((function() {
        var _ref2, _results2;
        _results2 = [];
        for (j = 0, _ref2 = this.columns; 0 <= _ref2 ? j < _ref2 : j > _ref2; 0 <= _ref2 ? j++ : j--) {
          this.grid[i][j].color = "";
          _results2.push(this.grid[i][j].alpha = 1);
        }
        return _results2;
      }).call(this));
    }
    return _results;
  };

  return Grid;

})();

App.Models.Title = (function() {

  function Title(value, targetId) {
    this.value = value;
    this.targetId = targetId;
  }

  return Title;

})();

App.Models.ColorSelector = (function() {

  function ColorSelector(colors) {
    this.colors = colors != null ? colors : new App.Utils.DefaultColors().colors;
  }

  return ColorSelector;

})();

App.Models.CanvasPreview = (function() {

  function CanvasPreview(targetId, gridModel, factor) {
    this.targetId = targetId;
    this.gridModel = gridModel;
    this.factor = factor != null ? factor : 4;
  }

  return CanvasPreview;

})();

App.Models.FactorSelector = (function() {

  function FactorSelector(targetId, factor, selectors) {
    this.targetId = targetId;
    this.factor = factor;
    this.selectors = selectors != null ? selectors : [1, 2, 3, 4];
  }

  return FactorSelector;

})();

App.Models.Menu = (function() {

  function Menu(items, targetId) {
    this.items = items != null ? items : [];
    this.targetId = targetId;
  }

  Menu.prototype.addItem = function(item) {
    return this.items.push(item);
  };

  Menu.prototype.removeItem = function(item) {
    return this.items.splice(this.items.indexOf(item), 1);
  };

  return Menu;

})();

/* VIEWS
*/

App.Views.Cell = (function() {

  function Cell() {}

  return Cell;

})();

App.Views.Grid = (function() {

  function Grid(divTargetId, gridModel, cellStyle, emptyCellStyle, pen) {
    this.divTargetId = divTargetId;
    this.gridModel = gridModel != null ? gridModel : new App.Models.Grid();
    this.cellStyle = cellStyle != null ? cellStyle : "cell";
    this.emptyCellStyle = emptyCellStyle != null ? emptyCellStyle : "emptyCell";
    this.pen = pen != null ? pen : {};
    this.setPenColor = __bind(this.setPenColor, this);
    this.setDrawMode = __bind(this.setDrawMode, this);
    this.drawMode = false;
    this.eventDispatcher = new App.Utils.EventDispatcher(this);
    this.eventDispatcher.addListener("drawmodechange", this.setDrawMode);
    this.divTargetId.classes = this.divTargetId.className;
  }

  Grid.prototype.render = function() {
    var column, element, row, _ref, _ref2,
      _this = this;
    this.divTargetId.innerHTML = "";
    this.divTargetId.className = " " + this.divTargetId.classes + " _" + this.gridModel.columns;
    this.el = "";
    for (row = 0, _ref = this.gridModel.rows; 0 <= _ref ? row < _ref : row > _ref; 0 <= _ref ? row++ : row--) {
      for (column = 0, _ref2 = this.gridModel.columns; 0 <= _ref2 ? column < _ref2 : column > _ref2; 0 <= _ref2 ? column++ : column--) {
        element = " <div name='cell' ";
        if (this.gridModel.grid[row][column].color !== null && this.gridModel.grid[row][column].color !== "") {
          element += " style='background-color:" + this.gridModel.grid[row][column].color + "' ";
        } else {
          element += " class='" + this.emptyCellStyle + "' ";
        }
        element += " data-row='" + row + "' data-column='" + column + "' ";
        element += " ></div> ";
        this.el += element;
      }
    }
    this.divTargetId.innerHTML += this.el;
    this.divTargetId.onmouseup = function(e) {
      _this.drawMode = false;
      return _this.eventDispatcher.dispatch(new App.Utils.Event("renderpreview"), {});
    };
    this.divTargetId.onmousemove = this.divTargetId.onmousedown = function(e) {
      if (e.type === "mousedown") _this.drawMode = true;
      if (e.target.getAttribute("name") === "cell" && _this.drawMode === true) {
        _this.eventDispatcher.dispatch(new App.Utils.Event("clickcell"), {
          element: e.target,
          tool: "pen",
          width: 2,
          color: _this.pen.color,
          row: e.target.getAttribute("data-row"),
          column: e.target.getAttribute("data-column")
        });
      }
      return false;
    };
    return this;
  };

  Grid.prototype.fillCell = function(e) {
    var color;
    color = e.datas.color.color;
    if (["", void 0].indexOf(color) < 0) {
      e.datas.element.style.backgroundColor = color;
      return e.datas.element.className = "";
    } else {
      e.datas.element.style.backgroundColor = null;
      return e.datas.element.className += " " + this.emptyCellStyle;
    }
  };

  Grid.prototype.setDrawMode = function(event) {
    return this.drawMode = event.datas;
  };

  Grid.prototype.setPenColor = function(color) {
    return this.pen.color = color;
  };

  return Grid;

})();

App.Views.Application = (function() {

  function Application(divTarget, applicationModel) {
    this.divTarget = divTarget;
    this.applicationModel = applicationModel;
    this.children = [];
  }

  Application.prototype.addChild = function(view) {
    return this.children.push(view);
  };

  Application.prototype.removeChild = function(view) {
    return this.children.splice(this.children.indexOf(view), 1);
  };

  Application.prototype.render = function() {
    var child, _i, _len, _ref, _results;
    _ref = this.children;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(typeof child.render === "function" ? child.render() : void 0);
    }
    return _results;
  };

  return Application;

})();

App.Views.Color = (function() {

  function Color(model) {
    this.model = model != null ? model : new App.Models.Color();
  }

  Color.prototype.render = function() {
    this.el = document.createElement("div");
    this.el.setAttribute("title", this.model.title);
    this.el.className += " color ";
    if (this.model.color !== null && this.model.color !== "") {
      this.el.style.backgroundColor = this.model.color;
    } else {
      this.el.className += " emptyCell ";
    }
    return this;
  };

  return Color;

})();

App.Views.Title = (function() {

  function Title(model) {
    this.model = model;
    this.eventDispatcher = new App.Utils.EventDispatcher(this);
  }

  Title.prototype.render = function() {
    var _this = this;
    this.el = this.model.value.italics();
    this.model.targetId.innerHTML = this.el;
    this.model.targetId.setAttribute("title", "Click here to change the grid title");
    this.model.targetId.onclick = function(e) {
      e.currentTarget.setAttribute("contenteditable", true);
      e.currentTarget.style.border = "1px solid #00EEFF";
      e.currentTarget.style.borderRadius = "2px";
      e.currentTarget.style.padding = "2px 5px 2px 5px";
      return false;
    };
    this.model.targetId.onblur = this.model.targetId.onkeypress = function(e) {
      if (e.type === "keypress" && e.which !== 13) return;
      e.currentTarget.setAttribute("contenteditable", false);
      e.currentTarget.style.border = "";
      _this.model.value = e.currentTarget.innerText.trim() !== "" ? e.currentTarget.innerText.trim() : _this.model.value;
      _this.eventDispatcher.dispatch(new App.Utils.Event("titlechanged"), _this.model.value);
      return false;
    };
    this.model.onkeypress;
    return this;
  };

  return Title;

})();

App.Views.ColorSelector = (function() {

  function ColorSelector(el, model) {
    this.el = el;
    this.model = model;
    if (!this.model instanceof App.Models.ColorSelector) {
      throw new Error("model must be an instance of ColorSelector");
    }
    this.children = [];
    this.eventDispatcher = new App.Utils.EventDispatcher();
  }

  ColorSelector.prototype.render = function() {
    var i, _ref,
      _this = this;
    this.children = [];
    this.currentColor = new App.Views.Color(App.Models.Application.prototype.currentColor);
    this.el.innerHTML = "";
    this.h4Element = document.createElement("h4");
    this.h4Element.innerHTML = "Current Color";
    this.el.appendChild(this.h4Element);
    this.el.appendChild(this.currentColor.render().el);
    this.el.innerHTML += "<h4>Color swatch</h4>";
    for (i = 0, _ref = this.model.colors.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      this.children[i] = new App.Views.Color(this.model.colors[i]);
      this.el.appendChild(this.children[i].render().el);
      this.children[i].el.onclick = function(e) {
        _this.eventDispatcher.dispatch(new App.Utils.Event("colorchange"), {
          "color": e.target.style.backgroundColor,
          "title": e.target.title
        });
        return _this.render();
      };
    }
    return this;
  };

  return ColorSelector;

})();

App.Views.CanvasPreview = (function() {

  function CanvasPreview(model) {
    this.model = model;
  }

  CanvasPreview.prototype.render = function(localFactor) {
    var canvas, ctx, i, j, pointHeight, pointWidth, x, y, _ref, _ref2;
    if (localFactor == null) localFactor = this.model.factor;
    this.model.targetId.innerHTML = "";
    canvas = document.createElement("canvas");
    canvas.setAttribute("width", this.model.factor * this.model.gridModel.rows);
    canvas.setAttribute("height", this.model.factor * this.model.gridModel.columns);
    this.model.targetId.appendChild(canvas);
    ctx = canvas.getContext("2d");
    pointWidth = pointHeight = this.model.factor;
    for (i = 0, _ref = this.model.gridModel.rows; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      for (j = 0, _ref2 = this.model.gridModel.columns; 0 <= _ref2 ? j < _ref2 : j > _ref2; 0 <= _ref2 ? j++ : j--) {
        x = j * this.model.factor;
        y = i * this.model.factor;
        if (this.model.gridModel.grid[i][j].color === null || this.model.gridModel.grid[i][j].color === "") {
          ctx.fillStyle = "#FFFFFF";
          ctx.globalAlpha = 0;
        } else {
          ctx.fillStyle = this.model.gridModel.grid[i][j].color;
          ctx.globalAlpha = this.model.gridModel.grid[i][j].alpha;
        }
        ctx.fillRect(x, y, this.model.factor, this.model.factor);
      }
    }
    this.el = this.model.targetId.innerHTML;
    return this;
  };

  return CanvasPreview;

})();

App.Views.FactorSelector = (function() {

  function FactorSelector(model) {
    this.model = model;
    this.eventDispatcher = new App.Utils.EventDispatcher(this);
  }

  FactorSelector.prototype.render = function() {
    var i, _i, _len, _ref,
      _this = this;
    this.el = "<p>Zoom preview by :</p>";
    _ref = this.model.selectors;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      this.el += "<input type='radio' name='factor' " + (i === this.model.factor ? "checked" : void 0) + "  value='" + i + "' /> x " + i + " <br/>";
    }
    this.model.targetId.innerHTML = this.el;
    this.model.targetId.onclick = function(e) {
      if (e.target.name === "factor") {
        _this.model.factor = parseInt(e.target.value);
        return _this.eventDispatcher.dispatch(new App.Utils.Event("selectfactor"), e.target.value);
      }
    };
    return this;
  };

  return FactorSelector;

})();

App.Views.Menu = (function() {

  function Menu(model) {
    this.model = model;
    this.eventDispatcher = new App.Utils.EventDispatcher(this);
  }

  Menu.prototype.render = function() {
    var button, i, _ref,
      _this = this;
    this.model.targetId.innerHTML = "";
    for (i = 0, _ref = this.model.items.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      button = document.createElement("input");
      button.setAttribute("value", this.model.items[i].label);
      button.setAttribute("type", "button");
      button.setAttribute("id", this.model.items[i].action);
      button.setAttribute("title", this.model.items[i].title);
      if (button.dataset == null) button.dataset = {};
      button.dataset.id = i;
      this.model.targetId.appendChild(button);
      button.onclick = (function(e) {
        var action, datas;
        action = _this.model.items[i].action;
        datas = _this.model.items[i].datas;
        return function(e) {
          return _this.eventDispatcher.dispatch(new App.Utils.Event(action), datas);
        };
      })();
      this.el = this.model.targetId.innerHTML;
    }
    return this;
  };

  /* CONTROLLERS
  */

  return Menu;

})();

App.Controllers.Application = (function() {

  function Application(model) {
    this.model = model;
  }

  return Application;

})();

/* MAIN
*/

Main = (function() {

  function Main() {
    this.showThickbox = __bind(this.showThickbox, this);
    this.selecFactor = __bind(this.selecFactor, this);
    this.updateViews = __bind(this.updateViews, this);
    this.restoreFromLocal = __bind(this.restoreFromLocal, this);
    this.savetolocal = __bind(this.savetolocal, this);
    this.emptygrid = __bind(this.emptygrid, this);
    this.changegridsize = __bind(this.changegridsize, this);
    this.exportCanvas = __bind(this.exportCanvas, this);
    this.oncolorchange = __bind(this.oncolorchange, this);
    this.renderPreview = __bind(this.renderPreview, this);
    this.titleChange = __bind(this.titleChange, this);
    this.clickcell = __bind(this.clickcell, this);
    var $canvasPreview, $colorSelector, $factorSelector, $menu, $target, $title, defaultColor, title, version;
    version = 0.1;
    this.thickbox = document.getElementById("thickbox");
    $target = document.getElementById("target");
    $canvasPreview = document.getElementById("canvasPreview");
    $colorSelector = document.getElementById("colorSelector");
    $menu = document.getElementById("menu");
    $factorSelector = document.getElementById("factorSelector");
    $title = document.getElementById("title");
    title = "Fav icon builder";
    defaultColor = "#000000";
    /* MODELS
    */
    this.applicationModel = new App.Models.Application();
    this.colorSelectorModel = new App.Models.ColorSelector();
    this.gridModel = new App.Models.Grid(16, 16, 0.1, "new grid");
    this.titleModel = new App.Models.Title("new grid", $title);
    this.canvasPreviewModel = new App.Models.CanvasPreview($canvasPreview, this.gridModel);
    this.factorSelectorModel = new App.Models.FactorSelector($factorSelector, this.canvasPreviewModel.factor);
    this.menuModel = new App.Models.Menu(new App.Utils.DefaultMenu().items, $menu);
    this.applicationModel.colorSelectorModel = this.colorSelectorModel;
    this.applicationModel.gridModel = this.gridModel;
    this.applicationModel.titleModel = this.titleModel;
    this.applicationModel.canvasPreviewModel = this.canvasPreviewModel;
    this.applicationModel.factorSelectorModel = this.factorSelectorModel;
    this.applicationModel.menuModel = this.menuModel;
    /* CONTROLLERS
    */
    /* VIEWS
    */
    this.applicationView = new App.Views.Application($target, this.applicationModel);
    this.colorSelectorView = new App.Views.ColorSelector($colorSelector, this.colorSelectorModel);
    this.colorSelectorView.eventDispatcher.addListener("colorchange", this.oncolorchange);
    this.canvasPreviewView = new App.Views.CanvasPreview(this.canvasPreviewModel);
    this.factorSelectorView = new App.Views.FactorSelector(this.factorSelectorModel);
    this.gridView = new App.Views.Grid($target, this.gridModel);
    this.titleView = new App.Views.Title(this.titleModel);
    this.gridView.setPenColor(this.applicationModel.currentColor);
    this.menuView = new App.Views.Menu(this.menuModel);
    this.applicationView.addChild(this.gridView);
    this.applicationView.addChild(this.titleView);
    this.applicationView.addChild(this.colorSelectorView);
    this.applicationView.addChild(this.canvasPreviewView);
    this.applicationView.addChild(this.factorSelectorView);
    this.applicationView.addChild(this.menuView);
    this.applicationView.render();
    /* EVENTS
    */
    this.menuView.eventDispatcher.addListener("exporttopng", this.exportCanvas);
    this.menuView.eventDispatcher.addListener("changegridsize", this.changegridsize);
    this.menuView.eventDispatcher.addListener("emptygrid", this.emptygrid);
    this.menuView.eventDispatcher.addListener("savetolocal", this.savetolocal);
    this.menuView.eventDispatcher.addListener("restorefromlocal", this.restoreFromLocal);
    this.menuView.eventDispatcher.addListener("showthickbox", this.showThickbox);
    this.factorSelectorView.eventDispatcher.addListener("selectfactor", this.selecFactor);
    this.gridView.eventDispatcher.addListener("renderpreview", this.renderPreview);
    this.gridView.eventDispatcher.addListener("updateviews", this.updateViews);
    this.gridView.eventDispatcher.addListener("clickcell", this.clickcell);
    this.titleView.eventDispatcher.addListener("titlechanged", this.titleChange);
  }

  Main.prototype.clickcell = function(e) {
    this.gridModel.fillCell(e.datas);
    return this.gridView.fillCell(e);
  };

  Main.prototype.titleChange = function(e) {
    return this.updateViews();
  };

  Main.prototype.renderPreview = function(e) {
    return this.canvasPreviewView.render();
  };

  Main.prototype.oncolorchange = function(e) {
    console.log("oncolorchange", e.datas.color, e.datas.title);
    this.applicationModel.currentColor.color = e.datas.color;
    return this.applicationModel.currentColor.title = e.datas.title;
  };

  Main.prototype.exportCanvas = function(e) {
    return window.open(this.canvasPreviewModel.targetId.getElementsByTagName('canvas')[0].toDataURL("image/png"));
  };

  Main.prototype.changegridsize = function(e) {
    console.log("changegridsize", e.datas);
    this.gridModel.rows = e.datas.rows;
    this.gridModel.columns = e.datas.columns;
    this.gridModel.fillGridBlank();
    return this.applicationView.render();
  };

  Main.prototype.emptygrid = function() {
    this.gridModel.emptyGrid();
    return this.gridView.render();
  };

  Main.prototype.savetolocal = function() {
    return (localStorage["faviconbuilderGrid"] = JSON.stringify(this.gridModel)) && alert("Icon saved to local storage");
  };

  Main.prototype.restoreFromLocal = function() {
    var gridModel;
    if (localStorage["faviconbuilderGrid"] !== null) {
      gridModel = JSON.parse(localStorage["faviconbuilderGrid"]);
      this.gridModel.grid = gridModel.grid;
      this.gridModel.rows = gridModel.rows;
      this.gridModel.columns = gridModel.columns;
      this.gridModel.version = gridModel.version;
      return this.updateViews();
    }
  };

  Main.prototype.updateViews = function() {
    return this.applicationView.render();
  };

  Main.prototype.selecFactor = function(e) {
    this.canvasPreviewModel.factor = parseInt(e.datas);
    return this.updateViews();
  };

  Main.prototype.showThickbox = function(e) {
    var _this = this;
    console.log(e, "show thickbox");
    this.thickbox.style.visibility = this.thickbox.style.visibility === "hidden" ? "visible" : "hidden";
    this.thickbox.style.opacity = parseInt(this.thickbox.style.opacity) < 1 ? 1 : 0;
    return this.thickbox.onclick = function(e) {
      return _this.showThickbox(e);
    };
  };

  return Main;

})();

if (typeof window !== "undefined" && window !== null) {
  window.onload = function() {
    return typeof window !== "undefined" && window !== null ? window.main = new Main() : void 0;
  };
}
