var viz;
var hostLocation;
var tableau;

function loadChaseViz () {
    var vizDiv = document.getElementById('chaseVizContainer');
    var vizURL = "https://public.tableau.com/views/CHASEWorkshopAnalysisVisualisation2/FieldsDashboard?:embed=y&:display_count=yes";
//    w= window.frameElement.offsetWidth-20;
//    h= window.frameElement.offsetHeight-20;    
    var options = {
        width: '1000px', 
        height: '900px'
        //hideTabs: true,
    };
    
    viz = new tableau.Viz(vizDiv, vizURL, options);    
    
    viz.addEventListener(tableau.TableauEventName.TAB_SWITCH, onTabSwitch());
    viz.addEventListener(tableau.TableauEventName.FILTER_CHANGE, onFilterChange());
    viz.addEventListener(tableau.TableauEventName.MARKS_SELECTION, onMarksSelection());
    viz.addEventListener(tableau.TableauEventName.PARAMETER_VALUE_CHANGE, onParameterValueChange());
    
    hostLocation = window.location.hostname;
};

function onMarksSelection(marksEvent) {
    var worksheet = marksEvent.getWorksheet();
    var wsType = worksheet.getSheetType();
    var wsName = worksheet.getName();
    
    var marksSelectionInfo = new Object();
    marksSelectionInfo.WorksheetName = wsName;
    marksSelectionInfo.WorksheetType = wsType;
    marksSelectionInfo.EventName = marksEvent.getEventName();
    
    if (hostLocation !== "localhost") {
        appInsights.trackEvent('MarksSelection', marksSelectionInfo);
    }
    
    marksEvent.getMarksAsync().then(reportSelectedMarks);
}

function onParameterValueChange(paramsEvent) {
    
    var paramValueChangeInfo = new Object();
    paramValueChangeInfo.ParameterName = paramsEvent.getParameterName();
    paramValueChangeInfo.EventName = paramsEvent.getEventName();
    
    if (hostLocation !== "localhost") {
        appInsights.trackEvent('ParameterValueChange', paramValueChangeInfo);
    }    
}

function onTabSwitch(tabSwitchEvent) {
    var newWorksheet = tabSwitchEvent.getNewSheetName();
    var oldWorksheet = tabSwitchEvent.getOldSheetName();
    var eventName = tabSwitchEvent.getEventName();    
    
    var tabChangeInfo = new Object();
    tabChangeInfo.NewWorksheetName = newWorksheet;
    tabChangeInfo.OldWorksheetName = oldWorksheet;
    tabChangeInfo.EventName = eventName; 
    
    if (hostLocation !== "localhost") {
        appInsights.trackEvent('TableauTabSwitch', tabChangeInfo);
    }
}

function onFilterChange(filterChangeEvent) {
    var worksheet = filterChangeEvent.getWorksheet();
    var wsType = worksheet.getSheetType();
    var wsName = worksheet.getName();
    
    var eventName = filterChangeEvent.getEventName();
    var fieldName = filterChangeEvent.getFieldName();
    
    var filterChangeInfo = new Object();
    filterChangeInfo.WorksheetName = wsName;
    filterChangeInfo.WorksheetType = wsType;
    filterChangeInfo.EventName = eventName;
    filterChangeInfo.FieldName = fieldName;
    
    if (hostLocation !== "localhost") {
        appInsights.trackEvent('TableauFilterChange', logFilterChange);
    }    
    
    filterChangeEvent.getFilterAsync().then(logFilterChange);
}

function logFilterChange(filter) {
    var filterInfo = new Object();

    filterInfo.FieldName = filter.getFieldName();
    filterInfo.FilterType = filter.getFilterType();
    filterInfo.DomainMin = filter.getDomainMin();
    filterInfo.DomainMax = filter.getDomainMax();
    filterInfo.Min = filter.getMin();
    filterInfo.Max = filter.getMax();
    filterInfo.IncludeNullValues = filter.getIncludeNullValues();
    filterInfo.Period = filter.getPeriod();
    filterInfo.Range = filter.getRange();
    filterInfo.RangeN = filter.getRangeN();
    
    if (hostLocation !== "localhost") {
        appInsights.trackEvent('TableauFilterChangeInfo', filterInfo);
    }    
    
}

function reportSelectedMarks(marks) {
    for (var markIndex = 0; markIndex < marks.length; markIndex++) {
        var pairs = marks[markIndex].getPairs();
        var marksSelectionInfo = [];
        
        for (j = 0; j < pairs.length; j++) {
            var fieldName = pairs[j].fieldName;
            var fieldValue = pairs[j].value;
            
            var markInfo = new Object();
            markInfo.FieldName = fieldName;
            markInfo.FieldValue = fieldValue;
            marksSelectionInfo.push(markInfo);
        }
        
        marksSelectionInfo.MarkInfo = markInfo;        
        
        if (hostLocation !== "localhost") {
            appInsights.trackEvent('MarkSelection', marksSelectionInfo);
        }        
        
    }
}