#!/bin/bash

StudyFolder="/data/Q1200/Diffusion"
wbc="/usr/local/workbench-1.4.1/bin_rh_linux64/wb_command"

out="${StudyFolder}/ave_mat1.dconn.nii"
mat1Ext="MNINonLinear/Results/TractographyMat1/Results/cort2cort.dconn"
input="/data/Q1200/Diffusion/all_good_subjects"

nSubs=`cat ${input} | wc -l`
for subID in `cat $input`
do
    echo -n ${subID}
    mat1="${StudyFolder}/${subID}/${mat1Ext}"
    if [ -f "${mat1}.nii.gz" ]; then  echo -n " - unzipping"; gunzip ${mat1}.nii.gz --force; fi
    if [ ${subID} -eq "100206" ];
    then
      echo -n " - copying"
      cp ${mat1}.nii ${out}
    else
      echo -n " - adding"
      t=`${wbc} -cifti-math '(x+y)' ${out} -var x ${mat1}.nii -var y ${out} -logging OFF`
    fi
    echo " - zipping"; gzip ${mat1}.nii --fast --force
done
echo "Final division..."
eval "wb_command -cifti-math 'x/${nSubs}' ${out} -var x ${out} -logging OFF"
echo "Done: ${out}"
