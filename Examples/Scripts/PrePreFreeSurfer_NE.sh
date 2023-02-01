StudyFolder=$1
Subject=$2

echo " "
echo "Subject: $Subject"
echo "StudyFolder: $StudyFolder"


dir=${StudyFolder}/derivatives/${Subject}/RawData
if [[ ! -e $dir ]]; then
    mkdir -p $dir
    echo $dir
else
    echo "$dir already exists"
fi



imcp ${StudyFolder}/${Subject}/ses-001/anat/${Subject}_ses-001_run-1_T1w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz
imcp ${StudyFolder}/${Subject}/ses-001/anat/${Subject}_ses-001_run-1_T2w.nii.gz  ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz
if [[ $Subject = 'sub-032128' ]]; then
  f=0.38
else
  f=0.2
fi
$MRCATDIR/core/bet_macaque.sh ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz ${dir}/${Subject}_ses-001_run-1_T1w_MPR1 -f $f
fslmaths ${dir}/${Subject}_ses-001_run-1_T1w_MPR1_brain.nii.gz -bin -dilD -dilD -dilD ${dir}/brain_mask.nii.gz
#flirt -dof 6 -in ${dir}/${Subject}_ses-001_run-1_T1w_MPR1.nii.gz -ref ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -omat ${dir}/mat.mat
# assuming T1w and T2w overlap already
applywarp -i ${dir}/brain_mask.nii.gz -o ${dir}/brain_maskT2.nii.gz -r ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz --usesqform
fslmaths ${dir}/${Subject}_ses-001_run-1_T2w_SPC1.nii.gz -mas ${dir}/brain_maskT2.nii.gz ${dir}/${Subject}_ses-001_run-1_T2w_SPC1_brain.nii.gz
echo 'done'
