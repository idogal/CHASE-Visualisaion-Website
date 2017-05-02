var viz;

function loadChaseViz () {
    var vizDiv = document.getElementById('chaseVizContainer');
    var vizURL = "https://public.tableau.com/views/CHASEWorkshopAnalysisVisualisation2/Papers-RawData?:embed=y&:display_count=yes";
//    w= window.frameElement.offsetWidth-20;
//    h= window.frameElement.offsetHeight-20;    
    var options = {
        width: '1000px', 
        height: '950px'
        //hideTabs: true,
    };

//    $.getScript("http://public.tableau.com/javascripts/api/tableau-2.min.js", function () {
//    });

    viz = new tableau.Viz(vizDiv, vizURL, options);
    
    //viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection);
};

// Content below is to resolve warning for missing 'tableau' object
var tableau;

function onMarksSelection(marksEvent) {
    var worksheet = marksEvent.getWorksheet();
    var wsType = worksheet.getSheetType();
    var wsName = worksheet.getName();
    
    if (wsName.toLowerCase().includes("author")) {
        return marksEvent.getMarksAsync().then(reportSelectedMarks);
    }
}

function reportSelectedMarks(marks) {
    for (var markIndex = 0; markIndex < marks.length; markIndex++) {
        var pairs = marks[markIndex].getPairs();
        for (j = 0; j < pairs.length; j++) {
            var fieldName = pairs[j].fieldName;
            if (fieldName.toLowerCase().includes("author")) {
                var fieldValue = pairs[j].value;
            }
        }
    }

    var authorNameElement = document.getElementById("authorName");
    authorNameElement.value = fieldValue;
    
    var event = new Event('change');
    authorNameElement.dispatchEvent(event);
}

function test() {
    var authorNameElement = document.getElementById("authorName");
    var authorName = authorNameElement.value;
    
    var workbook = viz.getWorkbook();
    workbook.activateSheetAsync("Authors List").then(function() {
        var sheet = workbook.getActiveSheet();
        sheet.applyFilterAsync("Author Name", authorName, tableau.FilterUpdateType.REPLACE);
    });
}