#!/bin/bash
set -e

#  sh /Users/neichert/code/NHPPipelines/Examples/Scripts/prep_NE.sh


if [[ $OSTYPE == "linux" ]] ; then
  origdir=/vols/Scratch/neichert/site-ucdavis
  StudyFolder=/vols/Scratch/neichert/site-ucdavis/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  RUN='fsl_sub -q veryshort.q sh'
  RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  origdir=/Users/neichert/Downloads/site-ucdavis
  StudyFolder=/Users/neichert/Downloads/site-ucdavis/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
  RUN='sh'
fi

# source this first outside of script
#source $ScriptsDir/SetUpHCPPipelineNHP.sh

Subjlist="sub-032128" #CHANGE!!
Task="POST" # "INIT" "PRE" "FREE" "POST" "CLEAN"

# run the "RENAME" task
if [[ $Task = "INIT" ]] ; then
  for Subject in $Subjlist; do
    ${RUN} $ScriptsDir/PrePreFreeSurfer_NE.sh $origdir $Subject
  done
fi

## run the "PRE-FREESURFER" task
if [[ $Task = "PRE" ]] ; then
  ${RUN} $ScriptsDir/PreFreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi
#
## run the "FREESURFER" task
if [[ $Task = "FREE" ]] ; then
  ${RUN} $ScriptsDir/FreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi
#
## run the "POST-FREESURFER" task
if [[ $Task = "POST" ]] ; then
   ${RUN} $ScriptsDir/PostFreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi
#
## run the "CLEAN-UP" task
#if [[ $Task = "CLEAN" ]] ; then
#  $ScriptsDir/CleanupStructuralPipelineBatchNHP.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi


#fslmaths /Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/T1w/T1w_acpc_dc_restore_brain.nii.gz \
#-div \
#/Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/T1w/T2w_acpc_dc_restore_brain.nii.gz \
#/Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/test.nii.gz

#wb_command -volume-to-surface-mapping /Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/test.nii.gz \
#/Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/T1w/Native/sub-032128.L.midthickness.native.surf.gii \
#/Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/test.func.gii -myelin-style \

