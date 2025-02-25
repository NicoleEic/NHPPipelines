#!/bin/bash
set -e
umask u+rw,g+rw # give group read/write permissions to all new files

usage () {
echo "Usage: $0 <StudyFolder> <SubjectID1@SubjectID2@SubjectID3...> <RunMode>"
echo "    Runmode: 0 - 8"
exit 1
}
[ "$1" = "" ] && usage

StudyFolder=$1
Subjlist=$2

echo " "
echo "Subjlist: $Subjlist"
echo "StudyFolder: $StudyFolder"

# see ${HCPPIPEDIR}/FreeSurfer/FreeSurferPipelineNHP.sh about what the runmodes do
RunMode='NE'

if [ X$SGE_ROOT != X ] ; then
    QUEUE="-q long.q"
fi

logdir=$StudyFolder/../logs

if [[ $OSTYPE == "linux" ]] ; then
  RUN="${FSLDIR}/bin/fsl_sub -N FREE ${QUEUE} -l ${logdir}"
  #RUN=''
elif [[ $OSTYPE == "darwin" ]] ; then
  RUN=''
fi

PRINTCOM=""

######################################### DO WORK ##########################################

for Subject in `echo $Subjlist | sed -e 's/@/ /g'` ; do

  #Input Variables
  SubjectID="$Subject" #FreeSurfer Subject ID Name
  SubjectDIR="${StudyFolder}/${Subject}/T1w" #Location to Put FreeSurfer Subject's Folder
  T1wImage="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
  T1wImageBrain="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)
  T2wImage="${StudyFolder}/${Subject}/T1w/T2w_acpc_dc_restore.nii.gz" #T2w FreeSurfer Input (Full Resolution)
  FSLinearTransform="${HCPPIPEDIR_Templates}/fs_xfms/eye.xfm" #Identity

    if [[ "$StudyFolder" == *"Jerome"* ]] ; then
      T2wFlag="${T2wFlag:=NONE}" # T2w, FLAIR or NONE. Default is T2w
      T2wFlag="NONE"
    else
      T2wFlag="${T2wFlag:=T2w}" # T2w, FLAIR or NONE. Default is T2w
  fi
  #GCAdir="${HCPPIPEDIR_Templates}/MacaqueYerkes19" #Template Dir with FreeSurfer NHP GCA and TIF files
  #RescaleVolumeTransform="${HCPPIPEDIR_Templates}/fs_xfms/Macaque_rescale" #Transforms to undo the effects of faking the dimensions to 1mm
  ############################################### Modified from here by Takuya Hayashi Nov 4th 2015 - Nov 2017.
  if [ -e "$SubjectDIR"/"$SubjectID"_1mm ] ; then
    if [ -e "$SubjectDIR"/"$SubjectID" ] ; then rm -r "$SubjectDIR"/"$SubjectID"; fi
    mv "$SubjectDIR"/"$SubjectID"_1mm "$SubjectDIR"/"$SubjectID"
  fi
  WmEdit="NONE";ControlPoints="NONE";AsegEdit="NONE";
  if [ "$RunMode" = "2" ] ; then

	if [ -e "$SubjectDIR"/"$SubjectID"/mri/brainmask.edit.mgz ] ; then
   		mkdir -p ${SubjectDIR}/${Subject}_edits
		cp "$SubjectDIR"/"$SubjectID"/mri/brainmask.edit.mgz "$SubjectDIR"/"$SubjectID"_edits/
	fi

  elif [ "$RunMode" = "3" ] ; then

  	if [ -e ${SubjectDIR}/${Subject}/mri/aseg.edit.mgz ] ; then
   		mkdir -p ${SubjectDIR}/${Subject}_edits
   		mv ${SubjectDIR}/${Subject}/mri/aseg.edit.mgz ${SubjectDIR}/${Subject}_edits/;
   		AsegEdit="${SubjectDIR}/${Subject}_edits/aseg.edit.mgz"
      	else
		echo "WARNING: cannot find ${SubjectDIR}/${Subject}/mri/aseg.edit.mgz. About to run FSaseg";
       fi
   	if [ -e ${SubjectDIR}/${Subject}/mri/wm.edit.mgz ] ; then
   		mv ${SubjectDIR}/${Subject}/mri/wm.edit.mgz ${SubjectDIR}/${Subject}_edits/
   	fi
   	WmEdit="NONE"
   	ControlPoints="NONE"

  elif [ "$RunMode" = "4" ] ; then
  	if [ -e ${SubjectDIR}/${Subject}/tmp/control.dat ] ; then
   		mkdir -p ${SubjectDIR}/${Subject}_edits
   		mv ${SubjectDIR}/${Subject}/tmp/control.dat ${SubjectDIR}/${Subject}_edits/
   		ControlPoints="${SubjectDIR}/${Subject}_edits/control.dat"
   		if [ -e ${SubjectDIR}/${Subject}/mri/wm.edit.mgz ] ; then
   			mv ${SubjectDIR}/${Subject}/mri/wm.edit.mgz ${SubjectDIR}/${Subject}_edits/
   		fi
  		AsegEdit="NONE"
   		WmEdit="NONE"
	else
		echo "WARNING: cannot find ${SubjectDIR}/${Subject}/tmp/control.dat. About to run FSnormalize2";
  	fi
  elif [ "$RunMode" = "5" ] ; then
  	if [ -e ${SubjectDIR}/${Subject}/mri/wm.edit.mgz ] ; then
   		mkdir -p ${SubjectDIR}/${Subject}_edits
   		mv ${SubjectDIR}/${Subject}/mri/wm.edit.mgz ${SubjectDIR}/${Subject}_edits/;
   		WmEdit="${SubjectDIR}/${Subject}_edits/wm.edit.mgz"
   		ControlPoints="NONE"
   		AsegEdit="NONE"
	else
		echo "WARNING: cannot find ${SubjectDIR}/${Subject}/mri/wm.edit.mgz. About to run FSwhite";
  	fi
  fi
  Seed="1234"
  ############################################### Modified until here by Takuya Hayashi Nov 4th 2015.

   ${RUN} ${HCPPIPEDIR}/FreeSurfer/FreeSurferPipelineNHP.sh \
    --subject="$Subject" \
    --subjectDIR="$SubjectDIR" \
    --t1="$T1wImage" \
    --t1brain="$T1wImageBrain" \
    --t2="$T2wImage" \
    --fslinear="$FSLinearTransform" \
    --gcadir="$GCAdir" \
    --rescaletrans="$RescaleVolumeTransform" \
    --asegedit="$AsegEdit" \
    --controlpoints="$ControlPoints" \
    --wmedit="$WmEdit" \
    --t2wflag="$T2wFlag" \
    --species="$SPECIES" \
    --runmode="$RunMode" \
    --seed="$Seed" \
    --intensitycor='FAST'\
    --printcom="$PRINTCOM"

done
