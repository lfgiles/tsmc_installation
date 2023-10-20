# TSMC_ESDLUP_CHECKER

Prepare and release TSMC ESD/LUP check based on calibre perc

# Goal/why

create from the TSMC package of TSMC for ESDLUP (and associated LVS):
TSMC unpacked and install as the following structure:

    .
    |-- 1P11M_2X1YA3Y2YY2R
    |   |-- pad_info.rules
    |   |-- perc_n07.lvs
    |   |-- perc_n07.map
    |   |-- perc_n07.ro
    |   |-- perc_n07_1P11M_2X1Ya3Y2Yy2R.top
    |   `-- pex_map.rules
    |-- 1_FileList.txt
    |-- 2_Copyright.txt
    |-- 3_UserGuide.txt
    |-- 4_ReleaseNotes.txt
    |-- ESD_LUP_Checker_Calibre_7nm_V13a.tar.gz
    |-- Recommended_tool_version_number.txt
    |-- TN07CLDR001C7_1_3A.pdf
    |-- TSMC_DOC_WM
    |   |-- PERC_Methodology_N07.pdf
    |   |-- PERC_Userguide_N07.pdf
    |   `-- Terms_of_Use_for_Mentor_Graphics_PERC_Deck.pdf
    |-- example.gds
    |-- install.pl
    |-- tsmc_lib
    |   |-- pad_info.rules
    |   |-- perc_n07.rules
    |   |-- perc_n07.top
    |   |-- perc_n07_14a.rules
    |   |-- perc_n07_7a.rules
    |   |-- perc_n07_9a.rules
    |   |-- perc_n07_constant.tcl
    |   |-- perc_n07_ldl.tbc
    |   |-- perc_n07_lib.tbc
    |   `-- pex_map.rules
    |-- tsmc_ro
    |   |-- perc_n07_1x1xa1ya.ro
    |   `-- perc_n07_2x1ya.ro
    |-- user.config
    `-- user.config_11M

The final structure for one metalstack should look similar to the following:

    -- rsf
        |-- RSF_digital_perc_esd_cd_tsmc
        |-- RSF_digital_perc_esd_ldl_tsmc
        |-- RSF_digital_perc_esd_p2p_tsmc
        |-- RSF_digital_perc_esd_topo_tsmc
        |-- RSF_digital_perc_esdsch_tsmc
        |-- RSF_perc_esd_cd_tsmc
        |-- RSF_perc_esd_ldl_tsmc
        |-- RSF_perc_esd_p2p_tsmc
        |-- RSF_perc_esd_topo_tsmc
        |-- RSF_perc_esdsch_tsmc
    -- runset
        |-- PERC
            |-- TSMC
                |-- pad_info.rules
                |-- perc_n07.lvs
                |-- perc_n07.map
                |-- perc_n07.ro
                |-- pex_map.rules
                |-- tsmc_lib
                    |-- pad_info.rules
                    |-- perc_n07.rules
                    |-- perc_n07.top
                    |-- perc_n07_14a.rules
                    |-- perc_n07_7a.rules
                    |-- perc_n07_9a.rules
                    |-- perc_n07_constant.tcl
                    |-- perc_n07_ldl.tbc
                    |-- perc_n07_lib.tbc
                    |-- pex_map.rules


## Usefule

- The TSMC dir `tsmc_lib` does not depend on the metalstack
- n6 and n7 seems to have the same constant file (22/10/2019)
- need to add tvf/VERBATIM and  header&footer for the `/tsmc_lib/perc_<node>_*.rules`
- variable inside `tsmc_lib/perc_<node>_constant.tcl`
- need to add `MASK SVDB DIRECTORY "svdb" QUERY` for the topo check without ldl
- see linux cmd `patch`
- alternativ sed cmd for header: `sed '1i\\n' perc_n06.rules | sed '1r /nfs/imu/proj/tec/tptest/INandOUT/nrichaud/workspace/tsmc_esdlup_checker/script/template/header_tsmc_lib_rules.temp' | sed '1d' | sed '$a\}' > tmp1`
- diff original version of TSMC vs intel release for n7:

    `meld /nfs/imu/proj/tec/tptest/INandOUT/n7/Greenland/prepare_tsmc_perc_M15/perc/tsmc_lib /nfs/imu/proj/globus/tpdev/tech5/n7/.dr/calibre/v1.0.501/1P15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/runset/PERC/TSMC/tsmc_lib`


## version of codev 26/07/2019

How to use:
1. adapt build.sh to unpack lvs and perc from the TSMC package. need to update the path as setenv
1. go inside the `perc` directory.
1. adapt the metalstack to use inisde the `/script/perc_prepare.py`
1. run `perc_prepare.py` inside the `prepare_tsmc_perc/perc` to create `prepare_tsmc_perc/tp` with a model of the tp structure
1. create/update the config file `dev/robert_version/cf_level0.dict`
1. create a dir `mkdir testdir`
1. point to the right `RSF_template` generate with `perc_prepare.py`
1. remove metal stack from the template file
1. run `perc_dp_gen -cfg cfg_level0.dict` to generate all the defpins file
1. migrate the rsf file in the right place inside the tp.
1. compare with the current status inside the tp before to commit on tpgit or transfer with:

    trans2tpdev n7 calibre v1.0.500 /nfs/site/disks/imu_inway_scratch/nrichaud/2tpdev/n7 -notes /nfs/site/disks/imu_inway_scratch/nrichaud/2tpdev/n7/Notes.txt -xml /nfs/site/disks/imu_inway_scratch/nrichaud/2tpdev/n7/.calibre.v1.0.500.tp.xml -cheetahxml /nfs/site/disks/imu_inway_scratch/nrichaud/2tpdev/n7/.calibre.v1.0.500.pdk.xml

## version of codev 24/10/2019



- [x] add gitlab-ci to build
- [x] according the config switch `SCHEMATIC` generate the MASK SVDB `DIRECTORY svdb QUERY` statement
- [x] generate right structure for each metal stack
- [x] add head/footer/source for the `tsmc_lib/perc_n7*.rules` file
- [x] automate update inside the `perc_constant.tcl` file

### Structure of the repo

```sh
tsmc_esdlup_checker/
|-- README.md
|-- pdk.xml
`-- script
    |-- compareTP.sh
    |-- prepareRSF.sh
    |-- prepareTP.sh
    |-- python
    |   |-- CfgFile.py
    |   |-- README
    |   |-- TplGenRunset.py
    |   |-- cfg_level0.dict
    |   `-- perc_dp_gen
    |-- rsf_prepare.py
    |-- stage_2tpdev.sh
    |-- stage_2tpgit.sh
    |-- template
    |   |-- constant
    |   |   |-- n5
    |   |   |   |-- cfg_level0.dict
    |   |   |   `-- perc_n05_constant.tcl
    |   |   |-- n6
    |   |   |   |-- cfg_level0.dict
    |   |   |   `-- perc_n06_constant.tcl -> ../n7/perc_n07_constant.tcl
    |   |   `-- n7
    |   |       |-- cfg_level0.dict
    |   |       `-- perc_n07_constant.tcl
    |   `-- header_tsmc_lib_rules.temp
    `-- unpack.sh

7 directories, 21 files
```


**How to use:**
1. update inside th`.gitlab-ci.yml the variable section
1. be sure to have the technology dir inside the /script/template/constant/nonde/*. See previous node.
1. For the compare step update the variable `PATH2COMPARE` with the path to the node/stack that you want to compare


## TODO:

- [ ] add step to test inside r2g
- [ ] add step to test inside cheetah
- [ ] add test outside flow for topo/ldl/p2p/cd/ with TSMC test gds

