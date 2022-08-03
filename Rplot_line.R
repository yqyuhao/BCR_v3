suppressMessages(library("ggplot2"))
suppressMessages(library("tidyverse"))
args <- commandArgs(T)
in_IGK <- args[1] 
if(length(args) != 1){
  cat("USAGE: RScript Rplot_line.R *.Statistics.sorted.xls\n")
  quit('no')
}
IGK.file <- read.table(in_IGK , sep = "\t", fill = T, header =F ,stringsAsFactors = F,
                       col.names = paste("V", 1:18, sep = ""))
colnames(IGK.file) <- as.character(IGK.file[which(IGK.file[,1]=="Read_No"),])
IGK.file <- data.frame(IGK.file[ -nrow(IGK.file) , c(1:7)])
input_file <- IGK.file[-which(IGK.file[,1]=="Read_No"),]
region_type <- gsub( ".Statistics.xls"  ,"",in_IGK)
input_file[,3] <- as.numeric(input_file[,3])
input_file[,4] <- as.numeric(input_file[,4])
length_min <- max(min(as.numeric(input_file[,3]))-10,0)
length_max <- max(as.numeric(input_file[,3]))+10
length_range <- seq(length_min,length_max,by = 1)
length <- input_file[c(3,4)]  %>%
      group_by(input_file$Seq_Len ) %>%
      summarise(count_sum=sum(Count))
length <- data.frame(data.frame(length),relation=length[,2]/sum(length[,2]))
length_range <- data.frame(range=length_range,relation=rep(0,length(length_range)))
for (i in 1:nrow(length)){
  for (j in 1:nrow(length_range)){
    if( length_range[j,"range"] == length$input_file.Seq_Len[i] ){
      length_range[ j,"relation" ] <- length$count_sum.1[i]
    }
  }
}
pdf(file=paste0(region_type,".Statistics.length.pdf",sep ="" ), height=8, width=8) 
  ggplot(data=length_range, aes(x=range, y=relation*100),geom = "smooth") + 
    geom_line( colour="orange3",  size=0.5)+geom_point(color="orange3", size=0.5)+
    scale_fill_discrete(labels=c(region_type))+
    labs(x="Sequence Length (bp)",y="Proportion (%)",title=region_type)+
    theme(plot.title=element_text(face="plain",size=15,hjust=0.5))+
    coord_cartesian( ylim = c(0, 100))
dev.off()