#!/bin/bash
set -e
umask u+rw,g+rw # give group read/write permissions to all new files

origdir=$1
subj=$2

echo " "
echo "subj: $subj"
echo "origdir: $origdir"

if [[ $OSTYPE == "linux" ]] ; then
  EnvironmentScript="/vols/Scratch/neichert/NHPPipelines/Examples/Scripts/SetUpHCPPipelineNHP.sh"
elif [[ $OSTYPE == "darwin" ]] ; then
  EnvironmentScript="/Users/neichert/code/NHPPipelines/Examples/Scripts/SetUpHCPPipelineNHP.sh"
fi

. ${EnvironmentScript}


dir=${origdir}/derivatives/${subj}/RawData
if [[ ! -e $dir ]]; then
    mkdir -p $dir
    echo $dir
else
    echo "$dir already exists"
fi


if [[ "$origdir" == *"newcastle"* ]] ; then
    case $subj in
        'sub-032097' )
            ses='002' ;;
         'sub-032100' )
            ses='003' ;;
         'sub-032102')
            ses='002' ;;
         'sub-032104')
            ses='003' ;;
            *)
            ses='001' ;;
    esac
    settings='-f 0.2 -fTP 0.05 -fFP 0.1 -s 75'
elif [[ "$origdir" == *"davis"* ]] ; then
    settings='-fTP 0.8 -fFP 0.8 -f 0.3'
    ses='001'
fi


if [[ "$origdir" == *"newcastle"* ]] ; then
    imcp ${origdir}/${subj}/ses-${ses}/anat/${subj}_ses-${ses}_run-1_T1w.nii.gz ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz
    imcp ${origdir}/${subj}/ses-${ses}/anat/${subj}_ses-${ses}_run-1_T2w.nii.gz ${dir}/${subj}_ses-00_run-1_T2w_SPC1.nii.gz

    # based on T1w
    #$MRCATDIR/core/bet_macaque.sh ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz ${dir}/init -m $settings
    # based on T2w
    #$MRCATDIR/core/bet_macaque.sh ${dir}/${subj}_ses-00_run-1_T2w_SPC1.nii.gz ${dir}/init

    # based on T1w/T2w
    #fslmaths ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz -div ${dir}/${subj}_ses-00_run-1_T2w_SPC1.nii.gz ${dir}/T1wDividedByT2w
    #fslmaths ${dir}/T1wDividedByT2w -mas ${dir}/init_brain_mask ${dir}/T1wDividedByT2w_init
    #$MRCATDIR/core/bet_macaque.sh ${dir}/T1wDividedByT2w_init ${dir}/T1w
    echo 'use manual brain mask'
    cp ${dir}/T1w_brain_mask_NE.nii.gz ${dir}/T1w_brain_mask.nii.gz

elif [[ "$origdir" == *"davis"* ]] ; then
    imcp ${origdir}/${subj}/ses-001/anat/${subj}_ses-${ses}_run-1_T1w.nii.gz ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz
    imcp ${origdir}/${subj}/ses-001/anat/${subj}_ses-${ses}_run-1_T2w.nii.gz ${dir}/${subj}_ses-00_run-1_T2w_SPC1.nii.gz
    $MRCATDIR/core/bet_macaque.sh ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz ${dir}/T1w -m $settings
elif [[ "$origdir" == *"Jerome"* ]] ; then
    echo 'use restored brain and brainmask from other pipeline'
    img=/vols/Scratch/neichert/monkeyRS/${subj}/structural/struct_restore.nii.gz
    sh $MRCATDIR/core/swapdims.sh $img x y z ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz 'image'

    img=/vols/Scratch/neichert/monkeyRS/${subj}/structural/struct_brain_mask.nii.gz
    sh $MRCATDIR/core/swapdims.sh $img x y z ${dir}/T1w_brain_mask.nii.gz 'image'

    # reuse T1w as T2w.......
    imcp ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz ${dir}/${subj}_ses-00_run-1_T2w_SPC1.nii.gz
fi

fslmaths ${dir}/${subj}_ses-00_run-1_T1w_MPR1 -mas ${dir}/T1w_brain_mask $dir/${subj}_ses-00_run-1_T1w_MPR1_brain

#flirt -dof 6 -in ${dir}/${subj}_ses-00_run-1_T1w_MPR1.nii.gz -ref ${dir}/${subj}_ses-00_run-1_T2w_SPC1.nii.gz -omat ${dir}/mat.mat
# assuming T1w and T2w overlap already:
echo 'get T2w brain mask'
applywarp -i ${dir}/T1w_brain_mask -o ${dir}/T2w_brain_mask -r ${dir}/${subj}_ses-00_run-1_T2w_SPC1 --usesqform
fslmaths ${dir}/${subj}_ses-00_run-1_T2w_SPC1 -mas ${dir}/T2w_brain_mask ${dir}/${subj}_ses-00_run-1_T2w_SPC1_brain
echo 'done'
