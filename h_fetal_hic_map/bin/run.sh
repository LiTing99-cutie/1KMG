#!/bin/bash
#SBATCH -J fastqDump_suBingHiC
#SBATCH -p q_c
#SBATCH -N 1
#SBATCH -o log/fastqDump_suBingHiC.log
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mem-per-cpu=10G

module load sratoolkit/2.9.6
--
module load dSQ
module load HiCPro/2.11.1
# This script pre-process of SuBing's macaque fetal brain Hi-C (CP/GZ zones),
# mainly performing HiC-Pro analysis.# The final most useful output was 
# something like CP.allValidPairs & GZ.allValidPairs.

################################
### Run HiC-Pro mapping step ###
################################

### 1. Preparation

splitFqDir=/home/zhangli_lab/dingwanqiu/DATA/uplee/1KMG/HiC/data/macaque_fetal_brain/rawData/fastq/splitFq

## 1.1 Directory hierarchy
for i in 1 2 3;do
  for z in CP GZ;do

    num=$( ls $splitFqDir/RM0${i}_${z}_HiC_*.fastq.* | while read f; do echo "${f##*.}";done | sort -k1,1nr | head -n1 )
    for c in `seq 1 $num`;do
      dataDir=data/RM0${i}_${z}_splitFq${c}/sample
      mkdir -p $dataDir
      # *_1.fastq
      [ -f $dataDir/RM0${i}_${z}_splitFq${c}_1.fastq ] && rm -f $dataDir/RM0${i}_${z}_splitFq${c}_1.fastq
      ln -s $splitFqDir/RM0${i}_${z}_HiC_1.fastq.${c}  $dataDir/RM0${i}_${z}_splitFq${c}_1.fastq
      # *_2.fastq
      [ -f $dataDir/RM0${i}_${z}_splitFq${c}_2.fastq ] && rm -f $dataDir/RM0${i}_${z}_splitFq${c}_2.fastq      
      ln -s $splitFqDir/RM0${i}_${z}_HiC_2.fastq.${c}  $dataDir/RM0${i}_${z}_splitFq${c}_2.fastq
      ## Output
      mkdir -p hicpro/RM0${i}_${z}_splitFq${c}

    done
  done
done

## 1.2 Log
mkdir -p log/

## 3 Run HiC-Pro 
# 3.1 Mapping

# Create jobList
[ -f HiC-Pro_mapping.jobLst ] && rm -f HiC-Pro_mapping.jobLst
for i in 1 2 3;do
  for z in CP GZ;do
    num=$( ls $splitFqDir/RM0${i}_${z}_HiC_*.fastq.* | while read f; do echo "${f##*.}";done | sort -k1,1nr | head -n1 )
    for c in `seq 1 $num`;do
      data=./data/RM0${i}_${z}_splitFq${c}/
      outDir=./hicpro/RM0${i}_${z}_splitFq${c}
      echo -e "time (HiC-Pro -s mapping -i $data  -o $outDir -c config-hicpro.txt)  1>log/HiC-Pro_mapping.RM0${i}_${z}_splitFq${c}.log 2>&1" >> HiC-Pro_mapping.jobLst
    done
  done
done


# Mapping step
module load dSQ
dsq --job-file  HiC-Pro_mapping.jobLst  -p q_cn -n 3 --mem-per-cpu 5g
sbatch dsq-HiC-Pro_mapping-2021-03-19.sh
#Submitted batch job 41312921
mv job_10006013_status.tsv  dsqOut/ 

sbatch RM02_CP_splitFq15.hicproMapping.sh
Submitted batch job 41313871

# 3.2 proc_hic

# Create jobList
#[ -f HiC-Pro_prochic.jobLst ] && rm -f HiC-Pro_prochic.jobLst
for i in 1 2 3;do
  for z in CP GZ;do
    num=$( ls $splitFqDir/RM0${i}_${z}_HiC_*.fastq.* | while read f; do echo "${f##*.}";done | sort -k1,1nr | head -n1 )
    for c in `seq 1 $num`;do
      data=./hicpro/RM0${i}_${z}_splitFq${c}/bowtie_results/bwt2/
      outDir=./hicpro/RM0${i}_${z}_splitFq${c}/
      echo -e "time (HiC-Pro  -s proc_hic -i $data  -o $outDir -c config-hicpro.txt) 1>log/HiC-Pro_prochic.RM0${i}_${z}_splitFq${c}.log 2>&1" >> HiC-Pro_prochic.jobLst
    done
  done
done

# proc_hic
module load dSQ
dsq --job-file  HiC-Pro_prochic.jobLst  -p q_cn -n 1 --mem-per-cpu 5g
sbatch dsq-HiC-Pro_prochic-2021-03-17.sh

# 3.3 quality_checks

# Create jobList
#[ -f HiC-Pro_qualityChecks.jobLst ] && rm -f HiC-Pro_qualityChecks.jobLst
for i in 1 2 3;do
  for z in CP GZ;do
    num=$( ls $splitFqDir/RM0${i}_${z}_HiC_*.fastq.* | while read f; do echo "${f##*.}";done | sort -k1,1nr | head -n1 )
    for c in `seq 1 $num`;do
      data=./hicpro/RM0${i}_${z}_splitFq${c}/bowtie_results/bwt2/
      outDir=./hicpro/RM0${i}_${z}_splitFq${c}/
      echo -e "time (HiC-Pro  -s quality_checks -i $data  -o  $outDir  -c config-hicpro.txt)  1>log/HiC-Pro_qualityChecks.RM0${i}_${z}_splitFq${c}.log 2>&1" >> HiC-Pro_qualityChecks.jobLst
    done
  done
