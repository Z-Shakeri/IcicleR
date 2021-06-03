library(sunburstR)
library(htmltools)
library(plotly)
library(shiny)
library(formattable)

path = '/Users/zahrashakeri/Documents/GitHub/IcileR'
setwd(path)

# d3 source tree from Mike Bostock
# https://gist.githubusercontent.com/mbostock/8fe6fa6ed1fa976e5dd76cfa4d816fec/

#------------------------------- filter the dataset---------------------------
data_icicle = read.csv('icicle_df.csv', stringsAsFactors = FALSE)
data_icicle$combined = paste(data_icicle$siteid, data_icicle$age_group, data_icicle$sex, sep="/")
data_icicle=data_icicle[data_icicle$sex != 'All',]
data_icicle=data_icicle[data_icicle$sex != 'Other',]

# colors
colors = c("#0072B2", "#E69F00", "#009E73", "#CC79A7", "#D55E00", "#ABB3B3", "#B31044", "#426878", "#39393B", "#647370",
           "#96B3AD", "#C5E6DF", "#40615A", "#DDF0E9", "#F2F5F4", "#407362", "#083325")


# match those colors to leaf names, matched by index
labels <- c("France", "Germany", "Italy", "Singapore", "USA", "All countries", "Female", "Male", "80+", "70 - 79",
            "50 - 69", "26 - 49", "18 - 25", "12 - 17", "6 - 11", "3 - 5", "0 - 2")

icicle_plot <- data_icicle %>%
  select('combined', 'per_patients')

d3_tree <- sunburstR:::csv_to_hier(
  icicle_plot,
  delim = "/"
)

#To make the legend always checked
sb<-htmlwidgets::onRender(
  sunburst(d3_tree, withD3 = TRUE, colors = list(range = colors, domain = labels), legend = list(w=100)),
  "
    function(el,x){
    d3.select(el).select('.sunburst-togglelegend').property('checked', true);
    d3.select(el).select('.sunburst-legend').style('visibility', '');
    document.getElementsByClassName('sunburst-sidebar')[0].childNodes[2].nodeValue = 'Country/Age/Sex';
    }
    "
)
 



sb$x$tasks <- list(htmlwidgets::JS("
function(){
  var chart = this.instance.chart;
  var data = this.instance.json;
  var el = this.el;
  var svg = d3.select(el).select('.sunburst-chart>svg');

  var btn = d3.select('#convert-btn')
  
  
  btn.on('click.tree', function() {
    var paths = svg.selectAll('path');
    paths.each(function(d,i) {
    debugger
      var interpolate = flubber.interpolate(
        d3.select(this).attr('d'),
        [
          [d.x0*120, Math.pow(d.y0,1/2)],
          [d.x0*120, Math.pow(d.y1,1/2)],
          [d.x1*120, Math.pow(d.y1,1/2)],
          [d.x1*120, Math.pow(d.y0,1/2)],
          [d.x0*120, Math.pow(d.y0,1/2)]
        ]
      );
      d3.select(this)
        .transition()
        .delay(i * 20)
        .duration(200)
        .attr('transform','translate(-400,-200)')
        .attrTween('d', function(d) {return interpolate});
    })
  });
 }

"))







botton_style= 'color: black; background-color:#E8E8D3;
                left: 10%; width: 100px; height: 30px; border-radius: 6px; font-size:90%'

a<- browsable(tagList(
    tags$head(tags$script(src="https://unpkg.com/flubber")),
    tags$button(id='convert-btn',"Iciclize", style= botton_style),
    # tags$button(id='convert-btn2',"Iciclized", style= botton_style, onclick="return confirm('Are you sure?');"),
    sb
  ))


a



#this link will be used in our Dash app
htmltools::save_html(a, 'index.html')

