# Ben Fasoli
source('../_libraries.r')
source('../_style_setup.r')

body <- dashboardBody(
  includeStyle,
  fluidRow(
    column(12,
           fluidRow(
             column(3, valueBoxOutput('value_O3_ppb', width = NULL)),
             'placeholder for other measurements...'
             # column(3, valueBoxOutput('x', width = NULL)),
             # column(3, valueBoxOutput('y', width = NULL)),
             # column(3, valueBoxOutput('z', width = NULL))
           ),
           box(width = NULL, status = 'danger',
               plotlyOutput('ts', height = 280)
           )
    )
  )
)

dashboardPage(title = 'Dashboard Home', skin = 'black',
              header, sidebar, body)
