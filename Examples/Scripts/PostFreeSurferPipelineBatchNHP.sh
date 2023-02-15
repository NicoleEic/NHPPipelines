#!/bin/bash

if [[ $OSTYPE == "linux" ]] ; then
  StudyFolder=/vols/Data/sj/Nicole/site-ucdavis/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
elif [[ $OSTYPE == "darwin" ]] ; then
  StudyFolder=/Users/neichert/Downloads/site-ucdavis/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
fi


if [ "$SPECIES" = "" ] ; then echo "ERROR: please export SPECIES first, Macaque or Marmoset"; exit 1;fi
EnvironmentScript="$ScriptsDir/SetUpHCPPipelineNHP.sh"
. ${EnvironmentScript}

StudyFolder=$1;shift
Subjlist=$@

QUEUE="-q long.q"
PRINTCOM=""

logdir=$StudyFolder/../logs

if [[ $OSTYPE == "linux" ]] ; then
  RUN="${FSLDIR}/bin/fsl_sub -N POST ${QUEUE} -l ${logdir}"
  #RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  RUN=''
fi

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

done
