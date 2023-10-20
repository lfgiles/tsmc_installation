#!/usr/bin/env bash
# Usage $ compareTP.sh NODE, PATH2COMPARE


if [[ $# != 4 ]]; then
	echo "There are $# arguments, required: NODE, METALSTACK_TP, PATH2COMPARE"
	exit
fi

NODE="$1"
METALSTACK_TP="$2"
PATH2COMPARE="$3"

_component="layoutverification_perc"
_tool="calibre"
_path_component=prepareTP/${_component}/${_tool}/${METALSTACK_TP}

_path_4comparaison=prepareTP/${NODE}/calibre/4COMPARAISON
_path_copyTP=prepareTP/${NODE}/calibre/tmp_copy

echo "## 1. copy, use the metal stack as reference "
wash -n intelall tpadm tptest $NODE ${NODE}tpdev $NODE dpp4qa -X cp -R $PATH2COMPARE $_path_copyTP

ls prepareTP/${NODE}/calibre/

#echo "## 2. Remove all not perc relevant"
#mkdir -p $_path_4comparaison/rsf
#mkdir -p $_path_4comparaison/runset/PERC


#find $_path_copyTP/rsf/. -type f -name "RSF*perc*" -exec cp {} $_path_4comparaison/rsf/. \;
cp -R $_path_copyTP $_path_4comparaison/.

rm -rf $_path_copyTP

echo "## 3. Create Patch file where are listed all the differences"
diff -ruN $_path_4comparaison $_path_stack > PatchFile

echo "##########"
echo "# Head patch file"
echo "##########"
head PatchFile
echo "##########"
echo "# Tail patch file"
echo "##########"
tail PatchFile
echo "##########"
echo "# of line of diff `wc -l PatchFile`"
echo "# More information:"
echo "gvim `pwd`/PatchFile"


echo "##4. diff tree"
echo "Reference: tree $_path_4comparaison |tee tree_reference.txt"
tree $_path_4comparaison |tee tree_reference.txt
echo "new generated: tree $_path_stack |tee tree_new.txt"
tree $_path_stack |tee tree_new.txt
#diff -u tree_reference.txt tree_new.txt

echo ""
echo "##########"
echo "# All details with:"
_path_to_workdir=`pwd`
echo "#1. difference txt file (PatchFile)"
echo "gvim $_path_to_workdir/PatchFile"
echo "#2. difference txt file (PatchFile)"
echo "meld ${_path_to_workdir}/${_path_4comparaison} ${_path_to_workdir}/${_path_stack} &"
echo "##########"
echo ""

# Apply patch
#$ patch -p0 < PatchFile
# undo patch
#$ patch -R -p0 OriginalFile < PatchFile

