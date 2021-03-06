source(list.files(pattern="[Pp]attern.*\\.R$",full.names=T, recursive=T))
source(list.files(pattern="scrape\\.live\\.R$",full.names=T, recursive=T))
source(list.files(pattern="weave\\.rbind\\.R$",full.names=T, recursive=T))
source(list.files(pattern="regex\\.scrape\\.R$",full.names=T, recursive=T))

scrape.chess.com <- function(id,type = c("live","correspondence","open")){
	type <- paste(type,collapse = "")
	
	if(grepl("open",type,ignore.case = T)){
		Link <- file.path("https://www.chess.com/games/view",id)
		DF1 <- regex.scrape(Link,"open")
		DF1 <- cbind(DF1, ID=paste("o",id,sep = "_"),stringsAsFactors=F)
	}else{
		DF1 <- data.frame(Link="NA", stringsAsFactors = F)
	}
	
	if(grepl("corres|turn|daily",type,ignore.case = T)){
		Link <- file.path("https://www.chess.com/daily/game",id)
		DF2 <- regex.scrape(Link, "correspondence")
		DF2 <- cbind(DF2, ID=paste("c",id,sep = "_"), stringsAsFactors=F)
	}else{
		DF2 <- data.frame(Link="NA", stringsAsFactors = F)
	}
	
	if(grepl("live",type,ignore.case = T)){
		Link <- file.path("https://www.chess.com/live/game",id)
		DF3 <- scrape.live(live.link=Link)
		DF3 <- cbind(DF3, ID=paste("l",id,sep="_"),stringsAsFactors=F)
	}else{
		DF3 <- data.frame(Link="NA", stringsAsFactors = F)
	}
	# if(!exists("DF3")){DF3 <- data.frame(Link, stringsAsFactors = F)}

	DF <- weave.rbind(DF1,DF2)
	DF <- weave.rbind(DF, DF3)
	DF <- DF[DF$White!="",]
	if(0<nrow(DF)){
		return(DF)
	}else{
		return(data.frame(ID=paste("NA",id,sep="_"),stringsAsFactors=F))
	}
}

# Receive arguments from bash
ARGS <- commandArgs()
# If there are any args,
if("--args" %in% ARGS){
	# convert them to numbers
	ARGS <- as.numeric(ARGS[grepl("^\\d+$",ARGS)])

	options(scipen = 9)
	filePattern <- paste0(min(ARGS), "-", max(ARGS), ".csv")
	filename <- paste("data/chess.com IDs", filePattern)
	Files <- readLines("temp.txt")

	if(sum(grepl(filename,Files))==0){

		# create sequence from minimum to maximum
		ARGS <- seq(min(ARGS), max(ARGS))
		# scrape the first ID in the sequence
		DF <- scrape.chess.com(ARGS[1])
		print(ARGS[1])
		# scrape the rest of the IDs in the sequence
		for(n in ARGS[-1]){
			DF <- weave.rbind(DF, scrape.chess.com(n))
			print(n)
		}; rm(n)
		# Test for my username in white
		TEST <- "thinkboolean"==DF$White
		# test for my username in black
		TEST <- TEST | "thinkboolean"==DF$Black
		# If my username ever occurs,
		if(0<sum(TEST)){
		  # store subset of games
			write.csv(x = DF[TEST,], row.names=F,
			          file = paste0("data/thinkboolean_", min(ARGS),"-",max(ARGS),"csv"))
		}
		# if there is no directory "data", make one
		if(!file.exists("data")){dir.create("data")}
		
		# remove duplicate rows
		DF <- unique(DF)
		
		# write data frame of games
		write.csv(DF, file = paste("data/chess.com IDs ", min(ARGS) ,"-",  max(ARGS),".csv", sep=""),
				row.names=F)
		rm(TEST)
	}else{
		print(paste("skipping", filename))
	}; rm(filePattern, filename, Files)

};rm(ARGS)
