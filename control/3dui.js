gTesting = false;

loadedInterfaceName = "3DUI";
interfaceOrientation = "landscape";
 
gFadeTime = 2000;

window.nodes = [];
window.nodeWidth = 250;
window.nodeHeight = 342;
window.rolloverNode = null;
window.nodeCounter = 0;

window.lastTapped = null;

window.tapTimeDelta = 400;
window.tapDistanceDelta = .5; // in perecentage of widget size

window.lastTappedNode = null;

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
        if(! $(e.target).is("li") && ! $(e.target).is("input") && !$(e.target).is("ul")) {
            e.preventDefault();
        }
        /*if($(e.target).is("ul") && e.type == "touchmove") {
            window.setTimeout(function() { window.canvasDraw(); }, 5);
        }*/
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

window.doubletap = function(xvalue, yvalue) {
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
                    //console.log("DOUBLE DOUBLE");
                    if(node != window.lastTappedNode) {
                        window.clearTimeout(node.timeout);
                        $(node).css("opacity", 1);
                        //console.log("SENDING " + control.id + " :: " + node.id);
                        oscManager.sendOSC('/selectNode', 'ii', control.id, node.id);
                        if(gTesting)
                            window.fakeNode(); 
                    }
                    window.lastTappedNode = node;
                }
            }
        }
    }
    
    window.lastTap = tap;
};

window.aList = "+ Name 1 | + Name 2 | + Name 3 | + Name 4 | + Name 5 | + Name 6 | + Name 7 | + Name 8 | + Name 9 | + Name 10",   

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
        "top"       : "38px",
        "left"      : "0px",
        "height"    : window.nodeHeight,
        "width"     : "1022px",
        "overflow-x": "scroll",
        "-webkit-overflow-scrolling": "touch",
        "border-width": "1px 0px",
        "border-color": "#777",
        "border-style": "solid",
    });

    $("#selectedInterface").append(control.nodeHolder);
    $(control.nodeHolder).bind('scroll', window.canvasDraw);
    
    control.canvas = document.createElement("canvas");
    $(control.canvas).attr("id", "canvas");
    $(control.canvas).attr("width", 1024);
    $(control.canvas).attr("height", 384);    
    $(control.canvas).css({
       "display": "block",  
       "position": "absolute", 
       "top": "384px", 
       "left": "50", 
       "background-color": "#000", 
       "z-index": -1,
    });
    
    $("#selectedInterface").append(control.canvas);
    
    control.canvasCtx = control.canvas.getContext("2d"); 
    
    oscManager.sendOSC('/handshake', 's', window.ipAddress);
};
 
window.test = function() {
    console.log("testing");
    var node = window.addTempNode(.4, .4, 1, "C" + window.nodeCounter++);
    
    $(node).bind("touchstart", function(e) {
        window.fakeNode();
    });
};

window.fakeNode = function() {
    window.addNode(1, "C" + window.nodeCounter, "Charlie Roberts", window.aList);
};

window.clearAllNodes = function() {
    control.canvas.width = control.canvas.width;
    window.nodes.length = 0;
    $(".node, .expandedNode").remove();  
};
window.tempNodes = [];

