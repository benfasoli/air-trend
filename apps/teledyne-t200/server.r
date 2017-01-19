# Ben Fasoli
source('../_global.r')

meas <- 'NOX_ppb'

function(input, output, session) {
  source('../_reader.r', local = T)

  # Value Boxes ----------------------------------------------------------------
  output$value_NOX_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NOX_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Nitrous Oxides (NO<sub>x</sub>)'),
               color = 'red', icon = icon('cloud'))
  })

  output$value_NO_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NO_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Nitrogen Monoxide (NO)'),
               color = 'green', icon = icon('cloud'))
  })

  output$value_NO2_ppb <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NO2_ppb %>%
      round(1) %>%
      paste('cc/m') %>%
      valueBox(subtitle = HTML('Nitrous Dioxide (NO<sub>2</sub>)'),
               color = 'orange', icon = icon('cloud'))
  })

  output$value_NOX_flow_ccm <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$NOX_flow_ccm %>%
      round(2) %>%
      paste('ccm') %>%
      valueBox(subtitle = HTML('Flow Rate'),
               color = 'blue', icon = icon('tachometer'))
  })

  output$value_NOX_pres_inhg <- renderValueBox({
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
