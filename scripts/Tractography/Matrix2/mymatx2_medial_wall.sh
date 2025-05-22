#!/bin/bash
### Run probtrackx2 with matrix2 option for left hemisphere-whole brain tracking
### Runs PreTractography script first, then RunMatrix2 script
StudyFolder=/data/Q1200
scriptsdir=/data/Q1200/scripts/Matrix2/medial_wall
DiffStudyFolder=$StudyFolder/Diffusion
StrucStudyFolder=$StudyFolder/Structural
#input=/data/Q1200/Diffusion/all_subjects
input=/mydtifit/Diffusion/test_subs2

# Input for PreTractography.sh
MSMflag=0

# Input for RunMatrix.sh
DistanceThreshold=-1
DownsampleMat2Target=1
# 0 for 90k Grayordinates, 1 for LH, 2 for RH, 3 for subcortex
SeedsModeLH=1
RMoptsLH=" $DistanceThreshold $DownsampleMat2Target $SeedsModeLH"

SeedsModeRH=2
RMoptsRH=" $DistanceThreshold $DownsampleMat2Target $SeedsModeRH"

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
	    # Call PreTractography.sh to prepare for tractography
	    echo "Running pre-tractography processing..."
	    echo
	    $scriptsdir/PreTractography_medial_wall.sh $DiffStudyFolder $StrucStudyFolder $var $MSMflag

	    # Call RunMatrix2.sh to run tractography (probtrackx2_gpu)
	    echo "Running probtrackx2 (matrix2)..."
	    echo
	    mkdir $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/3mm00
	    mkdir $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/LH
	    $scriptsdir/RunMatrix2_medial_wall.sh $DiffStudyFolder $StrucStudyFolder $var $RMoptsLH
	    mv $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/LH $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/3mm00/
	    
	    mkdir $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/RH
	    $scriptsdir/RunMatrix2_medial_wall.sh $DiffStudyFolder $StrucStudyFolder $var $RMoptsRH
	    mv $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/RH $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/3mm00/
	    
	    echo "Zipping matrix2 files..."
	    gzip $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/3mm00/LH/fdt_matrix2.dot --fast
	    gzip $DiffStudyFolder/$var/MNINonLinear/Results/Tractography_medial_wall/3mm00/RH/fdt_matrix2.dot --fast
	    
	    COUNTER=$((COUNTER+1))
	    echo "${var}" >> /data/Q1200/Diffusion/completed_Matrix2_medial_wall.txt
	    
	    # Call matlab script to calculate the blueprint matrix and create the CIFTI file
	    #echo "Running Matlab blueprint connectivity processing"
	    #cd $scriptsdir
	    #matlab_call='matlab -r -nodesktop -nojvm -nosplash "blueprintLinux($StudyFolder, $var, 2, $DistanceThreshold, 0.005)"'
	    #$matlab_call

	    echo "Finished processing ${var} at:  `date`"
	else
	    # Print failed runs to .txt
	    echo "Could not find all directories for ${var}"
	    echo "Moving onto next subject..."
	    echo "${var}" >> /data/Q1200/Diffusion/incomplete_Matrix2_medial_wall.txt
	    echo `date`
	fi
done < "$input"

echo
echo
echo
echo "Completed matrix2 processing on $COUNTER"
