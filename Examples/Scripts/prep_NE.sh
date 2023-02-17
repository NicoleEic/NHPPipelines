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
  SD=$origdir/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  logdir=/vols/Data/sj/Nicole/site-ucdavis/logs

elif [[ $OSTYPE == "darwin" ]] ; then
  origdir=/Users/neichert/Downloads/site-ucdavis
  SD=$origdir/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
fi

EnvironmentScript="$ScriptsDir/SetUpHCPPipelineNHP.sh"
. ${EnvironmentScript}

cd $origdir

subj_list_tot="sub-032125 sub-032126 sub-032127 sub-032128 sub-032129 \
               sub-032130 sub-032131 sub-032132 sub-032133 sub-032134 \
               sub-032135 sub-032136 sub-032137 sub-032138 sub-032139 \
               sub-032140 sub-032141 sub-032142 sub-032143"

Task="POST" # "INIT" "PRE" "FREE" "POST"
subj_list=$subj_list_tot

# -----------------------
# GET INITIAL BRAIN MASK
# -----------------------
if [[ $Task = "INIT" ]] ; then
  RUN1='fsl_sub -q veryshort.q -N INIT -l '$logdir
  RUN2='fsl_sub -q veryshort.q -j INIT -N INIT_check -l '$logdir
  cmd_str=''
  for subj in $subj_list; do
    ${RUN1} $ScriptsDir/PrePreFreeSurfer_NE.sh $origdir $subj
    D=$SD/$subj/RawData
    cmd_str="$cmd_str $D/${subj}_ses-001_run-1_T2w_SPC1 $D/brain_maskT2.nii.gz"
  done
  ${RUN2} slicesdir -o $cmd_str
fi
# firefox /vols/Data/sj/Nicole/site-ucdavis/slicesdir/index.html

# -----------------------
# RUN PRE STAGE
# -----------------------
if [[ $Task = "PRE" ]] ; then
  $ScriptsDir/PreFreeSurferPipelineBatchNHP.sh $SD "${subj_list[@]}"

  # check pre stage
  RUN='fsl_sub -q veryshort.q -j PRE -N PRE_check -l '$logdir
  cmd_str=''
  for subj in $subj_list; do
    TD=$SD/$subj/T1w
    cmd_str="$cmd_str $TD/T1w_acpc_dc_restore.nii.gz $TD/T1w_acpc_brain_mask.nii.gz"
  done
  ${RUN} slicesdir -o $cmd_str
fi
# firefox /vols/Data/sj/Nicole/site-ucdavis/slicesdir/index.html &

if [[ $Task = 'test_bet' ]]; then
    T1wImage='T1w_acpc'

    cmd_str="fsl_sub -q veryshort.q -j bet -N bet_check -l ${logdir} slicesdir -o "
    for subj in $subj_list; do
        fTP=0.5
        fFP=0.8
        f=0.3
        [[ $subj == 'sub-032126' ]] && fTP=0.55; f=0.25
        [[ $subj == 'sub-032129' ]] && fTP=0.75
        [[ $subj == 'sub-032131' ]] && fTP=0.85
        [[ $subj == 'sub-032132' ]] && fTP=0.6
        [[ $subj == 'sub-032135' ]] && fTP=0.3
        [[ $subj == 'sub-032138' ]] && fTP=0.8
        [[ $subj == 'sub-032141' ]] && fTP=0.8
        [[ $subj == 'sub-032142' ]] && fTP=0.9

        T1wFolder=$SD/$subj/T1w
        fsl_sub -q veryshort.q -l $logdir -N bet $MRCATDIR/core/bet_macaque.sh ${T1wFolder}/${T1wImage} -fTP $fTP -fFP $fFP -f $f
        cmd_str="${cmd_str} ${T1wFolder}/${T1wImage} ${T1wFolder}/${T1wImage}_brain_mask"
    done
    $cmd_str
fi

# -----------------------
# RUN FREE STAGE
# -----------------------
if [[ $Task = "FREE" ]] ; then
  $ScriptsDir/FreeSurferPipelineBatchNHP.sh $SD "${subj_list[@]}"

  # to hold
  RUN='fsl_sub -q veryshort.q -N FREE_check -j FREE -l '$logdir
  RUN2='fsl_sub -q veryshort.q -j FREE_check -N FREE_c2 -l '$logdir
  cmd_str=''
  for subj in $subj_list; do
    ${RUN} sh $ScriptsDir/FreeSurfer_check_NE.sh $SD $subj
    D=$SD/$subj/T1w
    cmd_str="$cmd_str $D/T1w_acpc_dc_restore.nii.gz $D/WM.nii.gz"
  done
  ${RUN2} slicesdir -o $cmd_str
fi
# firefox /vols/Data/sj/Nicole/site-ucdavis/slicesdir/index.html

## run the "POST-FREESURFER" task
if [[ $Task = "POST" ]] ; then
  $ScriptsDir/PostFreeSurferPipelineBatchNHP.sh $SD $subj_list
fi
# wb_view $SD/
