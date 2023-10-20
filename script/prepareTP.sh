#!/usr/bin/env bash
# Usage $ prepareTP.sh n6 v0.0.1 11M_2X1Ya3Y2Yy2R 1P11M_2X_hv_1Ya_h_3Y_vhv_2Yy2R


if [[ $# != 4 ]]; then
	echo "There are $# arguments, required: NODE, METALSTACK, METALSTACK_TP"
	exit
fi

NODE="$1"
METALSTACK="$2"
METALSTACK_perc="$3"
METALSTACK_TP="$4"

echo "prepareTP.sh $NODE $METALSTACK $METALSTACK_perc $METALSTACK_TP"

_component="layoutverification_perc"
_tool="calibre"
_stack_perc=`echo 1P$METALSTACK_perc |awk '{print toupper($0)}'`
_path_component=prepareTP/${_component}/${_tool}/${METALSTACK_TP}/
_path_deck=${_path_component}/PERC/TSMC/ESD
_stack_nb=`echo $METALSTACK |cut -c1-2|sed 's/[^0-9]*//g'`


echo "## Build tree structure for the tp"
mkdir -p ${_path_deck}

cp -R perc/tsmc_lib ${_path_deck}/.
cp ./perc/${_stack_perc}/* ${_path_deck}/.
mv ${_path_deck}/*.top ${_path_component}/RSF_perc_esd_template

echo "## Hack file to work inside cheetah"
_line_info="\t#modified by nrichaud@intel"
rm -rf ${_path_deck}/tsmc_lib/pad_info.rules

###
### rework the prec_n*.rules
###
echo "### 1.add tvf header for perc*.rules using template header_tsmc_lib_rules.temp"
for file_rules in ${_path_deck}/tsmc_lib/perc*.rules; do
    cp ${file_rules} ${file_rules}_bp
    sed  "/TO_REPLACE_1/r $file_rules" ../script/template/header_tsmc_lib_rules.temp > tmp
    mv tmp ${file_rules}
    sed -i '/TO_REPLACE_1/d' ${file_rules}
done


echo "### 2.update source in perc*.rules "
_line_to_add="${_line_info}\n\tset TSMC_CAL_PERC_PATH_tvf [tvf::svrf_var TSMC_CAL_PERC_PATH]\n \
    if [catch {source \$env(TSMC_CAL_PERC_CONSTANT_PATH_tvf)} msg] { puts \$msg; source [glob \${TSMC_CAL_PERC_PATH_tvf}/perc_\*constant.tcl]} else {puts \"WARNING: local constant file set by env variable TSMC_CAL_PERC_CONSTANT_PATH_tvf : \$env(TSMC_CAL_PERC_CONSTANT_PATH_tvf)\"}"

for file_rules in  ${_path_deck}/tsmc_lib/perc*.rules; do
    sed -i "s/\.\/tsmc_lib/\${TSMC_CAL_PERC_PATH_tvf}/g" ${file_rules}
    sed -i "/constant.tcl/i\ ${_line_to_add}" ${file_rules}
    sed -i "/_constant.tcl\"/s|source|#source|g" ${file_rules}
done

###
### rework the perc_n*_constant.tcl from TSMC template patch method
###
echo "### 3.update perc_n*_constant.tcl according value of WG"
echo "# see reference constante inside ../script/template/constant/${NODE}/perc_*_constant.tcl"
_constant_file=${_path_deck}/tsmc_lib/perc_*_constant.tcl
cp ${_constant_file} ${_path_deck}/tsmc_lib/constant_tsmc_relaxed.tcl
_constant_with_intel_mod=../script/template/constant/${NODE}/perc_*_constant.tcl
diff -u  $_constant_file $_constant_with_intel_mod > patch.txt
echo  "# Difference with TSMC constant : cat patch.txt"
cat patch.txt

#create backup of original TSMC constant file
cp $_constant_file ${_constant_file}_tsmc_orig
cp ${_path_deck}/tsmc_lib/perc_*_constant.tcl constant_file_tsmc_orig
patch $_constant_file < patch.txt

###
### add logusage.tvf
###
cp ../script/template/logusage.tvf ${_path_deck}/tsmc_lib/.

###
### Adapt LVS
### delete entries of rsf
###
echo  "### Remove SVRF command of the LVS when they are already part of rsf"
_perc_lvs=${_path_deck}/perc_n*.lvs
sed -i '/LAYOUT PRIMARY/d' ${_perc_lvs}
sed -i '/LAYOUT PATH/d' ${_perc_lvs}
sed -i '/LAYOUT SYSTEM GDSII/d' ${_perc_lvs}
sed -i '/SOURCE PRIMARY/d' ${_perc_lvs}
sed -i '/SOURCE PATH/d' ${_perc_lvs}
sed -i '/SOURCE SYSTEM SPICE/d' ${_perc_lvs}
sed -i '/LVS REPORT/s|LVS REP|//LVS REP|g' ${_perc_lvs}
sed -i '/MASK SVDB DIRECTORY/d' ${_perc_lvs}
### filter imess R(ZZ) -> LVS FILTER R(zz) SHORT
sed -i '5i\LVS FILTER R(zz) SHORT //short imess by nrichaud@intel' ${_perc_lvs}
### To enable MIM cap value (N6 and N7) ->impact cap extarction for ESD.BUMP
sed -i "/mim_top = ctm AND cbm/c\mim_top = (ctm AND cbm) NOT (OR ctm_open cbm_open) // Hack intel nrichaud 11/11/2019" ${_perc_lvs}

###
### Adapt RSF template
###
### TBH has seen issue with LAYOUT BUMP2 1000 -> proposal of Mentor to set it to LAYOUT BUMP2 50000 see detail inside gitlab error #8
echo  "### update related to LAYOUT BUMP2"
echo  "# Update default value inside rsf : LAYOUT BUMP2"
sed -i 's/LAYOUT BUMP2 1000/LAYOUT BUMP2 50000/g' ${_path_component}/RSF_perc_esd_template
echo  "# Update default value inside perc_n*.rules to add 50000 instead of 1000"
for file_rules in ${_path_deck}/tsmc_lib/perc*.rules; do
    sed -i "s/LAYER MAP 1999/LAYER MAP 50999/g" ${file_rules}
done
### Enable the svrf statement "PERC LDL LAYOUT REDUCE TOP LAYERS  Cu_RDL Mtop ..."
#echo  "### enable PERC LDL LAYOUT REDUCE TOP LAYERS Cu_RDL M18 M17 M16 M15 "
#sed -i "s|//PERC LDL LAYOUT REDUCE TOP LAYERS Cu_RDL Mtop ...|PERC LDL LAYOUT REDUCE TOP LAYERS AL M13 M12|g" ${_path_component}/RSF_perc_esd_template
echo  "### enable PERC LDL LAYOUT REDUCE TOP LAYERS  AP M${_stack_nb}"
sed -i "s|//PERC LDL LAYOUT REDUCE TOP LAYERS AP Mtop ...|PERC LDL LAYOUT REDUCE TOP LAYERS AP M${_stack_nb}|g" ${_path_component}/RSF_perc_esd_template

###
### clean-up
###
echo "### 4.clean up"
#rm -rf ${_path_deck}/tsmc_lib/*_tsmc_orig
cp ${_path_deck}/pad_info.rules ${_path_deck}/tsmc_lib/.
rm patch.txt

echo "## TODO ##"
echo "-- REVIEW THE PATCH FILE IF NEW TSMC PACKAGE--"
