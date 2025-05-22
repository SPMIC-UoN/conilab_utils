#!/bin/bash

DiffStudyFolder=$1      # "$1" #Path to Generic Study folder
StrucStudyFolder=$2     # "$2" #Path to Generic Study folder
subject=$3              # "$3" #SubjectID


anat_dir=${StrucStudyFolder}/${subject}/MNINonLinear/fsaverage_LR32k
BedpostxFolder=${DiffStudyFolder}/${subject}/T1w/Diffusion.bedpostX
ROIsFolder=${StrucStudyFolder}/${subject}/MNINonLinear/ROIs
RegFolder=${StrucStudyFolder}/${subject}/MNINonLinear/xfms
vol_dir=${DiffStudyFolder}/${subject}/MNINonLinear/Results/Tractography
DtiMask=${BedpostxFolder}/nodif_brain_mask
Nsamples=5000
ResultsFolder=${DiffStudyFolder}/${subject}/MNINonLinear/Results/TractographyMat1
if [ ! -e ${ResultsFolder} ] ; then
  mkdir -p ${ResultsFolder}
fi


rm -rf $ResultsFolder/stop
rm -rf $ResultsFolder/wtstop
rm -rf $ResultsFolder/volseeds
rm -rf $ResultsFolder/mat1_seeds

echo $vol_dir/CIFTI_STRUCTURE_ACCUMBENS_LEFT > $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_ACCUMBENS_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_AMYGDALA_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_AMYGDALA_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_BRAIN_STEM >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_CAUDATE_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_CAUDATE_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_CEREBELLUM_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_CEREBELLUM_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_DIENCEPHALON_VENTRAL_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_DIENCEPHALON_VENTRAL_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_HIPPOCAMPUS_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_HIPPOCAMPUS_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_PALLIDUM_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_PALLIDUM_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_PUTAMEN_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_PUTAMEN_RIGHT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_THALAMUS_LEFT >> $ResultsFolder/volseeds
echo $vol_dir/CIFTI_STRUCTURE_THALAMUS_RIGHT >> $ResultsFolder/volseeds


#Define Generic Options
generic_options=" --loopcheck --forcedir --fibthresh=0.01 -c 0.2 --sampvox=2 --randfib=1 -P ${Nsamples} -S 2000 --steplength=0.5"
o=" -s $BedpostxFolder/merged -m $DtiMask --meshspace=caret"

echo $vol_dir/white.L.asc > $ResultsFolder/mat1_seeds 
echo $vol_dir/white.R.asc >>$ResultsFolder/mat1_seeds
cat $ResultsFolder/volseeds >> $ResultsFolder/mat1_seeds


Seed="$ResultsFolder/mat1_seeds"
StdRef=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask
o=" $o -x $Seed --seedref=$StdRef"
o=" $o --xfm=`echo $RegFolder/standard2acpc_dc` --invxfm=`echo $RegFolder/acpc_dc2standard`"


echo $vol_dir/CIFTI_STRUCTURE_ACCUMBENS_LEFT > $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_ACCUMBENS_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_AMYGDALA_LEFT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_AMYGDALA_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_CAUDATE_LEFT >> $ResultsFolder/wtsto
echo $vol_dir/CIFTI_STRUCTURE_CAUDATE_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_CEREBELLUM_LEFT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_CEREBELLUM_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_HIPPOCAMPUS_LEFT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_HIPPOCAMPUS_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_PALLIDUM_LEFT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_PALLIDUM_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_PUTAMEN_LEFT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_PUTAMEN_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_THALAMUS_LEFT >> $ResultsFolder/wtstop
echo $vol_dir/CIFTI_STRUCTURE_THALAMUS_RIGHT >> $ResultsFolder/wtstop
echo $vol_dir/white.L.asc >> $ResultsFolder/wtstop
echo $vol_dir/white.R.asc >>$ResultsFolder/wtstop

echo $vol_dir/pial.L.asc > $ResultsFolder/stop
echo $vol_dir/pial.R.asc >>$ResultsFolder/stop

o=" $o --stop=${ResultsFolder}/stop --wtstop=$ResultsFolder/wtstop --forcefirststep"  #Should we include an exclusion along the midsagittal plane (without the CC and the commisures)?
o=" $o --waypoints=${ROIsFolder}/Whole_Brain_Trajectory_ROI_2"       #Use a waypoint to exclude streamlines that go through CSF 
o=" $o --omatrix1"
out=" --dir=$ResultsFolder/Results"

probtrackx2_gpu $generic_options $o $out

