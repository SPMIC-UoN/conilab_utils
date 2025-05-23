#!/bin/bash

if [ "$6" == "" ];then
    echo ""
    echo "usage: $0 <DiffusionFolder> <StructuralFolder> <Subject> <DistanceThreshold> <DownsampleMat2Target> <Subset_seeds>"
    echo "<DistanceThreshold> in mm (e.g. 4), defines the max distance allowed from the pial surface and the cubcortex"
    echo "                    for a voxel to be considered in Mat2 Target mask. Use -1 to avoid any stripping"
    echo "if flag <DownsampleMat2Target> is set to 1, the mask is downsampled to 3mm isotropic"
    echo "Subset_seeds:0 for 90k seed GrayordInates, 1:for LH, 2:for RH, 3:for subcortex"
    echo ""
    exit 1
fi

Nsamples=5000           # Number of samples requested per seed

DiffStudyFolder=$1      # "$1" #Path to Generic Study folder
StrucStudyFolder=$2     # "$2" #Path to Generic Study folder
Subject=$3              # "$3" #SubjectID
DistanceThreshold=$4
DownsampleMat2Target=$5
SeedsMode=$6


if [ $DownsampleMat2Target -eq 0 ]; then
    echo "Warning!! Not downsampling the target mask requires large amounts of memory!"
fi

ResultsFolder="$DiffStudyFolder"/"$Subject"/MNINonLinear/Results/Tractography
RegFolder="$StrucStudyFolder"/"$Subject"/MNINonLinear/xfms
ROIsFolder="$StrucStudyFolder"/"$Subject"/MNINonLinear/ROIs
if [ ! -e ${ResultsFolder} ] ; then
  mkdir ${ResultsFolder}
fi

BedpostxFolder="$DiffStudyFolder"/"$Subject"/T1w/Diffusion.bedpostX
DtiMask=$BedpostxFolder/nodif_brain_mask

rm -rf $ResultsFolder/stop
rm -rf $ResultsFolder/wtstop
rm -rf $ResultsFolder/volseeds
rm -rf $ResultsFolder/Mat2_seeds

echo $ResultsFolder/CIFTI_STRUCTURE_ACCUMBENS_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_ACCUMBENS_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_AMYGDALA_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_AMYGDALA_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_BRAIN_STEM >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_CAUDATE_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_CAUDATE_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_CEREBELLUM_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_CEREBELLUM_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_DIENCEPHALON_VENTRAL_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_DIENCEPHALON_VENTRAL_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_HIPPOCAMPUS_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_HIPPOCAMPUS_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_PALLIDUM_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_PALLIDUM_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_PUTAMEN_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_PUTAMEN_RIGHT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_THALAMUS_LEFT >> $ResultsFolder/volseeds
echo $ResultsFolder/CIFTI_STRUCTURE_THALAMUS_RIGHT >> $ResultsFolder/volseeds

#Define Generic Options
generic_options=" --loopcheck --forcedir --fibthresh=0.01 -c 0.2 --sampvox=2 --randfib=1 -P ${Nsamples} -S 2000 --steplength=0.5"
o=" -s $BedpostxFolder/merged -m $DtiMask --meshspace=caret"

#Define Seed
if [ "$SeedsMode" == "0" ]; then
    echo $ResultsFolder/white.L.asc >> $ResultsFolder/Mat2_seeds
    echo $ResultsFolder/white.R.asc >> $ResultsFolder/Mat2_seeds
    cat $ResultsFolder/volseeds >> $ResultsFolder/Mat2_seeds
fi
if [ "$SeedsMode" == "1" ]; then
    echo $ResultsFolder/white.L.asc > $ResultsFolder/Mat2_seeds
fi
if [ "$SeedsMode" == "2" ]; then
    echo $ResultsFolder/white.R.asc > $ResultsFolder/Mat2_seeds
fi
if [ "$SeedsMode" == "3" ]; then
    cat $ResultsFolder/volseeds >> $ResultsFolder/Mat2_seeds
fi

Seed="$ResultsFolder/Mat2_seeds"
StdRef=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask
o=" $o -x $Seed --seedref=$StdRef"
o=" $o --xfm=`echo $RegFolder/standard2acpc_dc` --invxfm=`echo $RegFolder/acpc_dc2standard`"

#Define Termination and Waypoint Masks
echo $ResultsFolder/pial.L.asc >> $ResultsFolder/stop      #Pial Surface as Stop Mask
echo $ResultsFolder/pial.R.asc >> $ResultsFolder/stop

