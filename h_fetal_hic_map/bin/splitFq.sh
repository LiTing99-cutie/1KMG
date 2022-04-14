################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Wed Oct  7 10:09:29 2020
################################################

#!/bin/sh 
#### 2020-10-07 ####
fileSplitter=/rd1/brick/lixs/Bin/PerlScript/file_splitter.gzip.pl

## 1 Split fastq

# 1.1 decompress 
ln -s NB_0508_1_clean.fq.gz human_PFC_1_clean.fq.gz 
ln -s NB_0508_2_clean.fq.gz human_PFC_2_clean.fq.gz  

# 1.2 split 
<<!
mkdir -p splitFq
for i in 1 2;do
  perl $fileSplitter -f ./human_PFC_${i}_clean.fq.gz  -l 50000000 -o ./splitFq &
done
wait
!
#### EO 2020-10-07 ####

#### 2020-10-12 ####
## Release space
for i in `seq 1 100`;do
 rm -f splitFq/human_PFC_1_clean.fq.$i.gz
 rm -f splitFq/human_PFC_2_clean.fq.$i.gz
done
#### EO 2020-10-12 ####q

#### 2021-08-06 ####
## Move human PFC HiC data to upleeDisk1
# See @NanjingServer:/media/uplee/upleeDisk1/dataset/inhouse/HiC/human_PFC/*
#### EO 2021-08-06 ####