window.canvasDraw = function() {
    var ctx = control.canvas.getContext("2d"); 
    
    control.canvas.width = control.canvas.width;

    //ctx.clearRect(0,0,1024,384); // this would improve performance... why does it work?
    ctx.strokeStyle = "#777";
    ctx.lineWidth = 1;

    var y1 = 384;
    for(var i = 0; i < window.nodes.length; i++) {
        var n1 = window.nodes[i];
        var xy = $(n1).position();
        var w  = $(n1).width();
        var h  = $(n1).height();
        var x1 = xy.left + (w / 2);
        
        ctx.moveTo(x1,xy.top);
        
        var n2 = n1.smallNode;
        var xy2 = $(n2).position();
        var w2 =  $(n2).width();
        var h2 =  $(n2).height();
        var x2 =  xy2.left + (w2 / 2);
        var y2 =  xy2.top - 384;
        
        //console.log("x2 " + x2 + " :: y2 " + y2);
        
        ctx.lineTo(x2,y2);
        
    }
    ctx.stroke();
}
window.addTempNode = function(xpos, ypos, nodeID, nodeName) {
    console.log("temp node");
    var tempNode = document.createElement("div");
    $(tempNode).css({
        // "background-color"   : "rgba(" + control.myColor[0] + "," + control.myColor[1] + "," + control.myColor[2] + ",1)",
        "background-color"   : "rgba(255,0,0,1)",
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
        "borderRadius"       : 5,
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
    
    $(tempNode).text(nodeName);

    $("#selectedInterface").append(tempNode);
    tempNodes.push(tempNode);
    //console.log("adding temp node 4");    
    return tempNode;
};
 
window.addNode = function(nodeID, authorName, authorNameFull, pubs) {
    console.log("PUBS = " + pubs);
    var pubsAsLI = pubs.split("|");
    console.log("CREATING");
    /**************************** CREATE NODE ****************************/
    var node = document.createElement("div");
    $(node).css({
        "background-color"  : "#000",
        "color"             : "#000",
        "position"          : "absolute",
        "left"              : window.nodes.length * window.nodeWidth + "px",
        "top"               : "0px",
        "width"             : window.nodeWidth  + "px",
        "height"            : window.nodeHeight + "px",
        "color"             : "#fff",
        "zIndex"            : 10,
        "border-width"      : "0px 1px",
        "border-color"      : "#999",
        "border-style"      : "solid",
    });
    
    $(node).addClass("expandedNode");
    
    node.smallNode = window.lastTappedNode;
    console.log("small node id = " + node.smallNode.id);
    node.id = nodeID;
    node.arrayPos = window.nodes.length;
    window.nodes.push(node);
    
    /**************************** CREATE HEADER **************************/
    var header = document.createElement("div");
    $(header).css({
        "backgroundColor"   : "#333",
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
        "background-color"  : "#333",
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
    console.log("pubs length = " + pubsAsLI.length);
    for(var i = 0; i < pubsAsLI.length - 1; i++) {
        pubsAsLI[i].replace("|", "");
        var appendHTML = "<li style='height:auto; margin-bottom:.5em;'>" + pubsAsLI[i] + "</li>";
        //console.log(appendHTML);
        //console.log("pubsAsLI = " + pubsAsLI[i]);
        $(pubList).append(appendHTML);
    }
    //$(pubList).html(pubs);
    
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
    window.canvasDraw();
};

window.deleteNode = function(node) {
    document.getElementById("selectedInterface").removeChild(node);
    window.canvasDraw();    
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
    // $(".node").each(function(index) {
    //     console.log(this);
    //     console.log($(this).text());
    //     if(expandedNode.id == $(this).text()) {
    //         $(this).remove();
    //     }
    // });
    
    for(var i =0; i < window.tempNodes.length; i++) {
        var tempNode = window.tempNodes[i];
        if(tempNode.id == expandedNode.id) {
            $(tempNode).remove();
            window.tempNodes.splice(i,1);
            break;
        }
    }
    
    
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
                window.addNode(args[0], args[1], args[2], args[3]);
                break;
            case "/idassigned":
                idLabel.setValue("id " + args[0]);
                control.id = args[0];
                control.myColor = [parseInt(args[1] * 255), parseInt(args[2] * 255), parseInt(args[3] * 255)];
                break;
        }
    }           
}

window.buttonWidth = (window.nodeWidth / 2) / 1024;
pages = [[
{
    "name": "tabButton",
    "type": "Button",
    "bounds": [.0, 0, window.buttonWidth, .05],
    "mode": "toggle",
    "stroke": "#aaa",
    "isLocal": true,
    "ontouchstart": "control.showToolbar();",
    "label": "menu",
},
{
    "name": "refresh",
    "type": "Button",
    "bounds": [window.buttonWidth, .0, window.buttonWidth, .05],
    "startingValue": 0,
    "isLocal": true,
    "mode": "contact",
    "ontouchstart": "$(control.canvas).remove(); interfaceManager.refreshInterface()",
    "stroke": "#aaa",
    "label": "refresh",
},
{
    "name":"handshake",
    "type": "Button",
    "stroke":"#aaa",
    "bounds": [window.buttonWidth * 2, .0, window.buttonWidth, .05], 
    "isLocal": "true",
    "label": "handshake",
    "ontouchstart": "oscManager.sendOSC('/handshake', 's', window.ipAddress);", 
    "mode":"contact",
},
{
    "name": "clear", 
    "type": "Button", 
    "stroke": "#aaa",
    "bounds": [window.buttonWidth * 3, 0, window.buttonWidth, .05], 
    "label": "clear", 
    "isLocal": true, 
    "ontouchstart": "window.clearAllNodes(); oscManager.sendOSC('/clear', 'i', control.id);", 
    "mode":"contact",    
},
{
    "name": "testButton", 
    "type": "Button", 
    "stroke": "#aaa",    
    "bounds": [window.buttonWidth * 4, 0, window.buttonWidth, .05], 
    "label": "test", 
    "ontouchstart": "window.test();", 
    "mode":"contact",    
},
{
    "name" : "multi",
    "type" : "MultiTouchXY",
    "bounds": [0, .5, 1, .5],
    "isMomentary": false,
    "colors":["rgba(0,0,0,0)", "rgba(0,0,0,0)", "rgba(0,0,0,0)"],
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
    "bounds": [window.buttonWidth * 5, 0, .25, .05], 
    "value":"BASAK",
},
{
    "name":"idLabel",
    "type": "Label", 
    "bounds": [.8, 0, .2, .05], 
    "value":"BASAK BASAK    ",
},
]   

];