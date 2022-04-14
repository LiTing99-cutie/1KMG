################################################
#File Name: run_0827.sh
#Author: LiTing
#Mail: liting@stu.pku.edu.cn
#Created Time: Fri 27 Aug 2021 03:20:29 PM CST
################################################

#!/bin/sh 

### 2.hic-pro

# prepare
mkdir tmp
mkdir -p data/CP
mkdir -p data/GZ

for i in 1 2 3;do
    for j in 1 2;do 
        for z in CP GZ;do
ln -s /home/user/data2/lit/project/h_fetal_hic_map/fastq/"$z"_"$i"/"$z"_"$i"_"$j".fastq.gz data/"$z"/"$z"_"$i"_R"$j".fastq.gz
        done
    done
done

config=/home/user/data2/lit/project/HiC/config-hicpro.hg38_comChr_20210827.txt

nohup HiC-Pro -i ./data  -o hicpro_output  -c $config  &> log/HiC-Pro.log &

### 2.split

fileSplitter=/home/user/data2/lit/software/file_splitter.gzip.pl
chmod 755 $fileSplitter

# test
mkdir test
nohup perl $fileSplitter -f ./data/CP/CP_1_R1.fastq.gz  -l 50000000 -o ./test &

# split
mkdir -p splitFq
ls fastq | while read sample
do 
    for i in 1 2
    do
    nohup perl $fileSplitter -f ./fastq/"$sample"/"$sample"_"${i}".fastq.gz  -l 50000000 -o ./splitFq &>"$sample".log &
    done
done

#log部分可以改进，结束后删除

### 3.hic-pro

## 3.1 test
config=/home/user/data2/lit/project/HiC/config-hicpro.hg38_comChr_20210827.txt

