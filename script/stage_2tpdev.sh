#!/usr/bin/env tcsh


set _METAL_STACK_TP=$METALSTACK_TP
set _PATH_TO_BUILD=`pwd`
set _GITLAB_MSG=`git log -1 --pretty=%B | head -1`
set _GITLAB_COMMIT_NB=`git log --oneline -1 | cut -c 1-7`
set _path_to_cheetahxml=$PATH_TO_CHEETAHXML
echo "#### commit ${_GITLAB_MSG} \n\tGITLAB HASH: ${_GITLAB_COMMIT_NB}"
module load /p/globus/tpdev/utils/TPdev.nfs/modules/TPdev
#wash -n intelall dt_users tpadm soc socenv soc73 tpgitg $NODE ${NODE}tpdev esdn7g esdlusyn tptest imcuser esdsupg -X ls
echo "<NOTES>" > Notes.xml
git show >> Notes.xml
echo "</NOTES>" >> Notes.xml

cp $_path_to_cheetahxml pdk.xml
tree
chmod -R 755 *
git log --graph --oneline --all -10
echo "####################"
echo "##To EXECUTE #######"
echo "cd $_PATH_TO_BUILD"
echo "module load /p/globus/tpdev/utils/TPdev.nfs/modules/TPdev"
echo "## run trans2tpdev "
echo "trans2tpdev $NODE calibre $COMP_VERSION ${_PATH_TO_BUILD}/prepareTP/${NODE} -notes ${_PATH_TO_BUILD}/Notes.xml -cheetahxml pdk.xml"
#wash -n intelall tpadm tptest tpgitg imcuser dt_users n7tpdev n7 n7tpdev esdn7g -X calibre -perc -hier -turbo 4 _RSF_perc_esd_bump_intel > log_$_timestamp
