#!/bin/bash
set -e

# how to run this script
#  sh /Users/neichert/code/NHPPipelines/Examples/Scripts/prep_NE.sh

# Before running the pipeline make all scripts executable
#chmod u+x -R /vols/Scratch/neichert/NHPPipelines/*
# but don't track this in Git:
# git config core.filemode false

if [[ $OSTYPE == "linux" ]] ; then
  origdir=/vols/Scratch/neichert/site-ucdavis
  StudyFolder=/vols/Scratch/neichert/site-ucdavis/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  #RUN='fsl_sub -q short.q -N INIT sh'
  RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  origdir=/Users/neichert/Downloads/site-ucdavis
  StudyFolder=/Users/neichert/Downloads/site-ucdavis/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
  RUN='sh'
fi

# source this first outside of script
. $ScriptsDir/SetUpHCPPipelineNHP.sh

Subjlist="sub-032128" #CHANGE!!
Task="CLEAN" # "INIT" "PRE" "FREE" "POST" "CLEAN"

# run the "RENAME" task
if [[ $Task = "INIT" ]] ; then
  for Subject in $Subjlist; do
    ${RUN} $ScriptsDir/PrePreFreeSurfer_NE.sh $origdir $Subject
  done
fi
# check the output of INIT by inspecting:
# $StudyFolder/$Subject/RawData/${Subject}_ses-001_run-1_T2w_SPC1_brain.nii.gz
#  It doesn't need to be perfect


## run the "PRE-FREESURFER" task
if [[ $Task = "PRE" ]] ; then
  ${RUN} $ScriptsDir/PreFreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi
#
# check the output of PRE by inspecting:
# $StudyFolder/$Subject/MNINonLinear/T1w_restore_brain.nii.gz

## run the "FREESURFER" task
if [[ $Task = "FREE" ]] ; then
  ${RUN} $ScriptsDir/FreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi
#
## run the "POST-FREESURFER" task
if [[ $Task = "POST" ]] ; then
   ${RUN} $ScriptsDir/PostFreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi