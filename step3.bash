#!/bin/bash

# LOAD MODULES:

#module load GATK/4.1.0.0
#module load bedops

# sample NUMBER:

sample=${sample:default_sample_num}

# INITIALIZE VARIABLES/ DIRECTORY PATHS:

out=${out:default_out}
data=${data:default_data}
ref_dir=${ref_dir:default_ref}

while [ $# -gt 0 ]; do            
    if [[ $1 == *"--"* ]]; then
      param="${1/--/}"
      declare $param="$2"
      echo $1 $2 #// Optional to see the parameter:value result
    fi       
  shift
done

mkdir -p ${out}/${sample}

gatk --java-options "-Xmx1G" HaplotypeCaller -R ${ref_dir}/genome.fa -I ${data}/${sample}_SM_bwa.bam -O ${out}/${sample}_SM_bwa_RawSNPs.vcf

convert2bed -i vcf < ${out}/${sample}_SM_bwa_RawSNPs.vcf > ${out}/${sample}_SM_bwa_RawSNPs.bed
