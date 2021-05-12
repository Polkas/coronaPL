library(shiny)
library(shinyalert)
library(miniUI)
library(leaflet)
library(ggplot2)
library(data.table)
library(dplyr)
library(lubridate)
library(sparkline)
library(htmltools)
library(htmlwidgets)
library(scales)

pow_df <- fread("http://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv")
pow_df <- pow_df[pow_df$powiat_miasto != "Cały kraj", ]

pov_raw <- readRDS("pov_small.RDS")

dd <- left_join(pov_raw@data, pow_df[, c("stan_rekordu_na", "liczba_na_10_tys_mieszkancow", "wojewodztwo", "powiat_miasto", "liczba_przypadkow", "zgony")], by = c("wojewodztwo", "powiat_miasto"))
# data.table to retain the order
setDT(dd)
# sparklines
spark1 <- dd[, .(list(spk_chr(liczba_na_10_tys_mieszkancow, width = "100%", type = "line"))), by = list(powiat_miasto, wojewodztwo)]
spark2 <- dd[, .(list(spk_chr(liczba_przypadkow, width = "100%", type = "line"))), by = list(powiat_miasto, wojewodztwo)]
spark3 <- dd[, .(list(spk_chr(zgony, width = "100%", type = "line"))), by = list(powiat_miasto, wojewodztwo)]

ecdf_fun <- function(x, perc) ecdf(x)(perc)
# Crucial only local values
risk <- dd[, .(list(ecdf_fun(liczba_na_10_tys_mieszkancow, tail(liczba_na_10_tys_mieszkancow, 1)))), by = list(powiat_miasto, wojewodztwo)]

pov_raw@data <- left_join(pov_raw@data, pow_df[pow_df$stan_rekordu_na == tail(pow_df$stan_rekordu_na, 1), c("stan_rekordu_na", "liczba_na_10_tys_mieszkancow", "wojewodztwo", "powiat_miasto", "liczba_przypadkow", "zgony")], by = c("wojewodztwo", "powiat_miasto"))

info_text <- "Aplikacja moblina do monitorowania pandemi koronawirusa w konkretnym powiecie.
Lokalne ryzyko szacowane jest jako kwantyl z rozkładu empirycznego wartości zakażeń na 10tys. mieszkańców w konkretnym powiecie.
Statystyka nie powinna wpływać na zachowania.
Wszelkie środki ostrożności są nadal konieczne."

ui <- miniPage(
  useShinyalert(),
  gadgetTitleBar("Corona19 Lokalnie",
    left = NULL,
    right = miniTitleBarButton("done", "Done", primary = TRUE)
  ),
  miniContentPanel(
    padding = 0,
    leafletOutput("c19", height = "100%"),
    actionButton(style = "position:absolute;bottom:20px;left:20px;",
                inputId = "info_button",
                label="",
                icon = icon("info-circle"))
  )
)

server <- function(input, output, session) {
  output$c19 <- renderLeaflet({
    #exponential
    bins <- round(c(0, 0.5, exp(seq(log(1), log(max(pow_df$liczba_na_10_tys_mieszkancow, na.rm = TRUE)), length = 5))), 2)
    pal <- colorBin("YlOrRd", domain = range(pow_df$liczba_na_10_tys_mieszkancow), bins = bins)

    ll <- leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels",
        options = providerTileOptions(minZoom = 6, maxZoom = 8)
      ) %>%
      setView(lng = 20, lat = 52, zoom = 6) %>%
      addPolygons(
        data = pov_raw,
        fillColor = ~ pal(liczba_na_10_tys_mieszkancow),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        stroke = TRUE,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ),
        popup = paste0(
          "<h4>", pov_raw@data$powiat_miasto, "</h4>",
          "<strong>", pov_raw@data$stan_rekordu_na, "</strong><br/>",
          "Lokalne Ryzyko* - (0 - good; 100 - bad)", "<br/>",
          "<span style='font-size:20px;color:", scales::seq_gradient_pal("green","red")(risk$V1),";'><strong>" , round(100 * unlist(risk$V1)), "%", "</strong></span><br/>",
          "Zakażenia na 10 tys: ",
          "<strong>", pov_raw@data$liczba_na_10_tys_mieszkancow, "</strong>", "<br/>",
          "Zgony: ",
          "<strong>", pov_raw@data$zgony, "</strong>", "<br>",
          "<br>",
          "<strong>2020-11-24 - ", pov_raw@data$stan_rekordu_na,"</strong>", "<br>",
          "Zakażenia na 10 tys.:", "<br>",
          spark1$V1, "<br>",
          "Zakażenia:", "<br>",
          spark2$V1, "<br>",
          "Zgony:", "<br>",
          spark3$V1, "<br>",
          "<p style='font-size:9px;'>*Statystyka nie powinna wpływać na zachowania.</p>"
        )
      ) %>%
      addLegend("bottomright",
        pal = pal, values = pov_raw@data$liczba_na_10_tys_mieszkancow,
        title = htmltools::HTML("Zakażenia na 10 tys.<br/> mieszkancow")
      )

    ll$dependencies <- c(ll$dependencies, sparkline:::spk_dependencies())

    htmlwidgets::onRender(
      ll,
      "function(el,x) {this.on('popupopen', function() {HTMLWidgets.staticRender();})}"
    )
  })

  observeEvent(input$done, {
    stopApp(TRUE)
  })

  observeEvent(input$info_button, {
                # Show a simple modal
    shinyalert(text=info_text, title = "Info Page")
    })
}

shinyApp(ui, server)
