# Ben Fasoli

reader <- list()

reader$`metone-es642` <- reactiveFileReader(
  intervalMillis = 5000, session = session,
  filePath = '/home/uataq/air-trend/log/data/metone-es642' %>%
    dir(full.names = T) %>%
    tail(1),
  readFunc = function(path) {
    '/home/uataq/air-trend/log/data/metone-es642' %>%
      dir(full.names = T) %>%
      tail(5) %>%
      lapply(read_csv,
             locale = locale(tz = 'UTC'),
             col_types = 'Tddddd__',
             col_names = c('Time', 'PM25_ugm3', 'PM25_flow_lpm', 'PM25_temp_c',
                           'PM25_rh_pct', 'PM25_pres_hpa')) %>%
      bind_rows() %>%
      mutate(PM25_ugm3 = PM25_ugm3 * 1000) %>%
      group_by(Time = trunc(Time, units = 'mins') %>% as.POSIXct()) %>%
      summarize_all(funs(mean(., na.rm = T)))
  })


reader$`teledyne-t200` <- reactiveFileReader(
  intervalMillis = 1000, session = session,
  filePath = '/home/uataq/air-trend/log/data/teledyne-t200' %>%
    dir(full.names = T) %>%
    tail(1),
  readFunc = function(path) {
    '/home/uataq/air-trend/log/data/teledyne-t200' %>%
      dir(full.names = T) %>%
      tail(5) %>%
      lapply(read_csv,
             locale = locale(tz = 'UTC'),
             col_types = 'T_____ddddd',
             col_names = c('Time', 'NOX_ppb', 'NO_ppb', 'NO2_ppb',
                           'NOX_flow_ccm', 'NOX_pres_inhg')) %>%
      bind_rows()
  })


reader$`teledyne-t300` <- reactiveFileReader(
  intervalMillis = 1000, session = session,
  filePath = '/home/uataq/air-trend/log/data/teledyne-t300' %>%
    dir(full.names = T) %>%
    tail(1),
  readFunc = function(path) {
    '/home/uataq/air-trend/log/data/teledyne-t300' %>%
      dir(full.names = T) %>%
      tail(5) %>%
      lapply(read_csv,
             locale = locale(tz = 'UTC'),
             col_types = 'T_____dddd',
             col_names = c('Time', 'CO_ppb', 'CO_stabil_ppb',
                           'CO_flow_ccm', 'CO_pres_inhg')) %>%
      bind_rows()
  })


reader$`teledyne-t400` <- reactiveFileReader(
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


reader$`teom-1400ab` <- reactiveFileReader(
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
