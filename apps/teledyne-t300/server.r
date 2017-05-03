# Ben Fasoli
source('../_global.r')

meas <- 'teledyne-t300'

function(input, output, session) {
  source('../_reader.r', local = T)

  # Value Boxes ----------------------------------------------------------------
  output$value_1 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$CO_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('Carbon Monoxide (CO) Concentration'),
               color = 'red', icon = icon('cloud'))
  })

  output$value_2 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$CO_stabil_ppb %>%
      round(2) %>%
      paste('ppb') %>%
      valueBox(subtitle = HTML('CO Standard Deviation'),
               color = 'green', icon = icon('line-chart'))
  })

  output$value_3 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$CO_flow_ccm %>%
      round(1) %>%
      paste('cc/m') %>%
      valueBox(subtitle = HTML('Sample Flow Rate'),
               color = 'orange', icon = icon('tachometer'))
  })

  output$value_4 <- renderValueBox({
    reader[[meas]]() %>%
      tail(1) %>%
      .$CO_pres_inhg %>%
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
        yaxis = list(title = 'CO\n[ppb]'),
        yaxis2 = list(title = 'Stability\n[ppb]'),
        yaxis3 = list(title = 'Flow\n[cc/m]'),
        yaxis4 = list(title = 'Pressure\n[inHg]')
      )
  })
}
