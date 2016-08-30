libs <- c(
  'dplyr',
  'ggplot2',
  'ggthemes',
  'plotly',
  'readr',
  'shiny',
  'shinydashboard',
  'uataq'
)

lapply(libs, library, character.only = T)