#!/bin/bash
export PATH=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/bin:$PATH
#### 2020-10-10 ####
#/rd1/user/lixs/Projects/1KMG/HiC/data/human_PFC/splitFq/human_PFC_1_clean.fq.1.gz
splitFqDir=/rd1/user/lixs/Projects/1KMG/HiC/data/human_PFC/splitFq

## 1 Preparation
<<!
for i in `seq 1 159`;do 
  ## Data
  mkdir -p data/splitFq${i}/sample
  [ -f ./data/splitFq${i}/sample/splitFq${i}_1.fastq.gz ] && rm -f ./data/splitFq${i}/sample/splitFq${i}_1.fastq.gz
  ln -s $splitFqDir/human_PFC_1_clean.fq.${i}.gz ./data/splitFq${i}/sample/splitFq${i}_1.fastq.gz
  [ -f ./data/splitFq${i}/sample/splitFq${i}_2.fastq.gz ] && rm -f ./data/splitFq${i}/sample/splitFq${i}_2.fastq.gz
  ln -s $splitFqDir/human_PFC_2_clean.fq.${i}.gz ./data/splitFq${i}/sample/splitFq${i}_2.fastq.gz

  ## Output
  mkdir -p hicpro/splitFq${i}

  ## Log
  mkdir -p log/
done
!
## 2 Create jobList
<<!
[ -f HiC-Pro_mapping.jobLst ] && rm -f HiC-Pro_mapping.jobLst
for i in `seq 1 159`;do
  data=./data/splitFq${i}/
  outDir=./hicpro/splitFq${i}
  echo -e "time (HiC-Pro -s mapping -i $data  -o $outDir -c config-hicpro.20201010.txt)  1>log/HiC-Pro_mapping.${i}.log 2>&1" >> HiC-Pro_mapping.jobLst
done
!
## 3 Run HiC-Pro mapping step

## 4 Run HiC-Pro following steps
<<!
# 4.1 Merge split bam files
mkdir -p hicpro/merged/bowtie_results/bwt2/human_PFC
# create bam list
[ -f splitFqBam_tag1.lst  ] &&  rm -f splitFqBam_tag1.lst 
[ -f splitFqBam_tag2.lst  ] &&  rm -f splitFqBam_tag2.lst
for i in `seq 1 159`;do
  echo `pwd`/hicpro/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_1_hg19.bwt2merged.bam >> splitFqBam_tag1.lst 
  echo `pwd`/hicpro/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_2_hg19.bwt2merged.bam >> splitFqBam_tag2.lst
done
# remove split bam files
bamDir=/rd1/user/lixs/Projects/1KMG/HiC/human_PFC/hg19_comChr/HiC-Pro/hicpro
for i in `seq 1 159`;do
  
  # bwt2
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_1_hg19.bwt2merged.bam
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2/sample/splitFq${i}_2_hg19.bwt2merged.bam
  
  # bwt2_global
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_global/sample/splitFq${i}_1_hg19.bwt2glob.bam
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_global/sample/splitFq${i}_2_hg19.bwt2glob.bam
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_global/sample/splitFq${i}_1_hg19.bwt2glob.unmap.fastq
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_global/sample/splitFq${i}_2_hg19.bwt2glob.unmap.fastq

  # bwt2_local
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_local/sample/splitFq${i}_1_hg19.bwt2glob.unmap_bwt2loc.bam
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_local/sample/splitFq${i}_1_hg19.bwt2glob.unmap_trimmed.fastq

  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_local/sample/splitFq${i}_2_hg19.bwt2glob.unmap_bwt2loc.bam
  rm -f $bamDir/splitFq${i}/bowtie_results/bwt2_local/sample/splitFq${i}_2_hg19.bwt2glob.unmap_trimmed.fastq
done


# samtools merge
echo -e "`date` **** samtools merge"
for i in 1 2;do
  echo -e "`date` **** samtools merge for tag${i}"
  time (samtools merge -b splitFqBam_tag${i}.lst -n -f -@ 15 hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg19.bwt2merged.bam) 1>log/mergeBam_tag${i}.log 2>&1 & 
done
wait

# samtools sort
echo -e "`date` **** samtools sort"
for i in 1 2;do
  echo -e "`date` **** samtools sort for tag${i}"
  mkdir -p Tmp/sort_tag${i}
  time (samtools sort -n -@ 15 -T Tmp/sort_tag${i} -o hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg19.bwt2merged.sorted.bam  hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg19.bwt2merged.bam) 1>log/sortBam_tag${i}.log 2>&1 
done 
wait
rm -fr Tmp/

# overwrite original bam by sorted bam (DEPRECATED, 20201028)
echo -e "`date` **** overwrite"
for i in 1 2;do
  echo -e "`date` **** overwrite for tag${i}"
  mv -f hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg19.bwt2merged.sorted.bam hicpro/merged/bowtie_results/bwt2/human_PFC/merged_${i}_hg19.bwt2merged.bam
done
!

# 4.2 Run HiC-Pro following steps
config=config-hicpro.20201010.txt
<<!
time (HiC-Pro  -s proc_hic -i ./hicpro/merged/bowtie_results/bwt2/  -o ./hicpro/merged -c $config)  1>log/HiC-Pro_proc_hic.log 2>&1

pushd hicpro/merged/
python /rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/scripts/mapped_2hic_fragments.py -v -a -f /rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/hg19_comChr_mboi.bed -r bowtie_results/bwt2/human_PFC/merged_hg19.bwt2pairs.bam -o hic_results/data/human_PFC 1>logs/human_PFC/mapped_2hic_fragments.log 2>&1
sort -T tmp -k2,2V -k3,3n -k5,5V -k6,6n -o hic_results/data/human_PFC/merged_hg19.bwt2pairs.validPairs hic_results/data/human_PFC/merged_hg19.bwt2pairs.validPairs
popd
!

time (HiC-Pro  -s merge_persample -i  ./hicpro/merged/hic_results/data/ -o ./hicpro/merged -c $config)  1>log/HiC-Pro_merge_persample.log 2>&1

time (HiC-Pro  -s quality_checks -i ./hicpro/merged/bowtie_results/bwt2/  -o  ./hicpro/merged  -c $config)  1>log/HiC-Pro_quality_checks.log 2>&1

time (HiC-Pro  -s build_contact_maps -i ./hicpro/merged/hic_results/data/ -o ./hicpro/merged  -c $config)  1>log/HiC-Pro_builld_contact_maps.log 2>&1

time (HiC-Pro  -s ice_norm -i ./hicpro/merged/hic_results/matrix -o ./hicpro/merged  -c $config)  1>log/HiC-Pro_ice_norm.log 2>&1
#### EO 2020-10-10 ####
