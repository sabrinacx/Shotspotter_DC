
library(shiny)
# loading libraries
library(tidyverse)
library(tigris)
library(sf)
library(gganimate)
library(ggthemes)
library(transformr)
library(viridis)

# pulls the shape file of DC 

shp = places("dc", class = "sf")

# reads in the DC Shotspotter dataset

dc <- read_csv("http://justicetechlab.org/wp-content/uploads/2018/05/washington_dc_2006to2017.csv",
               
               # learned in class (and on Piazza) that the following is a key chunk of code. col_types allows us to pass in any arguments that we want to the read_csv function and overrides the default choices
               
               col_types = cols(
                 incidentid = col_double(),
                 latitude = col_double(),
                 longitude = col_double(),
                 year = col_double(),
                 month = col_double(),
                 day = col_double(),
                 hour = col_double(),
                 minute = col_double(),
                 second = col_double(),
                 numshots = col_double(),
                 type = col_logical()
               ))

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Gunfire Incidents in DC between 2006 and 2017"),
   

   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        tags$h5(helpText("This is an animated graphic that shows the change in number of gunfire incidents in DC from 2006 to 2017.
                         As you can see, both the number of gunfire incidents and the number of gunshots at a single location have grown significantly in the past decade.")),
        tags$h6(helpText("You can find our GitHub repository here: https://github.com/sabrinacx/Shotspotter_DC"))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         imageOutput("mapPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$mapPlot <- renderImage({
      #create input
     dc_sample <- dc %>% sample_n(500)
     
     # turns the rows into a sf object using st_as_sf and stores it as dc_locations for future use
     
     dc_locations <- st_as_sf(dc_sample,
                              
                              # lets R know that these are spatial points
                              
                              coords = c("longitude", "latitude"),
                              
                              # creates the coordinate map/sets the coordinate reference system
                              
                              crs = 4326)
     
     #create map
     # creates the mapping environment using the shp data directly
     
     x = ggplot(data = shp) +
       
       # plots the shapes data
       
       geom_sf() +
       
       # plots the points-shaped data (dc_locations), as specified above. Changed the aesthetics to make our data better to visualize!
       
       geom_sf(data = dc_locations, aes(size = numshots, fill = numshots, color = numshots)) +
       
       # we always need to label our graph! this adds a title, so that the reader understands what they are looking at 
       
       labs(title = "Gunfire Incidents in DC between 2006 and 2017",
            
            # adds the subtitle, so the reader understands what years the data is from. Using {} allows variable year to change. The round function rounds each year and drops the decimals that would otherwise be shown.
            
            subtitle = "Year: {round(frame_time)}", 
            
            # # adding a caption allows us to add the source of the data the graph uses
            
            caption = "Source: ShotSpotter Data from the Justice Tech Lab. Thanks for providing the data!") +
       
       # allows us to have a clean theme that is useful for displaying maps
       
       theme_map() +
       
       # added the fivethirtyeight theme that we enjoy.
       
       theme_fivethirtyeight(base_size = 5) +
       
       scale_size( guide = "none") +
       
       
       # changes the size of the title, so that it fits the map!
       
       # gganimated the graph to progressively show the gunfire incidents by year
       
       transition_time(year)
     
     anim_save("outfile.gif", animate(x))
     
     list(src = "outfile.gif",
          contentType = 'image/gif')
   }, deleteFile = TRUE)
}



# Run the application 
shinyApp(ui = ui, server = server)

