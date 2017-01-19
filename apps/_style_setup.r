# Ben Fasoli

hexcolors <- c('#DD4B39', # Red
               '#00A65A', # Green
               '#FF851B', # Yellow
               '#0073B7') # Blue

# Header Layout ----------------------------------------------------------------
header <- dashboardHeader(
  title = HTML(
    '<div class="blklink">',
    '<a href="/dash/">',
    '<img src="http://air.utah.edu/~benfasoli/img/utelogo.png" style="height: 16px; position: relative; bottom:2px;">',
    'Atmospheric Trace gas & Air Quality Lab',
    '</a>',
    '</div>'),
  titleWidth = '100%'
)


# Sidebar Layout ---------------------------------------------------------------
sidebar <- dashboardSidebar(
  sidebarMenu(
    id = 'sidebar_active',
    menuItem('Dashboard', icon = icon('area-chart'),
             href = '/dash/', newtab = F),
    shiny::br(),
    menuItem('Teledyne T200', icon = icon('th'),
             href = '/teledyne-t200', newtab = F),
    menuItem('Teledyne T400', icon = icon('th'),
             href = '/teledyne-t400', newtab = F),
    menuItem('Intel NUC', icon = icon('desktop'),
             href = '/intel-nuc', newtab = F),
    shiny::br(),
    menuItem('Web home', icon = icon('globe'),
             href = 'http://air.utah.edu', newtab = F),
    menuItem('Site status', icon = icon('bar-chart'),
             href = 'http://air.utah.edu/status.html', newtab = F),
    menuItem('Sign in', icon = icon('lock'),
             href = 'http://air.utah.edu/s/auth/', newtab = F)
  )
)

# Additional html/css dependencies ---------------------------------------------
includeStyle <- tagList(
  includeHTML('../_header.html'),
  includeCSS('../_styles.css'),
  tags$head(HTML('<meta http-equiv="refresh" content="18000">'))
)
