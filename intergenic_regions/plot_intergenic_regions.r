#!/home/armita/prog/R/R-3.2.2/bin/Rscript

# R script for analysing a file of abundance of kmers.
# The input file should be a single column of abundance values.
# This script will produce a histogram of kmer abundance, a distribution plot
# and generate summary statistics.

#get config options
library(optparse)
library(scales)
library(RColorBrewer)
rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
r <- rf(32)


opt_list = list(
    make_option("--inp", type="character", help="tab seperated file containing 5' and 3' intergenic lengths"),
    make_option("--out", type="character", help="output gene density plot in pdf format")
)
opt = parse_args(OptionParser(option_list=opt_list))
f = opt$inp
o = opt$out

#f = "analysis/intergenic_regions/P.cactorum/10300/10300_intergenic_regions.txt"
#o = "analysis/intergenic_regions/P.cactorum/10300/10300_intergenic_density.pdf"

# options(download.file.method = "wget")
# install.packages("ggplot2")
library(ggplot2)

df <- read.delim(file=f, header=F, sep="\t")

colnames(df) <- c("ID", "five_IG", "three_IG")

density_plot <- ggplot(df, aes(df$five_IG, df$three_IG)) +
    stat_bin2d(bins = 100) +
    scale_y_continuous(trans='log2', expand=c(0,0)) +
    scale_x_continuous(trans='log2', expand=c(0,0)) +
    xlab("5' IG length") +
    ylab("3' IG length") +
    scale_fill_gradientn(colours=r)
  #  scale_fill_gradientn(colours=rainbow(30))
  #  scale_fill_gradientn(colours=c(muted("yellow"), muted("red"))

#    scale_fill_gradientn(colours=rainbow(7)) +
#    facet_grid(chrm1 ~ chrm2)

ggsave(o, density_plot, dpi=300, height=10, width=12)

q()
