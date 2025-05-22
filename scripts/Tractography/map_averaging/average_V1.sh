#!/bin/bash

### Set subject directory
StudyFolder="/data/Q1200"
MNI="/usr/local/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz"
# subject list
input=$1
# path to file directory (starting from after subject ID)
filePath=$2
# file name
fileName=$3

while IFS= read -r var
do
	echo "Processing ${var}"
	inp="${StudyFolder}/Diffusion/${var}/${filePath}/${fileName}"
	warp="${StudyFolder}/Structural/${var}/MNINonLinear/xfms/acpc_dc2standard.nii.gz"
	out="${StudyFolder}/Diffusion/${var}/MNINonLinear/${fileName}"

	# Vec registration for V1
	vecreg --input=${inp} --ref=${MNI} --output=${out} --warpfield=${warp}
done < "$input"

###### Average V1 (or any vector)
### Call matlab script to calc dyadic tensor
matlab -nodisplay -nodesktop -nosplash -r "mydyad ${StudyFolder}; quit"

### Use fslmaths to average dyads
fslcmd="fslmaths"
noSubs=$((`wc -l < ${input}`+1))
while IFS= read -r var
do
	inp="${StudyFolder}/Diffusion/${var}/MNINonLinear/dti_V1dyads.nii.gz"
	if [ -f $inp ]; then
	    fslcmd="${fslcmd} ${inp} -add"
	else
	    count=$((count+1))
	fi
done < "$input"
fslcmd="${fslcmd::-4}"
fslcmd="${fslcmd} -div $(($noSubs-$count-1)) ${StudyFolder}/Diffusion/average_maps/dti_V1dyads.nii.gz -odt float"
echo "Averaging $(($noSubs-$count-1)) subjects for ${fileName}"
${fslcmd}

### Use fslmaths -tensor_decomp to eigendecompose - keep 1st vector
fslmaths ${StudyFolder}/Diffusion/average_maps/dti_V1dyads.nii.gz -tensor_decomp ${StudyFolder}/Diffusion/average_maps/decomp
rm ${StudyFolder}/Diffusion/average_maps/decomp_FA.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_L2.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_MD.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_V2.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_L1.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_L3.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_MO.nii.gz ${StudyFolder}/Diffusion/average_maps/decomp_V3.nii.gz
mv ${StudyFolder}/Diffusion/average_maps/decomp_V1.nii.gz ${StudyFolder}/Diffusion/average_maps/dti_V1.nii.gz






