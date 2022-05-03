library(shiny)
library(shinydashboard)
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
library(zoo)
library(R.utils)
library(sp)

pow_df <- fread("http://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv.gz")
pow_df_all <- pow_df[pow_df$powiat_miasto == "Cały kraj", ]
pow_df_all_14 <- pow_df[pow_df$powiat_miasto == "Cały kraj" & pow_df$stan_rekordu_na >= (Sys.Date() - 15), ]
pow_df_all_last <- pow_df_all[pow_df_all$stan_rekordu_na == tail(pow_df_all$stan_rekordu_na, 1), ]
pow_df <- pow_df[pow_df$powiat_miasto != "Cały kraj", ]

pov_raw <- readRDS("./pov_small.RDS")

base_cols <- c("stan_rekordu_na",
               "liczba_na_10_tys_mieszkancow",
               "wojewodztwo",
               "powiat_miasto",
               "liczba_przypadkow",
               "zgony")

dd <- left_join(pov_raw@data,
                pow_df[, ..base_cols],
                by = c("wojewodztwo", "powiat_miasto"))
# data.table to retain the order
setDT(dd)
# sparklines
last_14 <- dd$stan_rekordu_na >= (Sys.Date() - 15)
spark1 <- dd[last_14, .(list(spk_chr(liczba_na_10_tys_mieszkancow, width = "100%", type = "line"))), by = list(powiat_miasto, wojewodztwo)]
spark2 <- dd[last_14, .(list(spk_chr(liczba_przypadkow, width = "100%", type = "line"))), by = list(powiat_miasto, wojewodztwo)]
spark3 <- dd[last_14, .(list(spk_chr(zgony, width = "100%", type = "line"))), by = list(powiat_miasto, wojewodztwo)]

ecdf_fun <- function(x, perc) mean(x < perc, na.rm = TRUE)
# Crucial only local values
risk <- dd[, .(list(ecdf_fun(zoo::rollapply(liczba_na_10_tys_mieszkancow[seq(length(liczba_na_10_tys_mieszkancow), 1, -7)], width = 3, FUN = mean, na.rm = TRUE, align = "right", fill = NA),
                             mean(liczba_na_10_tys_mieszkancow[length(liczba_na_10_tys_mieszkancow) - c(0, 7, 14)], na.rm = T)))),
           by = list(powiat_miasto, wojewodztwo)]
last_day <- tail(pow_df$stan_rekordu_na, 1)
pov_raw@data <- dd[dd$stan_rekordu_na == last_day, ]

info_text <- "Aplikacja moblina do monitorowania pandemi koronawirusa w konkretnym powiecie.
Lokalne ryzyko szacowane jest jako kwantyl z rozkładu empirycznego wartości zakażeń na 10tys. mieszkańców w konkretnym powiecie i konkretnego dnia tygodnia, analizujemy dane z konkretnego dnia tygodnia.
Dokładnie brane sa pod wage średnie z 3 obserwacji dla danego dnia tygodnia.
Oszacowana statystyka nie powinna wpływać na zachowania.
Wszelkie środki ostrożności są nadal konieczne."

# exponential and historical max
bins <- round(c(0, 0.5, exp(seq(log(1), log(max(pow_df$liczba_na_10_tys_mieszkancow, na.rm = TRUE)), length = 5))), 2)
pal <- leaflet::colorBin("YlOrRd", domain = range(pow_df$liczba_na_10_tys_mieszkancow), bins = bins)

stolice = c(
  "Białystok",
  "Bydgoszcz",
  "Gdańsk",
  "Gorzów Wielkopolski",
  "Katowice",
  "Kielce",
  "Kraków",
  "Lublin",
  "Łódź",
  "Olsztyn",
  "Opole",
  "Poznań",
  "Rzeszów",
  "Szczecin",
  "Toruń",
  "Warszawa",
  "Wrocław",
  "Zielona Góra"
)

pov_raw@data$Miasto <- ifelse(pov_raw@data$powiat_miasto %in% stolice, pov_raw@data$powiat_miasto, "")

ui <- miniPage(
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
                 icon = icon("info-circle")),
    tags$div(style = "position:absolute;top:20px;right:40px;background-color:white",
             uiOutput("summary"))
  )
)

server <- function(input, output, session) {
browser()
  output$c19 <- renderLeaflet({

    ll <- leaflet() %>%
      addProviderTiles(
        "CartoDB.PositronNoLabels",
        options = providerTileOptions(minZoom = 6, maxZoom = 8)
      ) %>%
      setView(lng = 20, lat = 52, zoom = 6)  %>%
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
        label = pov_raw@data$Miasto,
        labelOptions = labelOptions(noHide = T, direction = 'center', textOnly = T),
        popup = paste0(
          "<h4>", pov_raw@data$powiat_miasto, "</h4>",
          "<strong>", last_day, "</strong><br/>",
          "Lokalne Ryzyko* - (0 - good; 100 - bad)", "<br/>",
          "<span style='font-size:20px;color:", scales::seq_gradient_pal("green","red")(risk$V1),";'><strong>" , round(100 * unlist(risk$V1)), "%", "</strong></span><br/>",
          "Zakażenia: ",
          "<strong>", pov_raw@data$liczba_przypadkow, "</strong>", "<br/>",
          "Zakażenia na 10 tys: ",
          "<strong>", pov_raw@data$liczba_na_10_tys_mieszkancow, "</strong>", "<br/>",
          "Zgony: ",
          "<strong>", pov_raw@data$zgony, "</strong>", "<br>",
          "<br>",
          "<strong>", last_day - 15, "- ", last_day,"</strong>", "<br>",
          "Zakażenia na 10 tys.:", "<br>",
          spark1$V1, "<br>",
          "Zakażenia:", "<br>",
          spark2$V1, "<br>",
          "Zgony:", "<br>",
          spark3$V1, "<br>",
          "<p style='font-size:9px;'>*Kryterium nie powinno wpływać na zachowania.</p>"
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
    shinyalert(text=info_text, title = "Info Page")
  })

  output$summary <- renderUI({tags$div(class = "info legend leaflet-control",
                                       HTML(paste0("<strong>", pow_df_all_last$stan_rekordu_na, "</strong><br>",
                                                   "Zakazenia: ", pow_df_all_last$liczba_przypadkow, "<br>"
                                       )),
                                       sparkline::sparkline(pow_df_all_14$liczba_przypadkow, width = "100px"),
                                       HTML("<br>"),
                                       HTML(paste0("Zgony: ", pow_df_all_last$zgony, "<br>")),
                                       sparkline::sparkline(pow_df_all_14$zgony, width = "100px"))
  })

}

shinyApp(ui, server)
