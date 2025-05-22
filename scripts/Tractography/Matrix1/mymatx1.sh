#!/bin/bash
### Run probtrackx2 with matrix1 option for cortex-cortex connectivity
### Runs tractography and post processing
### Post processing produces symmetric .dconn and gyral bias dscalar
StudyFolder=/data/Q1200
scriptsdir=/data/Q1200/scripts/Matrix1
DiffStudyFolder=$StudyFolder/Diffusion
StrucStudyFolder=$StudyFolder/Structural
input=$1

echo `date`
COUNTER=0
while IFS= read -r var
do
	echo
	echo "Processing ${var}... started at `date`"
	echo
	
	# Check for folders - only run subject if all folders are found
	# If not found, subject ID is printed to .txt
	if
	[ -d "$DiffStudyFolder/$var" ] ||
	[ -d "$DiffStudyFolder/$var/T1w/Diffusion" ] ||
	[ -d "$DiffStudyFolder/$var/T1w/Diffusion.bedpostX" ] ||
	[ -d "$StrucStudyFolder/$var" ] ||
	[ -d "$StrucStudyFolder/$var/MNINonLinear" ] ||
	[ -d "$StrucStudyFolder/$var/MNINonLinear/fsaverage_LR32k" ]
	then
	    # Call RunMatrix2.sh to run tractography (probtrackx2_gpu)
	    echo "Running probtrackx2 (matrix1)..."
	    echo
	    $scriptsdir/RunMatrix1.sh $DiffStudyFolder $StrucStudyFolder $var

	    
	    # Call PostTractpgraphy to convert dot matrix to dconn
	    echo "Running post tractography processing..."
	    echo
	    OutFileName=cort2cort.dconn.nii
	    $scriptsdir/PostProcMatrix1.sh $StudyFolder $var $OutFileName

	    COUNTER=$((COUNTER+1))
	    echo "${var}" >> /data/Q1200/Diffusion/completed_Matrix1.txt
	    echo "Finished processing ${var} at:  `date`"
	else
	    # Print failed runs to .txt
	    echo "Could not find all directories for ${var}"
	    echo "Moving onto next subject..."
	    echo "${var}" >> /data/Q1200/Diffusion/incomplete_Matrix1.txt
	    echo `date`
	fi
done < "$input"
echo
echo
echo
echo "Completed matrix1 processing on $COUNTER"
