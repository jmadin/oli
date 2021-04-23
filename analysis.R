# Surface geometry and biodiversity

source("R/functions.R")
output <- "oli" # For housekeeping

### Data preparation

rock <- read.table("data/oli/plot 1/P01-Rock txt.txt", header=FALSE, as.is=TRUE)
inte <- read.table("data/oli/plot 1/P01-Intermediate txt.txt", header=FALSE, as.is=TRUE)
muss <- read.table("data/oli/plot 1/P01-Mussels txt.txt", header=FALSE, as.is=TRUE)

bott <- max(c(rock[["V3"]], inte[["V3"]], muss[["V3"]]))

rock["V3"] <- bott - rock["V3"]
inte["V3"] <- bott - inte["V3"]
muss["V3"] <- bott - muss["V3"]

# Composit layers
rock_inte <- rbind(rock, inte)
rock_inte_muss <- rbind(rock, inte, muss)

r <- raster(ncols=1000, nrows=500) # 0.36 mm res DEM generation

roc <- rasterize(rock[c("V1", "V2")], r, rock[c("V3")], fun=max, ask=TRUE)
int <- rasterize(inte[c("V1", "V2")], r, inte[c("V3")], fun=max, ask=TRUE)
roc_int <- rasterize(rock_inte[c("V1", "V2")], r, rock_inte[c("V3")], fun=max, ask=TRUE)
mus <- rasterize(muss[c("V1", "V2")], r, muss[c("V3")], fun=max, ask=TRUE)
roc_int_mus <- rasterize(rock_inte_muss[c("V1", "V2")], r, rock_inte_muss[c("V3")], fun=max, ask=TRUE)

### Scope (extent), scales of variation, and resolution (grain)
L <- 40 # Scope, 100 by 100 mm plots
scl <- L / c(1, 2, 4, 8, 16) # Scales, aim for 2 orders of magnitude
L0 <- min(scl) # Grain, resolution of processing

### Analysis
layers <- c("roc", "roc_int", "roc_int_mus")
store <- data.frame()

for (lay in layers) {
  data <- get(lay)
  data <- trim(data)
  png(paste0("figs/", lay, ".png"), width = 6, height = 6, units = 'in', res = 300)

  plot(data, axes=TRUE, main=lay, zlim=c(0, max(values(roc_int_mus), na.rm=TRUE)))
  contour(data, add=TRUE, col="darkgrey")

  xb <- mean(c(extent(data)[1], extent(data)[2])) - L
  yb <- mean(c(extent(data)[3], extent(data)[4])) - L

  # Iterate through quadrants (reps = 4) in plot
  rep <- 1
  for (i in c(0, L)) {
    for (j in c(0, L)) {
      x0 <- xb + i
      y0 <- yb + j
      temp <- height_variation(write=TRUE, return=TRUE)
      rect(x0, y0, x0+L, y0+L, border="white", lty=2, lwd=2)
      out <- rdh(temp)
      text(x0+L/2, y0+L/2, paste0("D=", round(out$D, 2), "\nR=", round(out$R, 2), "\nH=", round(out$H, 2)))
      
      store <- rbind(store, data.frame(lay=lay, rep=rep, out))
      rep <- rep + 1
    }
  }
  dev.off()
}



