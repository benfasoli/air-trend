# Ben Fasoli

reader <- list()


reader$O3_ppb <- reactiveFileReader(
  intervalMillis = 1000, session = session,
  filePath = '/home/uataq/air-trend/log/data/teledyne-t400' %>%
    dir(full.names = T) %>%
    tail(1),
  readFunc = function(path) {
    '/home/uataq/air-trend/log/data/teledyne-t400' %>%
      dir(full.names = T) %>%
      tail(5) %>%
      lapply(read_csv,
             locale = locale(tz = 'UTC'),
             col_types = 'T_____dddd',
             col_names = c('Time', 'O3_ppb', 'O3_stabil_ppb',
                           'O3_flow_ccm', 'O3_pres_inhg')) %>%
      bind_rows()
  })


reader$PM25_ugm3 <- reactiveFileReader(
  intervalMillis = 1000, session = session,
  filePath = '/home/uataq/air-trend/log/data/teom-1400ab' %>%
    dir(full.names = T) %>%
    tail(1),
  readFunc = function(path) {
    '/home/uataq/air-trend/log/data/teom-1400ab' %>%
      dir(full.names = T) %>%
      tail(5) %>%
      lapply(read_csv,
             locale = locale(tz = 'UTC'),
             col_types = 'Td__',
             col_names = c('Time', 'PM25_ugm3')) %>%
      bind_rows()
  })