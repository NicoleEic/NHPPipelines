#!/bin/bash

echo "This script must be SOURCED to correctly setup the environment prior to running any of the other HCP scripts contained here"

# source /Users/neichert/code/NHPPipelines/Examples/Scripts/SetupHCPPipelineNHP.sh

# on jalapeno
if [[ $OSTYPE == "linux" ]] ; then
    #export FSLDIR=/opt/fmrib/fsl
    . ${FSLDIR}/etc/fslconf/fsl.sh
    export HCPPIPEDIR=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
    export FREESURFER_HOME=/opt/fmrib/FreeSurfer_releases/6.0/
    . ${FREESURFER_HOME}/SetUpFreeSurfer.sh > /dev/null 2>&1
    export CARET7DIR='/opt/fmrib/bin/wb_command'
    export MATLAB_HOME='/opt/fmrib/bin/matlab'

# local laptop
elif [[ $OSTYPE == "darwin" ]] ; then
    . ${FSLDIR}/etc/fslconf/fsl.sh
    export HCPPIPEDIR=/Users/neichert/code/NHPPipelines
    export FREESURFER_HOME=/Applications/freesurfer/7.3.2
    . ${FREESURFER_HOME}/SetUpFreeSurfer.sh > /dev/null 2>&1
    export CARET7DIR='/Applications/workbench/bin_macosx64/'
 export MATLAB_HOME='/Applications/MATLAB_R2022a.app/bin/matlab'
fi

export CLUSTER=2.0
export SPECIES='Macaque'

# Global
export HCPPIPEDIR_Templates=${HCPPIPEDIR}/global/templates
export HCPPIPEDIR_Bin=${HCPPIPEDIR}/global/binaries
export HCPPIPEDIR_Config=${HCPPIPEDIR}/global/config
export HCPPIPEDIR_PreFS=${HCPPIPEDIR}/PreFreeSurfer/scripts
export HCPPIPEDIR_FS=${HCPPIPEDIR}/FreeSurfer/scripts
export HCPPIPEDIR_PostFS=${HCPPIPEDIR}/PostFreeSurfer/scripts
export HCPPIPEDIR_fMRISurf=${HCPPIPEDIR}/fMRISurface/scripts
export HCPPIPEDIR_fMRIVol=${HCPPIPEDIR}/fMRIVolume/scripts
export HCPPIPEDIR_tfMRI=${HCPPIPEDIR}/tfMRI/scripts
export HCPPIPEDIR_dMRI=${HCPPIPEDIR}/DiffusionPreprocessing/scripts
export HCPPIPEDIR_dMRITract=${HCPPIPEDIR}/DiffusionTractography
export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/scripts
export HCPPIPEDIR_tfMRIAnalysis=${HCPPIPEDIR}/TaskfMRIAnalysis/scripts
export MATLAB_COMPILER_RUNTIME=/usr/local/MATLAB/MATLAB_Compiler_Runtime
export NSLOTS=8
export FreeSurferLabels="${HCPPIPEDIR_Config}/FreeSurferAllLut.txt"
#OS="`lsb_release -a | grep Distributor | awk '{print $3}'`"
OS='NE_local'
if [  "$OS" = "CentOS" ] ; then
  export MSMBINDIR=/mnt/pub/devel/MSM/MSM_HOCR_v2/Centos
elif [  "$OS" = "Ubuntu" ] ; then
  export MSMBINDIR=/mnt/devel/devel/MSM/MSM_HOCR_v2/Ubuntu
elif [  "$OS" = "NE_local" ] ; then
  #export MSMBINDIR=/Users/neichert/code/external/MSM_HOCR_macOSX
  #export MSMBINDIR=/Users/neichert/fsl/bin/
  export MSMBINDIR=/Users/neichert/code/external/MSM_HOCR_v2/MacOSX
fi
export MSMCONFIGDIR=$HCPPIPEDIR/MSMConfig
export FixDir=/mnt/pub/devel/bcil/fix1.06
export RegName="MSMSulc" # MSMSulc is recommended, if binary is not available use FS (FreeSurfer)

if [ "$SPECIES" = Human ] ; then

  #Examples/Scripts/PreFreeSurferPipeLineNHP.bat
  export BrainSize="150" #BrainSize in mm, 150 for humans, 60 for macaques, 40 for marmosets
  export T1wTemplate="${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm.nii.gz"
  export T1wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T1_0.7mm_brain.nii.gz"
  export T1wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T1_2.0mm"
  export T2wTemplate="${HCPPIPEDIR_Templates}/MNI152_T2w_0.7mm.nii.gz"
  export T2wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T2w_0.7mm_brain"
  export T2wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T2w_2.0mm"
  export TemplateMask="${HCPPIPEDIR_Templates}/MNI152_T1w_0.7mm_brain_mask.nii.gz"
  export Template2mmMask="${HCPPIPEDIR_Templates}/MNI152_T1w_2.0mm_brain_mask_dil.nii.gz"
  export GCAdir="${FREESURFER_HOME}/average"
  #Examples/Scripts/PostFreeSurferPipeLineNHP.bat
  export SurfaceAtlasDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases"
  export GrayordinatesSpaceDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases"
  export ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii"
  export LowResMesh="32" #Needs to match what is in PostFreeSurfer
  export FinalfMRIResolution="2.0" #Needs to match what is in fMRIVolume
  export SmoothingFWHM="2.0" #Recommended to be roughly the voxel size
  export GrayordinatesResolution="2.0" #Needs to match what is in PostFreeSurfer. Could be the same as FinalfRMIResolution something different, which will call a different module for subcortical processing
  export MyelinMappingFWHM="5"
  export SurfaceSmoothingFWHM="4"
  export CorrectionSigma=7

