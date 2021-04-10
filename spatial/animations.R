if (!"pacman" %in% unname(installed.packages()[, 1])) install.packages("pacman")
pacman::p_load(
    sp,
    rgdal,
    maps,
    data.table,
    tmap,
    stringr,
    gifski,
    sf
)

plot_2png <- function(x, filename) {
    x <- substitute(x)
    stopifnot(is.call(x))
    filename_path <- file.path(getwd(), filename)
    file.create(filename_path)
    png(filename_path)
    eval(x, parent.frame())
    res <- dev.off()
}

pov_raw <- readOGR("spatial/data/powiaty") # 380 jedn.
pov_raw$powiat_miasto <-  str_replace_all(stringr::str_conv(pov_raw$jpt_nazwa_, "Windows-1250"), "powiat ", "")

data_nts <- read.table("spatial/data/data_nts4_2019.csv", sep = ";", dec = ",", header = TRUE)
data_nts15 <- data_nts[data_nts$year == 2015, ]
data_nts15$wojewodztwo <- stringr::str_to_lower(stringr::str_conv(data_nts15$region_name, "Windows-1250"))

pov_raw@data$wojewodztwo <- data_nts15$wojewodztwo

pow_df <- fread(file = "gov/data/pow_df.csv")
pow_df$liczba_na_10_tys_mieszkancow <- as.numeric(pow_df$liczba_na_10_tys_mieszkancow)

bbox_new <- st_bbox(pov_raw) # current bounding box
xrange <- bbox_new$xmax - bbox_new$xmin # range of x values
yrange <- bbox_new$ymax - bbox_new$ymin # range of y values
bbox_new[3] <- bbox_new[3] + (0.10 * xrange) # xmax - right
bbox_new[4] <- bbox_new[4] + (0.10 * yrange) # ymax - top
bbox_new <- bbox_new %>%  # take the bounding box ...
    st_as_sfc() # ... and make it a sf polygon

udates <- unique(pow_df$Date)
cc <- lapply(udates, function(x) {
    pov_temp <- pov_raw

    pov_temp@data <- dplyr::left_join(pov_temp@data, pow_df[pow_df$Date == x, ], by = c("wojewodztwo", "powiat_miasto"))

    res <- tm_shape(pov_temp, projection = "+proj=longlat +datum=NAD83", bbox = bbox_new) +
    tm_polygons(col = "zgony", style = "fixed", breaks = c(0, exp(seq(0, log(50), length = 5))[-1]), colorNULL = "red") +
    tm_compass(type = "8star", position = c("left", "top")) +
    tm_scale_bar(breaks = c(0, 100, 200)) +
    tm_layout(title = sprintf("Zgony %s, %s", x, format(x, "%a")), title.position = c('left', 'top'))

    plot_2png(print(res), sprintf("spatial/images/animation01/%s.png", format(x, "%Y%m%d")))
})

gifski::gifski(sort(list.files("spatial/images/animation01", full.names = TRUE)), "spatial/images/zgonyPL.gif", width=1200, height = 600, delay = 0.5)
