#!/bin/bash

### Set subject directory
StudyFolder="/data/Q1200"
MNI="/usr/local/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz"

# subject list
input=$1
# path to file directory (starting from after subject ID)
filePath="T1w/Diffusion/DKI"
# file name
fileName="dti_kurt.nii.gz"

while IFS= read -r var
do
	echo "Processing ${var}"
	inp="${StudyFolder}/Diffusion/${var}/${filePath}/${fileName}"
	mask="${StudyFolder}/Diffusion/${var}/T1w/Diffusion/nodif_brain_mask.nii.gz"
	out="${StudyFolder}/Diffusion/${var}/MNINonLinear/${fileName}"
	# Mask T1w space dti_kurt
	fslmaths ${inp} -mul ${mask} ${out}
	fslmaths ${out} -thr 0 -uthr 3 ${out}
	# Transform to standard space
	warp="${StudyFolder}/Structural/${var}/MNINonLinear/xfms/acpc_dc2standard.nii.gz"
	applywarp --ref=${MNI} --in=${out} --warp=${warp} --interp=spline --out=${out}
done < "$input"


###### Average feature maps
### Initiate for loop to gather subject paths
fslcmd="fslmaths"
count=0
noSubs=$((`wc -l < ${input}`+1))
while IFS= read -r subID
do
	inp="${StudyFolder}/Diffusion/${subID}/MNINonLinear/${fileName}"
	if [ -f $inp ]; then
	    fslcmd="${fslcmd} ${inp} -add"
	else
	    count=$((count+1))
	fi
done < "$input"
fslcmd="${fslcmd::-4}"
fslcmd="${fslcmd} -div $(($noSubs-$count-1)) ${StudyFolder}/Diffusion/average_maps/${fileName} -odt float"
echo "Averaging $(($noSubs-$count-1)) subjects for ${fileName}"
${fslcmd}






