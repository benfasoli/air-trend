# Ben Fasoli
source('../_global.r')

meas <- 'metone-es642'

function(input, output, session) {
  source('../_reader.r', local = T)
  
  showNotification(paste('Data displayed as minute averages but recorded at',
                          'a 1-s frequency'), duration = 10)
  
  # Value Boxes ----------------------------------------------------------------
  output$value_1 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$PM25_ugm3 %>%
      round(1) %>%
      paste('ug m<sup>-3</sup>') %>%
      HTML() %>%
      valueBox(subtitle = HTML('Particulate Matter (PM<sub>2.5</sub>)'),
               color = 'red', icon = icon('cloud'), href = NULL)
  })
  
  output$value_2 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$PM25_flow_lpm %>%
      round(2) %>%
      paste('L/min') %>%
      valueBox(subtitle = HTML('Sample Flow Rate'),
               color = 'green', icon = icon('tachometer'))
  })
  
  output$value_3 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$PM25_temp_c %>%
      round(1) %>%
      paste('<sup>o</sup>C') %>%
      HTML() %>%
      valueBox(subtitle = HTML('Inlet Temperature'),
               color = 'orange', icon = icon('thermometer-half'))
  })
  
  output$value_4 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$PM25_rh_pct %>%
      round(2) %>%
      paste('%') %>%
      valueBox(subtitle = HTML('Inlet Relative Humidity'),
               color = 'blue', icon = icon('tint'))
  })
  
  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    df <- reader[[meas]]()
    saveRDS(df, '~/test.rds')
    
    make_subplot(df) %>%
      layout(
        yaxis = list(title = 'PM 2.5\n[ug m-3]'),
        yaxis2 = list(title = 'Flow\n[L/m]'),
        yaxis3 = list(title = 'T\n[C]'),
        yaxis4 = list(title = 'RH\n[%]'),
        yaxis5 = list(title = 'P\n[hPa]')
      )
  })
}
