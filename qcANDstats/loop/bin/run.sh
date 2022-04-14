################################################
#File Name: run.sh
#Author: LiTing
#Mail: liting@stu.pku.edu.cn
#Created Time: Wed 01 Dec 2021 01:42:35 PM CST
################################################

#!/bin/sh 

# 1. APA plot

# juicer_tools of this version cannot work, should correspond to juicer_tools used in previous steps
# juicer_tools=/home/user/data2/lit/software/juicer_tools_1.22.01.jar

juicer_tools=/home/user/data2/lit/software/juicer_tools.1.9.9_jcuda.0.8.jar

[ -d log ] || mkdir log

[ -d input ] || mkdir input

ln -s /home/user/data/lit/project/1KMG/in_house/hic/h/domain/loop/HiCCUPS/hiccups_output/mediumRes/merged_loops.bedpe input/human_PFC.loops.txt
ln -s /home/user/data/lit/project/1KMG/in_house/hic/h/krNorm/human_PFC.allValidPairs.20200716.hic input/human_PFC.hic 
ln -s /home/user/data/lit/project/1KMG/in_house/hic/h/krNorm/human_PFC.allValidPairs.hic input/human_PFC.1.hic 

ln -s /home/user/data/lit/project/1KMG/in_house/hic/m/domain/loop/hiccups/hiccups_output/mediumRes25kb/merged_loops.bedpe input/macaque_PFC.loops.txt
ln -s /home/user/data/lit/project/1KMG/in_house/hic/m/krNorm/macaque_PFC.allValidPairs.20200717.hic input/macaque_PFC.1.hic 
ln -s /home/user/data/lit/project/1KMG/in_house/hic/m/krNorm/macaque_PFC.allValidPairs.20201013.hic input/macaque_PFC.2.hic 

java -jar $juicer_tools apa -u input/human_PFC.hic input/human_PFC.loops.txt output/human 

java -jar $juicer_tools apa -u input/macaque_PFC.1.hic input/macaque_PFC.loops.txt output/macaque

# nohup bash run.sh >>log/apa.log 2>&1 &

sed "s/\[//g" ./output/human/5000/gw/APA.txt |  sed "s/\]//g" > APA_h.txt

sed "s/\[//g" ./output/macaque/5000/gw/APA.txt |  sed "s/\]//g" > APA_m.txt

# 2. loop type

# 2.1 create random loop anchors (shuffle)

# genome files
# human
#/home/user/data2/uplee/data/general/fna/hg38/hg38*chrom*
hg38_genome=/home/user/data2/uplee/data/general/fna/hg38/hg38_comChr.chrom.sizes
# macaque
#/home/user/data2/uplee/data/general/fna/rheMac10Plus/rheMac10Plus*chrom*
rh10_genome=/home/user/data2/uplee/data/general/fna/rheMac10Plus/rheMac10Plus.comChr.chrom.sizes

# bedpe file location
loop_h=/home/user/data/lit/project/1KMG/in_house/hic/h/domain/loop/HiCCUPS/hiccups_output/mediumRes/merged_loops.neat.bedpe
loop_m=/home/user/data/lit/project/1KMG/in_house/hic/m/domain/loop/hiccups/hiccups_output/mediumRes25kb/merged_loops.neat.bedpe

# shuffle loop anchors
bedtools shuffle -i $loop_h -g $hg38_genome -bedpe > human.random_loop.bed
bedtools shuffle -i $loop_m -g $rh10_genome -bedpe > macaque.random_loop.bed

# 2.2 H3K27ac chip-seq file 
# download
mkdir -p histone_mdf/human
mkdir -p histone_mdf/macaque

# hg38
cd histone_mdf/human

wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM1660nnn/GSM1660049/suppl/GSM1660049_H3K27ac_Human_Brain_PrefrontalCortex_HS1_hg38_peaks.narrowPeak.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM1660nnn/GSM1660050/suppl/GSM1660050_H3K27ac_Human_Brain_PrefrontalCortex_HS2_hg38_peaks.narrowPeak.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM1660nnn/GSM1660051/suppl/GSM1660051_H3K27ac_Human_Brain_PrefrontalCortex_HS3_hg38_peaks.narrowPeak.gz

gunzip *.gz

# integrate three peak files

