#!/bin/bash

####### Script to register FA maps to MNI152 and produce average FA
### Set subject directory
StudyFolder="/mydtifit"
#StudyFolder="/data/Q1200"
SUBJECTS=`ls -d ${StudyFolder}/Diffusion/??????`
### Set directory for MNI
MNI="/usr/local/fsl/data/standard"

for i in $SUBJECTS
do
	echo "Processing ${i}"
	d_input_dir="${i}/T1w/Diffusion"
	s_input_dir="${StudyFolder}/Structural/${i: -6}"
### Create output directory and run applywarp
### to register FA map to MNI
	mkdir -p "${d_input_dir}/MNINonLinear/Results/DTI"
	applywarp --ref=${MNI}/MNI152_T1_1mm_brain.nii.gz --in=${d_input_dir}/DTI/dti_FA.nii.gz --warp=${s_input_dir}/MNINonLinear/xfms/acpc_dc2standard.nii.gz --interp=spline --out=${d_input_dir}/MNINonLinear/Results/DTI/FA2MNIreg

### Perform vecreg to register V1 to MNI
	vecreg --input=${d_input_dir}/DTI/dti_V1.nii.gz --ref=${MNI}/MNI152_T1_1mm_brain.nii.gz --output=${d_input_dir}/MNINonLinear/Results/DTI/V12MNI --warpfield=${s_input_dir}/MNINonLinear/xfms/acpc_dc2standard.nii.gz
done


###### Average FA maps
### Initiate for loop to gather subject paths
FAmaths="fslmaths"
for i in $SUBJECTS
do
### Concatenate subject path to 'maths' command line
	input_dir="${i}/T1w/Diffusion/MNIreg"
	FAmaths="${FAmaths} ${input_dir}/FA2MNIreg.nii.gz -add"
done
### Count the number of subjects
count=`ls ${StudyFolder}/Diffusion/?????? -l | grep "^d" | wc -l`
echo "Commencing averaging of ${count} subjects"
### Remove final '-add' and concatenate final options
FAmaths="${FAmaths::-4}"
FAmaths="${FAmaths} -div ${count} avg_FA_Q1200 -odt float"
### Run fslmaths
${FAmaths}


##### Average principal eiginvector
### Call matlab script to calc dyadic tensor
matlab -nodisplay -nodesktop -nosplash -r "mydyad ${StudyFolder}; quit"

### Use fslmaths to average 
FAmaths="fslmaths"
for i in $SUBJECTS
do
### Concatenate subject path to 'maths' command line
	input_dir="${i}/T1w/Diffusion/MNIreg"
	FAmaths="${FAmaths} ${input_dir}/V1dyads.nii.gz -add"
done
### Count the number of subjects
count=`ls ${StudyFolder}/Diffusion/?????? -l | grep "^d" | wc -l`
echo "Commencing averaging of ${count} subjects"
### Remove final '-add' and concatenate final options
FAmaths="${FAmaths::-4}"
FAmaths="${FAmaths} -div ${count} avg_V1dyad_Q1200 -odt float"
### Run fslmaths
${FAmaths}

### Use fslmaths -tensor_decomp to eigendecompose - keep 1st vector
fslmaths -tensor_decomp avg_V1dyad_Q1200.nii.gz




