# Surface geometry and biodiversity
source("R/functions.R")

# Scope (extent), scales of variation, and resolution (grain)
L <- 150 # Scope, 2 by 2 m reef patches
scl <- L / c(1, 2, 4, 8) #, 16, 32, 64, 128) # Scales, aim for 2 orders of magnitude
L0 <- min(scl) # Grain, resolution of processing ~ 6 cm

# Example surface (an 8x8m section of Horseshoe from Lizard Island)
output <- "oli" # For housekeeping

# Load example geotif
muss <- read.table("data/oli/3D Points - WGR-P05 - Layer 1 and 3 Combined.txt", header=FALSE, as.is=TRUE)
r <- raster(ncols=500, nrows=500) # kind of coarse for example
data <- rasterize(muss[c("V1", "V2")], r, muss[c("V3")], fun=max, ask=TRUE)

pdf("figs/fig.pdf", width = 8, height = 8)

image(data, asp=1)

rep <- 1
# Choose patch in which to calculate RDH (rugosity, fractal D and height range).
x0 <- -L/2 #data@extent[1]
y0 <- -L/2 #data@extent[3]
rect(x0, y0, x0+L, y0+L, border="white", lty=2)

dev.off()

# Calulate height variation at different scales (scl) within patch, and save output (because a time-consuming step)
example <- height_variation(write=TRUE, return=TRUE)

# Load the file if starting here:
example <- read.csv(paste0("output/", output, "/var_", names(data), "_0001.csv"), as.is=TRUE)

# Calculate rugosit, fractal dimension and height range (rdh function)
rdh(example)
