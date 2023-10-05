#!/bin/bash
StudyFolder=$1
Subjlist=$2
Tasklist=$3

echo " "
echo "Subjlist: $Subjlist"
echo "StudyFolder: $StudyFolder"
echo "TaskList: $Tasklist"

if [[ $OSTYPE == "linux" ]] ; then
  origdir=/vols/Data/sj/Nicole/site-ucdavis
  SD=$origdir/derivatives
  ScriptsDir=/vols/Scratch/neichert/NHPPipelines/Examples/Scripts
  logdir=/vols/Data/sj/Nicole/site-ucdavis/logs

elif [[ $OSTYPE == "darwin" ]] ; then
  origdir=/Users/neichert/Downloads/site-ucdavis
  SD=$origdir/derivatives
  ScriptsDir=/Users/neichert/code/NHPPipelines/Examples/Scripts
fi

EnvironmentScript="$ScriptsDir/SetUpHCPPipelineNHP.sh"
. ${EnvironmentScript}

logdir=$StudyFolder/../logs

if [[ $OSTYPE == "linux" ]] ; then
  RUN="${FSLDIR}/bin/fsl_sub -j POST -N fmriS -q long.q -l ${logdir}"
  #RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  RUN=''
fi

PRINTCOM=""
FinalfMRIResolution=1.25
for Subject in $Subjlist ; do
    echo 'do' ${Subject}

  #if [ -e ${StudyFolder}/${Subject}/RawData/hcppipe_conf.txt ] ; then
  # . ${StudyFolder}/${Subject}/RawData/hcppipe_conf.txt
  #else
  # echo "Cannot find hcppipe_conf.txt in ${Subject}/RawData";
  # echo "Exiting without processing.";
  # exit 1;
  #fi
  for fMRIName in $Tasklist ; do
    echo 'do' ${fMRIName}
    fMRIName=`remove_ext $fMRIName`
    LowResMesh="`echo $LowResMesh | sed -e 's/@/ /g' | awk '{print $NF}'`"
    #FinalfMRIResolution="1.25" #Needs to match what is in fMRIVolume
    #SmoothingFWHM="1.25" #Recommended to be roughly the voxel size
    #GrayordinatesResolution="1.25" #Needs to match what is in PostFreeSurfer. Could be the same as FinalfRMIResolution something different, which will call a different module for subcortical processing
    #RegName="FS"  # MSMSulc is recommended, if binary is not available use FS (FreeSurfer)
      ${RUN} ${HCPPIPEDIR}/fMRISurface/GenericfMRISurfaceProcessingPipeline.sh \
      --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$fMRIName \
      --lowresmesh=$LowResMesh \
      --fmrires=$FinalfMRIResolution \
      --smoothingFWHM=$SmoothingFWHM \
      --grayordinatesres=$GrayordinatesResolution \
      --regname=$RegName
   done
done
