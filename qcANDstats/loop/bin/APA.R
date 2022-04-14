setwd("/home/user/data2/lit/project/1KMG/qcANDstats/loop/")
rm(list=ls())
library(magrittr)
library(reshape2)

####### human #####
APA <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/APA_h.txt",sep = ',')

APA_measure <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/output/human/5000/gw/measures.txt")

APA %<>% as.data.frame(.) 
  
colnames(APA) <- c(paste(seq(-50,-5,by=5),"kb"),
                    0,
                    paste(seq(5,50,by=5),"kb"))
  
rownames(APA) <- colnames(APA)

APA$ID <- rownames(APA)

APA_m <- melt(APA,id.vars = "ID")

APA_m$ID <- factor(APA_m$ID,levels= c(paste(seq(-50,-5,by=5),"kb"),
                                      0,
                                      paste(seq(5,50,by=5),"kb")))

APA_m$variable <- factor(APA_m$variable,levels= c(paste(seq(-50,-5,by=5),"kb"),
                                                  0,
                                                  paste(seq(5,50,by=5),"kb")))


p_h <- ggplot(APA_m, aes(x=variable,y=ID)) +
  geom_tile(aes(fill=value))+
  #设定热图梯度颜色
  scale_fill_gradient(low = "white", high = "red")+
  #去掉图例
  guides(fill = "none")+
  #去掉坐标轴刻度线
  theme(axis.ticks.y = element_blank())+
  theme(axis.ticks.x = element_blank())+
  #调整坐标轴刻度标签粗细
  theme(axis.text.y = element_text(color="black",size=12))+
  theme(axis.text.x = element_text(color="black",size=12))+
  #调整绘图边框粗细
  theme(panel.border = element_rect(fill=NA,color="black",size=1.2,linetype = 1))+
  #设定坐标轴标签间隔
  scale_x_discrete(breaks = c("-50 kb","0","50 kb"))+
  scale_y_discrete(breaks = c("-50 kb","0","50 kb"))+
  #设置坐标轴的相对比例
  coord_fixed(ratio = 1/1)+
  #去掉横坐标轴标题
  theme(axis.title.y = element_blank())+
  theme(axis.title.x = element_blank())+
  #添加自定义注释标签
  annotate(
    "text", label = paste0("APA score:",round(APA_measure[4,2],2)),
    x="0",y="45 kb",
    size = 5,
    vjust=-0.5
  )
  
ggsave("APA_h.pdf",p_h)

######

####### macaque #####

rm(list=ls())

APA <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/APA_m.txt",sep = ',')

APA_measure <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/output/macaque/5000/gw/measures.txt")

APA %<>% as.data.frame(.) 
  
colnames(APA) <- c(paste(seq(-50,-5,by=5),"kb"),
                    0,
                    paste(seq(5,50,by=5),"kb"))
  
rownames(APA) <- colnames(APA)

APA$ID <- rownames(APA)

APA_m <- melt(APA,id.vars = "ID")

APA_m$ID <- factor(APA_m$ID,levels= c(paste(seq(-50,-5,by=5),"kb"),
                                      0,
                                      paste(seq(5,50,by=5),"kb")))

APA_m$variable <- factor(APA_m$variable,levels= c(paste(seq(-50,-5,by=5),"kb"),
                                                  0,
                                                  paste(seq(5,50,by=5),"kb")))


p_m <- ggplot(APA_m, aes(x=variable,y=ID)) +
  geom_tile(aes(fill=value))+
  #设定热图梯度颜色
  scale_fill_gradient(low = "white", high = "red")+
  #去掉图例
  guides(fill = "none")+
  #去掉坐标轴刻度线
  theme(axis.ticks.y = element_blank())+
  theme(axis.ticks.x = element_blank())+
  #调整坐标轴刻度标签粗细
  theme(axis.text.y = element_text(color="black",size=12))+
  theme(axis.text.x = element_text(color="black",size=12))+
  #调整绘图边框粗细
  theme(panel.border = element_rect(fill=NA,color="black",size=1.2,linetype = 1))+
  #设定坐标轴标签间隔
  scale_x_discrete(breaks = c("-50 kb","0","50 kb"))+
  scale_y_discrete(breaks = c("-50 kb","0","50 kb"))+
  #设置坐标轴的相对比例
  coord_fixed(ratio = 1/1)+
  #去掉横坐标轴标题
  theme(axis.title.y = element_blank())+
  theme(axis.title.x = element_blank())+
  #添加自定义注释标签
  annotate(
    "text", label = paste0("APA score:",round(APA_measure[4,2],2)),
    x="0",y="45 kb",
    size = 5,
    vjust=-0.5
  )
  
ggsave("APA_m.pdf",p_m)

######