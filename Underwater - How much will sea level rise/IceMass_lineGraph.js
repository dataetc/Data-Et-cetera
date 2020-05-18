const margin_IceMassLine = 5;
const padding_IceMassLine = 5;
const adj_hor = 60;
const adj_vert = 20;
const width_IceMassLine = 800,
    height_IceMassLine = 450;
// we are appending SVG first
const svg_IceMassLine = d3.select("#IceMass_lineGraph").append("svg")
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "-" +
        adj_hor + " -" +
        adj_vert + " " +
        (width_IceMassLine + adj_hor * 3) + " " +
        (height_IceMassLine + adj_vert * 3))
    .style("padding", padding_IceMassLine)
    .style("margin", margin_IceMassLine)
    .classed("svg-content", true);

//  const timeConv = d3.timeParse("%d-%b-%Y");
const timeConv = d3.timeParse("%Y");
const dataset = d3.csv("./data/Ice Mass.csv");

dataset.then(function (data) {

    var slices = data.columns.slice(1).map(function (id) {
        return {
            id: id,
            values: data.sort((a, b) => d3.ascending(timeConv(a.Year), timeConv(b.Year))).map(function (d) {
                return {
                    date: timeConv(d.Year),
                    measurement: +d[id] 
                };
            })
        };
    });

    console.log(slices);
    const xScale_IceMassLine = d3.scaleTime().range([0, width_IceMassLine]);
    const yScale_IceMassLine = d3.scaleLinear().rangeRound([height_IceMassLine, 0]);
    xScale_IceMassLine.domain(d3.extent(data, function (d) {
        return timeConv(d.Year)
    }));
    yScale_IceMassLine.domain([
        -5000,
         d3.max(slices, function (c) {
          
            return d3.max(c.values, function (d) {
                return d.measurement + 1;
            });
        })
    ]);

    const yaxis_IceMassLine = d3.axisLeft()
        .ticks(10) //(slices[0].values).length)
        .scale(yScale_IceMassLine);

    const xaxis_IceMassLine = d3.axisBottom()
        .ticks(21)
        .tickFormat(d3.timeFormat('%Y'))
        .scale(xScale_IceMassLine);

    const line_IceMassLine = d3.line()
        .x(function (d) {
            return xScale_IceMassLine(d.date);
        })
        .y(function (d) {
            return yScale_IceMassLine(d.measurement);
        });

    let id = 0;
    const ids = function () {
        return "line-" + id++;
    }
    svg_IceMassLine.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + height_IceMassLine + ")")
        .call(xaxis_IceMassLine);

    svg_IceMassLine.append("g")
        .attr("class", "axis")
        .call(yaxis_IceMassLine)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("dy", ".75em")
        .attr("y", 6)
        .attr("dx", -40)
        .style("text-anchor", "end")
        .style("font-size", "170%")
        .text("Change in ice mass (gigatons)");

    const lines_IceMassLine = svg_IceMassLine.selectAll("lines")
        .data(slices)
        .enter()
        .append("g");

    lines_IceMassLine.append("path")
        .attr("class", ids)
        .attr("d", function (d) {
            return line_IceMassLine(d.values);
        })
        .attr("fill", "transparent")
        .attr("stroke", "blue");

    lines_IceMassLine.append("text")
        .attr("class", "series_label")
        .datum(function (d) {
            return {
                id: d.id,
                value: d.values[d.values.length - 1]
            };
        })
        .attr("transform", function (d) {
            return "translate(" + (xScale_IceMassLine(d.value.date) + 10) +
                "," + (yScale_IceMassLine(d.value.measurement) + 5) + ")";
        })
        .attr("x", 5)
        .text(function (d) {
            return d.id;
        });

});
