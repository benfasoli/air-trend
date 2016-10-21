# Ben Fasoli
source('../_global.r')

meas <- 'O3_ppb'

function(input, output, session) {
  source('../_reader.r', local = T)
  
  # Value Boxes ----------------------------------------------------------------
  output$value_O3_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Ozone (O<sub>3</sub>) Concentration'),
               color = 'red', icon = icon('cloud'))
  })
  
  output$value_O3_stabil_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_stabil_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('O<sub>3</sub> Standard Deviation'),
               color = 'green', icon = icon('line-chart'))
  })
  
  output$value_O3_flow_ccm <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_flow_ccm %>%
      round(1) %>%
      paste('cc/m') %>%
      valueBox(subtitle = HTML('Sample Flow Rate'),
               color = 'orange', icon = icon('tachometer'))
  })
  
  output$value_O3_pres_inhg<- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$O3_pres_inhg %>%
      round(2) %>%
      paste('inHg') %>%
      valueBox(subtitle = HTML('Cavity Pressure'),
               color = 'blue', icon = icon('wrench'))
  })
  
  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    df <- reader[[meas]]()
    
    make_subplot(df) %>%
      layout(
        yaxis = list(title = 'O3\n[ppb]'),
        yaxis2 = list(title = 'Stability\n[ppb]'),
        yaxis3 = list(title = 'Flow\n[cc/m]'),
        yaxis4 = list(title = 'Pressure\n[inHg]')
      )
  })
}
