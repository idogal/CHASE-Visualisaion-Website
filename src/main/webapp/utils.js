window.onload = function (event) {
    populateValues();
    
    showGraph("simple");
};

function displayDashboard() {
    var dashboardContainer = document.getElementById("dashboardContent");
    var graphContainer = document.getElementById("graphContainer");
    var dbContainer = document.getElementById("forumContent");
    
    dashboardContainer.style.display = 'block';
    graphContainer.style.display = 'none';
    dbContainer.style.display = 'none';    
    
    var dashboardInnerHTML = dashboardContainer.innerHTML;
    if (dashboardInnerHTML === "") {
        var content = document.createElement("div");
        content.id = "chaseVizContainer";
        dashboardContainer.appendChild(content);

        loadChaseViz();        
    }
};

function displayAboutAndContactPage() {
    var dashboardContainer = document.getElementById("dashboardContent");
    var graphContainer = document.getElementById("graphContainer");
    var dbContainer = document.getElementById("forumContent");
    
    dashboardContainer.style.display = 'none';
    graphContainer.style.display = 'none';    
    dbContainer.style.display = 'block';        
}

function displayGroups() {
    var dashboardContainer = document.getElementById("dashboardContent");
    var graphContainer = document.getElementById("graphContainer");
    var dbContainer = document.getElementById("forumContent");
    
    dashboardContainer.style.display = 'none';
    graphContainer.style.display = 'none';    
    dbContainer.style.display = 'block';
    
    var containerLength = $("#forum_embed").contents().find("body").length;
    if (containerLength === 1) {
        document.getElementById("forum_embed").src =
           'https://groups.google.com/forum/embed/?place=forum/chase-workshop'
           + '&showsearch=true&showpopout=true&showtabs=true'
           + '&parenturl=' + encodeURIComponent(window.location.href);    
    }    
}

function displayNetwork() {
    var dashboardContainer = document.getElementById("dashboardContent");
    var graphContainer = document.getElementById("graphContainer");
    var aboutContainer = document.getElementById("forumContent");
    
    dashboardContainer.style.display = 'none';
    graphContainer.style.display = 'block';
    aboutContainer.style.display = 'none';    

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

var httpGetAsyncClient = function() {
    this.get = function(theUrl, callback) {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function() { 
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                callback(xmlHttp.responseText);
            } 
            else {
                console.log("Error", xmlHttp.status);
                console.log("Error", xmlHttp.statusText);
            }        
        }

        xmlHttp.open( "GET", theUrl, true );            
        xmlHttp.setRequestHeader("Ocp-Apim-Subscription-Key", "");
        xmlHttp.send( null );
    }
}


function processCocitations(authorName) {
    var authorPapersRefs = new Array();
    
    var getAuthorPapersUrl = "https://westus.api.cognitive.microsoft.com/academic/v1.0/evaluate?expr=Composite(AA.AuN='" 
            + authorName 
            + "')&attributes=Id,Ti";
    
    var client = new httpGetAsyncClient();
    client.get(getAuthorPapersUrl, function(response) {
        var authorPapers = JSON.parse(response);
        
        if (authorPapers) { 
            for (var i = 0, max = authorPapers.entities.length; i < max; i++) {
                var paperID =  authorPapers.entities[i].Id;
                var paperTitle =  authorPapers.entities[i].Ti;

                var getPaperRefsUrl = "https://westus.api.cognitive.microsoft.com/academic/v1.0/evaluate?expr=Id=" 
                        + paperID 
                        + "&attributes=RId";
                
                client.get(getPaperRefsUrl, function (response) {
                    var paperRefs = JSON.parse(response);

                    var authorPapersRef = new Object();

                    var refs = paperRefs.entities[0].RId;
                    if (refs) {
                        for (var j = 0, max = refs.length; j < max; j++) {
                            var refID = refs[j];


                            authorPapersRef.name = authorName;
                            authorPapersRef.paperId = paperID;
                            authorPapersRef.paperTitle = paperTitle;
                            authorPapersRef.refId = refID;

                            authorPapersRefs.push(authorPapersRef);
                        }
                    } else {
                        var authorPapersRef = new Object();
                        authorPapersRef.name = authorName;
                        authorPapersRef.paperId = paperID;
                        authorPapersRef.paperTitle = paperTitle;

                        authorPapersRefs.push(authorPapersRef);
                    }
                }); 
            }    
        }
        
        console.log('Pass1');
    });
    
    
}