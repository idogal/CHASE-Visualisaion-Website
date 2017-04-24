/**
 * This is an example on how to use sigma filters plugin on a real-world graph.
 */
var filter;

/**
 * DOM utility functions
 */
var utils = {
    $: function (id) {
        return document.getElementById(id);
    },

    all: function (selectors) {
        return document.querySelectorAll(selectors);
    },

    show: function (selectors) {
        this.removeClass(selectors, 'hidden');
    },

    hide: function (selectors) {
        this.addClass(selectors, 'hidden');
    },

    toggle: function (selectors, cssClass) {
        var cssClass = cssClass || "hidden";
        var nodes = document.querySelectorAll(selectors);
        var l = nodes.length;
        for (i = 0; i < l; i++) {
            var el = nodes[i];
            //el.style.display = (el.style.display != 'none' ? 'none' : '' );
            // Bootstrap compatibility
            if (-1 !== el.className.indexOf(cssClass)) {
                el.className = el.className.replace(cssClass, '');
            } else {
                el.className += ' ' + cssClass;
            }
        }
    }
};

// Add a method to the graph model that returns an
// object with every neighbors of a node inside:
sigma.classes.graph.addMethod('neighbors', function (nodeId) {
    var k,
            neighbors = {},
            index = this.allNeighborsIndex[nodeId] || {};

    for (k in index)
        neighbors[k] = this.nodesIndex[k];

    return neighbors;
});

function updatePane(graph, filter) {
    // get max degree
    var maxDegree = 0,
            categories = {};

    // read nodes
    graph.nodes().forEach(function (n) {
        maxDegree = Math.max(maxDegree, graph.degree(n.id));
        categories[n.attributes.acategory] = true;
    });

    // min degree
    utils.$('min-degree').max = maxDegree;
    utils.$('max-degree-value').textContent = maxDegree;
}

function parseAPDataXML(data, authorName) {
    if (window.DOMParser)
    {
        parser = new DOMParser();
        xmlDoc = parser.parseFromString(data, "text/xml");
    } else // Internet Explorer
    {
        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = false;
        xmlDoc.loadXML(txt);
    }
    
    var publicationNum = 1;
    var allPublications = "";
    var pbList = xmlDoc.getElementsByTagName("Author_Publication");
    for (var i = 0, apLength = pbList.length; i < apLength; i++) {
        var pb = pbList[i].childNodes; 
        
        var xmlAuthorName = "";
        var paperYear = "";
        var citCount ="";
        var displayName = "";
        var venueShortName = "";
        var DOI = "";
        var abstract = "";
        var affiliationName = "";
        var allAuthors = "";
        
        for (var j = 0, pbLength = pb.length; j < pbLength; j++) {
            var nodeName = pb[j].nodeName;
            if (pb[j].nodeType !== 1)
                continue;
            
            if (nodeName === "Paper_Year") {
                paperYear = pb[j].innerHTML;
                continue;
            }
            if (nodeName === "Citations_Count") {
                citCount = pb[j].innerHTML;
                continue;
            }
                
            if (nodeName === "Display_Name"){
                displayName = pb[j].innerHTML;
                continue;                
            }
                
            if (nodeName === "Venue_Short_Name"){
                venueShortName = pb[j].innerHTML;
                continue;
            }
                
            if (nodeName === "DOI"){
                DOI = pb[j].innerHTML;
                continue;
            }
                
            if (nodeName === "Abstract"){
                abstract = pb[j].innerHTML;  
                continue;
            }
                
            if (nodeName === "Author_Name"){
                xmlAuthorName = pb[j].innerHTML;   
                continue;
            }
                 
            if (nodeName === "Affiliation_Name"){
                affiliationName = pb[j].innerHTML;  
                continue;
            }
            
            if (nodeName === "All_Authors"){
                allAuthors = pb[j].innerHTML;  
                continue;
            }            
        } 
        
        if (xmlAuthorName === authorName) {
            var thisPublication = 
                    "Year: " + paperYear + " <br>" +
                    "Display Name: <b>" + displayName  + "</b> <br>" +
                    "Authors: " + allAuthors  + " <br>" +
                    "Affiliation: " + affiliationName + " <br>" +
                    "Venue (short): " + venueShortName  + " <br>" +
                    "Citations: " + citCount  + " <br>" +
                    "DOI: " + DOI + " <br>" ;                    

            if (allPublications === "") {
                allPublications = allPublications + "(" + publicationNum + ") <br>" + thisPublication;
            } else {
                allPublications = allPublications + "<br>(" + publicationNum + ") <br>" + thisPublication;
            }
            
            publicationNum++;
        }
    }    
    
    return allPublications;
}

function getAuthorData(authorName)
{
    var file = "resources/ap_data.xml";
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status === 0)
            {
                var allText = rawFile.responseText;
                var publicationText = parseAPDataXML(allText, authorName);
                
                document.getElementById("details-pane").hidden = false;
                document.getElementById("authors-details-paragraph").innerHTML = publicationText;
            }
        }
    }
    rawFile.send();
}

var actualGraph;

