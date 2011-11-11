gTesting = false;

loadedInterfaceName = "3DUI";
interfaceOrientation = "landscape";
 
gFadeTime = 2000;

window.nodes = [];
window.nodeWidth = 250;
window.nodeHeight = 380;
window.rolloverNode = null;
window.nodeCounter = 0;

window.tapTimeDelta = 500;
window.tapDistanceDelta = .5; // in perecentage of widget size

window.lastTap = null;

control.id = 1;

control.sendCount = 0;

window.outputTouchInfo = function(_widget) {
    if(control.sendCount++ % 2 == 0) {
        var valueString = "";

        valueString = "|" + _widget.address;
        if (_widget.maxTouches > 1) {
          valueString += "/" + touch.activeNumber;
        }
        
        valueString += ":" + control.id + "," + _widget.xvalue + "," + _widget.yvalue;
        
        control.valuesString += valueString;
    }
};

function _preventBehavior(e) { // prevent scrolling
     // console.log(event.target.nodeName);
     // console.log("preventing " + control.shouldPrevent);
     // if(control.shouldPrevent) { e.preventDefault(); return; }
     // e.preventDefault();
    if($(e.target).is("div")) {
        e.preventDefault();
    }else{
        //console.log("list height = " + $(e.target).parent().height() + " :: wrapper height = " + $("#wrapper").height());
        //console.log(e.target.nodeName);
        if(! $(e.target).is("li") && ! $(e.target).is("input")) {
            e.preventDefault();
        }
    }
};

$("body").unbind('touchmove touchstart touchend', preventBehavior);
$("html").unbind('touchmove touchstart touchend', preventBehavior); // why the hell is this getting events???? must be bug in webkit      
$("#selectedInterface").unbind('touchmove touchstart touchend', preventBehavior);            
$("#SelectedInterfacePage").unbind('touchmove touchstart touchend', preventBehavior);

$("body").bind('touchmove touchstart touchend', _preventBehavior);
$("html").bind('touchmove touchstart touchend', _preventBehavior); // why the hell is this getting events???? must be bug in webkit      
$("#selectedInterface").bind('touchmove touchstart touchend', _preventBehavior);            
$("#SelectedInterfacePage").bind('touchmove touchstart touchend', _preventBehavior);

//$("#selectedInterface").height("768px");
window.doubletap = function(xvalue, yvalue) {
    console.log("DOUBLE TAP");
    var now = new Date().getTime();
    var tap = {
        "time": now,
        "xvalue": xvalue,
        "yvalue": yvalue,
    }
    
    if(window.lastTap != null) {
        if(tap.time - lastTap.time < window.tapTimeDelta) {
            var distance = Math.sqrt( Math.pow(tap.xvalue - lastTap.xvalue, 2) + Math.pow(tap.yvalue - lastTap.yvalue, 2) );
            if(distance < .05) {
                var node = window.selectNode();
                if(node != null) {
                    console.log("DOUBLE DOUBLE");
                    window.clearTimeout(node.timeout);
                    $(node).css("opacity", 1);
                    console.log("SENDING " + control.id + " :: " + node.id);
                    oscManager.sendOSC('/selectNode', 'ii', control.id, node.id);
                    if(gTesting)
                        window.fakeNode(); 
                }
            }
        }
    }
    
    window.lastTap = tap;
};

window.aList = "<li>Name 1</li><li>Name 2</li><li>Name 3</li><li>Name 4</li><li>Name 5</li><li>Name 6</li><li>Name 7</li><li>Name 1</li><li>Name 1</li><li>Name 1</li><li>Name 1</li><li>Name 1</li><li>Name 1</li><li>Name 1</li>";

window.selectNode = function() {
    return window.rolloverNode;
    
};

window.initInterface = function() {
    control.moveCount = 0;
    $(window.multi).bind('touchmove touchstart touchend', preventBehavior);
    
    control.nodeHolder = document.createElement("div");
    $(control.nodeHolder).css({
        "display"   : "block",
        "position"  : "absolute",
        "top"       : "0px",
        "left"      : "0px",
        "height"    : window.nodeHeight,
        "width"     : "900px",
        "overflow-x": "scroll",
        "-webkit-overflow-scrolling": "touch",
        "border"    : "1px solid #777",
    });

    $("#selectedInterface").append(control.nodeHolder);
    
    // control.canvas = document.createElement("canvas");
    // $(control.canvas).css({
    //    "display": "block",  
    //    "position": "absolute", 
    //    "top": "334px", 
    //    "left": "0", 
    //    "height": "334px", 
    //    "width": "1024px",
    //    "background-color": "#f00", 
    // });
    
    // $("#selectedInterface").append(control.canvas);
    // 
    // control.canvasCtx = control.canvas.getContext("2d"); 
    // control.canvasCtx.fillStyle = "rgba(255,25,0,1)";
    // control.canvasCtx.fillRect(100,100,50,50); 
    
    //window.fakeNode();
    oscManager.sendOSC('/handshake', 's', window.ipAddress);
};
 
