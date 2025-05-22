#!/bin/bash
### Average tracts

StudyFolder=/data/Q1200/Diffusion

output="${StudyFolder}/average_mat1"
if [ -d $output ]; then
    rm $output -r; mkdir $output
else
    mkdir $output
fi

##### Function to average chunks of subject data
ave_split () {
	input=$1
	noSubs=$((`wc -l < ${input}`))
	cmd="/usr/local/workbench/bin_rh_linux64/wb_command -cifti-average ${output}/cort2cort_sum_${input: -1}.dscalar.nii"
	count=0
	for subID in `cat $input`
	do
    	inp="${StudyFolder}/${subID}/MNINonLinear/Results/TractographyMat1/Results/cort2cort_sum.dscalar.nii"
    	if [ -f $inp ]; then
		cmd="${cmd} -cifti ${inp}"
    	else
		count=$((count+1))
    	fi
	done
	echo "Averaging $(($noSubs-$count)) subjects"
	${cmd}
}

ave_split "/data/Q1200/Diffusion/subject_split/1"
ave_split "/data/Q1200/Diffusion/subject_split/2"
ave_split "/data/Q1200/Diffusion/subject_split/3"
ave_split "/data/Q1200/Diffusion/subject_split/4"
ave_split "/data/Q1200/Diffusion/subject_split/5"

# Average split averages
echo "Averaging split data"
/usr/local/workbench/bin_rh_linux64/wb_command -cifti-average ${output}/cort2cort_sum.dscalar.nii -cifti ${output}/cort2cort_sum_1.dscalar.nii -cifti ${output}/cort2cort_sum_2.dscalar.nii -cifti ${output}/cort2cort_sum_3.dscalar.nii -cifti ${output}/cort2cort_sum_4.dscalar.nii -cifti ${output}/cort2cort_sum_5.dscalar.nii

rm ${output}/cort2cort_sum_1.dscalar.nii ${output}/cort2cort_sum_2.dscalar.nii ${output}/cort2cort_sum_3.dscalar.nii ${output}/cort2cort_sum_4.dscalar.nii ${output}/cort2cort_sum_5.dscalar.nii


