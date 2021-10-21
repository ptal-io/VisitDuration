#!/usr/bin/env Rscript
library(emdist)
args = commandArgs(trailingOnly=TRUE)

# supply two data files, either one for each city (pre or during covid) or one for each time period (same city)
if (length(args) < 2) {
  stop("Two file names must be supplied", call.=FALSE)
}

# example
#args[1] <- "newyork_precovid"
#args[2] <- "losangeles_precovid"

# load data
name1 <- paste("../data/",args[1],"_timespent_full.csv",sep='')
name2 <- paste("../data/",args[2],"_timespent_full.csv",sep='')
lapre <- read.csv(name1,header=T)
nypre <- read.csv(name2,header=T)

#temp output matrix
m <- matrix(nrow=3000, ncol=16)

# loop through each of the dataframes
cnt <- 0
for(i in 1:length(nypre)) {
	for(j in 1:length(lapre)) {
		# if the place types are the same...
		if (colnames(nypre)[i] == colnames(lapre[j])) {
			print(colnames(nypre)[i])
			la_t <- lapre[1:length(lapre[,1]),j]
			f <- la_t[!is.na(la_t)]
			ny_t <- nypre[1:length(nypre[,1]),i]
			g <- ny_t[!is.na(ny_t)]
			# t-test
			t <- t.test(f,g)
			# kernel densities
			ff <- density(f, bw=5)
			gg <- density(g, bw=5)
			# Kolmogorov-Sminorv test
			ks <- ks.test(ff$y,gg$y)
			# Earth Mover's Distance
			em <- emd(cbind(ff$y,ff$x), cbind(gg$y,gg$x))
			ff1 <- cbind(ff$x,ff$y)
			gg1 <- cbind(gg$x,gg$y)
			# Difference in peaks
			ff1max <- ff1[ff1[,2] == max(ff1[,2]),1][1]
			gg1max <- gg1[gg1[,2] == max(gg1[,2]),1][1]
			cnt <- cnt +1
			
			#output matrix
			m[cnt,1] <- as.character(colnames(nypre)[i])
			m[cnt,2] <- as.numeric(t$statistic)
			m[cnt,3] <- as.numeric(t$p.value)
			m[cnt,4] <- mean(f)
			m[cnt,5] <- mean(g)
			m[cnt,6] <- mean(f) - mean(g)
			m[cnt,7] <- sd(f)
			m[cnt,8] <- sd(g)
			m[cnt,9] <- length(f)
			m[cnt,10] <- length(g)
			m[cnt,11] <- median(f)
			m[cnt,12] <- median(g)
			m[cnt,13] <- ks$p.value
			m[cnt,14] <- ks$statistic
			m[cnt,15] <- em[[1]]
			m[cnt,16] <- ff1max - gg1max
			#a <- density(pre, bw=6)
			#c <- cbind(a$x,a$y)
			#c[c[,2] ==max(c[,2]),1]
		}
	}
}

m <- na.omit(m)
d <- data.frame(m)
colnames(d) <- c('cat','tstat','pval',paste(args[1],"_mean",sep=''),paste(args[2],"_mean",sep=''),paste(args[1],"-",args[2],sep=''),paste(args[1],"_sd",sep=''),paste(args[2],"_sd",sep=''),paste(args[1],"_len",sep=''),paste(args[2],"_len",sep=''),paste(args[1],"_med",sep=''),paste(args[2],"_med",sep=''),'ks.test','ks.stat','emd','peakdiff')

output <- paste("../data/ttest_",args[1],"-",args[2],".csv", sep='')
write.table(d, file=output, col.names = T, row.names = F, sep=',')


