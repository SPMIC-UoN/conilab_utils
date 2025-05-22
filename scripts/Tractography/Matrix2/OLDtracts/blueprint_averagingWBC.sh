#!/bin/bash
### Average tracts

StudyFolder=/data/Q1200/Diffusion

output="${StudyFolder}/blueprint_averagingWBC"
if [ -d $output ]; then
    rm $output -r; mkdir $output
else
    mkdir $output
fi

##### Function to average chunks of subject data
ave_split () {
	input=$1
	noSubs=$((`wc -l < ${input}`))
	cmd="/usr/local/workbench/bin_rh_linux64/wb_command -cifti-average ${output}/ave_${input: -1}.dtseries.nii"
	count=0
	while IFS= read -r subID
	do
    	bpFile="${StudyFolder}/${subID}/MNINonLinear/Results/blueprint/bpTracts.dtseries.nii"
    	if [ -f $bpFile ]; then
		cmd="${cmd} -cifti ${bpFile}"
    	else
		count=$((count+1))
    	fi
	done < "$input"
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
/usr/local/workbench/bin_rh_linux64/wb_command -cifti-average ${output}/ave_blueprint.dtseries.nii -cifti ${output}/ave_1.dtseries.nii -cifti ${output}/ave_2.dtseries.nii -cifti ${output}/ave_3.dtseries.nii -cifti ${output}/ave_4.dtseries.nii -cifti ${output}/ave_5.dtseries.nii

rm ${output}/ave_1.dtseries.nii ${output}/ave_2.dtseries.nii ${output}/ave_3.dtseries.nii ${output}/ave_4.dtseries.nii ${output}/ave_5.dtseries.nii


