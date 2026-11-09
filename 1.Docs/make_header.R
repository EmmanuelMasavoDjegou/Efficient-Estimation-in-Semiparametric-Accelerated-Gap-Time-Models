## 1.Docs/make_header.R -- draws 1.Docs/header.png (README banner)
## Run from RStudio with any working directory: the script finds its own folder.
local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f)) {
    setwd(dirname(normalizePath(f[1])))
  } else if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    setwd(dirname(rstudioapi::getSourceEditorContext()$path))
  }
})
suppressPackageStartupMessages(library(ggplot2))

## ---- effective age under three intervention mechanisms ----------------------
## events at calendar times 1.2, 2.3, 3.6, 4.4 on [0, 5.5]
## minimal (ABAO): age = s; perfect (AGAN): age resets to 0;
## imperfect: each intervention halves the age accumulated so far
age_path <- function(kind, ev = c(1.2, 2.3, 3.6, 4.4), smax = 5.5) {
  bounds <- c(0, ev, smax); a0 <- 0; out <- NULL
  for (k in seq_len(length(bounds) - 1)) {
    s <- seq(bounds[k], bounds[k + 1], length.out = 50)
    a <- switch(kind,
                abao = s,
                agan = s - bounds[k],
                imp  = a0 + (s - bounds[k]))
    out <- rbind(out, data.frame(s = s, a = a, kind = kind))
    end <- a[length(a)]
    a0  <- switch(kind, abao = end, agan = 0, imp = 0.5 * end)
  }
  out
}
ev <- c(1.2, 2.3, 3.6, 4.4)
paths <- rbind(age_path("abao"), age_path("imp"), age_path("agan"))

## canvas: x in [0, 32], y in [0, 10]; plot panel on the right
x0 <- 17.25; x1 <- 30.25; yb <- 2.05; ytop <- 7.6
X <- function(s) x0 + (x1 - x0) * s / 5.5
Y <- function(a) yb + (ytop - yb) * a / 5.5
paths$x <- X(paths$s); paths$y <- Y(paths$a)

cols <- c(abao = "#C9D63E", imp = "#3AA87C", agan = "#7FB8E6")
grid_col <- "#A99FD6"

## diagonal background gradient
pal <- colorRampPalette(c("#2A2150", "#483A82"))(256)
nr <- 60; nc <- 200
v  <- outer(seq(0, 1, length.out = nr), seq(0, 1, length.out = nc), function(r, c) (r + c) / 2)
bg <- matrix(pal[1 + round(v * 255)], nr, nc)

leg <- data.frame(kind  = c("abao", "imp", "agan"),
                  label = c("minimal (ABAO)", "imperfect", "perfect (AGAN)"),
                  y     = c(7.45, 6.85, 6.25))

g <- ggplot() +
  annotation_raster(bg, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, interpolate = TRUE) +
  ## left: title, tagline, keywords
  annotate("text", x = 1.6, y = 6.2, label = "Accelerated Effective Age", hjust = 0, vjust = 0,
           colour = "white", size = 10.1, fontface = "bold", family = "sans") +
  annotate("text", x = 1.6, y = 5.0, label = "Gap-Time Models", hjust = 0, vjust = 0,
           colour = "white", size = 10.1, fontface = "bold", family = "sans") +
  annotate("text", x = 1.6, y = 3.7, hjust = 0, vjust = 0, colour = "#D9D4F0", size = 4.8,
           label = "Covariates rescale the effective age, so subjects age") +
  annotate("text", x = 1.6, y = 3.05, hjust = 0, vjust = 0, colour = "#D9D4F0", size = 4.8,
           label = "faster or slower under imperfect interventions.") +
  annotate("text", x = 1.6, y = 1.8, hjust = 0, vjust = 0, colour = grid_col, size = 3.7,
           label = "Semiparametric models | Accelerated gap-time model | Efficient estimation") +
  annotate("text", x = 1.6, y = 1.25, hjust = 0, vjust = 0, colour = grid_col, size = 3.7,
           label = "Survival analysis | Recurrent events | Incomplete follow-up") +
  ## right: axes, event markers, effective age paths, legend
  annotate("segment", x = x0, xend = x1 + 0.2, y = yb, yend = yb, colour = grid_col, linewidth = 0.5) +
  annotate("segment", x = x0, xend = x0, y = yb, yend = ytop + 0.35, colour = grid_col, linewidth = 0.5) +
  annotate("segment", x = X(ev), xend = X(ev), y = yb, yend = ytop + 0.15,
           colour = grid_col, linewidth = 0.3, linetype = "22", alpha = 0.6) +
  geom_path(data = paths, aes(x, y, colour = kind, group = kind), linewidth = 1.1, lineend = "round") +
  annotate("point", x = X(ev), y = yb, colour = "white", size = 2.6) +
  geom_segment(data = leg, aes(x = 17.75, xend = 18.4, y = y, yend = y, colour = kind), linewidth = 1.1) +
  geom_text(data = leg, aes(x = 18.6, y = y, label = label), hjust = 0, colour = "white", size = 3.5) +
  annotate("text", x = 16.95, y = 8.15, label = "effective age", hjust = 0, colour = grid_col, size = 3.5) +
  annotate("text", x = 30.45, y = 1.3, label = "calendar time", hjust = 1, colour = grid_col, size = 3.5) +
  annotate("text", x = 23.75, y = 1.3, label = "● = event / intervention", colour = grid_col, size = 3.5) +
  scale_colour_manual(values = cols, guide = "none") +
  coord_cartesian(xlim = c(0, 32), ylim = c(0, 10), expand = FALSE) +
  theme_void()

ggsave("header.png", g, width = 12.8, height = 4, dpi = 200)   # 2560 x 800 pixels