window.test = function() {
    var node = window.addTempNode(.4, .4, 1, "Charlie" + window.nodeCounter++);
    
    $(node).bind("touchstart", function(e) {
        window.fakeNode();
    });
};

window.fakeNode = function() {
    window.addNode(3, "Charlie" + window.nodeCounter, window.aList);
};

window.clearAllNodes = function() {
  $(".node, .expandedNode").remove();  
};

window.addTempNode = function(xpos, ypos, nodeID, nodeName) {
    var tempNode = document.createElement("div");
    $(tempNode).css({
        "background-color"   : "#a0a",
        "display"            : "block",
        "position"           : "absolute",
        "left"               : xpos * 1024 + "px",
        "top"                : 384 + ypos * 384  + "px", // TODO: GET RID OF MAGIC NUMBERS!!!
        "width"              : "20px",
        "height"             : "20px",
        "color"              : "#fff",
        "padding"            : "10px",
        "z-index"            : 10,
        "opacity"            : 1,
        "webkitTransitionProperty"   : "opacity",
        "webkitTransitionDuration"   : gFadeTime + "ms",
    });
    
    $(tempNode).addClass("node");
    
    var fadeDelay = 250;
    tempNode.timeout = setTimeout(function() {
         window.deleteNode(node);
    }, gFadeTime + fadeDelay );
    
    setTimeout(function() { 
        tempNode.style.opacity = 0;
    }, fadeDelay );
      
    tempNode.id = nodeID;
    // $(tempNode).bind('touchstart', function(e) {
    //     console.log("TEMP NODE TOUCH " + $(this).text());
    //     window.clearTimeout($(this).timeout);
    //     $(this).css("opacity", 1);
    //     oscManager.sendOSC('/selectNode', 'ii', control.id, tempNode.id); 
    // });
    
    window.rolloverNode = tempNode;
    
    $(tempNode).text(nodeID);

    $("#selectedInterface").append(tempNode);
    //console.log("adding temp node 4");    
    return tempNode;
};
 
window.addNode = function(nodeID, authorName, pubs) {
    console.log("CREATING");
    /**************************** CREATE NODE ****************************/
    var node = document.createElement("div");
    $(node).css({
        "background-color"  : "#ccc",
        "color"             : "#000",
        "position"          : "absolute",
        "left"              : window.nodes.length * window.nodeWidth + "px",
        "top"               : "0px",
        "width"             : window.nodeWidth  + "px",
        "height"            : window.nodeHeight + "px",
        "color"             : "#fff",
        "zIndex"            : 10,
    });
    
    $(node).addClass("expandedNode");
    node.id = nodeID;
    node.arrayPos = window.nodes.length;
    window.nodes.push(node);
    
    /**************************** CREATE HEADER **************************/
    var header = document.createElement("div");
    $(header).css({
        "backgroundColor"   : "#f00",
        "width"             : window.nodeWidth - 10 + "px",
        "height"            : "30px",
        "margin"            : 0,
        "padding-left"      : "10px",
        "padding-top"       : "10px",
        "position"          : "relative",
        "top"               : 0,
        "left"              : 0,
    });
    
    /**************************** CREATE HEADER TEXT *********************/
    var headerText = document.createElement("h4");
    $(headerText).text(authorName);
    $(headerText).css({
        "background-color"  : "#f00",
        "width"             : window.nodeWidth - 50 + "px",
        "height"            : "30px",
        "margin"            : 0,
        "fontSize"          : "1.5em",
        "overflow"          : "hidden",
        "text-overflow"     : "ellipsis",
        "white-space"       : "nowrap",
        "font-size"         : "1.5em",
        "position"          : "relative",
    });
    
    /**************************** CREATE DISMISSAL BUTTON ****************/
    var dismiss = document.createElement("button");
    $(dismiss).css({
        "width"     : "30px",
        "height"    : "30px",
        "top"       : "5px",
        "right"     : "5px",
        "position"  : "absolute",
    });
    
    $(dismiss).text("X");
    $(dismiss).bind('touchstart', function(e) {
        console.log("DELETING DELETING DELeti");
         window.deleteExpandedNode(node); 
    });
    
    /**************************** CREATE PUSH BUTTON **********************/
    var push = document.createElement("button");
    $(push).css({
        "width"     : "30px",
        "height"    : "30px",
        "top"       : "5px",
        "right"     : "55px",
        "position"  : "absolute",
    });
    
    $(push).text("P");
    $(push).bind('touchstart', function(e) {
        console.log("PUSH IT BABY, PUSH IT REAL GOOD");
        oscManager.sendOSC('/displayNode', 'ii', control.id, node.id); 
    });
    /**************************** CREATE SCROLL WRAP DIV  *****************/
    // var wrap = document.createElement("div");
    // $(wrap).css({
    //     "position"      : "relative",
    // 
    // });
    
    // wrap.style.overflow = "scroll";
    // wrap.style.webkitOverflowScrolling = "touch";
    
    /**************************** CREATE PUBLICATION LIST *****************/
    var pubList = document.createElement("ul");
    $(pubList).css({
        "position"      : "relative",
        "height"        : window.nodeHeight - 60 + "px",
        "overflow-y"    : "scroll",
        "-webkit-overflow-scrolling": "touch",
        "padding-left"  : "10px",
        "color"         : "#000",
    });
    
    $(pubList).addClass("pubList");
    $(pubList).html(pubs);
    
    /**************************** FINALIZE & APPEND TO DOM ****************/
    $(header).append(headerText);
    $(header).append(push);
    $(header).append(dismiss);
    
    node.header = header;
    node.headerText = headerText;
    node.pubList = pubList;
    
    $(node).append(header);
    $(node).append(pubList);
    //$(node).append(wrap);

    //$("#selectedInterface").append(node);
    $(control.nodeHolder).append(node);
};

