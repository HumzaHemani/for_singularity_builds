#!/bin/bash

# ARGUMENTS
Sample=${Sample:default_sample_num}
DataDirectory=${DataDirectory:default_data_dir}
Targets=${Targets:default_targets}

echo arguments read in
READ_EXOME=$(samtools view -c -F 4 -L ${Targets} ${DataDirectory}/${Sample})
echo read_exome done
READ_SAM=$(samtools view -c -F 4 ${DataDirectory}/${Sample})
echo read_sam done
UMI=$(samtools view  ${DataDirectory}/${Sample} | grep -o \'UB:............\' | grep -o \'..........$\' | uniq -c | wc -l)
echo umi done
COV_EXOME=$(samtools depth -b ${Targets} ${DataDirectory}/${Sample} | wc -l)
echo cov_exome done
COV=$(samtools depth ${DataDirectory}/${Sample} | wc -l)
echo cov done
echo $Sample, $READ_EXOME, $READ_SAM, $UMI, $COV_EXOME, $COV >> mutations.csv