elif [ "$SPECIES" = Macaque ] ; then

  #Examples/Scripts/PreFreeSurferPipeLineNHP.bat
  export BrainSize="60" #BrainSize in mm, 150 for humans, 60 for macaques, 40 for marmosets
  export T1wTemplate="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_0.5mm_dedrift.nii.gz" #MacaqueYerkes0.5mm template
  export T1wTemplateBrain="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_0.5mm_brain_dedrift.nii.gz" #Brain extracted MacaqueYerkes0.5mm template
  export T1wTemplate2mm="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_1.0mm_dedrift" #MacaqueYerkes1.0mm template brain modified by Takuya Hayshi on Oct 24th 2015.
  export T2wTemplate="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_0.5mm_dedrift.nii.gz" #MacaqueYerkes0.5mm T2wTemplate
  export T2wTemplateBrain="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_0.5mm_brain_dedrift.nii.gz" #Brain extracted MacaqueYerkes0.5mm T2wTemplate
  export T2wTemplate2mm="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T2w_1.0mm_dedrift" #MacaqueYerkes1.0mm T2wTemplate brain, modified by Takuya Hayashi on Oct 24th 2015.
  export TemplateMask="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_0.5mm_brain_mask_dedrift.nii.gz" #Brain mask MacaqueYerkes0.5mm template
  export Template2mmMask="${HCPPIPEDIR_Templates}/MacaqueYerkes19_T1w_1.0mm_brain_mask_dedrift.nii.gz" #MacaqueYerkes1.0mm template
  export RescaleVolumeTransform="${HCPPIPEDIR_Templates}/fs_xfms/Macaque_rescale" #Transforms to undo the effects of faking the dimensions to 1mm
  export FNIRTConfig="${HCPPIPEDIR_Config}/T1_2_MNI_NHP.cnf"
  export GCAdir="${HCPPIPEDIR_Templates}/MacaqueYerkes19" #Template Dir with FreeSurfer NHP GCA and TIF files
  export SurfaceAtlasDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque_dedrift"
  export GrayordinatesSpaceDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque_dedrift"
  export ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque_dedrift/MacaqueYerkes19.MyelinMap_BC.164k_fs_LR.dscalar.nii"
  export LowResMesh="32@10" #Needs to match what is in PostFreeSurfer
  export FinalfMRIResolution="1.25" #Needs to match what is in fMRIVolume
  export SmoothingFWHM="1.25" #Recommended to be roughly the voxel size
  export GrayordinatesResolution="1.25" #Needs to match what is in PostFreeSurfer. Could be the same as FinalfRMIResolution something different, which will call a different module for subcortical processing
  export MyelinMappingFWHM="2"
  export SurfaceSmoothingFWHM="2"
  export CorrectionSigma="5"

elif [ "$SPECIES" = Marmoset ] ; then

  #Examples/Scripts/PreFreeSurferPipeLineNHP.bat=g
  export BrainSize="40" #BrainSize in mm, 150 for humans, 60 for macaques, 40 for marmosets
  export T1wTemplate="/mnt//devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT1w_restore_dedrift.nii.gz"
  export T1wTemplateBrain="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT1w_restore_dedrift_brain.nii.gz"
  export T1wTemplate2mm="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT1w_restore_dedrift_0.5mm.nii.gz"
  export T2wTemplate="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT2w_restore_dedrift.nii.gz"
  export T2wTemplateBrain="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT2w_restore_dedrift_brain.nii.gz"
  export T2wTemplate2mm="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT2w_restore_dedrift_0.5mm.nii.gz"
  export TemplateMask="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT1w_restore_dedrift_brain_mask_dilM.nii.gz"
  export Template2mmMask="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN/RIKENMarmoset15_AverageT1w_restore_dedrift_0.5mm_brain_mask_dilM.nii.gz"
  export FNIRTConfig="${HCPPIPEDIR_Config}/T1_2_MNI_NHP.cnf"
  export GCAdir="/mnt/devel/devel/NHPHCPPipeline/global/templates/MarmosetRIKEN"
  #export GCAdir="${HCPPIPEDIR_Templates}/MacaqueYerkes19" #Used for initialization of surfreg Takuya Hayashi Jan 2018
  export RescaleVolumeTransform="${HCPPIPEDIR_Templates}/fs_xfms/Marmoset_rescale"
  #Examples/Scripts/PostFreeSurferPipeLineNHP.bat
  export SurfaceAtlasDIR="/mnt/devel/devel/NHPHCPPipeline/global/templates/standard_mesh_atlases_marmoset"
  export GrayordinatesSpaceDIR="/mnt/devel/devel/NHPHCPPipeline/global/templates/standard_mesh_atlases_marmoset"
  export ReferenceMyelinMaps="/mnt/devel/devel/NHPHCPPipeline/global/templates/standard_mesh_atlases_marmoset/MyelinMap_BC.164k_fs_LR.dscalar.nii"
  #Grayordinates
  export LowResMesh=32@10@2 #Needs to match what is in PostFreeSurfer
  export FinalfMRIResolution="1.0" #Needs to match what is in fMRIVolume
  export SmoothingFWHM="1.0" #Recommended to be roughly the voxel size
  export GrayordinatesResolution="1.0" #Needs to match what is in PostFreeSurfer. Could be the same as FinalfRMIResolution something different, which will call a different module for subcortical processing
  export MyelinMappingFWHM="1.6"
  export SurfaceSmoothingFWHM="1.6"
  export CorrectionSigma="3"

else

 echo "Not yet supported speces: $SPECIES"

fi
