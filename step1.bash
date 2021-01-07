#!/bin/bash
# NEEDED MODULES:
# module load parallel
# module load bamtools
# module load samtools
# module load bowtie
# module load GATK/4.1.3.0
# module load bwa
# module load trimgalore

# PARSING PARAMETERS
# sample NUMBER:
sample=${sample:default_sample_num}
# VARIABLES/ DIRECTORY PATHS:
data_dir=${data_dir:default_data_dir}
data_dir=${data_dir:default_data_dir}
combined_dir=${combined_dir:default_combined_dir}
aligned_dir=${aligned_dir:default_aligned_dir}
ref_dir=${ref_dir:default_ref_dir}


while [ $# -gt 0 ]; do            
    if [[ $1 == *"--"* ]]; then
      param="${1/--/}"
      declare $param="$2"
      #echo $1 $2 // Optional to see the parameter:value result
    fi       
  shift
done

echo "vars: $sample $data_dir $combined_dir $aligned_dir $ref_dir"

# merge multiple sequencing runs if not already done:
#cat ${data_dir}/${sample}_Snum_L004_R1_001.fastq.gz ${data_dir}/${sample}_S0_L009_R1_001.fastq.gz > ${combined_dir}/${sample}_Snum_L004_R1_001.fastq.gz
#cat ${data_dir}/${sample}_Snum_L004_R2_001.fastq.gz ${data_dir}/${sample}_S0_L009_R2_001.fastq.gz > ${combined_dir}/${sample}_Snum_L004_R2_001.fastq.gz

# trim sequences with adapters remove unpaired sequences:
trim_galore -j 8 --paired "${data_dir}/${sample}_S1_L004_R1_001.fastq.gz" "${data_dir}/${sample}_S1_L004_R2_001.fastq.gz" -o "${data_dir}"
echo finished trimming

# align to the genome sort and index:
#set -o xtrace
bwa index "${ref_dir}genome.fa" 
bwa mem -M -t 10 "${ref_dir}genome.fa" "${data_dir}${sample}_1_val_1.fq.gz" "${data_dir}${sample}_2_val_2.fq.gz" > "${aligned_dir}${sample}_bwa.sam"
#set +o xtrace
echo finished bwa

samtools sort "${aligned_dir}/${sample}_bwa.sam" > "${aligned_dir}/${sample}_bwa.bam"
samtools index "${aligned_dir}/${sample}_bwa.bam"

# add a unique name for read group in header
gatk --java-options "-Xmx1G" AddOrReplaceReadGroups \
-I ${aligned_dir}/${sample}_bwa.bam \
-O ${aligned_dir}/${sample}_SM_bwa.bam \
-ID ${sample}_combined \
-LB MissingLibrary \
-PL ILLUMINA \
-PU ${sample}_combined \
-SM ${sample}_combined

samtools index ${aligned_dir}/${sample}_SM_bwa.bam

gatk ValidateSamFile -I ${aligned_dir}/${sample}_SM_bwa.bam -M SUMMARY
