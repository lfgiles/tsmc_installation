#!/usr/bin/env bash
# Usage $ prepareRSF.sh NODE, METALSTACK, METALSTACK_perc, METALSTACK_TP


if [[ $# != 4 ]]; then
	echo "There are $# arguments, required: NODE, METALSTACK, METALSTACK_perc, METALSTACK_TP"
	exit
fi

NODE="$1"
METALSTACK="$2"
METALSTACK_perc="$3"
METALSTACK_TP="$4"

echo "prepareRSF $NODE $METALSTACK $METALSTACK_TP"

_component="layoutverification_perc"
_tool="calibre"
_stack_perc=`echo 1P$METALSTACK_perc |awk '{print toupper($0)}'`
_path_component=prepareTP/${_component}/${_tool}/${METALSTACK_TP}/
_path_deck=${_path_component}/PERC/TSMC/ESD

_stack_nb=`echo $METALSTACK |cut -c1-2|sed 's/[^0-9]*//g'`
_stack_TP=$METALSTACK_TP

#_path_rsf=prepareTP/${NODE}/calibre/${COMP_VERSION}/${METALSTACK_TP}/rsf

echo "## 1. prepare dict for python script"
cp ../script/template/constant/${NODE}/cfg_level0.dict .
mv ${_path_component}/RSF_perc_esd_template .
# Rework the template
echo "## 1.1 Add logusage to the RSF template"
_line_to_change=`sed -n '/==== PERC Rule File ====/=' RSF_perc_esd_template`
sed -i "${_line_to_change}a\INCLUDE \"./tsmc_lib/logusage.tvf\"" RSF_perc_esd_template

echo "## 1.2 Add commentare for cheetah R2G  flow"
_line_to_change=`sed -n '/#DEFINE TOPO/=' RSF_perc_esd_template`
# cheetah R2G need "// start switch see gitlab issue #14"
sed -i "${_line_to_change}i\\/\/ start switch" RSF_perc_esd_template
_line_to_change=`sed -n '/VARIABLE VIA_REDUCE_STEP/=' RSF_perc_esd_template`
# cheetah R2G need "// end switch" see gitlab issue #14
sed -i "${_line_to_change}i\\/\/ end switch" RSF_perc_esd_template

echo "## 1.3 Add SVRF variable between start/end switches cheetah R2G  flow see 1.2"
echo "## 1.4 Add default_on/off for the svrf VARIABLE and INCLUDE R2G  flow see 1.2"
# detect beginnig section to add between the start/end switch
_line_to_virtual_connect=`sed -n '/VIRTUAL CONNECT/=' RSF_perc_esd_template`
# detect end section to add between the start/end switch
_line_to_pad_info=`sed -n '/pad_info\.rules/=' RSF_perc_esd_template`
# write on tmp file the section to add between the switch
sed -n "${_line_to_virtual_connect},${_line_to_pad_info}p" RSF_perc_esd_template > tmp_rsf_pwr_gnd
# delete the line to be include between the switch
sed -i "${_line_to_virtual_connect},${_line_to_pad_info}d" RSF_perc_esd_template
#update the tmp rsf to add defaulton/off to svrf VIRTUAL CONNECT, VARIABLE and INCLUDE mix with python
sed -i '/VIRTUAL CONNECT/ s/VIRTUAL CONNECT NAME \"?\"/\/\/VIRTUAL CONNECT NAME \"?\"  \/\/default_off/g' tmp_rsf_pwr_gnd
sed -i '/^VARIABLE/ s/\"  /\"  \/\/default_on/g' tmp_rsf_pwr_gnd
sed -i '/^\/\/VARIABLE/ s/\"  /\"  \/\/default_off/g' tmp_rsf_pwr_gnd
# add the tmp file above "// end switch"
_line_to_end_switch=`sed -n '/end switch/=' RSF_perc_esd_template`
sed -i "${_line_to_end_switch}i\tmp_rsf" RSF_perc_esd_template
sed -i "/tmp_rsf/ {
r tmp_rsf_pwr_gnd
d}" RSF_perc_esd_template

_slash=/
_backslashslash=\\/
_path_component_sed=`echo ${_path_component//$_slash/$_backslashslash}`
echo "sed -i \"/DESTPATH/ s/_path_component/$_path_component_sed/g\" cfg_level0.dict"
sed -i "/DESTPATH/ s/_path_component/${_path_component_sed}/g" cfg_level0.dict 
sed -i "/nbMetal/ s/_stack_nb/${_stack_nb}/g" cfg_level0.dict 
sed -i "/tpName/ s/_stack_TP/${_stack_TP}/g" cfg_level0.dict 
sed -i "/percName/ s/_stack_perc/${_stack_perc}/g" cfg_level0.dict 

echo "## 2. Run python script to create RSF"
../script/python/perc_dp_gen -cfg cfg_level0.dict

#echo "## 3. compare with existing tp, create patch file" -> separate pipeline step

echo "## 4. stamp file with git commit hash and node"
_git_commit_nb=`git log --oneline -1 | cut -c 1-7`
_dp_var="${_git_commit_nb}_${NODE}"
echo "hash: $_dp_var"
for rsf_file in ${_path_component}/RSF*; do
    _RSF_basename=`basename $rsf_file`
    sed -i "1a\set env(TP_CAL_VERSION) $_dp_var" $rsf_file
    sed -i "2a\set env(TP_CAL_RUNSET) $_RSF_basename" $rsf_file
done
for rule_file in ${_path_deck}/tsmc_lib/perc*.rules; do
    sed -i "1a\#$_dp_var" $rule_file
done

find $_path_deck/. -name *constant*.tcl -exec sed -i "1a\#$_dp_var" {} +

#cp perc/${_stack_perc}/* ${_path_deck}/.
#mv ${_path_deck}/*.top ${_path_component}/RSF_perc_esd_template

#
#diff -u  $_constant_tsmc_orig $_constant_with_intel_mod > patch.txt
#echo  "# Difference with TSMC constant : cat diff_constant_ed_script.txt"
#cat patch.txt
#cp $_constant_tsmc_orig ${_constant_tsmc_orig}_bp
#patch $_constant_tsmc_orig < patch.txt

###
### clean-up
###
echo "### 4.clean up"

mkdir backup 
mv ${_path_component}/RSF_digital_* backup 
mv ${_path_deck}/tsmc_lib/*_bp backup 
mv ${_path_deck}/tsmc_lib/constant_tsmc_relaxed.tcl backup 
mv ${_path_deck}/tsmc_lib/perc_*_constant.tcl_tsmc_orig ${_path_deck}/perc_constant_tsmc_orig.tcl
wash -n intelall tptestg tpadm $NODE ${NODE}tpdev -X chmod -R 750 ${_path_component}
wash -n intelall tptestg tpadm $NODE ${NODE}tpdev -X chgrp -R tptest ${_path_component}


echo "### 5.prepare to compare with existing solution"
echo ""
echo "_RECOMANDATION_"
echo "Goto the perforce delivery directory and apply diff with previous data"
echo "Recommand to sync the git with perforce and create a new branch before to run it"
