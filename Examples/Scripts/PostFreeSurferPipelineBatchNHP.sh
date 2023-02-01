#!/bin/bash

if [[ $OSTYPE == "linux" ]] ; then
  StudyFolder=/vols/Scratch/neichert/site-ucdavis/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  RUN='fsl_sub -q long.q sh'
  #RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  StudyFolder=/Users/neichert/Downloads/site-ucdavis/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
  RUN='sh'
fi

# source this first outside of script
#source $ScriptsDir/SetUpHCPPipelineNHP.sh

if [ "$SPECIES" = "" ] ; then echo "ERROR: please export SPECIES first, Macaque or Marmoset"; exit 1;fi
EnvironmentScript="$ScriptsDir/SetUpHCPPipelineNHP.sh"
. ${EnvironmentScript}

StudyFolder=$1;shift
Subjlist=$@

QUEUE="-T 120"
PRINTCOM=""

for Subject in $Subjlist ; do
  #Input Variables
  #SurfaceAtlasDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque"
  #GrayordinatesSpaceDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque"
  #GrayordinatesResolution="1.25" #Usually 2mm
  HighResMesh="164" #Usually 164k vertices, if multiple delimit with @, must already exist in templates dir
  #LowResMesh="32@10" #Usually 32k vertices, if multiple delimit with @, must already exist in templates dir
  SubcorticalGrayLabels="${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt"
  FreeSurferLabels="${HCPPIPEDIR_Config}/FreeSurferAllLut.txt"
  #ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases_macaque/MacaqueYerkes19.MyelinMap_BC.164k_fs_LR.dscalar.nii"
  #RegName="MSMSulc" # "MSMSulc" #MSMSulc is recommended, if binary is not available use FS (FreeSurfer)
  #CorrectionSigma="7"
  LOG="-l ${StudyFolder}/${Subject}/logs"

  ${RUN} ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh \
      --path="$StudyFolder" \
      --subject="$Subject" \
      --surfatlasdir="$SurfaceAtlasDIR" \
      --grayordinatesdir="$GrayordinatesSpaceDIR" \
      --grayordinatesres="$GrayordinatesResolution" \
      --hiresmesh="$HighResMesh" \
      --lowresmesh="$LowResMesh" \
      --subcortgraylabels="$SubcorticalGrayLabels" \
      --freesurferlabels="$FreeSurferLabels" \
      --refmyelinmaps="$ReferenceMyelinMaps" \
      --regname="$RegName" \
      --printcom=$PRINTCOM
#      --mcsigma="$CorrectionSigma" \

  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...
#
#   echo "set -- --path="$StudyFolder" \
#      --subject="$Subject" \
#      --surfatlasdir="$SurfaceAtlasDIR" \
#      --grayordinatesdir="$GrayordinatesSpaceDIR" \
#      --grayordinatesres="$GrayordinatesResolution" \
#      --hiresmesh="$HighResMesh" \
#      --lowresmesh="$LowResMesh" \
#      --subcortgraylabels="$SubcorticalGrayLabels" \
#      --freesurferlabels="$FreeSurferLabels" \
#      --refmyelinmaps="$ReferenceMyelinMaps" \
#      --regname="$RegName" \
#      --mcsigma="$CorrectionSigma" \
#      --printcom=$PRINTCOM"
#
   echo ". ${EnvironmentScript}"
done

