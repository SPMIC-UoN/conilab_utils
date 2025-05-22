#!/bin/bash

StudyFolder="/data/Q1200/Diffusion"

wbc="/usr/local/workbench-1.4.1/bin_rh_linux64/wb_command"

HomeFolder=""

out="${HomeFolder}/ave_mat1_pmzyl.dconn.nii"
mat1Ext="MNINonLinear/Results/TractographyMat1/Results/cort2cort.dconn"
#input="/data/Q1200/scripts/temp_list"
input="${HomeFolder}/ave_ids.txt"

for subID in `cat $input`
do
    echo ${subID}
    mat1="${StudyFolder}/${subID}/${mat1Ext}"
    if [ -f "${mat1}.nii.gz" ]; then cp ${mat1}.nii.gz ${HomeFolder}; 
	gunzip ${HomeFolder}/cort2cort.dconn.nii.gz --force; fi
    if [ ${subID} -eq "100206" ];
    then
      cp ${HomeFolder}/cort2cort.dconn.nii ${out}; count=1
    else
      ${wbc} -cifti-math 'x+y' ${out} -var x ${out} -var y ${HomeFolder}/cort2cort.dconn.nii; $((count++))
    fi
    #gzip ${mat1}.nii --fast --force
    rm ${HomeFolder}/cort2cort.dconn.nii; echo ${count}
done
${wbc} -cifti-math 'x/${count}' ${out} -var x ${out}
