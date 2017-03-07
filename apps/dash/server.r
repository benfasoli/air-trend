# Ben Fasoli
source('../_global.r')

function(input, output, session) {
  source('../_reader.r', local = T)

  # Value Boxes ----------------------------------------------------------------
  output$value_1 <- renderValueBox({
    reader[['metone-es642']]() %>%
      tail(1) %>%
      .$PM25_ugm3 %>%
      round(1) %>%
      paste('ug m<sup>-3</sup>') %>%
      HTML() %>%
      valueBox(subtitle = HTML('Particulate Matter (PM<sub>2.5</sub>)'),
               color = 'red', icon = icon('cloud'), href = NULL)
  })

  output$value_2 <- renderValueBox({
    reader[['teledyne-t400']]() %>%
      tail(1) %>%
      .$O3_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Ozone (O<sub>3</sub>)'),
               color = 'green', icon = icon('sun-o'), href = '/teledyne-t400/')
  })


  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    df <- bind_rows(reader[['metone-es642']](),
                    reader[['teledyne-t400']]()) %>%
      select(Time, PM25_ugm3, O3_ppb)

    make_subplot(df) %>%
      layout(yaxis = list(title = 'PM2.5\n[ugm-3]'),
             yaxis2 = list(title = 'O3\n[ppb]')
      )
  })
}
