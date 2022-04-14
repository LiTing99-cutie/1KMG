setwd("/home/user/data2/lit/project/1KMG/qcANDstats")

library(tidyverse)
rm(list=ls())

######################
# 1. TAD
TAD_h <- read.table("/home/user/data/lit/project/1KMG/in_house/hic/h/domain/TAD/insulScor/bin40000_sqs1000000_dls200000/bigWig/human_PFC_40000.isTad.bed")
TAD_h <- mutate(TAD_h,size=(V3-V2)/1000000,Species="H-PFC")

TAD_m <- read.table("/home/user/data/lit/project/1KMG/in_house/hic/m/domain/TAD/insulScor/bin40000_sqs1000000_dls200000/bigWig/macaque_PFC_40000.isTad.bed")
TAD_m <- mutate(TAD_m,size=(V3-V2)/1000000,Species="R-PFC")
TAD_size <- rbind(TAD_h,TAD_m)

TAD_number <- data.frame(Species=c("H-PFC","R-PFC"),TAD.number=c(nrow(TAD_h),nrow(TAD_m)))

p <- ggplot(data = TAD_number,
            mapping = aes(x = Species ,
                          y=TAD.number,
                          fill=Species))+
  geom_bar(stat = 'identity',width=0.5)+labs(y = "TAD number",x='')+
  coord_fixed(ratio = 1/800)+
  theme_set(theme_bw())+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"),
        axis.ticks.x = element_blank())+
  guides(fill = "none") +
  geom_text(aes(label = TAD.number),size=3.2,vjust=-0.3)
ggsave("/home/user/data2/lit/project/1KMG/qcANDstats/TAD_number.pdf",p)


p <- ggplot(data = TAD_size,
            mapping = aes(
              y = size, 
              x = Species,
              fill = Species))+
  geom_boxplot(notch=TRUE,width=0.5,outlier.shape = NA)+
  stat_boxplot(geom = "errorbar",width=0.5)+
  theme_set(theme_bw())+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"),
        axis.ticks.x = element_blank())+
  labs(y = "TAD size (Mb)",x='')+
  guides(fill = "none")+
  coord_fixed(ylim = c(0,4),ratio = 1/1.6)+
  annotate(
    "text", label = paste0(round(median(TAD_h$size)*1000),"kb"),x=1,y=2.85,
    size = 3.2
  )+
  annotate(
    "text", label = paste0(round(median(TAD_m$size)*1000),"kb"),x=2,y=3.65,
    size = 3.2
  )
ggsave("/home/user/data2/lit/project/1KMG/qcANDstats/TAD_size.pdf",p)


#################
# 2. loop
loop_h <- read.table("/home/user/data/lit/project/1KMG/in_house/hic/h/domain/loop/HiCCUPS/hiccups_output/mediumRes/merged_loops.bedpe")
loop_m <- read.table("/home/user/data/lit/project/1KMG/in_house/hic/m/domain/loop/hiccups/hiccups_output/mediumRes25kb/merged_loops.bedpe")
loop_number <- data.frame(Species=c("H-PFC","R-PFC"),loop.number=c(nrow(loop_h),nrow(loop_m)))


p <- ggplot(data = loop_number,
            mapping = aes(x = Species,
                          y=loop.number,
                          fill=Species))+
  theme_set(theme_bw())+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"),
        axis.ticks.x = element_blank())+
  geom_bar(stat = 'identity',width=0.5)+labs(y = "loop number",x='') + guides(fill = "none") +
  geom_text(aes(label = loop.number),size=3.2,vjust=-0.3)+
  coord_fixed(ratio = 1/1600)
  
ggsave("/home/user/data2/lit/project/1KMG/qcANDstats/loop_number.pdf",p)

