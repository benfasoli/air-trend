# Ben Fasoli
source('../_global.r')
source('../_style_setup.r')

body <- dashboardBody(
  includeStyle,
  fluidRow(
    column(12,
           fluidRow(
             column(2, valueBoxOutput('value_CPU_pct', width = NULL)),
             column(2, valueBoxOutput('value_RAM_pct', width = NULL)),
             column(2, valueBoxOutput('value_HDD_pct', width = NULL))
           )
    )
  ),
  fluidRow(
    column(4,
           box(title = 'Active Logging',
               width = NULL, status = 'danger',
               tableOutput('screen_list')
           )
           )
  )
)


dashboardPage(title = 'Intel NUC', skin = 'black',
              header, sidebar, body)
