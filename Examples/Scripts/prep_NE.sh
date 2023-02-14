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
Task="CLEAN" # "INIT" "PRE" "FREE" "POST" "CLEAN"

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
gi