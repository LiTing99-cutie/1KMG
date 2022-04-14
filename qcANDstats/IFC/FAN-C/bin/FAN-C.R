
setwd("/home/user/data2/lit/project/1KMG/qcANDstats/IFC/FAN-C/")
rm(list=ls())

IFC_h <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/IFC/FAN-C/IFC.h.txt",header = TRUE)
IFC_m <- read.table("/home/user/data2/lit/project/1KMG/qcANDstats/IFC/FAN-C/IFC.m.txt",header = TRUE)

p_h <- ggplot(data=IFC_h,mapping = aes(x=distance,y=Human))+
  geom_line(color="#00BFC4")+
  coord_fixed(ratio = 1/1)+
  scale_x_log10(breaks=10^(5:8),labels=log10(10^(5:8)))+
  scale_y_log10(breaks=10^(0:3),labels=log10(10^(0:3)))+
  theme_set(theme_bw())+
  annotation_logticks()+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"))+
  labs(y = "Expected contact stength",x='Genomic distance')

ggsave("IFC_h.pdf",p_h)


p_m <- ggplot(data=IFC_m,mapping = aes(x=distance,y=Rhesus_Macaque))+
  geom_line(color="#00BFC4")+
  coord_fixed(ratio = 1/1)+
  scale_x_log10(breaks=10^(5:8),labels=log10(10^(5:8)))+
  scale_y_log10(breaks=10^(-1:2),labels=log10(10^(-1:2)))+
  theme_set(theme_bw())+
  annotation_logticks()+
  theme(panel.grid.major=element_blank())+
  theme(panel.grid.minor = element_blank())+
  theme(panel.border = element_blank())+
  theme(axis.line.y = element_line(color="black", size = 0.5),
        axis.line.x = element_line(color="black", size = 0.5),
        axis.text.y = element_text(color="black"),
        axis.text.x = element_text(color="black"))+
  labs(y = "Expected contact stength",x='Genomic distance')

ggsave("IFC_m.pdf",p_m)