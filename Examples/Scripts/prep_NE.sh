#!/bin/bash
set -e
umask u+rw,g+rw # give group read/write permissions to all new files

# -----------------------
# How to run this script
# -----------------------
#  sh /vols/Scratch/neichert/NHPPipelines/Examples/Scripts/prep_NE.sh

# Before running the pipeline make all scripts executable
#chmod u+x -R /vols/Scratch/neichert/NHPPipelines/*
# but don't track this in Git:
# git config core.filemode false

# Requirements for this script
#  installed versions of: FSL5.0.2 or higher , FreeSurfer (version 5.2 or higher) , gradunwarp (python code from MGH)
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

if [[ $OSTYPE == "linux" ]] ; then
  origdir=/vols/Data/sj/Nicole/site-ucdavis
  StudyFolder=$origdir/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  logdir=/vols/Data/sj/Nicole/site-ucdavis/logs

elif [[ $OSTYPE == "darwin" ]] ; then
  origdir=/Users/neichert/Downloads/site-ucdavis
  StudyFolder=$origdir/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
fi

EnvironmentScript="$ScriptsDir/SetUpHCPPipelineNHP.sh"
. ${EnvironmentScript}

cd $origdir

Subjlist_tot="sub-032125 sub-032126 sub-032127 sub-032128 sub-032129 \
          sub-032130 sub-032131 sub-032132 sub-032133 sub-032134 \
          sub-032135 sub-032136 sub-032137 sub-032138 sub-032139 \
          sub-032140 sub-032141 sub-032142 sub-032143"

Task="PRE" # "INIT" "PRE" "FREE" "POST"

# -----------------------
# GET INITIAL BRAIN MASK
# -----------------------
if [[ $Task = "INIT" ]] ; then
  Subjlist=$Subjlist_tot
  RUN1='fsl_sub -q veryshort.q -N INIT -l '$logdir
  RUN2='fsl_sub -q veryshort.q -j INIT -N INIT_check -l '$logdir
  cmd_str=''
  for Subject in $Subjlist; do
    ${RUN1} $ScriptsDir/PrePreFreeSurfer_NE.sh $origdir $Subject
    D=$StudyFolder/$Subject/RawData
    cmd_str="$cmd_str $D/${Subject}_ses-001_run-1_T2w_SPC1 $D/brain_maskT2.nii.gz"
  done
  ${RUN2} slicesdir -o $cmd_str
fi
# firefox /vols/Data/sj/Nicole/site-ucdavis/slicesdir/index.html

# -----------------------
# RUN PRE STAGE
# -----------------------
if [[ $Task = "PRE" ]] ; then
  Subjlist=$Subjlist_tot
  $ScriptsDir/PreFreeSurferPipelineBatchNHP.sh $StudyFolder "${Subjlist[@]}"

  # check pre stage
  RUN='fsl_sub -q veryshort.q -j PRE -N PRE_check -l '$logdir
  cmd_str=''
  for Subject in $Subjlist; do
    TD=$StudyFolder/$Subject/T1w
    cmd_str="$cmd_str $TD/T1w_acpc_dc_restore.nii.gz $TD/T1w_acpc_brain_mask.nii.gz"
  done
  ${RUN} slicesdir -o $cmd_str
fi
# firefox /vols/Data/sj/Nicole/site-ucdavis/slicesdir/index.html &

# -----------------------
# RUN FREE STAGE
# -----------------------
if [[ $Task = "FREE" ]] ; then
  Subjlist=( "${Subjlist_tot[@]/'sub-032143'}" )
  $ScriptsDir/FreeSurferPipelineBatchNHP.sh $StudyFolder "${Subjlist[@]}"
fi


## run the "POST-FREESURFER" task
if [[ $Task = "POST" ]] ; then
  Subjlist=$Subjlist_tot
  ${RUN} $ScriptsDir/PostFreeSurferPipelineBatchNHP.sh $StudyFolder $Subjlist
fi
