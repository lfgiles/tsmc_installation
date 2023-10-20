#!/usr/bin/env bash
# Usage $ build_die2die_220.sh n6 v1.3.0 11M_2X1Ya3Y2Yy2R 1P11M_2X_hv_1Ya_h_3Y_vhv_2Yy2R


if [[ $# != 4 ]]; then
	echo "There are $# arguments, required: NODE,COMP_VERSION, METALSTACK, METALSTACK_TP"
	exit
fi

NODE="$1"
NODE_NB=`echo $NODE |sed 's/n/n0/g'`
COMP_VERSION="$2"
METALSTACK="$3"
METALSTACK_TP="$4"

_component="layoutverification_perc"
_tool="calibre"
_path_component=prepareTP/${_component}/${_tool}/${METALSTACK_TP}/
_path_deck=${_path_component}/PERC/TSMC/ESD

## create a copy of tsmc_lib to apply die2die relaxation rules
echo "## create a copy of tsmc_lib to apply die2die rlaxation rules"
cp -R ${_path_deck}/tsmc_lib ${_path_deck}/tsmc_lib_die2die

#`perc_*_constant.tcl` already contains the first level modification
_constant_file_relaxed=${_path_deck}/tsmc_lib_die2die/perc_*_constant.tcl

## ESD relaxed constant values (die2die)
_constant_with_intel_relaxed_mod=script/template/constant/${NODE}/perc_${NODE_NB}_constant_die2die.tcl
diff -u  $_constant_file_relaxed $_constant_with_intel_relaxed_mod > patch_relaxed.txt
echo  "# Difference with TSMC constant : cat patch_relaxed.txt"
cat patch_relaxed.txt

# The `perc_*_constant.tcl` get the intel die2die relaxation with the `patch` cmd
patch $_constant_file_relaxed < patch_relaxed.txt

## Adapt the perc_n*.rules to desactivate the TSMC rules
echo " ## Adapt the perc_n*.rules to desactivate the TSMC rules"

declare -a arr_topo=( "ESD.WARN.3gu"
    "ESD.WARN.3.1gu"
    "ESD.WARN.4.2gu"
    "ESD.8gu"
    "ESD.8.1gu"
    "ESD.9gu"
    "ESD.31g"
    "ESD.LC.5gu"
    "ESD.CDM.1gu"
    "ESD.CDM.1.1gu"
    "ESD.CDM.1.3gu"
    "ESD.CDM.2gu"
    "ESD.CDM.2gu_topo"
    "ESD.CDM.4.1gu"
    "ESD.CDM.6g"
    "ESD.45gu"
    "ESD.45.0.1gu"
    "ESD.CDM.X.1gu"
    "ESD.XDM.VIC.3gu:gsd"
    "ESD.XDM.VIC.3gu:sdg"
    "ESD.XDM.VIC.4gu"
    "LUP.WARN.4u"
    "ESD.CD.2gu:dio:up"
    "ESD.CD.2gu:dio:dn"
    "ESD.CD.2gu:mos:up"
    "ESD.CD.2gu:mos:dn"
    "ESD.14.5.1gu"
    "ESD.14.5.2gu"
    "ESD.CDM.C.3gu:export"
    "ESD.CDM.C.2gu_ldl"
    "ESD.CDM.C.3.1gu_ldl"
    "ESD.CDM.C.3.2gu_ldl"
    "ESD.CDM.C.5gu_ldl"
    "LUP.2.0.1"
    "LUP.2.1"
    "ESD.14.4gu"
    "ESD.14.3.1gu:dio"
    "ESD.14.3.2gu"
    "ESD.14.3.1gu:mos"
    "ESD.14.6gu"
    "ESD.14.7gu"
    "ESD.14.8gu"
    "ESD.LCP2P.1.1gu"
    "ESD.LCP2P.1.2gu"
    "ESD.CDM.P.1.1gu:dio:up"
    "ESD.CDM.P.1.1gu:dio:dn"
    "ESD.CDM.P.1.1gu:mos:dn"
     "ESD.CDM.P.1.1.0.1gu"
     "ESD.CDM.P.1.1.0.2gu"
     "ESD.CDM.P.1.1.0.3gu"
    "ESD.CDM.P.5gu"
    "ESD.CDM.P.5.1gu"
     "ESD.CDM.P.5.0.1gu"
     "ESD.CDM.P.5.0.2gu"
     "ESD.CDM.P.5.1.0.1gu"
     "ESD.CDM.P.5.1.0.2gu"
    "ESD.CDM.P.10gu"
    )
    ## Active rules for topo:
    #"ESD.NET.1gu"
    #"ESD.15gu"
    #"ESD.43gu"
    #"ESD.40.3.1gu"
    #"ESD.CDM.4gu"
    #"ESD.CDM.B.1gu"
    #"ESD.CDM.B.2gu"

for i in "${arr_topo[@]}";do
        echo "topo desactivated rules $i"
done

for file_rules in ${_path_deck}/tsmc_lib_die2die/perc*.rules; do
    for i in "${arr_topo[@]}"
    do
        sed -i 's|^ *'$i'.*$|//\0 //desactivate for die2die nichaud 22/12/2020 |g' ${file_rules}
    done
done

## desactivate the ESD.CD.2gu rules

declare -a arr_p2pcd=( "-rulecheck ESD.CD.2gu"
    "-rulecheck ESD.CD.2gu:dio:up"
    "-rulecheck ESD.CD.2gu:dio:dn"
    "-rulecheck ESD.CD.2gu:mos:up"
    "-rulecheck ESD.CD.2gu:mos:dn"
    "-rulecheck ESD.14.3.1gu:dio"
    "-rulecheck ESD.14.3.2gu"
    "-rulecheck ESD.14.3.1gu:mos"
    "-rulecheck ESD.14.4gu"
    "-rulecheck ESD.14.5.1gu"
    "-rulecheck ESD.14.5.2gu"
    "-rulecheck ESD.14.6gu"
    "-rulecheck ESD.14.7gu"
    "-rulecheck ESD.14.8gu"
    "-rulecheck ESD.CDM.P.1.1gu:dio:up"
    "-rulecheck ESD.CDM.P.1.1gu:dio:dn"
    "-rulecheck ESD.CDM.P.1.1gu:mos:dn"
     "-rulecheck ESD.CDM.P.1.1.0.1gu"
     "-rulecheck ESD.CDM.P.1.1.0.2gu"
     "-rulecheck ESD.CDM.P.1.1.0.3gu"
    "-rulecheck ESD.CDM.P.10gu"
    "-rulecheck ESD.LCP2P.1.1gu"
    "-rulecheck ESD.LCP2P.1.2gu"
    "-rulecheck ESD.LCP2P.2.1gu"
    "-rulecheck ESD.LCP2P.2.2gu"
    "-rulecheck ESD.CDM.P.5gu"
    "-rulecheck ESD.CDM.P.5.1gu"
     "-rulecheck ESD.CDM.P.5.0.1gu"
     "-rulecheck ESD.CDM.P.5.0.2gu"
     "-rulecheck ESD.CDM.P.5.1.0.1gu"
     "-rulecheck ESD.CDM.P.5.1.0.2gu"
    "-rulecheck ESD.DISTP2P.1.0.1gu"
    "-rulecheck ESD.DISTP2P.1.0.2gu"
    "-rulecheck ESD.DISTP2P.1gu:up"
    "-rulecheck ESD.DISTP2P.1gu:dn"
    "-rulecheck ESD.DISTP2P.1.1gu:up"
    "-rulecheck ESD.DISTP2P.1.1gu:dn"
    "-rulecheck ESD.DISTP2P.1.2gu:up"
    "-rulecheck ESD.DISTP2P.1.2gu:dn"
    "-rulecheck ESD.DISTP2P.1.3gu:up"
    "-rulecheck ESD.DISTP2P.1.3gu:dn"
    )

for i in "${arr_p2pcd[@]}";do
        echo "CurrentDensity/P2P desactivated rules $i"
done

for file_rules in ${_path_deck}/tsmc_lib_die2die/perc*.rules; do
    for i in "${arr_p2pcd[@]}"
    do
        sed -i "s|.*$i'*|#\0 ;#desactivate for die2die nichaud 22/12/2020 |g" ${file_rules}
    done
done


## Adapt RSF file to add the die2die switch
cp ${_path_component}/RSF_perc_esd_template RSF_perc_esd_template_without_die2die

# Add 'DEFINE' switch close of the CDM
_line_to_change=`sed -ne '/DEFINE CDM_/=;/DEFINE CDM_/q' ${_path_component}/RSF_perc_esd_template`
sed -i "${_line_to_change}i\\/\/#DEFINE IO_DIE2DIE_CDM_35V_220mA   //Intel switch for Die2Die protection more info on goto/ESD" ${_path_component}/RSF_perc_esd_template

# Add path to the relaxed runset

_line_to_change=`sed -ne '/#IFDEF CDM_/=;/#IFDEF CDM_/q' ${_path_component}/RSF_perc_esd_template`
sed -i "${_line_to_change}i\#IFDEF IO_DIE2DIE_CDM_35V_220mA //add by Intel\n  INCLUDE \"./tsmc_lib_die2die/perc_${NODE_NB}.rules\"\n#ELSE\n" ${_path_component}/RSF_perc_esd_template
sed -i '$i#ENDIF //end IO_DIE2DIE_CDM_35V_220mA' ${_path_component}/RSF_perc_esd_template


echo " ## END special relax die2die see also log"
