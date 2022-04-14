################################################
#File Name: run_1124.sh
#Author: LiTing
#Mail: liting@stu.pku.edu.cn
#Created Time: Wed 24 Nov 2021 11:10:16 AM CST
################################################

#!/bin/sh 

# due to misoperation, this mission will be re-executed
# now we still have split-fastq file
# this script referred to run_0827.sh written 3 months ago

# 3.2 run 
# 3.2.1 prepare split files
splitFqDir=/home/user/data/lit/h_fetal_hic_map/splitFq
ls /home/user/data/lit/h_fetal_hic_map/fastq | \
# head -n1 | \
while read sample 
do
    for i in `seq 1 "$(ls $splitFqDir/"$sample"_1.fastq.* | wc -l)"`
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
mkdir log
config=./config-hicpro.hg38_comChr_20211124.txt
ls /home/user/data/lit/h_fetal_hic_map/fastq | \
# head -n1 | \
while read sample 
do
    for i in `seq 1 "$(ls $splitFqDir/"$sample"_1.fastq.* | wc -l)"`
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

ls /home/user/data/lit/h_fetal_hic_map/fastq | \
# head -n1 | \
while read sample 
do
    for i in `seq 1 "$(ls $splitFqDir/"$sample"_1.fastq.* | wc -l)"`
    # for i in 1
    do 
    echo `pwd`/hicpro/"$sample"/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_1_hg38.bwt2merged.bam >> "$sample"_splitFqBam_tag1.lst
    echo `pwd`/hicpro/"$sample"/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_2_hg38.bwt2merged.bam >> "$sample"_splitFqBam_tag2.lst
    done
    wait
done
echo "splitbam list are ready"

# samtools merge
ls /home/user/data/lit/h_fetal_hic_map/fastq | \
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
ls /home/user/data/lit/h_fetal_hic_map/fastq | \
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
# [ -d bowtie_results/bwt2/CP ] && rm -rf bowtie_results/bwt2/CP/*
# [ -d bowtie_results/bwt2/GZ ] && rm -rf bowtie_results/bwt2/GZ/*

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

# [ -d hic_pro_in_all ] && rm -rf hic_pro_in_all/*  
# if you write this, your result files are easily get removed!
HiC-Pro -i ./bowtie_results/bwt2 -o hic_pro_in_all  -c $config  -s proc_hic -s merge_persample  -s build_contact_maps \
-s ice_norm -s quality_checks &> log/HiC-Pro_fetal_brain.log &
wait
echo "all is done"

# nohup bash ./run_1124.sh &> hicpro_fetal_brain.log &
# less hicpro_fetal_brain.log
# less $(ls -t log/* | head -n 5) 

### 4.visualization

nohup /home/user/data2/uplee/tools/HiC-Pro-3.1.0/HiC-Pro_3.1.0/bin/utils/hicpro2juicebox.sh -i ./hic_pro_in_all/hic_results/data/GZ/GZ.allValidPairs \
-g hg38 -j /home/user/data2/lit/software/juicer_tools_1.22.01.jar &> log/allValidPairs_to_hic_GZ.log &

nohup /home/user/data2/uplee/tools/HiC-Pro-3.1.0/HiC-Pro_3.1.0/bin/utils/hicpro2juicebox.sh -i ./hic_pro_in_all/hic_results/data/CP/CP.allValidPairs \
-g hg38 -j /home/user/data2/lit/software/juicer_tools_1.22.01.jar &> log/allValidPairs_to_hic_CP.log &

echo ".hic file is ready"


## move result files to other places
data_dir=/home/user/data/lit/project/1KMG/h_fetal_hic_map

nohup cp -r --parents ./hic_pro_in_all/bowtie_results/bwt2/CP/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/bowtie_results/bwt2/GZ/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/data/CP/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/matrix/CP/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/pic/CP/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/stats/CP/ $data_dir &

nohup cp ./CP.allValidPairs.hic $data_dir &

rm -rf hic_pro_in_all

nohup cp -r --parents ./hic_pro_in_all/hic_results/data/GZ/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/matrix/GZ/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/pic/GZ/ $data_dir &

nohup cp -r --parents ./hic_pro_in_all/hic_results/stats/GZ/ $data_dir &

rm -rf hic_pro_in_all

## remove 

ls *.bam | less
rm -rf *.bam

ls *.lst | less
rm -rf *.lst

ls  CP* GZ* | less
rm -rf  CP* GZ*

# 
nohup HiC-Pro -i ./bowtie_results/bwt2/ -o ./hic_pro_in_all  \
-c $config  -s proc_hic -s merge_persample  -s build_contact_maps \
-s ice_norm -s quality_checks &> ./log/HiC-Pro_fetal_brain.log &

