#!/usr/bin/Rscript

# Plot a 5-way Venn diagram from a tab delimited file containing a matrix showing
 # presence /absence of orthogroups within 5 isolates.

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
#    make_option("--maxrf", type="double", default=0.2, help="max rf to consider as linked"),
#    make_option("--minlod", type="double", default=20.0, help="min LOD to consider as linked")
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
area3=sum(df1[, 3])
area4=sum(df1[, 4])
area5=sum(df1[, 5])

#print(area1, area2, area3, area4, area5)

colname1 <- paste(colnames(df1)[1])
colname2 <- paste(colnames(df1)[2])
colname3 <- paste(colnames(df1)[3])
colname4 <- paste(colnames(df1)[4])
colname5 <- paste(colnames(df1)[5])

label1 <- paste(colname1, ' (', area1, ')', sep="" )
label2 <- paste(colname2, ' (', area2, ')', sep="" )
label3 <- paste(colname3, ' (', area3, ')', sep="" )
label4 <- paste(colname4, ' (', area4, ')', sep="" )
label5 <- paste(colname5, ' (', area5, ')', sep="" )

n12=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1))
n13=nrow(subset(df1, df1[,1] == 1 & df1[,3] == 1))
n14=nrow(subset(df1, df1[,1] == 1 & df1[,4] == 1))
n15=nrow(subset(df1, df1[,1] == 1 & df1[,5] == 1))
n23=nrow(subset(df1, df1[,2] == 1 & df1[,3] == 1))
n24=nrow(subset(df1, df1[,2] == 1 & df1[,4] == 1))
n25=nrow(subset(df1, df1[,2] == 1 & df1[,5] == 1))
n34=nrow(subset(df1, df1[,3] == 1 & df1[,4] == 1))
n35=nrow(subset(df1, df1[,3] == 1 & df1[,5] == 1))
n45=nrow(subset(df1, df1[,4] == 1 & df1[,5] == 1))
n123=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,3] == 1))
n124=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,4] == 1))
n125=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,5] == 1))
n134=nrow(subset(df1, df1[,1] == 1 & df1[,3] == 1 & df1[,4] == 1))
n135=nrow(subset(df1, df1[,1] == 1 & df1[,3] == 1 & df1[,5] == 1))
n145=nrow(subset(df1, df1[,1] == 1 & df1[,4] == 1 & df1[,5] == 1))
n234=nrow(subset(df1, df1[,2] == 1 & df1[,3] == 1 & df1[,4] == 1))
n235=nrow(subset(df1, df1[,2] == 1 & df1[,3] == 1 & df1[,5] == 1))
n245=nrow(subset(df1, df1[,2] == 1 & df1[,4] == 1 & df1[,5] == 1))
n345=nrow(subset(df1, df1[,3] == 1 & df1[,4] == 1 & df1[,5] == 1))
n1234=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,3] == 1 & df1[,4] == 1))
n1235=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,3] == 1 & df1[,5] == 1))
n1245=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,4] == 1 & df1[,5] == 1))
n1345=nrow(subset(df1, df1[,1] == 1 & df1[,3] == 1 & df1[,4] == 1 & df1[,5] == 1))
n2345=nrow(subset(df1, df1[,2] == 1 & df1[,3] == 1 & df1[,4] == 1 & df1[,5] == 1))
n12345=nrow(subset(df1, df1[,1] == 1 & df1[,2] == 1 & df1[,3] == 1 & df1[,4] == 1 & df1[,5] == 1))

summary(n12)
summary(n123)
summary(n1234)
summary(n12345)

pdf(o)
draw.quintuple.venn(
  area1, area2, area3, area4, area5,
  n12, n13, n14, n15, n23, n24, n25, n34, n35, n45,
  n123, n124, n125, n134, n135, n145, n234, n235, n245, n345,
  n1234, n1235, n1245, n1345, n2345,
  n12345,
  category = c(label1, label2, label3, label4, label5),
  lwd = rep(2, 5),
	lty = rep("solid", 5),
  col = rep("black", 5),
  fill = NULL,
  alpha = rep(0.5, 5),
  label.col = rep("black", 31),
  cex = rep(1, 31),
  fontface = rep("plain", 31),
  fontfamily = rep("serif", 31),
  cat.pos = c(0, 287.5, 215, 145, 70),
  cat.dist = rep(0.2, 5),
  cat.col = rep("black", 5),
  cat.cex = rep(1, 5),
  cat.fontface = rep("plain", 5),
  cat.fontfamily = rep("serif", 5),
  cat.just = rep(list(c(0.5, 0.5)), 5),
  rotation.degree = 0,
  rotation.centre = c(0.5, 0.5),
  ind = TRUE,
  margin = 0.15
)

dev.off()

singles = df1[grepl("single*", rownames(df1)), ]
uniq_1=sum(singles[, 1])
uniq_2=sum(singles[, 2])
uniq_3=sum(singles[, 3])
uniq_4=sum(singles[, 4])
uniq_5=sum(singles[, 5])
orthogroups = df1[grepl("orthogroup*", rownames(df1)), ]
inpara_1 = sum(orthogroups[,1] == 1 & orthogroups[,2] == 0 & orthogroups[,3] == 0 & orthogroups[,4] == 0 & orthogroups[,5] == 0)
inpara_2 = sum(orthogroups[,1] == 0 & orthogroups[,2] == 1 & orthogroups[,3] == 0 & orthogroups[,4] == 0 & orthogroups[,5] == 0)
inpara_3 = sum(orthogroups[,1] == 0 & orthogroups[,2] == 0 & orthogroups[,3] == 1 & orthogroups[,4] == 0 & orthogroups[,5] == 0)
inpara_4 = sum(orthogroups[,1] == 0 & orthogroups[,2] == 0 & orthogroups[,3] == 0 & orthogroups[,4] == 1 & orthogroups[,5] == 0)
inpara_5 = sum(orthogroups[,1] == 0 & orthogroups[,2] == 0 & orthogroups[,3] == 0 & orthogroups[,4] == 0 & orthogroups[,5] == 1)
label1
uniq_1
inpara_1
label2
uniq_2
inpara_2
label3
uniq_3
inpara_3
label4
uniq_4
inpara_4
label5
uniq_5
inpara_5

warnings()
q()
