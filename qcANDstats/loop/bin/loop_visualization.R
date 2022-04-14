setwd("/home/user/data2/lit/project/1KMG/qcANDstats/loop/")
rm(list=ls())

library(tidyverse)

loop_target <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/loop/loop_target.txt")

loop_target_add <- data.frame(V1=loop_target$V2,V2=loop_target$V1,V3=loop_target$V3)

rbind(loop_target,loop_target_add) %>% distinct(.) -> loop_target_all


ggplot(loop_target_all, aes(x=V1,y=V2)) +
  geom_tile(aes(fill=log2(V3)))+
  #设定热图梯度颜色
  scale_fill_gradient2(low = "white", high = "red",midpoint = 1)


loop_KR <- read.table("./test_5Kb.txt")

loop_KR_add <- data.frame(V1=loop_KR$V2,V2=loop_KR$V1,V3=loop_KR$V3)

rbind(loop_KR,loop_KR_add) %>% distinct(.) -> loop_KR_all

loop_KR_all$V1 <- factor(loop_KR_all$V1,levels= seq(134050000,134550000,by=5000))

loop_KR_all$V2 <- factor(loop_KR_all$V2,levels= seq(134550000,134050000,by=-5000))


# 134050000
# 
# 134550000

p_KR <- ggplot(loop_KR_all, aes(x=V1,y=V2)) +
  geom_tile(aes(fill=log2(V3)))+
  #设定热图梯度颜色
  scale_fill_gradient2(low = "white", high = "red",midpoint = 0)+
  #去掉图例
  guides(fill = "none")+
  #去掉坐标轴刻度线
  theme(axis.ticks.y = element_blank())+
  theme(axis.ticks.x = element_blank())+
  #去掉坐标轴标题
  theme(axis.title.y = element_blank())+
  theme(axis.title.x = element_blank())+
  theme(axis.text.y = element_blank())+
  theme(axis.text.x = element_blank())+
  #设置坐标轴的相对比例
  coord_fixed(ratio = 1/1)+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(panel.background = element_blank())+
  annotate("rect", xmin = factor(134400000), xmax = factor(134425000), ymin = factor(134125000) , ymax = factor(134100000)  ,color='#000000',
           alpha = 0,linetype=6)+
  annotate("rect", xmin = factor(134225000), xmax = factor(134250000), ymin = factor(134125000) , ymax = factor(134100000) ,color='#000000',
           alpha = 0,linetype=6)+
  annotate("rect", xmin = factor(134100000), xmax = factor(134125000), ymin = factor(134250000) , ymax = factor(134225000),color='#000000',
           alpha = 0,linetype=6)+
  annotate("rect", xmin = factor(134100000), xmax = factor(134125000), ymin = factor(134425000), ymax = factor(134400000),color='#000000',
           alpha = 0,linetype=6)
 

ggsave(p_KR,file="loop_KR.pdf")

# 285228 285232

# 285253 285257

# 285288 285292

# 134100000 134125000

# 134400000 134425000

# 134225000 134250000
