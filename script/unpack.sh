#!/usr/bin/env bash
# Usage $ unpack.sh n6 source/calibre/perc/TN06CLDR001C7_0_5_1A.zip source/calibre/lvs/TN06CLSP001C1_0_5A.zip 11M_2X1Ya3Y2Yy2R

#   TSMC_PERC_PKG_PATH: "/nfs/imu/proj/globus/tpdev/tech5/n6/.dr/source/calibre/perc/TN06CLDR001C7_0_5_1A.zip"
#   TSMC_LVS_PKG_PATH: "/nfs/imu/proj/globus/tpdev/tech5/n6/.dr/source/calibre/lvs/TN06CLSP001C1_0_5A.zip"
#   METALSTACK: "11M_2X1Ya3Y2Yy2R"


if [[ $# != 5 ]]; then
	echo "There are $# arguments, required: NODE TSMC_PERC_PKG_PATH, TSMC_LVS_PKG_PATH, METALSTACK, METALSTACK_perc"
	exit
fi

NODE="$1"
TSMC_PERC_PKG_PATH="$2"
TSMC_LVS_PKG_PATH="$3"
METALSTACK="$4"
METALSTACK_perc="$5"

tsmc_perc_prepare_workdir_path=`pwd`
echo "## Runner workdir $tsmc_perc_prepare_workdir_path"
echo "## unzip lvs"
_lvs_unpack=$tsmc_perc_prepare_workdir_path/lvs4perc
mkdir -p ${_lvs_unpack}
cd ${_lvs_unpack}
echo "## LVS TSMC package $TSMC_LVS_PKG_PATH"
wash -n intelall tptestg tpadm $NODE ${NODE}tpdev -X unzip $TSMC_LVS_PKG_PATH -d .
tar xvfz *.tar.gz
rm -rf *all.tar.gz
tar xvfz *.tar.gz
echo "## Metal stack $METALSTACK"
sleep 3
echo "## Run tsmc lvs instal script"
echo "./LVS_Install.pl -m ${METALSTACK} -mimcap 1 -shpmimcap 2 -flicker_corner_extraction 0 -self_heating_effect_extraction 0 > LVS_Install.log"
./LVS_Install.pl -m ${METALSTACK} -mimcap 1 -shpmimcap 3  -flicker_corner_extraction 0 -self_heating_effect_extraction 0  > LVS_Install.log
if [[ $? -ne 0 ]] ; then
    echo "## :-("
    echo "instal LVS fail"
    echo `pwd`
    exit 1
fi

echo "## unzip perc"
mkdir -p $tsmc_perc_prepare_workdir_path/perc
cd $tsmc_perc_prepare_workdir_path/perc
echo "## ESD/LUP TSMC package $TSMC_PERC_PKG_PATH"
wash -n intelall tptestg tpadm $NODE ${NODE}tpdev -X unzip $TSMC_PERC_PKG_PATH -d .
#wash -n intelall tptest tpadm $NODE ${NODE}tpdev -X cp $TSMC_PERC_PKG_PATH .
tar xvfz *.tar.gz

echo "## update user.config"
cp user.config user.config_bp
_line_to_change=`sed -n '/INSTALLATION_PATH/=' user.config`
sed -i "${_line_to_change}c\INSTALLATION_PATH = ." user.config
_line_to_change=`sed -n '/METAL_SCHEME/=' user.config`
sed -i "${_line_to_change}c\METAL_SCHEME = 1P${METALSTACK_perc}" user.config
_line_to_change=`sed -n '/LVS_PACKAGE_DIRECTORY/=' user.config`
sed -i "${_line_to_change}c\LVS_PACKAGE_DIRECTORY = ${_lvs_unpack}" user.config



echo "## tsmc perc release note and tool"
echo "##cat 4_ReleaseNotes.txt\n"
cat 4_ReleaseNotes.txt
echo "\n##cat Recommended_tool_version_number.txt\n"
cat Recommended_tool_version_number.txt


echo "## Run tsmc perc install script"
echo "/usr/intel/pkgs/perl/5.20.1/bin/perl install.pl user.config > PERC_Install.log"
/usr/intel/pkgs/perl/5.20.1/bin/perl install.pl user.config > PERC_Install.log
if [[ $? -ne 0 ]] ; then
    echo "## :-("
    echo "instal perc fail"
    echo `pwd`
    exit 1
fi

echo "## Runner workdir $tsmc_perc_prepare_workdir_path"

