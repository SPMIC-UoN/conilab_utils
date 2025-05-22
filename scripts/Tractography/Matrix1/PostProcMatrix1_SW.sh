#!/bin/bash

Caret7_command=/usr/local/workbench/bin_rh_linux64/wb_command

if [ "$3" == "" ];then
    echo ""
    echo "usage: $0 <StudyFolder> <Subject> <OutFileName>"
    echo "Convert the merged.dot file to .dconn.nii"
    exit 1
fi

StudyFolder=$1          # "$1" #Path to Generic Study folder
Subject=$2              # "$2" #SubjectID
OutFileName=$3          # "$3" #Name of result file - gyral bias dscalar
TemplateFolder=/data/Q1200/scripts/91282_Greyordinates

ResultsFolder="${StudyFolder}/Diffusion/${Subject}/MNINonLinear/Results/TractographyMat1"

echo "Converting fdt_matrix.dot file to dconn for ${Subject}"

${Caret7_command} -probtrackx-dot-convert ${ResultsFolder}/Results/fdt_matrix1.dot ${ResultsFolder}/Results/Mat1.dconn.nii -row-cifti ${TemplateFolder}/91282_Greyordinates.dscalar.nii COLUMN -col-cifti ${TemplateFolder}/91282_Greyordinates.dscalar.nii COLUMN
${Caret7_command} -cifti-transpose ${ResultsFolder}/Results/Mat1.dconn.nii ${ResultsFolder}/Results/Mat1_transp.dconn.nii
${Caret7_command} -cifti-average ${ResultsFolder}/Results/${OutFileName} -cifti ${ResultsFolder}/Results/Mat1.dconn.nii -cifti ${ResultsFolder}/Results/Mat1_transp.dconn.nii

if [ -s  $ResultsFolder/Results/${OutFileName} ]; then
   rm -f ${ResultsFolder}/Results/Mat1.dconn.nii
   rm -f ${ResultsFolder}/Results/Mat1_transp.dconn.nii
   rm -f ${ResultsFolder}/Results/fdt_matrix1.dot
fi
echo "Calculating .dconn and gyral bias"
##Create RowSum of dconn to get gyral bias
OutFileTemp=`echo ${OutFileName//".dconn.nii"/""}`
${Caret7_command} -cifti-reduce ${ResultsFolder}/Results/${OutFileName} SUM  ${ResultsFolder}/Results/${OutFileTemp}_sum.dscalar.nii
mv $ResultsFolder/Results/waytotal $ResultsFolder/Results/${OutFileTemp}_waytotal

echo "Running parcellations..."
. /data/Q1200/scripts/Matrix1/ParcelConn.sh ${StudyFolder} ${Subject} ${OutFileName}

echo "Zipping files..."
gzip $ResultsFolder/${OutFileName} --fast
