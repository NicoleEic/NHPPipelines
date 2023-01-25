#!/bin/bash
set -e

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
Task="FREE" # "INIT" "PRE" "FREE" "POST" "CLEAN"

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
#if [[ $Task = "POST" ]] ; then
#  $ScriptsDir/PostFreeSurferPipelineBatchNHP.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
#
## run the "CLEAN-UP" task
#if [[ $Task = "CLEAN" ]] ; then
#  $ScriptsDir/CleanupStructuralPipelineBatchNHP.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi


mri_em_register -rusage \
/Users/neichert/Downloads/site-ucdavis/derivatives/sub-032128/touch/rusage.mri_em_register.dat \
-uns 3 -mask brainmask.mgz nu.mgz \
/Users/neichert/code/NHPPipelines/global/templates/MacaqueYerkes19/RB_all_2008-03-26.gca transforms/talairach.lta