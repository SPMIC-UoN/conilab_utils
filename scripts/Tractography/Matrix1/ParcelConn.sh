#!/bin/bash

Caret7_command=/usr/local/workbench/bin_rh_linux64/wb_command

if [ "$3" == "" ];then
    echo ""
    echo "usage: $0 <StudyFolder> <Subject> <OutFileName>"
    echo "Get Parcellated Connectomes"
    exit 1
fi

StudyFolder=$1          # "$1" #Path to Generic Study folder
Subject=$2              # "$2" #SubjectID
OutFileName=$3

ResultsFolder=${StudyFolder}/Diffusion/${Subject}/MNINonLinear/Results/TractographyMat1/Results
ParcelsFolder=${ResultsFolder}/Parcellated
mkdir -p $ParcelsFolder
OutFileTemp=`echo ${OutFileName//".dconn.nii"/""}`
# Uses both FreeSurfer parcellations and Glasser
# Takes mean, sum and non-zero parcellations

dconn_parc () {
    Subject=$1
    ResultsFolder=$2
    ParcellationLabel=$3
    ParcName=$4
    Method=$5
    OutFileName=$6

    OutFileTemp=`echo ${OutFileName//".dconn.nii"/""}`
    if  [ -f ${ParcellationLabel} ]; then
	echo "${ParcName} parc..."
	echo ${Method}
	${Caret7_command} -cifti-parcellate $ResultsFolder/${OutFileName} ${ParcellationLabel} COLUMN $ParcelsFolder/${OutFileTemp}.pdconn.nii -method ${Method}
	${Caret7_command} -cifti-parcellate $ParcelsFolder/${OutFileTemp}.pdconn.nii ${ParcellationLabel} ROW $ParcelsFolder/${OutFileTemp}_${ParcName}_${Method}.pconn.nii -method ${Method}  
    fi
}

# FreeSurfer 34
ParcellationLabel="${StudyFolder}/Structural/${Subject}/MNINonLinear/fsaverage_LR32k/${Subject}.aparc.32k_fs_LR.dlabel.nii"
ParcName="FS34"
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} SUM ${OutFileName}
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} MEAN ${OutFileName}
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} COUNT_NONZERO ${OutFileName}

# FreeSurfer 2009a
ParcellationLabel="${StudyFolder}/Structural/${Subject}/MNINonLinear/fsaverage_LR32k/${Subject}.aparc.a2009s.32k_fs_LR.dlabel.nii"
ParcName="FS2009"
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} SUM ${OutFileName}
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} MEAN ${OutFileName}
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} COUNT_NONZERO ${OutFileName}

# Glasser
ParcellationLabel="/data/Q1200/Structural/Glasser_et_al_2016_HCP_MMP1.0_RVVG/Glasser_parc_LR.dlabel.nii"
ParcName="Glass"
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} SUM ${OutFileName}
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} MEAN ${OutFileName}
dconn_parc ${Subject} ${ResultsFolder} ${ParcellationLabel} ${ParcName} COUNT_NONZERO ${OutFileName}

rm $ParcelsFolder/${OutFileTemp}.pdconn.nii
