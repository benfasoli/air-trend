# Ben Fasoli
source('../_libraries.r')
source('../_constants.r')

meas <- 'O3_ppb'

function(input, output, session) {
  source('../_reader.r', local = T)
  
  # Value Boxes ----------------------------------------------------------------
  output$value_O3_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_ppb %>%
      round(2) %>%
      paste('[ppb]') %>%
    valueBox(subtitle = HTML('Ozone (O<sub>3</sub>) Concentration'),
             color = 'red', icon = icon('cloud'))
  })
  
  output$value_O3_stabil_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_stabil_ppb %>%
      round(2) %>%
      paste('[ppb]') %>%
      valueBox(subtitle = HTML('O<sub>3</sub> Standard Deviation'),
               color = 'green', icon = icon('line-chart'))
  })
  
  output$value_O3_flow_ccm <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_flow_ccm %>%
      round(1) %>%
      paste('[cc/m]') %>%
      valueBox(subtitle = HTML('Sample Flow Rate'),
               color = 'orange', icon = icon('tachometer'))
  })
  
  output$value_O3_pres_inhg<- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_pres_inhg %>%
      round(2) %>%
      paste('[inHg]') %>%
      valueBox(subtitle = HTML('Cavity Pressure'),
               color = 'blue', icon = icon('wrench'))
  })
  
  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    df <- reader[[meas]]()
    plot_ly(data = df, x = Time, y = O3_pres_inhg, yaxis = 'y1',
            hoverinfo = 'x+y', fill = 'tozeroy') %>%
      add_trace(x = Time, y = O3_flow_ccm, yaxis = 'y2',
                hoverinfo = 'x+y', fill = 'tozeroy') %>%
      add_trace(x = Time, y = O3_stabil_ppb, yaxis = 'y3',
                hoverinfo = 'x+y', fill = 'tozeroy') %>%
      add_trace(x = Time, y = O3_ppb, yaxis = 'y4',
                hoverinfo = 'x+y', fill = 'tozeroy') %>%
      layout(
        showlegend = FALSE,
        xaxis = list(title = ''),
        yaxis = list(anchor = 'x', domain = c(0, 0.24), title = 'Pressure \n [inHg]'),
        yaxis2 = list(anchor = 'x', domain = c(0.26, 0.49), title = 'Flow \n [cc/m]'),
        yaxis3 = list(anchor = 'x', domain = c(0.51, 0.74), title = 'Stability \n [ppb]'),
        yaxis4 = list(anchor = 'x', domain = c(0.76, 1), title = 'O3 \n [ppb]')
      )
  })
}
