
#!/usr/bin/env bash
# Usage $ reoderTP.sh n6 v0.0.1 11M_2X1Ya3Y2Yy2R 1P11M_2X_hv_1Ya_h_3Y_vhv_2Yy2R


if [[ $# != 4 ]]; then
	echo "There are $# arguments, required: NODE,COMP_VERSION, METALSTACK, METALSTACK_TP"
	exit
fi

NODE="$1"
COMP_VERSION="$2"
METALSTACK="$3"
METALSTACK_TP="$4"

_workdir=`pwd`
_path_rsf=prepareTP/${NODE}/calibre/${COMP_VERSION}/${METALSTACK_TP}/rsf
_path_deck=prepareTP/${NODE}/calibre/${COMP_VERSION}/${METALSTACK_TP}/runset/PERC/TSMC


echo "## Build  new tree structure for cheetah2 calibre"
_new_path=prepareTP_cheetah2/${NODE}-layoutverification_perc/layoutverification_perc/calibre/${METALSTACK_TP}/
mkdir -p ${_new_path}

cp -R ${_path_deck}/../../PERC ${_new_path}/.


for rsf_file in ${_path_rsf}/RSF*; do
    sed -i "/INCLUDE/ s|runset/PERC/|PERC/|g" $rsf_file
done
cp ${_path_rsf}/RSF* ${_new_path}/.

# Clean up of cheetah1 artefact
rm -rf ${_new_path}/RSF_digi*
rm -rf ${_new_path}/PERC/TSMC/tsmc_lib/constant_relaxed_MTL.tcl

tree prepareTP_cheetah2

echo "## Transfer to tptest/p4homes with:"
echo "cp -R ${_workdir}/${_new_path}/* /nfs/imu/proj/tec/tptest/p4homes/nrichaud/${NODE}/git/${NODE}-layoutverification_perc/layoutverification_perc/calibre/${METALSTACK_TP}/."
echo "or:"
echo "cp -R ${_workdir}/prepareTP_cheetah2/${NODE}-layoutverification_perc/* /nfs/imu/proj/tec/tptest/p4homes/nrichaud/${NODE}/git/${NODE}-layoutverification_perc/"
