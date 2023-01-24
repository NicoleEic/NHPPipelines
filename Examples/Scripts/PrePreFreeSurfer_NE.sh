StudyFolder=$1
Subject=$2

echo " "
echo "Subject: Subject"
mkdir -p ${StudyFolder}/derivatives/${Subject}/RawData
dir=${StudyFolder}/derivatives/${Subject}/RawData
imcp ${StudyFolder}/${Subject}/ses-001/anat/sub-032128_ses-001_run-1_T1w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz
imcp ${StudyFolder}/${Subject}/ses-001/anat/sub-032128_ses-001_run-1_T2w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz
$MRCATDIR/core/bet_macaque.sh ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz ${dir}/${Subject}_ses-001_run-1_T1w_MPR1
fslmaths ${dir}/${Subject}_ses-001_run-1_T1w_MPR1_brain.nii.gz -bin -dilD -dilD -dilD ${dir}/brain_mask.nii.gz
#flirt -dof 6 -in ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz -ref ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -omat ${dir}/mat.mat
# assuming T1w and T2w overlap already
applywarp -i ${dir}/brain_mask.nii.gz -o ${dir}/brain_maskT2.nii.gz -r ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz --usesqform
fslmaths ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -mas ${dir}/brain_maskT2.nii.gz ${dir}/${Subject}_ses-001_run-1_T2w_SPC1_brain.nii.gz
echo 'done'