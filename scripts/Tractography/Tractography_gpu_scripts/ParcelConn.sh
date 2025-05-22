#!/bin/bash

Caret7_command=/workbench_rh_linux64_latest/bin_rh_linux64/wb_command

if [ "$4" == "" ];then
    echo ""
    echo "usage: $0 <StudyFolder> <Subject> <GrayOrdinates_Templatedir> <OutFileName>"
    echo "Get Parcellated Connectomes"
    exit 1
fi

StudyFolder=$1          # "$1" #Path to Generic Study folder
Subject=$2              # "$2" #SubjectID
TemplateFolder=$3
OutFileName=$4

ResultsFolder="$StudyFolder"/"$Subject"/MNINonLinear/Results/Tractography
ParcelsFolder=$ResultsFolder/Parcellated
mkdir -p $ParcelsFolder

OutFileTemp=`echo ${OutFileName//".dconn.nii"/""}`

echo "Creating Parcellated Connectomes..."

ParcellationLabel="$StudyFolder/91282_Greyordinates/147_parcels.dlabel.nii"
${Caret7_command} -cifti-parcellate $ResultsFolder/${OutFileName} ${ParcellationLabel} COLUMN $ParcelsFolder/${OutFileTemp}_RSN.pdconn.nii
${Caret7_command} -cifti-parcellate $ParcelsFolder/${OutFileTemp}_RSN.pdconn.nii ${ParcellationLabel} ROW $ParcelsFolder/${OutFileTemp}_RSN.pconn.nii

ParcellationLabel="$StudyFolder/91282_Greyordinates/Surfaces_and_subcortex.dlabel.nii"
${Caret7_command} -cifti-parcellate $ResultsFolder/${OutFileName} ${ParcellationLabel} COLUMN $ParcelsFolder/${OutFileTemp}_Subctx.pdconn.nii
${Caret7_command} -cifti-parcellate $ParcelsFolder/${OutFileTemp}_Subctx.pdconn.nii ${ParcellationLabel} ROW $ParcelsFolder/${OutFileTemp}_Subctx.pconn.nii

ParcellationLabel="${ParcelsFolder}/${Subject}.aparc.32k_fs_LR_sep.dlabel.nii"
if  [ -f ${ParcellationLabel} ]; then
    ${Caret7_command} -cifti-parcellate $ResultsFolder/${OutFileName} ${ParcellationLabel} COLUMN $ParcelsFolder/${OutFileTemp}_FS.pdconn.nii
    ${Caret7_command} -cifti-parcellate $ParcelsFolder/${OutFileTemp}_FS.pdconn.nii ${ParcellationLabel} ROW $ParcelsFolder/${OutFileTemp}_FS.pconn.nii
fi

ParcellationLabel="${ParcelsFolder}/${Subject}.aparc.a2009s.32k_fs_LR_sep.dlabel.nii"
if  [ -f ${ParcellationLabel} ]; then
    ${Caret7_command} -cifti-parcellate $ResultsFolder/${OutFileName} ${ParcellationLabel} COLUMN $ParcelsFolder/${OutFileTemp}_FSa2009.pdconn.nii
    ${Caret7_command} -cifti-parcellate $ParcelsFolder/${OutFileTemp}_FSa2009.pdconn.nii ${ParcellationLabel} ROW $ParcelsFolder/${OutFileTemp}_FSa2009.pconn.nii
fi
