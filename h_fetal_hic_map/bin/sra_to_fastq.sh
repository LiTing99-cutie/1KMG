#!/bin/bash

### 1. sra to fastq
# create new dirs
mkdir rawdata
mkdir fastq
mkdir log

# dir which saves the data
data_dir=/home/user/data/uplee/data/dataset/database/dbGaP/2018-cell-humanFetalCortexHiC_and_ATACseq_and_RNA-seq/phs001190/sra

# create soft links
cd /rawdata || echo "fail when change directory"
ln -s ${data_dir}/SRR2970466_dbGaP-28727.sra CP_1
ln -s ${data_dir}/SRR2970467_dbGaP-28727.sra CP_2
ln -s ${data_dir}/SRR2970468_dbGaP-28727.sra CP_3

ln -s ${data_dir}/SRR2973607_dbGaP-28727.sra GZ_1
ln -s ${data_dir}/SRR2973608_dbGaP-28727.sra GZ_2
ln -s ${data_dir}/SRR2973609_dbGaP-28727.sra GZ_3

# fastq-dump
cd ..
ls rawdata/ | while read file; do 
   nohup fastq-dump --split-3 --gzip --ngc /home/user/data2/lit/software/sratoolkit.2.11.1-centos_linux64/prj_28727.ngc -O ./fastq/"$file" ./rawdata/"$file" &>./log/fastq-dump."$file".log &
done

