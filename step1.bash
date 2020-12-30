  #!/bin/bash
  
  # NEEDED MODULES:
   module load parallel
   module load bamtools
   module load samtools
   module load bowtie
   module load GATK/4.1.3.0
   module load bwa
   module load trimgalore
  
  # PARSING PARAMETERS
  # SAMPLE NUMBER:
  SAMPLE=${sample:default_sample_num}
  # VARIABLES/ DIRECTORY PATHS:
  DATA_DIR=${data_dir:default_data_dir}
  COMBINED_DIR=${combined_dir:default_combined_dir}
  ALIGNED_DIR=${aligned_dir:default_aligned_dir}
  REF=${ref_dir:default_ref_dir}
  
  while [ $# -gt 0 ]; do            
      if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
      fi       
    shift
  done
  
  # merge multiple sequencing runs if not already done:
  #cat ${DATA_DIR}/',donor,'_S',num,'_L004_R1_001.fastq.gz ${DATA_DIR}/',donor,'_S0_L009_R1_001.fastq.gz > ${COMBINED_DIR}/',donor,'_S',num,'_L004_R1_001.fastq.gz
  #cat ${DATA_DIR}/',donor,'_S',num,'_L004_R2_001.fastq.gz ${DATA_DIR}/',donor,'_S0_L009_R2_001.fastq.gz > ${COMBINED_DIR}/',donor,'_S',num,'_L004_R2_001.fastq.gz
  
  # trim sequences with adapters, remove unpaired sequences:
  trim_galore -j 6 --paired ${DATA_DIR}/',donor,'_1.fastq.gz ${DATA_DIR}/',donor,'_2.fastq.gz -o ${DATA_DIR}
  
  # align to the genome, sort and index:
  bwa mem -M -t 10 ${REF}/genome.fa ${DATA_DIR}/',donor,'_1_val_1.fq.gz ${DATA_DIR}/',donor,'_2_val_2.fq.gz > ${ALIGNED_DIR}/',donor,'_bwa.sam
  samtools sort ${ALIGNED_DIR}/',donor,'_bwa.sam > ${ALIGNED_DIR}/',donor,'_bwa.bam
  samtools index ${ALIGNED_DIR}/',donor,'_bwa.bam
  
  # add a unique name for read group in header
  gatk --java-options "-Xmx1G" AddOrReplaceReadGroups \\
  -I ${ALIGNED_DIR}/',donor,'_bwa.bam \\
  -O ${ALIGNED_DIR}/',donor,'_SM_bwa.bam \\
  -ID ',donor,'_combined \\
  -LB MissingLibrary \\
  -PL ILLUMINA \\
  -PU ',donor,'_combined \\
  -SM ',donor,'_combined
  
  samtools index ${ALIGNED_DIR}/',donor,'_SM_bwa.bam
  
  #gatk ValidateSamFile I=${ALIGNED_DIR}/',donor,'_SM_bwa.bam MODE=SUMMARY