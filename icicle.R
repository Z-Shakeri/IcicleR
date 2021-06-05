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
data_icicle=data_icicle[data_icicle$siteid != 'All countries',]
data_icicle$combined = paste(data_icicle$siteid, data_icicle$age_group, data_icicle$sex, sep="/")
data_icicle=data_icicle[data_icicle$sex != 'All',]
data_icicle=data_icicle[data_icicle$sex != 'Other',]



# colors
colors = c("#0072B2", "#E69F00", "#009E73", "#CC79A7", "#D55E00", "#39393B", "#647370",
           "#96B3AD", "#C5E6DF", "#40615A", "#DDF0E9", "#F2F5F4", "#407362", "#083325", "#B31044", "#426878")


# match those colors to leaf names, matched by index
labels <- c("France", "Germany", "Italy", "Singapore", "USA", "80+", "70 - 79",
            "50 - 69", "26 - 49", "18 - 25", "12 - 17", "6 - 11", "3 - 5", "0 - 2", "Female", "Male")

icicle_plot <- data_icicle %>%
  select('combined', 'per_patients')

d3_tree <- sunburstR:::csv_to_hier(
  icicle_plot,
  delim = "/"
)

#To make the legend always checked
sb<-htmlwidgets::onRender(
  sunburst(d3_tree, withD3 = TRUE,  valueField= 'size', percent= F, count = TRUE, colors = list(range = colors, domain = labels, breadcrumb=list(100,10)),
           legend = list(w=100),legendOrder = labels, explanation = "function(d){if (d.data.size) return d.data.name + '<br>'+ d.data.size + '%'}"),
  "
    function(el,x,d){
    var paths = d3.select(el).select('.sunburst-chart')
    .select('svg')
    .selectAll('path')
    .filter(function(d) {
      return d.data.name;
    });
    
  
    
    d3.select(el).select('.sunburst-togglelegend').property('checked', true);
    d3.select(el).select('.sunburst-legend').style('visibility', '');
 

    document.getElementsByClassName('sunburst-sequence')[0].childNodes[0].textContent = '';
    document.getElementsById('sunburst-sequence').style.top = '100';


    document.getElementsByClassName('sunburst-sidebar')[0].childNodes[2].nodeValue = 'Country/Age/Sex';
    
    var div = d3.select(el)
        .append('div')
        .style('position','absolute')
        .style('opacity',0)
        .style('padding','5px')
        .style('border-radius',5)
        .style('border','1px dotted black')
        .style('background','white')
        .style('pointer-events','none');
        
      paths.on('mousemove', function(d) {
          div.style('opacity',0.9)
           .html(d.data.name)
           .style('left', d3.event.pageX + 'px')
           .style('top', (d3.event.pageY - 15) + 'px' );
        })
        .on('mouseout', function(d) {
          div.style('opacity',0)
        });

    d3.select(d).select('#percentage').text('Heyyy');

    
    
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
  var btn2 = d3.select('#convert-btn2')
  
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

iframe<- browsable(tagList(
    tags$head(tags$script(src="https://unpkg.com/flubber")),
    tags$button(id='convert-btn',"Iciclize", style= botton_style),
    sb
  ))
iframe



#this link will be used in our Dash app
htmltools::save_html(iframe, 'index.html')

