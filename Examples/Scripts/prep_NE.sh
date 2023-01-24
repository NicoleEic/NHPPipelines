#!/bin/bash

if [[ $OSTYPE == "linux" ]] ; then
  StudyFolder=/vols/Scratch/neichert/site-ucdavis
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
elif [[ $OSTYPE == "darwin" ]] ; then
  StudyFolder=/Users/neichert/Downloads/site-ucdavis
  BatchFolder=/Users/neichert/code/NHPPipelines/Examples/Scripts
fi

Subjlist="sub-032128" #CHANGE!!
Task="INIT" # "INIT" "PRE" "FREE" "POST" "CLEAN"

# run the "RENAME" task
if [[ $Task = "INIT" ]] ; then
    for $Subject in $Subjlist; do
      echo " "
      echo "Subject: $subj"

      mkdir -p ${StudyFolder}/derivatives/${Subject}/RawData
      dir=${StudyFolder}/derivatives/${Subject}/RawData
      imcp ${StudyFolder}/${Subject}/ses-001/anat/sub-032128_ses-001_run-1_T1w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz
      imcp ${StudyFolder}/${Subject}/ses-001/anat/sub-032128_ses-001_run-1_T2w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz
      $MRCATDIR/core/bet_macaque.sh ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz ${dir}/${Subject}_ses-001_run-1_T1w_MPR1
      fslmaths ${dir}/${Subject}_ses-001_run-1_T1w_MPR1_brain.nii.gz -bin -dilD -dilD -dilD ${dir}/brain_mask.nii.gz
      #flirt -dof 6 -in ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz -ref ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -omat ${dir}/mat.mat
      applywarp -i ${dir}/brain_mask.nii.gz -o ${dir}/brain_maskT2.nii.gz -r ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz --usesqform
      fslmaths ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -mas ${dir}/brain_maskT2.nii.gz ${dir}/${Subject}_ses-001_run-1_T2w_SPC1_brain.nii.gz
    done
  echo "MRI structural images are prepared and ready for the HCP pipeline."
fi


## run the "PRE-FREESURFER" task
#if [[ $Task = "PRE" ]] ; then
#  $BatchFolder/PreFreeSurferPipelineBatch.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
#
## run the "FREESURFER" task
#if [[ $Task = "FREE" ]] ; then
#  $BatchFolder/FreeSurferPipelineBatch.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
#
## run the "POST-FREESURFER" task
#if [[ $Task = "POST" ]] ; then
#  sh $BatchFolder/PostFreeSurferPipelineBatch.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
#
## run the "CLEAN-UP" task
#if [[ $Task = "CLEAN" ]] ; then
#  $BatchFolder/CleanupStructuralPipelineBatch.sh \
#  --StudyFolder="$StudyFolder" \
#  --SubjList="$Subjlist"
#fi
