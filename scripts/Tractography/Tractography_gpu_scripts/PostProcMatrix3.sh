#!/bin/bash

bindir=/usr/local/fsl/bin
scriptsdir=/data/Q1200/scripts/Tractography_gpu_scripts
Caret7_command=/usr/local/workbench/bin_rh_linux64/wb_command


if [ "$3" == "" ];then
    echo ""
    echo "usage: $0 <StudyFolder> <Subject> <GrayOrdinates_Templatedir> <OutFileName>"
    echo "Final Merge of the three .dconn /wbsparse blocks"
    exit 1
fi

StudyFolder=$1          # "$1" #Path to Generic Study folder
Subject=$2              # "$2" #SubjectID
TemplateFolder=$3
OutFileName=$4

ResultsFolder="$StudyFolder"/"$Subject"/MNINonLinear/Results/Tractography

${Caret7_command} -probtrackx-dot-convert ${ResultsFolder}/fdt_matrix3.dot ${ResultsFolder}/${OutFileName} -row-cifti ${TemplateFolder}/91282_Greyordinates.dscalar.nii COLUMN -col-cifti ${TemplateFolder}/91282_Greyordinates.dscalar.nii COLUMN -make-symmetric

if [ -s  $ResultsFolder/${OutFileName} ]; then
   rm -f ${ResultsFolder}/fdt_matrix3.dot
fi 

##Create RowSum of dconn to check gyral bias
OutFileTemp=`echo ${OutFileName//".dconn.nii"/""}`
${Caret7_command} -cifti-reduce ${ResultsFolder}/${OutFileName} SUM  ${ResultsFolder}/${OutFileTemp}_sum.dscalar.nii
mv $ResultsFolder/waytotal $ResultsFolder/${OutFileTemp}_waytotal

gzip ${ResultsFolder}/${OutFileName} --fast

