
setwd("/home/user/data2/lit/project/1KMG/qcANDstats/loop/")
rm(list=ls())
library(readr)
library(GenomicRanges)
library(tidyverse)
library(rtracklayer)


########## human   ############
loops <- read.table("/home/user/data/lit/project/1KMG/in_house/hic/h/domain/loop/HiCCUPS/hiccups_output/mediumRes/merged_loops.neat.bedpe")

mutate(loops,status="loop anchor") -> loops
loops_random <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/human.random_loop.bed")
mutate(loops_random,status="random") -> loops_random
rbind(loops,loops_random) -> loops
rm(loops_random)


anchor1 <- GRanges(loops$V1,
                   IRanges(loops$V2+1, loops$V3))
anchor2 <- GRanges(loops$V4,
                   IRanges(loops$V5+1, loops$V6))

loop.status <- factor(loops$status)
table(loop.status)

anchor1$loop.status <- loop.status
anchor2$loop.status <- loop.status


enh <- import.bed("/home/user/data2/lit/project/1KMG/qcANDstats/loop/histone_mdf/human/hg38_h_PFC_H3K27ac_overlap_sorted_merged.narrowPeak")
enh <- keepStandardChromosomes(enh, pruning.mode="coarse")


# BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
g <- genes(txdb)
g <- keepStandardChromosomes(g, pruning.mode="coarse")
promoter <- promoters(g, upstream=2000, downstream=2000)

# simply removes from the enhancer GRanges any regions overlapping a promoter
enh <- enh[!overlapsAny(enh, promoter)]
anchor1$promoter <- overlapsAny(anchor1, promoter)
anchor1$enhancer <- overlapsAny(anchor1, enh)
anchor2$promoter <- overlapsAny(anchor2, promoter)
anchor2$enhancer <- overlapsAny(anchor2, enh)
EE <- loop.status[anchor1$enhancer & anchor2$enhancer]
PP <- loop.status[anchor1$promoter & anchor2$promoter]
EP <- loop.status[(anchor1$enhancer & anchor2$promoter) |
                    (anchor2$enhancer & anchor1$promoter)]

tab <- cbind(EE=table(EE), PP=table(PP), EP=table(EP))

for (i in c(1,2,3)){
  data.frame(tab) %>% dplyr::select(i) %>% mutate(other=length(anchor1)/2-.[1,]) %>% t() %>% fisher.test() %>% print()
}


apply(tab,2,function(x){x/(length(anchor1)/2)}) -> prop_tab

loop_type <- data.frame(percentage=as.vector(prop_tab)*100,loop=factor(rep(c("loop anchor","random"),3),levels = c("random","loop anchor")),
                        loop_type=rep(c("E-E","P-P","E-P"),each=2))


p_h <- ggplot(data = loop_type,
            mapping = aes(x = loop_type,
                          y=percentage,
                          fill=loop))+
  theme_set(theme_bw())+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"),
        axis.ticks.x = element_blank())+
  geom_bar(stat = 'identity',width=0.5,position = "dodge")+
  labs(title="human PFC",y = "Percentage of Loop (%)",x='',fill='') +
  theme(plot.title = element_text(hjust = 0.5)) +
  annotate(
    "text", label = "*",x="E-E",y=10.4,
    size = 8,
    hjust=-0.6
  )+
  annotate(
    "text", label = "*",x="E-P",y=18.5,
    size = 8,
    hjust=-0.6
  )+
  annotate(
    "text", label = "*",x="P-P",y=12.5,
    size = 8,
    hjust=-0.6
  )
  
ggsave("loop_type_h.pdf",p_h)


##################



####### rhesus macaque ##########
rm(list=ls())

loops <- read.table("/home/user/data/lit/project/1KMG/in_house/hic/m/domain/loop/hiccups/hiccups_output/mediumRes25kb/merged_loops.neat.bedpe")

