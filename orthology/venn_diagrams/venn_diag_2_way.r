#!/usr/bin/Rscript

# Plot a 2-way Venn diagram from a tab delimited file containing a matrix showing
 # presence /absence of orthogroups between 2 genomes.

 # This is intended to be used on the output of the orthoMCL pipeline following
 # building of the matrix using:
 # ~/git_repos/emr_repos/tools/pathogen/orthology/orthoMCL/orthoMCLgroups2tab.py

# This script requires the optparse R package. This can be downloaded by opening
# R and running the following command:
# install.packages("optparse",repos="http://cran.uk.r-project.org")
# When given the option, install this package to a local library.

#get config options
library(optparse)
library(VennDiagram, lib.loc="/home/armita/R-packages/")
opt_list = list(
    make_option("--inp", type="character", help="tab seperated file containing matrix of presence of orthogroups"),
    make_option("--out", type="character", help="output venn diagram in pdf format")
)
opt = parse_args(OptionParser(option_list=opt_list))
f = opt$inp
o = opt$out

orthotabs <-data.frame()
orthotabs <- read.table(f)
df1 <- t(orthotabs)
summary(df1)


area1=sum(df1[, 1])
area2=sum(df1[, 2])

# print(area1, area2, area3, area4)

colname1 <- paste(colnames(df1)[1])
colname2 <- paste(colnames(df1)[2])

label1 <- paste(colname1, ' (', area1, ')', sep="" )
label2 <- paste(colname2, ' (', area2, ')', sep="" )

n12=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1))
summary(n12)
pdf(o)
draw.pairwise.venn(area1, area2,
    n12,
    category = c(label1, label2),
#    rep("", 4),
    rotation = 1,
    reverse = FALSE,
    euler.d = FALSE,
    scaled = FALSE,
    lwd = rep(2, 2),
    lty = rep("solid", 2),
    col = rep("black", 2),
    fill = NULL,
    alpha = rep(0.5, 2),
    label.col = rep("black", 3),
    cex = rep(1, 3),
    fontface = rep("plain", 3),
    fontfamily = rep("serif", 3),
    cat.pos = c(-50, 50),
    cat.dist = rep(0.025, 2),
    cat.cex = rep(1, 2),
    cat.col = rep("black", 2),
    cat.fontface = rep("plain", 2),
    cat.fontfamily = rep("serif", 2),
    cat.just = rep(list(c(0.5, 0.5)), 2),
    cat.default.pos = "outer",
    cat.prompts = FALSE,
    ext.pos = rep(0, 2),
    ext.dist = rep(0, 2),
    ext.line.lty = "solid",
    ext.length = rep(0.95, 2),
    ext.line.lwd = 1,
    rotation.degree = 0,
    rotation.centre = c(0.5, 0.5),
    ind = TRUE,
    sep.dist = 0.5,
    offset = 0
    )

dev.off()
singles = df1[grepl("single*", rownames(df1)), ]
uniq_1=sum(singles[, 1])
uniq_2=sum(singles[, 2])
orthogroups = df1[grepl("orthogroup*", rownames(df1)), ]
inpara_1 = sum(orthogroups[,1] == 1 & orthogroups[,2] == 0)
inpara_2 = sum(orthogroups[,1] == 0 & orthogroups[,2] == 1)
label1
uniq_1
inpara_1
label2
uniq_2
inpara_2

warnings()
q()
