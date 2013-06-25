Sys.setlocale(category="LC_TIME", "C")

log2 <- read.table("access.extend.log-20130527", quote="\"")

#convert timestamp
log2$V2 <- as.POSIXct(strptime(substr(paste(log2$V4, log2$V5), 2, 27), format="%d/%b/%Y:%H:%M:%S %z"))
log2$V5 <- NULL
log2$V6 <- as.character(log2$V6)
log2[log2$V6=="-", "V6"] <- "- - -" #Must be two spaces in this field
log2$V6 <- as.factor(log2$V6)
