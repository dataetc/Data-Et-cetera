var margin = {
        top: 10,
        right: 30,
        bottom: 167,
        left: 90
    },
    width = 750 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var svg = d3.select("#svg_element")
    .append("svg")
   
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "0 0 " + (width + margin.left + margin.right) + " " + (height + margin.top + margin.bottom))
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Add the tool tip to the svg
var toolTip_text = "";
var toolTip = d3.select("#toolTip");
    toolTip.text(toolTip_text);

// Define the x and y scales
var x = d3.scaleBand()
    .range([0, width])
    .padding(0.2);

var y = d3.scaleLinear()
    .range([height, 0]);

// Create a formatter for the y axis date
var timeParse = d3.timeParse("%Y-%m-%d");
var formatDateYAxis = d3.timeFormat("%B %d");
var formatTooltip = d3.format(",.0f");

// Add the axes to the figure
var xAxis = svg.append("g")
    .attr("transform", "translate(0," + height + ")")
.style("font-size", "11.5px");
var yAxis = svg.append("g");

// Add label for the Axes
svg.append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - margin.left)
    .attr("x", 0 - height / 2)
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .attr("id", "text_YAxis");

// Set up coloring for Covid bar vs others
var colorCovid = d3.scaleOrdinal()
    .domain([false, true])
    .range(["steelblue", "red"]);

// Create a function to highlight/hide bars for the first 6 timesteps
// 1 = not covid, non-highlight
// 2 = covid
// 3 = call attention to this bar
var hideBars = d3.scaleOrdinal()
    .domain([1, 2, 3])
    .range([0.3, 1, 1]);

d3.csv("wonder_data - Copy.csv")
    .then(function (data) {
        data.forEach(function (d) {
            d.Date = d.Date;
            d.Month = +d.Month;
            d.Day = +d.Day;
            d.Cause = d.Cause;
            d.Deaths = +d.Deaths;
            d.time_step = +d.time_step;
            d.highlightColor = +d.highlightColor;
        });

        display(data);

    }).catch(function (error) {
        console.log(error);
    });

function display(data) {

    // setup scroll functionalitys
    let scroll = scroller()
        .container(d3.select('#graphic'));

    let lastIndex, activeIndex = 0
    //This is where most of the magic happens. Every time the user scrolls, we receive a new index. First, we find all the irrelevant sections, and reduce their opacity. 
    scroll.on('active', function (index) {

        d3.selectAll('.step')
            .transition().duration(200)
            .style('opacity', function (d, i) {
                return i + 1 === index ? 1 : 0.1;
            });

    })

    scroll.on('progress', function (index, progress) {
        
        activeIndex = index
        let sign = (activeIndex - lastIndex) < 0 ? -1 : 1;
        let scrolledSections = d3.range(lastIndex + sign, activeIndex + sign, sign);
        scrolledSections.forEach(i => {
            //    activationFunctions[i]();
        })
        lastIndex = activeIndex;
        createPlot(data, index);
        //plot.update(index, progress);
    });

    return scroll()
}


// Functions to create the plots
function createPlot(data, time_step) {
    var time_stepOffset = 1;
    
    // Filter the data to the current month to display, and 
    // Then sort the data in descending order by number of deaths
    var indexCovid = 0,
        tipText_date = "temp",
        tipText_value = 0,
        tipText_month = 0,
        startTip_text = "temp";
        
        data.filter(d => d.time_step === time_step + time_stepOffset)
        .sort(function (a, b) {
            return -a.Deaths - -b.Deaths
        })
        .filter(function (d, i) {
                 if(d.Cause === "COVID-19"){
                    indexCovid = i;
                     tipText_date = formatDateYAxis(timeParse(d.Date));
                     tipText_value = d.Deaths
                     
                     if(d.Month === 2){
                         startTip_text = "February";
                     } 
                     if(d.Month === 3){
                         startTip_text = "March";
                     }
                     if(d.Month === 4){
                         startTip_text = "April";
                     }
                     tipText_month = d.Month;
         
               }            
        });
    
    // Initialize the neutral text of the tool tip
    var neutralText = "Mouse over a bar for data";
    toolTip.text(neutralText);
                   
    
    
    var plotData = data.filter(d => d.time_step === time_step +time_stepOffset)
        .sort(function (a, b) {
            return -a.Deaths - -b.Deaths
        })
        .filter(function (d, i) {
            if (d.time_step <= 6 | indexCovid <= 20) {
                return i <= 20
            } else {
              return i <= indexCovid
                        
            }
        });
    
    // How long will all tranisitions take?
    var transitionTime = 500;

    // Update the domain of the x axis
    x.domain(plotData.map(function (d) {
        return d.Cause;
    }));
    xAxis
        .transition().duration(transitionTime)
        .call(d3.axisBottom(x))
        .selectAll("text")
        .style("fill", "black")
        .attr("transform", "translate(-10,0)rotate(-47)")
        .style("text-anchor", "end");

    // Update the domain of the y axis
    var yMax = d3.max(plotData, d => d.Deaths + 100);
    if (yMax < 2500) {
        yMax = 2500
    } else {
        if (yMax < 2600) {
            yMax = 2600
        } else {
            if (yMax < 2700) {
                yMax = 2700
            } else {
                if (yMax < 3000) {
                    yMax = 3000
                } else {
                    if (yMax < 3500) {
                        yMax = 3500
                    } else {
                        if (yMax < 4000) {
                            yMax = 4000
                        }
                    }
                }
            }
        }
    }

    y.domain([0, yMax]);
    yAxis.transition().duration(transitionTime)
        .call(d3.axisLeft(y))
    
        .selectAll("text")
        .style("fill", "black");
    // update the y-axis text with this selection's date:
    d3.select("#text_YAxis")
        // This version adds the date to the y-axis
        .text("Number of deaths per day");


    svg.selectAll("rect")
        .data(plotData, d => d.Cause)
        .join(

            enter => enter.append("rect")
            .attr("height", d => height - y(d.Deaths))
            .attr("width", x.bandwidth())
            .attr("fill", d => colorCovid(d.Cause == "COVID-19"))
            .attr("opacity", d => hideBars(d.highlightColor))
            .attr("x", d => x(d.Cause))
            .attr("y", d => y(d.Deaths))
            .on("mouseover",function(d){
                
                if(d.Month === 2){
                    toolTip.text("In February, " + formatTooltip(d.Deaths) + " people died of " + d.Cause + " per day");
                } else {
                    if(d.Month === 3 & (d.Day ===1 | d.Day ===2 )) {
                         toolTip.text("In March, " + formatTooltip(d.Deaths) + " people died of " + d.Cause + " per day");
                        
                    } else {
                         toolTip.text("On " + formatDateYAxis(timeParse(d.Date)) + ", " + formatTooltip(d.Deaths) + " people died of " + d.Cause);
                    }
                }
            }
               
               )
            , // 
            update => update
            .transition().duration(transitionTime)
            .attr("width", x.bandwidth())
            .attr("height", d => height - y(d.Deaths))
            .attr("x", d => x(d.Cause))
            .attr("fill", d => colorCovid(d.Cause == "COVID-19"))
            .attr("y", d => y(d.Deaths))
            .attr("opacity", d => hideBars(d.highlightColor)),
            exit => exit.remove()
        )
}
