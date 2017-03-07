# Ben Fasoli
source('../_global.r')
source('../_style_setup.r')

body <- dashboardBody(
  includeStyle,
  fluidRow(
    column(12,
           fluidRow(
             column(2, valueBoxOutput('value_1', width = NULL)),
             column(2, valueBoxOutput('value_2', width = NULL)),
             column(2, valueBoxOutput('value_3', width = NULL)),
             column(2, valueBoxOutput('value_4', width = NULL)),
             column(2, valueBoxOutput('value_5', width = NULL))
           ),
           box(title = 'Teledyne T200',
               width = NULL, status = 'danger',
               div(class = 'tall',
                   plotlyOutput('ts', height = '100%')
               )
           )
    )
  )
)

dashboardPage(title = 'Teledyne T200', skin = 'black',
              header, sidebar, body)