#### method 1 ####

    bedtools multiinter -i GSM1660049_H3K27ac_Human_Brain_PrefrontalCortex_HS1_hg38_peaks.narrowPeak \
    GSM1660051_H3K27ac_Human_Brain_PrefrontalCortex_HS3_hg38_peaks.narrowPeak \
    GSM1660050_H3K27ac_Human_Brain_PrefrontalCortex_HS2_hg38_peaks.narrowPeak > hg38_h_PFC_H3K27ac.narrowPeak

    awk -v OFS='\t' '$4>1 {print $1,$2,$3}' hg38_h_PFC_H3K27ac.narrowPeak > hg38_h_PFC_H3K27ac_overlap.narrowPeak

    bedtools sort -i hg38_h_PFC_H3K27ac_overlap.narrowPeak > hg38_h_PFC_H3K27ac_overlap_sorted.narrowPeak

    bedtools merge -i hg38_h_PFC_H3K27ac_overlap_sorted.narrowPeak > hg38_h_PFC_H3K27ac_overlap_sorted_merged.narrowPeak

#### EO method 1 ####


#### method 2 (deprecated)  ####

    #### trial and error ####
        # install from github and use virtual environment
        source ~/anaconda3/etc/profile.d/conda.sh
        conda activate idr 
        pip install numpy
        pip install scipy -i https://pypi.tuna.tsinghua.edu.cn/simple
        cd /home/user/data2/lit/software
        wget https://github.com.cnpmjs.org/nboley/idr/archive/2.0.2.zip --no-check-certificate
        unzip 2.0.2.zip
        cd idr-2.0.2/
        python3 setup.py install
        #### error_1 ####
            # pkg_resources.ResolutionError: Script 'scripts/idr' not found in metadata at '/home/user/data2/lit/software/idr-2.0.2/idr.egg-info'
        #### EO error_1 ####
        mkdir -p idr.egg-info/scripts
        cp ./build/scripts-3.10/idr idr.egg-info/scripts

        idr -h

        cd /home/user/data2/lit/project/1KMG/qcANDstats/loop/histone_mdf/human

        # rename
        mv GSM1660049_H3K27ac_Human_Brain_PrefrontalCortex_HS1_hg38_peaks.narrowPeak H3K27ac_HS1_hg38.narrowPeak
        mv GSM1660050_H3K27ac_Human_Brain_PrefrontalCortex_HS2_hg38_peaks.narrowPeak H3K27ac_HS2_hg38.narrowPeak
        mv GSM1660051_H3K27ac_Human_Brain_PrefrontalCortex_HS3_hg38_peaks.narrowPeak H3K27ac_HS3_hg38.narrowPeak

        #Sort peak by -log10(p-value)
        for i in 1 2 3;do
        sort -k8,8nr H3K27ac_HS${i}_hg38.narrowPeak > H3K27ac_HS${i}_hg38.sorted.narrowPeak
        done

        cd /home/user/data2/lit/project/1KMG/qcANDstats/loop/

        idr --samples histone_mdf/human/H3K27ac_HS1_hg38.sorted.narrowPeak histone_mdf/human/H3K27ac_HS1_hg38.sorted.narrowPeak \
        --input-file-type narrowPeak \
        --rank p.value 

        #### error_2 ####
            [lit@rhesus-server loop]$ conda install idr=2.0.3 -c bioconda
            Collecting package metadata (current_repodata.json): done
            Solving environment: failed with initial frozen solve. Retrying with flexible solve.
            Collecting package metadata (repodata.json): done
            Solving environment: failed with initial frozen solve. Retrying with flexible solve.
            Solving environment: \ 
            Found conflicts! Looking for incompatible packages.
            This can take several minutes.  Press CTRL-C to abort.
            failed                                                                                                                                                                

            UnsatisfiableError: The following specifications were found
            to be incompatible with the existing python installation in your environment:

            Specifications:

            - idr=2.0.3 -> python[version='3.4.*|3.5.*|3.6.*|>=3.5,<3.6.0a0|>=3.6,<3.7.0a0']

            Your python: python=3.9

            If python is on the left-most side of the chain, that's the version you've asked for.
            When python appears to the right, that indicates that the thing on the left is somehow
            not available for the python version you are constrained to. Note that conda will not
            change your python version to a different minor version unless you explicitly specify
            that.

            The following specifications were found to be incompatible with your system:

            - feature:/linux-64::__glibc==2.27=0
            - feature:|@/linux-64::__glibc==2.27=0

            Your installed version is: 2.27
        #### EO error_2 ####
    #### EO trial and error ####

    # conda install
    # search for different versions of idr and required python version, seems to newer than github...
    conda create -n idr_py36 python=3.6
    conda search idr -c bioconda
    conda activate idr_py36
    conda install idr=2.0.3 -c bioconda 

    # only supports for two files one time, deprecated 
    idr --samples histone_mdf/human/H3K27ac_HS1_hg38.sorted.narrowPeak histone_mdf/human/H3K27ac_HS2_hg38.sorted.narrowPeak \
    --input-file-type narrowPeak \
    --rank p.value 

