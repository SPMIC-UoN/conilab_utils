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

#input=/data/Q1200/Diffusion/subject_split4/4 
#filePath=T1w/Diffusion/DTI
#fileName=dti_FA.nii.gz

while IFS= read -r var
do
	echo "Processing ${var}"
	inp="${StudyFolder}/Diffusion/${var}/${filePath}/${fileName}"
	warp="${StudyFolder}/Structural/${var}/MNINonLinear/xfms/acpc_dc2standard.nii.gz"
	out="${StudyFolder}/Diffusion/${var}/MNINonLinear/${fileName}"
	# applywarp --ref=${MNI} --in=${inp} --warp=${warp} --interp=spline --out=${out}

	# Vec registration for V1
	# vecreg --input=${inp} --ref=${MNI} --output=${out} --warpfield=${warp}
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



###### Average V1 (or any vector)
### Call matlab script to calc dyadic tensor
#matlab -nodisplay -nodesktop -nosplash -r "mydyad ${StudyFolder}; quit"

### Use fslmaths to average dyads
#fslcmd="fslmaths"
#while IFS= read -r var
#do
#	echo "Processing ${var}"
#	inp="${StudyFolder}/Diffusion/${var}/MNINonLinear/${fileName}"
#	if [ -f $inp ]; then
#	    fslcmd="${fslcmd} ${inp} -add"
#	else
#	    count=$((count+1))
#	fi
#done < "$input"
#fslcmd="${fslcmd::-4}"
#fslcmd="${fslcmd} -div $(($noSubs-$count-1)) ${StudyFolder}/Diffusion/average_maps/${fileName} -odt float"
#echo "Averaging $(($noSubs-$count-1)) subjects for ${fileName}"
#${fslcmd}







