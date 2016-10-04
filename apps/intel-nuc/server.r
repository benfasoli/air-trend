# Ben Fasoli
source('../_libraries.r')
source('../_constants.r')

update_interval <- 5 * 1000

pct_color <- function(pct) {
  if (pct < 30) color <- 'green'
  else if (pct >= 30 && pct < 60) color <- 'yellow'
  else color <- 'red'
}


function(input, output, session) {
  source('../_reader.r', local = T)
  
  # Value Boxes ----------------------------------------------------------------
  output$value_CPU_pct <- renderValueBox({
    invalidateLater(update_interval)
    idle <- system("mpstat 1 1 | awk '$12 ~ /[0-9.]+/ { print $13 }'",
                   intern = T)[1] %>%
      as.numeric()
    cpu_pct <- round(100 - idle, 2)
    valueBox(paste(cpu_pct, '%'), subtitle = 'CPU Load',
             color = pct_color(cpu_pct), icon = icon('tachometer'))
  })

  output$value_RAM_pct <- renderValueBox({
    invalidateLater(update_interval)
    ram_pct <- system("free | grep Mem | awk '{print $3/$2 * 100.0}'",
                      intern = T)[1] %>%
      as.numeric() %>%
      round(2)
    valueBox(paste(ram_pct, '%'), subtitle = 'RAM',
             color = pct_color(ram_pct), icon = icon('th'))
  })

  output$value_HDD_pct <- renderValueBox({
    invalidateLater(update_interval)
    hdd_pct <- system("df -hl | grep /dev/sda1 | awk '{ sum+=$5 } END { print sum }'",
                      intern = T) %>%
      as.numeric() %>%
      round(1)
    valueBox(paste(hdd_pct, '%'), subtitle = 'Disk Usage (256GB)',
             color = pct_color(hdd_pct), icon = icon('hdd-o'))
  })
  
  # Active Screens -------------------------------------------------------------
  output$screen_list <- renderTable({
    invalidateLater(update_interval)
    system('screen -ls', intern = T) %>%
      head(-1) %>%
      tail(-1) %>%
      data_frame(Active = .)
  })
  
}
