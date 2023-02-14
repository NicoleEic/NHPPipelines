#!/bin/bash
set -e
umask u+rw,g+rw # give group read/write permissions to all new files

origdir=$1
Subject=$2

echo " "
echo "Subject: $Subject"
echo "origdir: $origdir"

if [[ $OSTYPE == "linux" ]] ; then
  EnvironmentScript="/vols/Scratch/neichert/NHPPipelines/Examples/Scripts/SetUpHCPPipelineNHP.sh"
elif [[ $OSTYPE == "darwin" ]] ; then
  EnvironmentScript="/Users/neichert/code/NHPPipelines/Examples/Scripts/SetUpHCPPipelineNHP.sh"
fi

. ${EnvironmentScript}


dir=${origdir}/derivatives/${Subject}/RawData
if [[ ! -e $dir ]]; then
    mkdir -p $dir
    echo $dir
else
    echo "$dir already exists"
fi

imcp ${origdir}/${Subject}/ses-001/anat/${Subject}_ses-001_run-1_T1w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz
imcp ${origdir}/${Subject}/ses-001/anat/${Subject}_ses-001_run-1_T2w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz


$MRCATDIR/core/bet_macaque.sh ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz ${dir}/${Subject}_ses-001_run-1_T1w_MPR1  -fTP 0.8 -fFP 0.8 -f 0.3
fslmaths ${dir}/${Subject}_ses-001_run-1_T1w_MPR1_brain.nii.gz -bin -dilD -dilD -dilD ${dir}/brain_mask.nii.gz
#flirt -dof 6 -in ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz -ref ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -omat ${dir}/mat.mat
# assuming T1w and T2w overlap already
echo 'get T2w brain mask'
applywarp -i ${dir}/brain_mask.nii.gz -o ${dir}/brain_maskT2.nii.gz -r ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz --usesqform
fslmaths ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -mas ${dir}/brain_maskT2.nii.gz ${dir}/${Subject}_ses-001_run-1_T2w_SPC1_brain.nii.gz
echo 'done'
