#!/bin/bash

if [[ $OSTYPE == "linux" ]] ; then
  StudyFolder=/vols/Scratch/neichert/site-ucdavis
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  #RUN='fsl_sub -q veryshort.q sh'
  RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  StudyFolder=/Users/neichert/Downloads/site-ucdavis
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
  RUN='sh'
fi

# source this first outside of script
#source $ScriptsDir/SetUpHCPPipelineNHP.sh

Subjlist="sub-032128" #CHANGE!!
Task="INIT" # "INIT" "PRE" "FREE" "POST" "CLEAN"

# run the "RENAME" task
if [[ $Task = "INIT" ]] ; then
  for Subject in $Subjlist; do
    ${RUN} $ScriptsDir/PrePreFreeSurfer_NE.sh $StudyFolder $Subject
  done
fi

## run the "PRE-FREESURFER" task
if [[ $Task = "PRE" ]] ; then
  $ScriptsDir/PreFreeSurferPipelineBatch.sh \
  --StudyFolder="$StudyFolder" \
  --SubjList="$Subjlist"
fi
#
## run the "FREESURFER" task
if [[ $Task = "FREE" ]] ; then
  $ScriptsDir/FreeSurferPipelineBatch.sh \
  --StudyFolder="$StudyFolder" \
  --SubjList="$Subjlist"
fi
#
## run the "POST-FREESURFER" task
#if [[ $Task = "POST" ]] ; then
#  $ScriptsDir/PostFreeSurferPipelineBatch.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
#
## run the "CLEAN-UP" task
#if [[ $Task = "CLEAN" ]] ; then
#  $ScriptsDir/CleanupStructuralPipelineBatch.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
