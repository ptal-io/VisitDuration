#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


if (length(args) < 2) {
  stop("Two file names must be supplied", call.=FALSE)
}

#args[1] <- "newyork_precovid"
#args[2] <- "losangeles_precovid"

name1 <- paste("../data/",args[1],"_timespent_full.csv",sep='')
name2 <- paste("../data/",args[2],"_timespent_full.csv",sep='')


lapre <- read.csv(name1,header=T)
nypre <- read.csv(name2,header=T)

m <- matrix(nrow=1000, ncol=5)
cnt <- 0
for(i in 1:length(lapre)) {
	match <- FALSE
	cnt <- cnt + 1
	for(j in 1:length(nypre)) {
		#  & colnames(nypre)[i] == 'drive'
		if (colnames(lapre)[i] == colnames(nypre[j])) {
			match <- TRUE
			z <- j
		}
	}
	if (match == TRUE) {
		print(colnames(lapre)[i])
		nyt <- nypre[1:length(nypre[,1]),z]
		g <- nyt[!is.na(nyt)]
		lat <- lapre[1:length(lapre[,1]),i]
		f <- lat[!is.na(lat)]
		
		m[cnt,1] <- as.character(colnames(lapre)[i])
		m[cnt,2] <- length(f)
		m[cnt,3] <- length(g)
		m[cnt,4] <- length(f) - length(g)
		m[cnt,5] <- length(g) / length(f)
	} else {
		print(colnames(lapre)[i])
		lat <- lapre[1:length(lapre[,1]),i]
		f <- lat[!is.na(lat)]
		
		m[cnt,1] <- as.character(colnames(lapre)[i])
		m[cnt,2] <- length(f)
		m[cnt,3] <- 0
		m[cnt,4] <- length(f)
		m[cnt,5] <- 0;
	}

}

m <- na.omit(m)
d <- data.frame(m)
colnames(d) <- c('cat','pre','post')

output <- paste("../data/prepost_",args[1],"-",args[2],".csv", sep='')
write.table(d, file=output, col.names = T, row.names = F, sep=',')


