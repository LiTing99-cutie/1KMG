################################################
#File Name: run.sh
#Author: LiTing
#Mail: liting@stu.pku.edu.cn
#Created Time: Fri 26 Nov 2021 04:37:59 PM CST
################################################

#!/bin/sh 
. /home/user/BGM/lit/anaconda3/etc/profile.d/conda.sh
conda create fanc_2 python=3.9
conda activate fanc_2
pip install fanc -i https://pypi.tuna.tsinghua.edu.cn/simple
fanc --version

### test ###
    # [ -d log ] || mkdir log
    # [ -d test ] || mkdir test
    # [ -d test/log ] || mkdir -p test/log
    # hic_dir=/home/user/data2/lit/project/1KMG/HiC/human_PFC.allValidPairs.hic

    # # example
    # # fanc expected -p architecture/expected/fanc_example_500kb_expected.png \
    # #               -c chr19 \
    # #               output/hic/binned/fanc_example_500kb.hic \
    # #               architecture/expected/fanc_example_500kb_expected.txt

    # # not work
    # fanc expected -p fanc_expected.png \
    #             /home/user/data2/lit/project/1KMG/HiC/human_PFC.allValidPairs.hic@1000 \
    #             fanc_expected.txt \
    #             # > log/fanc.test.log 2>&1
    # # TypeError: object of type 'NoneType' has no len()

    # # nohup bash run.sh > log/fanc.log 2>&1 &

    # # test using fanc example

    # wget https://github.com/vaquerizaslab/fanc/archive/refs/heads/main.zip

    # # not work
    # fanc expected -p fanc_expected.png \
    #             fanc-main/fanc/test/test_matrix/test_juicer.hic \
    #             fanc_expected.txt 
    # # ValueError: File type not recognised (fanc-main/fanc/test/test_matrix/test_juicer.hic).

    # # work
    # architecture=fanc-main/examples/architecture
    # fanc expected -l "HindIII 100k" "HindIII 5M" "MboI 100k" "MboI 1M" "MboI 50k" \
    #             -c chr19 -p expected_multi.png \
    #             $architecture/other-hic/lowc_hindiii_100k_1mb.hic \
    #             $architecture/other-hic/lowc_hindiii_5M_1mb.hic \
    #             $architecture/other-hic/lowc_mboi_100k_1mb.hic \
    #             $architecture/other-hic/lowc_mboi_1M_1mb.hic \
    #             $architecture/other-hic/lowc_mboi_50k_1mb.hic \
    #             expected_multi.txt


    # fanc hic --deepcopy $hic_dir@1kb human_PFC.fanc.hic

    # # weird
    # fanc expected -p fanc_expected.png \
    #             human_PFC.fanc.hic \
    #             fanc_expected.txt 


    # matrix=/home/user/data2/lit/project/1KMG/HiC/hicpro_output/hic_results/matrix/human_PFC/iced/1000/human_PFC_1000_iced.matrix
    # absbed=/home/user/data2/lit/project/1KMG/HiC/hicpro_output/hic_results/matrix/human_PFC/raw/1000/human_PFC_1000_abs.bed
    # # 1h2min
    # fanc from-txt $matrix $absbed human_PFC.fanc.hicpro.1kb.hic 

    # matrix=/home/user/data2/lit/project/1KMG/HiC/hicpro_output/hic_results/matrix/human_PFC/iced/50000/human_PFC_50000_iced.matrix
    # absbed=/home/user/data2/lit/project/1KMG/HiC/hicpro_output/hic_results/matrix/human_PFC/raw/50000/human_PFC_50000_abs.bed
    # nohup fanc from-txt $matrix $absbed human_PFC.fanc.hicpro.50kb.hic  > log/hicpro2fanc.50kb.log 2>&1 &

    # matrix=/home/user/data2/lit/project/1KMG/HiC/hicpro_output/hic_results/matrix/human_PFC/iced/100000/human_PFC_100000_iced.matrix
    # absbed=/home/user/data2/lit/project/1KMG/HiC/hicpro_output/hic_results/matrix/human_PFC/raw/100000/human_PFC_100000_abs.bed
    # nohup fanc from-txt $matrix $absbed human_PFC.fanc.hicpro.100kb.hic  > log/hicpro2fanc.100kb.log 2>&1 &

    # fanc expected -p fanc_expected.1.png \
    #             human_PFC.fanc.hicpro.1kb.hic \
    #             fanc_expected.1.txt           

    # fanc expected -p fanc_expected.2.png \
    #             -c chr19 \
    #             human_PFC.fanc.hicpro.1kb.hic \
    #             fanc_expected.2.txt    

    # fanc expected -p fanc_expected.3.png \
    #             human_PFC.fanc.hicpro.50kb.hic \
    #             fanc_expected.3.txt  

    # fanc expected -p fanc_expected.4.png \
    #             human_PFC.fanc.hicpro.100kb.hic \
    #             fanc_expected.4.txt  

    # fanc expected -l "HindIII 100k" \
    #             -c chr19 -p expected_multi.1.png \
    #             $architecture/other-hic/lowc_hindiii_100k_1mb.hic \
    #             expected_multi.1.txt

    # fanc expected -p expected_multi.2.png \
    #             $architecture/other-hic/lowc_hindiii_100k_1mb.hic \
    #             expected_multi.2.txt
    
    # mv *.png *.txt *hic test/
    # mv log/* test/log

### EO test ###

ln -s /home/user/data/lit/project/1KMG/in_house/hic/h/matrix/human_PFC/iced/40000/human_PFC_40000_iced.matrix human_PFC_40000_iced.matrix
ln -s /home/user/data/lit/project/1KMG/in_house/hic/h/matrix/human_PFC/raw/40000/human_PFC_40000_abs.bed human_PFC_40000_abs.bed
nohup fanc from-txt human_PFC_40000_iced.matrix human_PFC_40000_abs.bed human_PFC.fanc.hicpro.40kb.hic  > log/hicpro2fanc.human_PFC.40kb.log 2>&1 &

ln -s /home/user/data/lit/project/1KMG/in_house/hic/m/matrix/macaque_PFC/iced/40000/macaque_PFC_40000_iced.matrix macaque_PFC_40000_iced.matrix
ln -s /home/user/data/lit/project/1KMG/in_house/hic/m/matrix/macaque_PFC/raw/40000/macaque_PFC_40000_abs.bed macaque_PFC_40000_abs.bed
nohup fanc from-txt macaque_PFC_40000_iced.matrix macaque_PFC_40000_abs.bed macaque_PFC.fanc.hicpro.40kb.hic  > log/hicpro2fanc.macaque_PFC.40kb.log 2>&1 &

wait 

echo "hic files are ready"

fanc expected -l "Human" \
            -p IFC.h.png \
            human_PFC.fanc.hicpro.40kb.hic \
            IFC.h.txt    

fanc expected -l "Rhesus_Macaque" \
            -p IFC.m.png \
            macaque_PFC.fanc.hicpro.40kb.hic \
            IFC.m.txt 

wait 

echo "all is well"

# nohup bash run.sh >log/run.log 2>&1 &

# 2022-04-14

rm -rf fanc-main.zip

mkdir -p /home/user/data/lit/project/1KMG/qcANDstats/IFC/FAN-C && \
cp -r ./*.hic /home/user/data/lit/project/1KMG/qcANDstats/IFC/FAN-C && \
rm -rf ./*.hic &

mkdir bin 
mv run.sh bin/
mv FAN-C.R bin/

mkdir input 
mv *PFC* input

mkdir output
mv IFC* output