# Ben Fasoli
source('../_global.r')

meas <- 'teledyne-t200'

function(input, output, session) {
  source('../_reader.r', local = T)

  # Value Boxes ----------------------------------------------------------------
  output$value_1 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NOX_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Nitrous Oxides (NO<sub>x</sub>)'),
               color = 'red', icon = icon('cloud'))
  })

  output$value_2 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NO_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Nitrogen Monoxide (NO)'),
               color = 'green', icon = icon('cloud'))
  })

  output$value_3 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NO2_ppb %>%
      round(1) %>%
      paste('cc/m') %>%
      valueBox(subtitle = HTML('Nitrous Dioxide (NO<sub>2</sub>)'),
               color = 'orange', icon = icon('cloud'))
  })

  output$value_4 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NOX_flow_ccm %>%
      round(2) %>%
      paste('ccm') %>%
      valueBox(subtitle = HTML('Flow Rate'),
               color = 'blue', icon = icon('tachometer'))
  })

  output$value_5 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NOX_pres_inhg %>%
      round(2) %>%
      paste('inHg') %>%
      valueBox(subtitle = HTML('Cavity Pressure'),
               color = 'purple', icon = icon('wrench'))
  })

  # Timeseries -----------------------------------------------------------------
  output$ts <- renderPlotly({
    df <- reader[[meas]]()

    make_subplot(df) %>%
      layout(
        yaxis = list(title = 'NOX\n[ppb]'),
        yaxis2 = list(title = 'NO\n[ppb]'),
        yaxis3 = list(title = 'NO2\n[ppb]'),
        yaxis4 = list(title = 'Flow\n[cc/m]'),
        yaxis5 = list(title = 'Pressure\n[inHg]')
      )
  })
}
