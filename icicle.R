library(sunburstR)
library(htmltools)
library(plotly)
library(shiny)
library(formattable)

path = '/Users/zahrashakeri/Documents/GitHub/EHR-Draft/Lessons/Lesson6/Dash/lesson6'
setwd(path)

# d3 source tree from Mike Bostock
# https://gist.githubusercontent.com/mbostock/8fe6fa6ed1fa976e5dd76cfa4d816fec/

data_icicle = read.csv('icicle_df.csv', stringsAsFactors = FALSE)
data_icicle$combined = paste(data_icicle$siteid, data_icicle$age_group, data_icicle$sex, sep="/")
data_icicle=data_icicle[data_icicle$sex != 'All',]
data_icicle=data_icicle[data_icicle$sex != 'Other',]

d3_tree <- sunburstR:::csv_to_hier(
  icicle_plot,
  delim = "/"
)

icicle_plot <- data_icicle %>%
  select('combined', 'per_patients')

sb <- sunburst(d3_tree, withD3 = TRUE)
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
          [d.x0*90, Math.pow(d.y0,1/2)],
          [d.x0*90, Math.pow(d.y1,1/2)],
          [d.x1*90, Math.pow(d.y1,1/2)],
          [d.x1*90, Math.pow(d.y0,1/2)],
          [d.x0*90, Math.pow(d.y0,1/2)]
        ]
      );
      d3.select(this)
        .transition()
        .delay(i * 20)
        .duration(200)
        .attr('transform','translate(-400,-200)')
        .attrTween('d', function(d) {return interpolate});
    })
  })
}
"))



a<- browsable(
  tagList(
    tags$head(tags$script(src="https://unpkg.com/flubber")),
    tags$button(id='convert-btn',"icicl-ize"),
    sb
  ))
a

htmltools::save_html(a, 'index.html')
