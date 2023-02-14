for Subject in $Subjlist; do
  TD=$StudyFolder/$Subject/T1w
  for hemi in lh rh; do
    mris_convert --cras_correction $TD/$Subject/surf/${hemi}.white $TD/$Subject/surf/${hemi}.white.surf.gii
    wb_command -create-signed-distance-volume $TD/$Subject/surf/${hemi}.white.surf.gii \
    $TD/T1w_acpc_dc_restore_brain.nii.gz $TD/${hemi}.WM.nii.gz
    fslmaths $TD/${hemi}.WM.nii.gz -uthr 0 -abs -bin $TD/${hemi}.WM.nii.gz
  done
  fslmaths $TD/lh.WM.nii.gz -add $TD/rh.WM.nii.gz -bin $TD/WM.nii.gz
  rm $TD/lh.WM.nii.gz
  rm $TD/rh.WM.nii.gz
