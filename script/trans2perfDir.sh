#!/usr/bin/env bash
# Usage $ trans2perfDir.sh n3 nrichaud 1P17M_1X_h_1Xb_v_1Xc_h_1Xd_v_1Ya_h_1Yb_v_6Y_hvhvhv_2Yy2R_shdmim_ut-alrdl


if [[ $# != 3 ]]; then
	echo "There are $# arguments, required: NODE, user,  METALSTACK_TP"
	exit
fi

NODE="$1"
USER="$2"
METALSTACK_TP="$3"


_component="layoutverification_perc"
_tool="calibre"
_path_component=prepareTP/${_component}/${_tool}/${METALSTACK_TP}
_path_deck=${_path_component}/PERC/TSMC/ESD


_path_to_perfDir=/nfs/imu/proj/tec/tptest/p4homes/$USER/$NODE/git/$NODE-layoutverification_perc/layoutverification_perc/calibre/$METALSTACK_TP


echo "####################"
echo "##To COPY to perforce Directory for $USER #######"
echo "cp -R ${_path_component} ${_path_to_perfDir}"
wash -n intelall tptest tpadm $NODE ${NODE}tpdev -X cp -R ${_path_component} ${_path_to_perfDir}/..
echo "Goto the perforce delivery directory and apply diff with previous data"
echo "Recommand to sync the git with perforce and create a new branch before to run it"
echo "cd ${_path_to_perfDir};git diff --stat;git status"
echo ""
