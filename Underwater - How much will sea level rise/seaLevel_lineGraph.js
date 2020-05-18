const margin_seaIceLine = 5;
const padding_seaIceLine = 5;
const adj = 30;
const width_seaIceLine = 800, 
      height_seaIceLine = 350;
// we are appending SVG first
const svg_seaIceLine = d3.select("#seaLevel_lineGraph").append("svg")
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "-" +
        adj + " -" +
        adj + " " +
        (width_seaIceLine + adj * 3) + " " +
        (height_seaIceLine + adj * 3))
    .style("padding", padding_seaIceLine)
    .style("margin", margin_seaIceLine)
    .classed("svg-content", true);

//                        const timeConv = d3.timeParse("%d-%b-%Y");
const timeConv = d3.timeParse("%Y");
const dataset = d3.csv("./data/Ice Extent.csv");

dataset.then(function (data) {


   
    var slices = data.columns.slice(1).map(function (id) {
        return {
            id: id,
            values: data.sort((a,b) => d3.ascending(timeConv(a.Year), timeConv(b.date))).map(function (d) {
                return {
                    date: timeConv(d.Year),
                    measurement: +d[id]
                };
            })
        };
    });
    
 
   
    const xScale_seaIceLine = d3.scaleTime().range([0, width_seaIceLine]);
    const yScale_seaIceLine = d3.scaleLinear().rangeRound([height_seaIceLine, 0]);
    xScale_seaIceLine.domain(d3.extent(data, function (d) {
        return timeConv(d.Year)
    }));
    yScale_seaIceLine.domain([(0), d3.max(slices, function (c) {
        return d3.max(c.values, function (d) {
            return d.measurement + 1;
        });
    })]);

    const yaxis_seaIceLine = d3.axisLeft()
        .ticks(10)//(slices[0].values).length)
        .scale(yScale_seaIceLine);

    const xaxis_seaIceLine = d3.axisBottom()
        .ticks(21)
        .tickFormat(d3.timeFormat('%Y'))
        .scale(xScale_seaIceLine);

    const line_seaIceLine = d3.line()
        .x(function (d) {
            return xScale_seaIceLine(d.date);
        })
        .y(function (d) {
            return yScale_seaIceLine(d.measurement);
        });

    let id = 0;
    const ids = function () {
        return "line-" + id++;
    }
    svg_seaIceLine.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + height_seaIceLine + ")")
        .call(xaxis_seaIceLine);

    svg_seaIceLine.append("g")
        .attr("class", "axis")
        .call(yaxis_seaIceLine)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("dy", ".75em")
        .attr("y", 6)
        .style("text-anchor", "end")
        .text("Area of ocean with at least 15% sea ice");

    const lines_seaIceLine = svg_seaIceLine.selectAll("lines")
        .data(slices)
        .enter()
        .append("g");

    lines_seaIceLine.append("path")
        .attr("class", ids)
        .attr("d", function (d) {
            return line_seaIceLine(d.values);
        });

    lines_seaIceLine.append("text")
        .attr("class", "serie_label")
        .datum(function (d) {
            return {
                id: d.id,
                value: d.values[d.values.length - 1]
            };
        })
        .attr("transform", function (d) {
            return "translate(" + (xScale_seaIceLine(d.value.date) + 10) +
                "," + (yScale_seaIceLine(d.value.measurement) + 5) + ")";
        })
        .attr("x", 5)
        .text(function (d) {
            return d.id;
        });

});