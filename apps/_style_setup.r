
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
    br(),
    menuItem('Teledyne T400', icon = icon('th'),
             href = '/teledyne-t400', newtab = F)
  )
)

# Additional html/css dependencies ---------------------------------------------
includeStyle <- tagList(
  includeHTML('../_header.html'),
  includeCSS('../_styles.css')
)
