# Ben Fasoli

# Dependencies -----------------------------------------------------------------
libs <- c(
  'ggthemes',
  'plotly',
  'shiny',
  'shinydashboard',
  'tidyverse',
  'uataq'
)

lapply(libs, library, character.only = T)


# Constants --------------------------------------------------------------------
gas <- list(
  O3_ppb = list(
    min = 0,
    max = 70
  ),

  pm25 = list(
    min = 0,
    max = 55
  )
)


# Functions --------------------------------------------------------------------
make_subplot <- function(df) {
  # Requires POSIXct column "Time" and columns for observations. Recommend
  # building df with bind_rows to combine multiple datasets of interest
  nvar <- ncol(df %>% select(-Time))

  vars <- df %>%
    select(-Time) %>%
    colnames()

  fig <- lapply(vars, df, FUN = function(var, df) {
    plot_ly(df, x = ~Time, y = as.formula(paste0('~', var)),
            hoverinfo = 'x+y', fill = 'tozeroy') %>%
      add_lines() %>%
      layout(showlegend = F,
             xaxis = list(title = '', showgrid = F))
  }) %>%
    subplot(nrows = nvar, shareX = T, titleX = F, margin = 0)

  # Hacky way of setting figure colors to hexcolors defined in _style_setup.r
  for (i in 1:nvar) {
    fig$x$data[[i]]$line$color <- hexcolors[c(1:nvar)[i]]
  }
  fig
}