function showGraph(pathToFile) {    
    if (actualGraph) {
        sigma.parsers.gexf( 
            pathToFile,
            actualGraph,
            function(s) {
               s.refresh();
               initGraphFuncionality(s);
            }
        );    
    } else {    
        sigma.parsers.gexf(
            pathToFile,
            {
                renderer: {
                    container: 'graph-container',
                    type: 'canvas'
                },
                settings: {
                    edgeLabelSize: 'proportional',
                    minArrowSize: '7',
                    defaultEdgeType: 'curvedArrow',
                    hoverFontStyle: 'bold',
                    labelThreshold: 4,
                    defaultLabelSize: 12
                }
            },
            function(s) {
                actualGraph = s;
                initGraphFuncionality(s);
            }
        );
    }; 
    
    resetHtmlActions();
}

function resetHtmlActions() {
    var authorNameElement = document.getElementById("authorName");
    var authorDetailsElement = document.getElementById("authors-details-paragraph");
    authorNameElement.value = "";
    authorDetailsElement.innerHTML = "";
    document.getElementById("details-pane").hidden = true;
}

function initGraphFuncionality(s) {
    filter = new sigma.plugins.filter(s);
    updatePane(s.graph, filter);

    // Initialize the dragNodes plugin:
    var dragListener = sigma.plugins.dragNodes(s, s.renderers[0]);

    dragListener.bind('startdrag', function (event) {
        console.log(event);
    });
    dragListener.bind('drag', function (event) {
        console.log(event);
    });
    dragListener.bind('drop', function (event) {
        console.log(event);
    });
    dragListener.bind('dragend', function (event) {
        console.log(event);
    });

    // We first need to save the original colors of our
    // nodes and edges, like this:
    s.graph.nodes().forEach(function (n) {
        n.originalColor = n.color;
    });
    s.graph.edges().forEach(function (e) {
        e.originalColor = e.color;
    });



    s.bind('clickNode', function (e) {
        var nodeId = e.data.node.id;
        var nodeLabel = e.data.node.label;
        var authorNameElement = document.getElementById("authorName");
        authorNameElement.value = nodeLabel;

        highlightNeighbours(e, nodeId);

        getAuthorData(nodeLabel);
        //var event = new Event('input');
        //authorNameElement.dispatchEvent(event);
    });

    function applyMinDegreeFilter(e) {
        var v = e.target.value;
        utils.$('min-degree-val').textContent = v;

        filter
                .undo('min-degree')
                .nodesBy(function (n) {
                    return this.degree(n.id) >= v;
                }, 'min-degree')
                .apply();
    }

    function highlightNeighbours(e, nodeId) {
        var toKeep = s.graph.neighbors(nodeId);
        if (e.type === "clickNode")
            toKeep[nodeId] = e.data.node;

        s.graph.nodes().forEach(function (n) {
            if (toKeep[n.id])
                n.color = n.originalColor;
            else
                n.color = '#eee';
        });

        s.graph.edges().forEach(function (e) {
            if (toKeep[e.source] && toKeep[e.target])
                e.color = e.originalColor;
            else
                e.color = '#eee';
        });

        s.refresh();
    }

    function getInputAuthorNode(authorName) {
        var returnNode;

        s.graph.nodes().forEach(function (node) {
            var nodeLabel = node.label;
            if (authorName === nodeLabel) {
                returnNode = node;
            }
        });

        return returnNode;
    }

    function filterByAuthor(e) {
        var inputAuthourName = document.getElementById("authorName").value;
        var inputAuthorNode = getInputAuthorNode(inputAuthourName);

        if (typeof inputAuthorNode !== 'undefined') {
            var inputAuthorNodeID = inputAuthorNode.id;
            highlightNeighbours(e, inputAuthorNodeID);

            s.graph.nodes().forEach(function (n) {
                if (inputAuthorNodeID === n.id) {
                    n.color = n.originalColor;
                }
            });

            s.graph.edges().forEach(function (e) {
                if ((e.source === inputAuthorNode.id || e.target === inputAuthorNode.id)) {
                    e.color = e.originalColor;
                }
            });

            s.refresh();
        }
    }

    function resetAuthorFilter() {
        resetHtmlActions();
        resetGraph();
    }

    function resetGraph() {
        s.graph.nodes().forEach(function (n) {
            n.color = n.originalColor;
        });

        s.graph.edges().forEach(function (e) {
            e.color = e.originalColor;
        });

        // Same as in the previous event:
        s.refresh();
    }

    function exportGraph() {
        console.log('exporting...');
        var output = s.toSVG(
                {download: true
                    , filename: 'CHASE_Authors_BC_Graph.svg'
                    , size: 1000
                    , labels: true
                });
        console.log(output);
    }
    ;

    utils.$('min-degree').addEventListener("input", applyMinDegreeFilter);  // for Chrome and FF
    utils.$('min-degree').addEventListener("change", applyMinDegreeFilter); // for IE10+, that sucks
    utils.$('reset-author-btn').addEventListener("click", resetAuthorFilter);
    utils.$('apply-author-btn').addEventListener("click", filterByAuthor);
    utils.$('export-btn').addEventListener("click", exportGraph);
    utils.$('authorName').addEventListener("input", filterByAuthor);
    utils.$('authorName').addEventListener("change", filterByAuthor);
    // reset button
    utils.$('reset-btn').addEventListener("click", function (e) {
        utils.$('min-degree').value = 0;
        utils.$('min-degree-val').textContent = '0';
        //utils.$('node-category').selectedIndex = 0;
        filter.undo().apply();
        utils.$('dump').textContent = '';
        utils.hide('#dump');
    });
}

showGraph("data/simple.gexf");