done

# quality_checks 
module load dSQ
dsq --job-file HiC-Pro_qualityChecks.jobLst  -p q_cn -n 10 --mem-per-cpu 10g
sbatch dsq-HiC-Pro_qualityChecks-2021-03-17.sh  

# 3.4 merge_persample (by rhesus individuals)

mkdir -p hicpro/CP/hic_results/data/RM01_CP hicpro/CP/hic_results/data/RM02_CP hicpro/CP/hic_results/data/RM03_CP  hicpro/GZ/hic_results/data/RM01_GZ hicpro/GZ/hic_results/data/RM02_GZ hicpro/GZ/hic_results/data/RM03_GZ

splitFqDir=/home/zhangli_lab/dingwanqiu/DATA/uplee/1KMG/HiC/data/macaque_fetal_brain/rawData/fastq/splitFq
datadir=/home/zhangli_lab/dingwanqiu/DATA/uplee/1KMG/HiC/macaque_fetal_brain/r10p_comChr/HiC-Pro/hicpro

for i in 1 2 3;do
  for z in CP GZ;do
    num=$( ls $splitFqDir/RM0${i}_${z}_HiC_*.fastq.* | while read f; do echo "${f##*.}";done | sort -k1,1nr | head -n1 )
    for c in `seq 1 $num`;do
      ln -s $datadir/RM0${i}_${z}_splitFq${c}/hic_results/data/sample/RM0${i}_${z}_splitFq${c}_rheMac10Plus_comChr.bwt2pairs.* ./hicpro/${z}/hic_results/data/RM0${i}_${z}
    done
  done
done

module load HiCPro/2.11.1
module load dSQ 
echo -e "time (HiC-Pro  -s merge_persample -i  hicpro/CP/hic_results/data/ -o hicpro/CP  -c config-hicpro.txt)  1>log/HiC-Pro_merge_persample.CP.log 2>&1
time (HiC-Pro  -s merge_persample -i  hicpro/GZ/hic_results/data/ -o hicpro/GZ -c config-hicpro.txt)  1>log/HiC-Pro_merge_persample.GZ.log 2>&1" > HiC-Pro_merge_persample.jobLst
dsq --job-file HiC-Pro_merge_persample.jobLst  -p q_cn -n 17 --mem-per-cpu 10g
sbatch dsq-HiC-Pro_merge_persample-2021-03-17.sh


## 4 Run HiC-Pro following steps

# 4.1 Merge split bam files
mkdir -p hicpro/CP/bowtie_results/bwt2/fetalCP
mkdir -p hicpro/GZ/bowtie_results/bwt2/fetalGZ
# create bam list

 # CP
 [ -f splitFqBam_tag1.CP.lst  ] &&  rm -f splitFqBam_tag1.CP.lst 
 [ -f splitFqBam_tag2.CP.lst  ] &&  rm -f splitFqBam_tag2.CP.lst
for i in seq 1 159;do
  echo `pwd`/hicpro/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_1_hg38_comChr.bwt2merged.bam >> splitFqBam_tag1.lst 
  echo `pwd`/hicpro/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_2_hg38_comChr.bwt2merged.bam >> splitFqBam_tag2.lst
done
 # GZ
# samtools merge
echo -e "`date` **** samtools merge"
for i in 1 2;do
  echo -e "`date` **** samtools merge for tag${i}"
  time (samtools merge -b splitFqBam_tag${i}.lst -n -f -@ 15 hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg38_comChr.bwt2merged.bam) 1>log/mergeBam_tag${i}.log 2>&1 & 
done
wait

# samtools sort
echo -e "`date` **** samtools sort"
for i in 1 2;do
  echo -e "`date` **** samtools sort for tag${i}"
  mkdir -p Tmp/sort_tag${i}
  time (samtools sort -n -@ 15 -T Tmp/sort_tag${i} -o hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg38_comChr.bwt2merged.sorted.bam  hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg38_comChr.bwt2merged.bam) 1>log/sortBam_tag${i}.log 2>&1 & 
done 
wait
rm -fr Tmp/

# overwrite original bam by sorted bam
echo -e "`date` **** overwrite"
for i in 1 2;do
  echo -e "`date` **** overwrite for tag${i}"
  mv -f hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg38_comChr.bwt2merged.sorted.bam hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg38_comChr.bwt2merged.bam
done

# 4.2 Run HiC-Pro following steps
config=config-hicpro.20200629.txt
#time (HiC-Pro  -s proc_hic -i ./hicpro/merged/bowtie_results/bwt2/  -o ./hicpro/merged -c $config)  1>log/HiC-Pro_proc_hic.log 2>&1

time (HiC-Pro  -s merge_persample -i  ./hicpro/merged/hic_results/data/ -o ./hicpro/merged -c $config)  1>log/HiC-Pro_merge_persample.log 2>&1

time (HiC-Pro  -s quality_checks -i ./hicpro/merged/bowtie_results/bwt2/  -o  ./hicpro/merged  -c $config)  1>log/HiC-Pro_quality_checks.log 2>&1

time (HiC-Pro  -s build_contact_maps -i ./hicpro/merged/hic_results/data/ -o ./hicpro/merged  -c $config)  1>log/HiC-Pro_builld_contact_maps.log 2>&1

time (HiC-Pro  -s ice_norm -i ./hicpro/merged/hic_results/matrix -o ./hicpro/merged  -c $config)  1>log/HiC-Pro_ice_norm.log 2>&1
#### EO 2020-06-28 ####

