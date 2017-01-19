# Ben Fasoli
source('../_global.r')
source('../_style_setup.r')

body <- dashboardBody(
  includeStyle,
  fluidRow(
    column(12,
           fluidRow(
             column(2, valueBoxOutput('value_NOX_ppb', width = NULL)),
             column(2, valueBoxOutput('value_NO_ppb', width = NULL)),
             column(2, valueBoxOutput('value_NO2_ppb', width = NULL)),
             column(2, valueBoxOutput('value_NOX_flow_ccm', width = NULL)),
             column(2, valueBoxOutput('value_NOX_pres_inhg', width = NULL))
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
