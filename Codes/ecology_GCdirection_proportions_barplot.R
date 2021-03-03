jump_common_dir <- "../Results/jump_analysis/"
eco_directions_data <- read.table(paste0(jump_common_dir, "Ecology_GCdirection_proportions.tab"), stringsAsFactors=F, header = T)
eco_directions_data$percentage <- sapply(1:nrow(eco_directions_data), function(x) round(100*eco_directions_data[x,"Number"]/sum(eco_directions_data[which(eco_directions_data[,"EcoFactor"]==eco_directions_data[x,"EcoFactor"]),"Number"])))
  
library(ggplot2)
library(cowplot)
eco_directions_plot <- ggplot(data = eco_directions_data, mapping = aes(x = EcoFactor, y = Number, fill = Direction)) + geom_bar(stat = "identity", color="white") + scale_fill_grey() + theme_cowplot()
eco_directions_plot <- eco_directions_plot + geom_text(data = eco_directions_data, aes(x = EcoFactor, y = Number, label=percentage, color=Direction), fontface="bold")
eco_directions_plot <- eco_directions_plot + scale_x_discrete(name="") + scale_color_manual(values=c("white", "black"))
eco_directions_plot

ggsave2(paste0(jump_common_dir, "Ecology_GCdirection_proportions.svg"), eco_directions_plot, dpi = 300, width = 6, height = 3.5,
units = "in")