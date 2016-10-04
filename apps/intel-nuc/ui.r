# Ben Fasoli
source('../_libraries.r')
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
  box(title = 'Active Logging',
      width = 6, status = 'danger',
          tableOutput('screen_list')
  )
)


dashboardPage(title = 'Intel NUC', skin = 'black',
              header, sidebar, body)