echo $ResultsFolder/CIFTI_STRUCTURE_ACCUMBENS_LEFT >> $ResultsFolder/wtstop    #WM boundary Surface and subcortical volumes as Wt_Stop Masks
echo $ResultsFolder/CIFTI_STRUCTURE_ACCUMBENS_RIGHT >> $ResultsFolder/wtstop   #Exclude Brainstem and diencephalon, otherwise cortico-cerebellar connections are stopped!
echo $ResultsFolder/CIFTI_STRUCTURE_AMYGDALA_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_AMYGDALA_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_CAUDATE_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_CAUDATE_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_CEREBELLUM_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_CEREBELLUM_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_HIPPOCAMPUS_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_HIPPOCAMPUS_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_PALLIDUM_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_PALLIDUM_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_PUTAMEN_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_PUTAMEN_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_THALAMUS_LEFT >> $ResultsFolder/wtstop
echo $ResultsFolder/CIFTI_STRUCTURE_THALAMUS_RIGHT >> $ResultsFolder/wtstop
echo $ResultsFolder/white.L.asc >> $ResultsFolder/wtstop
echo $ResultsFolder/white.R.asc >> $ResultsFolder/wtstop
o=" $o --stop=${ResultsFolder}/stop --wtstop=$ResultsFolder/wtstop" 
o=" $o --waypoints=${ROIsFolder}/Whole_Brain_Trajectory_ROI_2"       #Use a waypoint to exclude streamlines that go through CSF 



#Define Targets
if [ "$DistanceThreshold" == "-1" ]; then
    ${FSLDIR}/bin/imcp $ROIsFolder/Whole_Brain_Trajectory_ROI_2 ${ResultsFolder}/Mat2_target
else 
######Create mask stripped from deep WM...
    $FSLDIR/bin/surf2volume $ResultsFolder/pial.L.asc $StdRef $ResultsFolder/Lsurf_pial caret
    $FSLDIR/bin/surf2volume $ResultsFolder/pial.R.asc $StdRef $ResultsFolder/Rsurf_pial caret

    $FSLDIR/bin/fslmaths $ResultsFolder/Lsurf_pial -add $ResultsFolder/Rsurf_pial -add $ResultsFolder/CIFTI_STRUCTURE_ACCUMBENS_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_AMYGDALA_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_BRAIN_STEM -add $ResultsFolder/CIFTI_STRUCTURE_CAUDATE_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_CEREBELLUM_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_DIENCEPHALON_VENTRAL_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_HIPPOCAMPUS_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_PALLIDUM_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_PUTAMEN_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_THALAMUS_RIGHT -add $ResultsFolder/CIFTI_STRUCTURE_ACCUMBENS_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_AMYGDALA_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_BRAIN_STEM -add $ResultsFolder/CIFTI_STRUCTURE_CAUDATE_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_CEREBELLUM_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_DIENCEPHALON_VENTRAL_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_HIPPOCAMPUS_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_PALLIDUM_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_PUTAMEN_LEFT -add $ResultsFolder/CIFTI_STRUCTURE_THALAMUS_LEFT $ResultsFolder/LRsurfvols
    ${FSLDIR}/bin/distancemap -m ${StdRef} -i ${ResultsFolder}/LRsurfvols -o ${ResultsFolder}/dist.nii.gz
    ${FSLDIR}/bin/fslmaths ${ResultsFolder}/dist.nii.gz -uthr $DistanceThreshold -bin -mul $ROIsFolder/Whole_Brain_Trajectory_ROI_2 ${ResultsFolder}/Mat2_target
    ${FSLDIR}/bin/imrm ?surf_pial
    ${FSLDIR}/bin/imrm LRsurfvols
######...Finished creating mask
fi

#Downsample Target mask to 3mm
if [ "$DownsampleMat2Target" == "1" ]; then   
    $FSLDIR/bin/immv ${ResultsFolder}/Mat2_target ${ResultsFolder}/Mat2_target_orig
    $FSLDIR/bin/flirt -in ${ResultsFolder}/Mat2_target_orig -ref $StdRef -out $ResultsFolder/Mat2_target -applyisoxfm 3 -interp nearestneighbour
fi

o=" $o --omatrix2 --target2=$ResultsFolder/Mat2_target"


#Do Tractography with results folder specified by hemisphere
if [ "$SeedsMode" == "1" ]; then
    out=" --dir=$ResultsFolder/LH"
    cp $ResultsFolder/Mat2_target.nii.gz $ResultsFolder/LH/Mat2_target.nii.gz
    $FSLDIR/bin/probtrackx2_gpu $generic_options $o $out
elif  [ "$SeedsMode" == "2" ]; then
    out=" --dir=$ResultsFolder/RH"
    cp $ResultsFolder/Mat2_target.nii.gz $ResultsFolder/RH/Mat2_target.nii.gz
    $FSLDIR/bin/probtrackx2_gpu $generic_options $o $out 
else
    out=" --dir=$ResultsFolder"
    $FSLDIR/bin/probtrackx2_gpu $generic_options $o $out
fi




