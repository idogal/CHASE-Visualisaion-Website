var viz;

window.onload = function() {
    var vizDiv = document.getElementById('myViz');
    var vizURL = "https://public.tableau.com/views/CHASE_2/CHASEstory?:embed=y&:display_count=yes";
    var options = {
      width: '760px',
      height: '760px'
    };
    viz = new tableau.Viz(vizDiv, vizURL, options);
};

// Content below is to resolve warning for missing 'tableau' object
var tableau;