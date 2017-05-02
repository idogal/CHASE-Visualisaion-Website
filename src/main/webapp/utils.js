window.onload = function (event) {
    populateValues();
};

function showDashboard() {
    var dashboardContainer = document.getElementById("dashboardContent");
    var graphContainer = document.getElementById("graphContainer");
    
    dashboardContainer.style.display = 'block';
    graphContainer.style.display = 'none';
    
    var dashboardInnerHTML = dashboardContainer.innerHTML;
    if (dashboardInnerHTML === "") {
        var content = document.createElement("div");
        content.id = "chaseVizContainer";
        dashboardContainer.appendChild(content);

        loadChaseViz();        
    }
};

function showGraph() {
    var dashboardContainer = document.getElementById("dashboardContent");
    var graphContainer = document.getElementById("graphContainer");
    
    dashboardContainer.style.display = 'none';
    graphContainer.style.display = 'block';

};

function getAuthorNamesFromXML(data) {
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
    

    var allNames = [];
    var pbList = xmlDoc.getElementsByTagName("Author_Publication");
    for (var i = 0, apLength = pbList.length; i < apLength; i++) {
        var pb = pbList[i].childNodes; 
        
        var xmlAuthorName = "";
        
        for (var j = 0, pbLength = pb.length; j < pbLength; j++) {
            var nodeName = pb[j].nodeName;
            if (pb[j].nodeType !== 1)
                continue;
                
            if (nodeName === "Author_Name"){
                xmlAuthorName = pb[j].innerHTML;   
                continue;
            }         
        } 
        
        allNames.push(xmlAuthorName);
    }    
    
    return allNames;
};        
        
function populateValues () {
    var file = "resources/ap_data.xml";
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function () {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status === 0)
            {
                var allText = rawFile.responseText;
                var authorNamesArray = getAuthorNamesFromXML(allText);
                var authorsDOMList = document.getElementById("authorName");
                
                authorNamesArray = Array.from(new Set(authorNamesArray));
                authorNamesArray.sort();
                
                for (var i = 0, max = authorNamesArray.length; i < max; i++) {
                    var option = document.createElement('option');
                    option.value = authorNamesArray[i];
                    option.innerHTML = authorNamesArray[i];
                    authorsDOMList.appendChild(option);                     
                }               
            }
        }
    };
    rawFile.send();
};