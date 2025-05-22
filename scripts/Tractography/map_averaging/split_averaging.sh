#!/bin/bash

### Set subject directory
StudyFolder="/data/Q1200"
MNI="/usr/local/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz"

# path to file directory (starting from after subject ID)
filePath=T1w/Diffusion/DTI
# file name
fileName=dti_tensor
mx=$1
outDir="/data/Q1200/Diffusion/subject_split${mx}"
orig=${outDir}/all

ave_split () {
	input=$1
	i=$2
	noSubs=`wc -l < ${input}`
	fslcmd="fslmaths"
	count=0
	tempDir="${StudyFolder}/Diffusion/average_maps/temp"
	for var in `cat $input`
	do
    	inp="${StudyFolder}/Diffusion/${var}/MNINonLinear/${fileName}.nii.gz"
    	if [ -f $inp ]; then
		fslcmd="${fslcmd} ${inp} -add"
    	else
		count=$((count+1))
    	fi
	done < "$input"
	fslcmd="${fslcmd::-4}"
	fslcmd="${fslcmd} -div $(($noSubs-$count)) ${tempDir}/${fileName}_${i}.nii.gz -odt float"
	echo "Averaging $(($noSubs-$count)) subjects for ${fileName}"
	${fslcmd}
}

noFiles=`find /data/Q1200/Diffusion/subject_split${mx}/* -type f | wc -l`
i=0
tempDir="${StudyFolder}/Diffusion/average_maps/temp"
rm $tempDir -r
mkdir $tempDir
while [[ "$i" -le "$noFiles" ]]; do
    i=$((i+1))
    ave_split "/data/Q1200/Diffusion/subject_split${mx}/${i}" $i
done

# Average split averages
echo "Averaging split data"
i=0
fslcmd="fslmaths"
while [[ "$i" -lt "$noFiles" ]]; do
    i=$((i+1))
    inp="${tempDir}/${fileName}_${i}.nii.gz"
    fslcmd="${fslcmd} ${inp} -add"
done
fslcmd="${fslcmd::-4}"
fslcmd="${fslcmd} -div ${i} /data/Q1200/Diffusion/average_maps/${fileName}.nii.gz -odt float"
echo "Averaging ${i} files for ${fileName}"
${fslcmd}
