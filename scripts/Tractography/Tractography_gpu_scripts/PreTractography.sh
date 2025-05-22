#!/bin/bash

scriptsdir=${HCPPIPEDIR_dMRITract}

if [ "$2" == "" ];then
    echo ""
    echo "usage: $0 <StudyFolder> <Subject>"
    echo "       T1w and MNINonLinear folders are expected within <StudyFolder>/<Subject>"
    echo ""
    exit 1
fi

StudyFolder=$1
Subject=$2  

WholeBrainTrajectoryLabels=${HCPPIPEDIR_Config}/WholeBrainFreeSurferTrajectoryLabelTableLut.txt
LeftCerebralTrajectoryLabels=${HCPPIPEDIR_Config}/LeftCerebralFreeSurferTrajectoryLabelTableLut.txt 
RightCerebralTrajectoryLabels=${HCPPIPEDIR_Config}/RightCerebralFreeSurferTrajectoryLabelTableLut.txt
FreeSurferLabels=${HCPPIPEDIR_Config}/FreeSurferAllLut.txt


T1wDiffusionFolder="${StudyFolder}/${Subject}/T1w/Diffusion"
DiffusionResolution=`${FSLDIR}/bin/fslval ${T1wDiffusionFolder}/data pixdim1`
DiffusionResolution=`printf "%0.2f" ${DiffusionResolution}`
LowResMesh=32
StandardResolution="2"

#Needed for making the fibre connectivity file in Diffusion space
#${scriptsdir}/MakeTrajectorySpace.sh \
#    --path="$StudyFolder" --subject="$Subject" \
#    --wholebrainlabels="$WholeBrainTrajectoryLabels" \
#    --leftcerebrallabels="$LeftCerebralTrajectoryLabels" \
#    --rightcerebrallabels="$RightCerebralTrajectoryLabels" \
#   --diffresol="${DiffusionResolution}" \
#    --freesurferlabels="${FreeSurferLabels}"

#${scriptsdir}/MakeWorkbenchUODFs.sh --path="${StudyFolder}" --subject="${Subject}" --lowresmesh="${LowResMesh}" --diffresol="${DiffusionResolution}"


#Create lots of files in MNI space used in tractography
${scriptsdir}/MakeTrajectorySpace_MNI.sh \
    --path="$StudyFolder" --subject="$Subject" \
    --wholebrainlabels="$WholeBrainTrajectoryLabels" \
    --leftcerebrallabels="$LeftCerebralTrajectoryLabels" \
    --rightcerebrallabels="$RightCerebralTrajectoryLabels" \
    --standresol="${StandardResolution}" \
    --freesurferlabels="${FreeSurferLabels}" \
    --lowresmesh="${LowResMesh}"