rm -rf test/*

mkdir test/sample
mkdir mapping_results

ln -s `pwd`/splitFq/CP_1_1.fastq.1 test/sample/CP_1.fastq
ln -s `pwd`/splitFq/CP_1_2.fastq.1 test/sample/CP_2.fastq

HiC-Pro -i ./test -o mapping_results  -c $config  -s mapping &> log/HiC-Pro.log &

HiC-Pro -i ./test -o mapping_results_1  -c $config  -s mapping -s quality_checks &> log/HiC-Pro_1.log &

HiC-Pro -i ./mapping_results/bowtie_results/bwt2 -o qc_results  -c $config  -s quality_checks &> log/HiC-Pro_2.log &

HiC-Pro -i ./mapping_results/bowtie_results/bwt2 -o qc_proc_results  -c $config  -s proc_hic -s quality_checks &> log/HiC-Pro_3.log &

HiC-Pro -i ./mapping_results/bowtie_results/bwt2 -o proc_merge_results  -c $config  -s proc_hic -s merge_persample &> log/HiC-Pro_4.log &

# 3.2 run 

# 3.2.1 prepare split files
splitFqDir=/home/user/data2/lit/project/h_fetal_hic_map/splitFq
ls fastq | \
# head -n1 | \
while read sample 
do
    for i in `seq 1 "$(ls splitFq/"$sample"_1.fastq.* | wc -l)"`
    do   
    #mkdir 
    [ -d "$sample"/splitFq${i}/sample ] || mkdir -p "$sample"/splitFq${i}/sample
    #softlinks
    [ -f ./"$sample"/splitFq${i}/sample/splitFq${i}_1.fastq ] && rm -f ./"$sample"/splitFq${i}/sample/splitFq${i}_1.fastq 
    ln -s $splitFqDir/"$sample"_1.fastq.${i} ./"$sample"/splitFq${i}/sample/splitFq${i}_1.fastq
    [ -f ./"$sample"/splitFq${i}/sample/splitFq${i}_2.fastq ] && rm -f ./"$sample"/splitFq${i}/sample/splitFq${i}_2.fastq 
    ln -s $splitFqDir/"$sample"_2.fastq.${i} ./"$sample"/splitFq${i}/sample/splitFq${i}_2.fastq
    done
    wait
done

echo "softlinks are ready"

## 3.2.2 mapping
config=/home/user/data2/lit/project/HiC/config-hicpro.hg38_comChr_20210827.txt
ls fastq | \
# head -n1 | \
while read sample 
do
    for i in `seq 1 "$(ls splitFq/"$sample"_1.fastq.* | wc -l)"`
    # for i in 1
    do   
    data=./"$sample"/splitFq${i}/
    outDir=./hicpro/"$sample"/splitFq${i}/
    HiC-Pro -s mapping -i "$data"  -o "$outDir" -c "$config" &>log/HiC-Pro_"$sample"_mapping.${i}.log &
    done
    wait
done

echo "files are mapped"

## 3.2.3 merge split bam files

[ -f CP_1_splitFqBam_tag1.lst ] && rm -f CP_1_splitFqBam_tag1.lst
[ -f CP_1_splitFqBam_tag2.lst ] && rm -f CP_1_splitFqBam_tag2.lst

ls fastq | \
# head -n1 | \
while read sample 
do
    for i in `seq 1 "$(ls splitFq/"$sample"_1.fastq.* | wc -l)"`
    # for i in 1
    do 
    echo `pwd`/hicpro/"$sample"/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_1_hg38.bwt2merged.bam >> "$sample"_splitFqBam_tag1.lst
    echo `pwd`/hicpro/"$sample"/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_2_hg38.bwt2merged.bam >> "$sample"_splitFqBam_tag2.lst
    done
    wait
done
echo "splitbam list are ready"

# samtools merge
ls fastq | \
# head -n1 | \
while read sample 
do
echo -e "`date` **** samtools merge for $sample"
for i in 1 2;do
  echo -e "`date` **** samtools merge for tag${i}"
  samtools merge -b "$sample"_splitFqBam_tag${i}.lst -n -f -@ 15 "$sample"_merged_${i}_hg38.bwt2merged.bam &>log/"$sample"_mergeBam_tag${i}.log  & 
done
wait
done

echo "bams are merged"

# samtools sort
ls fastq | \
# head -n1 | \
while read sample
do
echo -e "`date` **** samtools sort for $sample"
for i in 1 2;do
  echo -e "`date` **** samtools sort for tag${i}"
  mkdir -p Tmp/sort_tag${i}
  samtools sort -n -@ 15 -T Tmp/sort_tag${i} -o "$sample"_merged_${i}_hg38.bwt2merged.sorted.bam  "$sample"_merged_${i}_hg38.bwt2merged.bam &>log/"$sample"_sortBam_tag${i}.log &
done 
wait
done
echo "bams are sorted"

rm -fr Tmp/

## 3.2.4 construct dir
[ -d bowtie_results/bwt2/CP ] || mkdir -p bowtie_results/bwt2/CP
[ -d bowtie_results/bwt2/GZ ] || mkdir -p bowtie_results/bwt2/GZ
[ -d bowtie_results/bwt2/CP ] && rm -rf bowtie_results/bwt2/CP/*
[ -d bowtie_results/bwt2/GZ ] && rm -rf bowtie_results/bwt2/GZ/*

for i in CP GZ
# for i in CP
do
mv "$i"*sorted.bam bowtie_results/bwt2/"$i"/
done

#change file name 
for i in CP GZ
# for i in CP
do
for j in 1 2 3
# for j in 1
do
mv bowtie_results/bwt2/"$i"/"$i"_"$j"_merged_1_hg38.bwt2merged.sorted.bam bowtie_results/bwt2/"$i"/"$i""$j"_1_hg38.bwt2merged.bam
mv bowtie_results/bwt2/"$i"/"$i"_"$j"_merged_2_hg38.bwt2merged.sorted.bam bowtie_results/bwt2/"$i"/"$i""$j"_2_hg38.bwt2merged.bam
done
done

## 3.2.5 run the rest steps of hic-pro
config=/home/user/data2/lit/project/HiC/config-hicpro.hg38_comChr_20210827.txt
[ -d hic_pro_in_all ] && rm -rf hic_pro_in_all/*
HiC-Pro -i ./bowtie_results/bwt2 -o hic_pro_in_all  -c $config  -s proc_hic -s merge_persample  -s build_contact_maps \
-s ice_norm -s quality_checks &> log/HiC-Pro_fetal_brain.log &
wait
echo "all is done"

# nohup bash ./run_0827.sh &> hicpro_fetal_brain.log &
# less hicpro_fetal_brain.log
# less $(ls -t log/* | head -n 5) 

# 3.2.6 remove 
for i in CP GZ
do
for j in 1 2 3
do
rm -rf "$i"_"$j"
# echo "$i"_"$j"
done
done

rm -f *bam # remove merged bams
rm -f *lst # remove bam listsqq

rm -rf hicpro # rm splitFq mapping results

# rm test results
rm -rf mapping* 
rm -rf *results # oops, remove bowtie_results also

### 4.visualization

nohup /home/user/data2/uplee/tools/HiC-Pro-3.1.0/HiC-Pro_3.1.0/bin/utils/hicpro2juicebox.sh -i ./hic_pro_in_all/hic_results/data/GZ/GZ.allValidPairs \
-g hg38 -j /home/user/data2/lit/software/juicer_tools_1.22.01.jar &> log/allValidPairs_to_hic_GZ.log &

nohup /home/user/data2/uplee/tools/HiC-Pro-3.1.0/HiC-Pro_3.1.0/bin/utils/hicpro2juicebox.sh -i ./hic_pro_in_all/hic_results/data/CP/CP.allValidPairs \
-g hg38 -j /home/user/data2/lit/software/juicer_tools_1.22.01.jar &> log/allValidPairs_to_hic_CP.log &