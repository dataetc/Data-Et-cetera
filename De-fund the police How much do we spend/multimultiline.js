   const step = 50,
       overlap = 1;

   const visual_width = 700,
       visual_height = 1900;

   const grid_width = 6;

   let width_plot = visual_width * 1 / grid_width;

   let groupedData;





// Create a legend for the multiline plot:
let legend = d3.select("#multiline_legend")
    .append("svg")
    .attr("viewBox", [0, 0, visual_width, 17])
    //.attr("width", visual_width)
    //.attr("height", 15);

// Rectangles
    legend.append("rect")
        .attr("height", 7)
        .attr("width", 19)
        .attr("x", visual_width/5)
        .attr("y", 5)
        .attr("fill", "deepskyblue");
    legend.append("rect")
        .attr("height", 7)
        .attr("width", 19)
        .attr("x", 3*visual_width/6)
        .attr("y", 5)
        .attr("fill", "indianred");
    // Text
    legend.append("text")
        .attr("x", visual_width/5 + 29)
        .attr("y", 14)
        .text("Public safety")

 legend.append("text")
        .attr("x", 3 * visual_width/6 + 29)
        .attr("y", 14)
        .text("Social welfare")





   d3.csv("./data/citySpending.csv")
       .then(display);


   function display(rawData) {


       // Clean rawData data types
       rawData.forEach(function (d) {
           d.police = +d.police;
           d.housing_commdevt = +d.housing_commdevt;
           d.social_services = +d.social_services;
           d.envir_housing = +d.envir_housing;
           d.public_welfare = d.social_services + d.housing_commdevt;
           //         d.ratio_police_public_welfare = +d.ratio_police_public_welfare;
           //          d.combined_police = +d.combined_police;
           //            d.combined_public_welfare = +d.combined_public_welfare;
       })

       // Group/nest data by city    
       groupedData = d3.groups(rawData, d => d.city + ", " + d.state);

       let minX = 1977,
           maxX = 2017,
           minY, maxY;


       // Create and array of all years present in the dataset
       let years = Array.from(new Set(d3.map(rawData, d => +d.year)));

       let margin = {
               top: 20,
               bottom: 10,
               left: 10,
               right: 10
           },
           height = visual_height / (Math.round(groupedData.length / grid_width));

       let xScale = d3.scaleLinear()
           .domain([minX, maxX])
           .range([margin.left, width_plot - (margin.right)]);

       let yScale = d3.scaleLinear()
           .range([(height - margin.bottom), margin.top]);

       const svg = d3.select("#visual")
           .append("svg")
           .attr("viewBox", [0, 0, visual_width, visual_height])
           .style("font", "10px sans-serif");

       /*
       let tip = svg.append("g")
           .attr("id", "tooltip_multiline")
           .attr("transform", "translate(" + ((width_plot * 0.1) + (width_plot * grid_width)) + "," + (margin.top + height / 5) + ")")


       tip
           .append("text")
           .attr("id", "tooltip_text_1")
           .attr("y", 5)
           .text("Mouse over a city");
       tip
           .append("text")
           .attr("y", 15)
           .attr("id", "tooltip_text_2")
           .text("for more");
       tip
           .append("text")
           .attr("y", 25)
           .attr("id", "tooltip_text_3")
           .html("info");;
       tip
           .append("text")
           .attr("y", 35)
           .attr("id", "tooltip_text_4");
       tip
           .append("text")
           .attr("y", 45)
           .attr("id", "tooltip_text_5");
       tip
           .append("text")
           .attr("y", 55)
           .attr("id", "tooltip_text_6");
       tip
           .append("text")
           .attr("y", 65)
           .attr("id", "tooltip_text_7");
*/
       // Create overlay for mouse events
       const g = svg.append("g")
           .selectAll("g")
           .data(groupedData)
           .enter()
           .append("g")
           .attr("transform", (d, i) => {
               return "translate(" + ((i % grid_width) * width_plot) + "," + (Math.floor(i / grid_width) * (height)) + ")"
           })
           .attr("id", (d, i) => {
               return "city_" + i;
           })


       g.append("rect")
           .attr("width", width_plot)
           .attr("height", height)
           .attr("stroke", "transparent")
           .attr("fill", "transparent")
           .on("mouseover", (d, i) => mouseIn(d, i))
           .on("mouseleave", d => {
               mouseOut()
           });

       let xAxis = d3.axisBottom()
           .scale(xScale)
           .ticks(5);
            
        let yAxis = d3.axisLeft()
           .scale(yScale)
           .ticks(height);


       let areaGenerator = d3.area()
           .x(d => xScale(+d.year))
           .y0(d => yScale(+d.public_welfare))
           .y1(d => yScale(+d.public_safety));

       // Add lines    
       g.append("text")
           .attr("x", 4)
           .attr("y", 10)
           .attr("dy", "0.35em")
           .text(d => d[0])


       let line_public_safety = d3.line()
           .x(d => xScale(+d.year))
           .y(d => yScale(+d.public_safety));
       let line_public_welfare = d3.line()
           .x(d => xScale(+d.year))
           .y(d => yScale(+d.public_welfare));


       let area = g.append("g")
           .attr("fill", "grey")
           .attr("opacity", 0.1)
           .attr("stroke", "none")
           .append("path")
           .attr("d", d => {
               // Rescale the y for each city:
               minY = d3.min([
                    d3.min(d[1].map(h => +h.public_safety)),
                    d3.min(d[1].map(h => +h.public_welfare))
                ]);
               maxY = d3.max([
                    d3.max(d[1].map(h => +h.public_safety)),
                    d3.max(d[1].map(h => +h.public_welfare))
                ]);
               yScale.domain([0, maxY]);
               //yScale.domain([minY, maxY]);
               // Create the police line:
               return areaGenerator(d[1])
           })

       let path_public_safety = g.append("g")
           .attr("fill", "none")
           .attr("stroke", "deepskyblue")
           .style("stroke-width", 1.5)
           .style("stroke-linejoin", "round")
           .style("stroke-linecap", "round")
           .append("path")
           .style("mix-blend-mode", "multiply")
           .attr("d", d => {
               // Rescale the y for each city:
               minY = d3.min([
                    d3.min(d[1].map(h => +h.public_safety)),
                    d3.min(d[1].map(h => +h.public_welfare))
                ]);
               maxY = d3.max([
                    d3.max(d[1].map(h => +h.public_safety)),
                    d3.max(d[1].map(h => +h.public_welfare))
                ]);
               yScale.domain([0, maxY]);
               //yScale.domain([minY, maxY]);
               // Create the police line:
               return line_public_safety(d[1])
           })

       //.attr("d", d => areaGenerator(d[1]));

       let path_socialServices = g.append("g")
           .attr("fill", "none")
           .attr("stroke", "indianred") //"steelblue")
           .style("stroke-width", 1.5)
           .style("stroke-linejoin", "round")
           .style("stroke-linecap", "round")
           .append("path")
           .style("mix-blend-mode", "multiply")
           .attr("d", d => {
               // Rescale the y for each city:
               minY = d3.min([
                    d3.min(d[1].map(h => +h.public_safety)),
                    d3.min(d[1].map(h => +h.public_welfare))
                ]);
               maxY = d3.max([
                    d3.max(d[1].map(h => +h.public_safety)),
                    d3.max(d[1].map(h => +h.public_welfare))
                ]);
               
               yScale.domain([0, maxY]);
               //yScale.domain([minY, maxY]);
               // Create the police line:
               return line_public_welfare(d[1])
           })


       // Add an axis to the first plot:
       /*
       let axis = g
            .append("g")
            .attr("transform", `translate(${0},${height - 1})`);
       */
       let axis = d3.select("#city_0")
            .append("g")
            .attr("transform", `translate(${0},${height - 1})`);
           
axis.append("text").attr("class", "xAxis").text("1977").attr("x", -2)
axis.append("text").attr("class", "xAxis").text("2017").attr("y", 0).attr("x", width_plot - 30)

       
       

   } //display


   function mouseIn(d, i, j) {
       //d3.selectAll(".overlay").attr("class", "overlay fade")
       //let thisChart = d3.select("#" + d.path[1].id)
       let thisChart = d3.select("#city_" + i)

       let thisChart_height = +thisChart.attr("transform").split(",").pop().split(")")[0];

       if(thisChart_height > 1836){
       thisChart_height = thisChart_height - 30
    
       }
       
       // Move the tooltip:
       d3.select("#tooltip_multiline").transition()
           .duration(500)
           .attr("transform", "translate(" + ((width_plot * 0.1) + (width_plot * grid_width)) + "," + (thisChart_height + step / 2) + ")")



       // Change the tooltip's text
       let thisChart_data = groupedData[thisChart.attr("id").split("_").pop()];

       let pct_police = thisChart_data[1][0].pct_police,
           pct_social = thisChart_data[1][0].pct_social;


       d3.select("#tooltip_text_1")
           .text(thisChart_data[0])
            .attr("stroke", "black").attr("stroke-opacity", 0.6)

       thisChart_data = thisChart_data[1].filter(d => d.year == "2017");

       d3.select("#tooltip_text_2")
           .text("Public Safety")
            .attr("fill", "deepskyblue")
            .attr("stroke", "deepskyblue").attr("stroke-opacity", 0.6)

       d3.select("#tooltip_text_3")
           .text(d3.format("$,")(Math.round(thisChart_data[0].public_safety)) + " per person in 2017")

       pct_police = Math.round(pct_police) > 0 ?("Up " + Math.round(pct_police)) : ("Down " + (Math.abs(Math.round(pct_police))));
       pct_social = Math.round(pct_social) > 0 ?("Up " + Math.round(pct_social)) : ("Down " + (Math.abs(Math.round(pct_social))))
       
       d3.select("#tooltip_text_4")
         .text(pct_police + "% since 1977" )
           
           
           //.text("- Public safety: " + d3.format("$,")(Math.round(thisChart_data[0].public_safety)))

       d3.select("#tooltip_text_5")
           .text("Public Welfare")
            .attr("fill", "indianred")
            .attr("stroke", "indianred").attr("stroke-opacity", 0.6)

       d3.select("#tooltip_text_6") 
           .text(d3.format("$,")(Math.round(thisChart_data[0].public_welfare)) + " per person in 2017") 

       d3.select("#tooltip_text_7")
          .text(pct_social + "% since 1977")

   }

   function mouseOut() {
       //d3.selectAll(".overlay").attr("class", "overlay start")
       //d3.select(this).attr("class", "overlay start")
   }