if(F){
  
  file <- "/home/user/data/lit/database/in_house/rheMac10Plus/rheMac10Plus.addgeneName.gtf"
  
  # make txdb from rhesus 
  rheMac10Plus_txdb <- makeTxDbFromGFF(file,
                                       format="gtf",
                                       dataSource="BGM")
  
  saveDb(rheMac10Plus_txdb, file="rheMac10Plus_txdb.sqlite")
  file <- "rheMac10Plus_txdb.sqlite"
  if (file.exists(file)) {
    system("mv rheMac10Plus_txdb.sqlite /home/user/data/lit/database/in_house/rheMac10Plus/")
  }
}

mutate(loops,status="loop anchor") -> loops
loops_random <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/macaque.random_loop.bed")
mutate(loops_random,status="random") -> loops_random
rbind(loops,loops_random) -> loops
rm(loops_random)


anchor1 <- GRanges(loops$V1,
                   IRanges(loops$V2+1, loops$V3))
anchor2 <- GRanges(loops$V4,
                   IRanges(loops$V5+1, loops$V6))

loop.status <- factor(loops$status)
table(loop.status)

anchor1$loop.status <- loop.status
anchor2$loop.status <- loop.status

enh <- import.bed("/home/user/data2/lit/project/1KMG/qcANDstats/loop/histone_mdf/macaque/rheMac10Plus_m_PFC_H3K27ac_overlap_sorted_merged.narrowPeak")
enh <- keepStandardChromosomes(enh, pruning.mode="coarse")

rheMac10Plus_txdb <- loadDb("/home/user/data/lit/database/in_house/rheMac10Plus/rheMac10Plus_txdb.sqlite")

txdb <- rheMac10Plus_txdb
g <- genes(txdb)
g <- keepStandardChromosomes(g, pruning.mode="coarse")
promoter <- promoters(g, upstream=2000, downstream=2000)

# simply removes from the enhancer GRanges any regions overlapping a promoter
enh <- enh[!overlapsAny(enh, promoter)]
anchor1$promoter <- overlapsAny(anchor1, promoter)
anchor1$enhancer <- overlapsAny(anchor1, enh)
anchor2$promoter <- overlapsAny(anchor2, promoter)
anchor2$enhancer <- overlapsAny(anchor2, enh)
EE <- loop.status[anchor1$enhancer & anchor2$enhancer]
PP <- loop.status[anchor1$promoter & anchor2$promoter]
EP <- loop.status[(anchor1$enhancer & anchor2$promoter) |
                    (anchor2$enhancer & anchor1$promoter)]

tab <- cbind(EE=table(EE), PP=table(PP), EP=table(EP))

for (i in c(1,2,3)){
  data.frame(tab) %>% dplyr::select(i) %>% mutate(other=length(anchor1)/2-.[1,]) %>% t() %>% fisher.test() %>% print()
}


apply(tab,2,function(x){x/(length(anchor1)/2)}) -> prop_tab

loop_type <- data.frame(percentage=as.vector(prop_tab)*100,loop=factor(rep(c("loop anchor","random"),3),levels = c("random","loop anchor")),
                        loop_type=rep(c("E-E","P-P","E-P"),each=2))


p_m <- ggplot(data = loop_type,
            mapping = aes(x = loop_type,
                          y=percentage,
                          fill=loop))+
  theme_set(theme_bw())+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"),
        axis.ticks.x = element_blank())+
  geom_bar(stat = 'identity',width=0.5,position = "dodge")+
  labs(title="macaque PFC",y = "Percentage of Loop (%)",x='',fill='') +
  theme(plot.title = element_text(hjust = 0.5)) +
  annotate(
    "text", label = "*",x="E-E",y=14.5,
    size = 8,
    hjust=-0.6
  )+
  annotate(
    "text", label = "*",x="E-P",y=34,
    size = 8,
    hjust=-0.6
  )+
  annotate(
    "text", label = "*",x="P-P",y=29.5,
    size = 8,
    hjust=-0.6
  )

ggsave("loop_type_m.pdf",p_m)

##################