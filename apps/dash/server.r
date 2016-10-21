# Ben Fasoli
source('../_global.r')

function(input, output, session) {
  source('../_reader.r', local = T)
  
  # Value Boxes ----------------------------------------------------------------
  output$value_PM25_ugm3 <- renderValueBox({
    reader[['PM25_ugm3']]() %>%
      tail(1) %>%
      .$PM25_ugm3 %>%
      round(1) %>%
      paste('ug m<sup>-3</sup>') %>%
      HTML() %>%
      valueBox(subtitle = HTML('Particulate Matter (PM<sub>2.5</sub>)'),
               color = 'red', icon = icon('car'), href = '/dash/')
  })
  
  output$value_O3_ppb <- renderValueBox({
    reader[['O3_ppb']]() %>%
      tail(1) %>%
      .$O3_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Ozone (O<sub>3</sub>)'),
               color = 'green', icon = icon('sun-o'), href = '/teledyne-t400/')
  })
  
  
  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    PM25_ugm3 <- reader[['PM25_ugm3']]()
    O3_ppb <- reader[['O3_ppb']]()
    df <- bind_rows(PM25_ugm3, O3_ppb) %>%
      select(Time, PM25_ugm3, O3_ppb)
    
    make_subplot(df) %>%
      layout(yaxis = list(title = 'PM2.5\n[ugm-3]'),
             yaxis2 = list(title = 'Ozone\n[ppb]')
      )
  })
}
