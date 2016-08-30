# Ben Fasoli
source('../_libraries.r')
source('../_constants.r')

plot_build <- function(df, meas) {
  plot_ly(data = df, x = Time, y = df[[meas]],
          type = 'scatter', mode = 'markers',
          marker = list(color = df[[meas]],
                        cmin = gas[[meas]]$min,
                        cmax = gas[[meas]]$max,
                        showscale = F,
                        autocolorscale = F,
                        colorscale = 'Jet'),
          size = rep(1, nrow(df)),
          hoverinfo = 'x+y') %>%
    layout(
      xaxis = list(title = ''),
      yaxis = list(title = meas)
    )
}

function(input, output, session) {
  source('../_reader.r', local = T)
  
  # Value Boxes ----------------------------------------------------------------
  output$value_O3_ppb <- renderValueBox({
    reader[['O3_ppb']]() %>%
      tail(1) %>%
      .$O3_ppb %>%
      round(2) %>%
      paste('[ppb]') %>%
      valueBox(subtitle = HTML('Ozone (O<sub>3</sub>)'),
               color = 'red', icon = icon('cloud'), href = '/teledyne-t400/')
  })
  
  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    meas <- 'O3_ppb'
    df <- reader[[meas]]()
    plot_build(df, meas)
  })
}