#### EO method 2 ####

# rheMac3

cd histone_mdf/macaque

wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM1660nnn/GSM1660025/suppl/GSM1660025_H3K27ac_Rhesus_Brain_PrefrontalCortex_RM1_rheMac3_peaks.narrowPeak.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM1660nnn/GSM1660026/suppl/GSM1660026_H3K27ac_Rhesus_Brain_PrefrontalCortex_RM2_rheMac3_peaks.narrowPeak.gz
wget https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM1660nnn/GSM1660027/suppl/GSM1660027_H3K27ac_Rhesus_Brain_PrefrontalCortex_RM3_rheMac3_peaks.narrowPeak.gz

gunzip *.gz

# integrate three peak files

bedtools multiinter -i GSM1660025_H3K27ac_Rhesus_Brain_PrefrontalCortex_RM1_rheMac3_peaks.narrowPeak \
GSM1660025_H3K27ac_Rhesus_Brain_PrefrontalCortex_RM1_rheMac3_peaks.narrowPeak \
GSM1660025_H3K27ac_Rhesus_Brain_PrefrontalCortex_RM1_rheMac3_peaks.narrowPeak > rheMac3_m_PFC_H3K27ac.narrowPeak

awk -v OFS='\t' '$4>1 {print $1,$2,$3}'  rheMac3_m_PFC_H3K27ac.narrowPeak > rheMac3_m_PFC_H3K27ac_overlap.narrowPeak

bedtools sort -i rheMac3_m_PFC_H3K27ac_overlap.narrowPeak > rheMac3_m_PFC_H3K27ac_overlap_sorted.narrowPeak

bedtools merge -i rheMac3_m_PFC_H3K27ac_overlap_sorted.narrowPeak > rheMac3_m_PFC_H3K27ac_overlap_sorted_merged.narrowPeak

# liftOver
liftOver rheMac3_m_PFC_H3K27ac_overlap_sorted_merged.narrowPeak \
/home/user/data/lit/database/in_house/rheMac10Plus/liftOver/rheMac3ToRheMac10Plus.over.chain.gz \
rheMac10Plus_m_PFC_H3K27ac_overlap_sorted_merged.narrowPeak unMapped


#### 2021.12.28 draw customized heatmap ####

    # file location
     
    abs_bed=/home/user/data/lit/project/1KMG/h_fetal_hic_map/hic_pro_in_all/hic_results/matrix/CP/raw/5000/CP_5000_abs.bed
    matrix=/home/user/data/lit/project/1KMG/h_fetal_hic_map/hic_pro_in_all/hic_results/matrix/CP/iced/5000/CP_5000_iced.matrix
    echo -e "chr2\t134050000\t134550000" > loop_region.bed
    bedtools intersect -a loop_region.bed -b $abs_bed -wb | awk '{print $7}' | sort > loop_id.txt
    

    awk '$1 >= 285218 && $1 <= 285317 && $2 >= 285218 && $2 <= 285317 {print $1,$2,$3}' $matrix | sort -k 1,2 > loop_target.txt
 
    

#### EO draw customized heatmap ####


#### 2021.12.28 draw customized heatmap ####

    # file location


    human_fetal_hic=/home/user/data/lit/project/1KMG/in_house/hic/h/krNorm/human_PFC.allValidPairs.20200716.hic
    juicer_tools=/home/user/data2/lit/software/juicer_tools.1.9.9_jcuda.0.8.jar

    java -jar $juicer_tools dump observed KR $human_fetal_hic 2:134050000:134550000 2:134050000:134550000 BP 5000 test_5Kb.txt
    
    loop_h=/home/user/data/lit/project/1KMG/in_house/hic/h/domain/loop/HiCCUPS/hiccups_output/mediumRes/merged_loops.neat.bedpe

    bedtools sort -i $loop_h | less > loops.h.sorted.bedpe

    bedtools intersect -a loop_region.bed -b loops.h.sorted.bedpe -wb | awk -v OFS='\t' '{print $4,$5,$6}' > loop_anchor.1.bed

    bedtools intersect -a loop_region.bed -b loops.h.sorted.bedpe -wb | awk -v OFS='\t' '{print $7,$8,$9}' > loop_anchor.2.bed

    bedtools intersect -a loop_anchor.1.bed -b $abs_bed -wb -wa | sort -k 7 | uniq

    bedtools intersect -a loop_anchor.2.bed -b $abs_bed -wb -wa | sort -k 7 | uniq


#### EO draw customized heatmap ####


# 2022-04-14
mkdir bin
mv *R *sh bin 

mkdir -p output/visualization
mv *pdf output/visualization

mv *txt *bed *bedpe output