window.deleteNode = function(node) {
    console.log("deleting" + $(node).text());
    document.getElementById("selectedInterface").removeChild(node);
    node = null;
};

window.deleteExpandedNode = function(expandedNode) {
    //oscManager.sendOSC('/displayNode',  'ii', control.id, expandedNode.id);
    oscManager.sendOSC('/deselectNode', 'ii', control.id, expandedNode.id);
    
    var nodeName = $(expandedNode.headerText).text();
    
    // remove from nodes array
    for (var i in window.nodes) {
        var n = window.nodes[i];
        if(n.id == expandedNode.id) {
            window.nodes.splice(i,1);
        }
    }
    
    // remove smaller node representation
    $(".node").each(function(index) {
        console.log($(this).text());
        if(nodeName == $(this).text()) {
            $(this).remove();
        }
    });
    
    // remove from DOM
    $(expandedNode).remove();
    console.log("DELETE");
    for (var i in window.nodes) {
        var n = window.nodes[i];
        console.log("CALLING for node number " + i);
        $(n).css("left", i * window.nodeWidth);
    }
};
 
window.oscManager.delegate = {
    processOSC : function(oscAddress, typetags, args) {
        console.log(oscAddress + " :: " + typetags);
        window.label.setValue(oscAddress + " :: " + typetags);
        switch(oscAddress) {
            case "/rollover": // type tags f f s i 
                window.addTempNode(args[0], args[1], args[2], args[3]);
                //window.addTempNode(args[0], args[1], args[2]);
                break;
            case "/createNode":
                console.log("CREATING NODE");
                window.addNode(args[0], args[1], args[2]);
                break;
            case "/idassigned":
                idLabel.setValue("id " + args[0]);
                control.id = args[0];
                break;
        }
    }           
}

pages = [[
{
    "name": "tabButton",
    "type": "Button",
    "bounds": [.9, 0, .1, .05],
    "mode": "toggle",
    "stroke": "#aaa",
    "isLocal": true,
    "ontouchstart": "control.showToolbar();",
    "label": "menu",
},
{
    "name": "refresh",
    "type": "Button",
    "bounds": [.9, .05, .1, .05],
    "startingValue": 0,
    "isLocal": true,
    "mode": "contact",
    "ontouchstart": "interfaceManager.refreshInterface()",
    "stroke": "#fff",
    "label": "refresh",
},
{
    "name":"handshake",
    "type": "Button",
    "colors": ["#f00", "#000", "#fff"] ,
    "bounds": [.9, .1, .1, .05], 
    "isLocal": "true",
    "label": "handshake",
    "ontouchstart": "oscManager.sendOSC('/handshake', 's', window.ipAddress);", 
    "mode":"contact",
},
{
    "name": "clear", 
    "type": "Button", 
    "bounds": [.9,.15,.1,.05], 
    "label": "clear", 
    "ontouchstart": "window.clearAllNodes(); oscManager.sendOSC('/clear');", 
    "mode":"contact",    
},
{
    "name": "testButton", 
    "type": "Button", 
    "bounds": [.9,.2,.1,.05], 
    "label": "test", 
    "ontouchstart": "window.test();", 
    "mode":"contact",    
},
{
    "name" : "multi",
    "type" : "MultiTouchXY",
    "bounds": [0, .5, 1, .5],
    "isMomentary": false,
    "colors":["rgba(255,0,0,0)", "#000", "#999"],
    "maxTouches": 1,
    "address":"/screencoord",
    "touchSize":"20px",
    "isLocal":true,
    "ontouchmove":"window.outputTouchInfo(this);",
    "ontouchend": "window.doubletap(this.xvalue, this.yvalue)",
    "oninit":     "window.initInterface();",    
},

{
    "name":"label",
    "type": "Label", 
    "bounds": [.9, .3, .1, .05], 
    "value":"testaaaaa",
},
{
    "name":"idLabel",
    "type": "Label", 
    "bounds": [.9, .4, .1, .05], 
    "value":"no id yet loser",
},
]   

];