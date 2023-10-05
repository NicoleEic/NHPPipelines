#!/bin/bash

# Wrapper to run NHP-HCP structural pipeline and surface fMRI processing

set -e
umask u+rw,g+rw # give group read/write permissions to all new files

# Before running the pipeline for the first time make all scripts executable
#chmod u+x -R /vols/Scratch/neichert/NHPPipelines/*
# but don't track this in Git:
# git config core.filemode false

# Requirements for this script
#  installed versions of: FSL5.0.2 or higher , FreeSurfer (version 5.2 or higher) , gradunwarp (python code from MGH)
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

dataset='Jerome'
origdir=/vols/Data/sj/Nicole/${dataset}
SD=$origdir/derivatives
ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
logdir=/vols/Data/sj/Nicole/${dataset}/logs

EnvironmentScript="$ScriptsDir/SetUpHCPPipelineNHP.sh"
. ${EnvironmentScript}

cd $origdir


if [[ $dataset = 'site-ucdavis' ]] ; then
    subj_list_tot="sub-032125 sub-032126 sub-032127 sub-032128 sub-032129 \
                   sub-032130 sub-032131 sub-032132 sub-032133 sub-032134 \
                   sub-032135 sub-032136 sub-032137 sub-032138 sub-032139 \
                   sub-032140 sub-032141 sub-032142 sub-032143"
    task_list="run-1_func_cleaned run-2_func_cleaned"
elif [[ $dataset = 'site-newcastle' ]] ; then
    subj_list_tot="sub-032097 sub-032100 sub-032102 sub-032104 sub-032105 \
                   sub-032106 sub-032107 sub-032108 sub-032109 sub-032110"
    task_list="run-1_func_cleaned run-2_func_cleaned"

elif [[ $dataset = 'Jerome' ]] ; then
    subj_list_tot='orson orvil puzzle sadif tickle tim travis valhalla voodoo winky'
    task_list="run-1_func_cleaned"
fi
# -----------------------
# How to run this script
# -----------------------
#  sh /vols/Scratch/neichert/NHPPipelines/Examples/Scripts/the_wrapper_of_wrappers.sh

Task="fMRIS" # "INIT" "PRE" "FREE" "POST" "fMRIS"
#subj_list=$subj_list_tot
subj_list="orvil puzzle sadif tickle tim travis valhalla voodoo winky"
#subj_list="orson"
#subj_list=("${subj_list_tot[@]/'sub-032107'}")

# -----------------------
# GET INITIAL BRAIN MASK
# -----------------------
if [[ $Task = "INIT" ]] ; then
  RUN1='fsl_sub -q veryshort.q -N INIT -l '$logdir
  RUN2='fsl_sub -q veryshort.q -j INIT -N INIT_check -l '$logdir
  #RUN1=''
  #RUN2=''
  cmd_str=''
  for subj in $subj_list; do
    ${RUN1} $ScriptsDir/PrePreFreeSurfer_NE.sh $origdir $subj
    D=$SD/$subj/RawData
    cmd_str="$cmd_str $D/${subj}_ses-00_run-1_T1w_MPR1 $D/T1w_brain_mask.nii.gz"
  done
  ${RUN2} slicesdir -o $cmd_str
fi
# firefox /vols/Data/sj/Nicole/site-ucdavis/slicesdir/index.html
#subj='sub-032105'; D=/vols/Data/sj/Nicole/site-newcastle/derivatives/${subj}/RawData/ ; fsleyes $D/${subj}_ses-00_run-1_T1w_MPR1 $D/${subj}_ses-00_run-1_T2w_SPC1 $D/init_brain_mask -cm red-yellow -a 20

# -----------------------
# RUN PRE STAGE
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
# wb_view $SD/*/MNINonLinear/fsaverage_LR10k/*.*.pial.10k_fs_LR.surf.gii


if [[ $Task = "fMRIS" ]] ; then
  $ScriptsDir/GenericfMRISurfaceProcessingPipelineBatchNHP.sh $SD "${subj_list[@]}" "${task_list[@]}"
fi
