################################################
#File Name: run_0830.sh
#Author: LiTing
#Mail: liting@stu.pku.edu.cn
#Created Time: Mon 30 Aug 2021 11:12:11 AM CST
################################################

#!/bin/sh 

# due to occupied disk, part of the run_0827 didn't work 
# here we redo this part of work

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

## 3.2.3 construct dir
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

## 3.2.4 run the rest steps of hic-pro
config=/home/user/data2/lit/project/HiC/config-hicpro.hg38_comChr_20210827.txt
[ -d hic_pro_in_all ] && rm -rf hic_pro_in_all/*
HiC-Pro -i ./bowtie_results/bwt2 -o hic_pro_in_all  -c $config  -s proc_hic -s merge_persample  -s build_contact_maps \
-s ice_norm -s quality_checks &> log/HiC-Pro_fetal_brain.log &
wait
echo "all is done"

# nohup bash ./run_0830.sh &> hicpro_fetal_brain_rerun.log &