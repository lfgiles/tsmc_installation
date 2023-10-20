##
## Intel Confidential
##
## ** Not use this file without agreement with the ESD team in Munich **
##
## contact mailto:nicolas.richaud@intel.com;harshit.dhakad@intel.com;krzysztof.domanski@intel.com
## 22/01/2020: https://gitlab.devtools.intel.com/PDK/tsmc_esdlup_checker/issues/7
##
## `perc_n06_constant.tcl` is sourced inside the `TSMC/tsmc_lib/perc_n06*.rules`
## To enable this value the recomandation is to link the `perc_n06_constant.tcl` to `constant_relaxed.tcl`
##
## ```sh
## cd runset/PERC/TSMC/tsmc_lib/
## mv perc_n06_constant.tcl perc_n06_constant.tcl_backup
## ln -s constant_relaxed.tcl perc_n06_constant.tcl
## ```
##
##//////////////////////////////////////////////////////////////////////////////// 
##// DISCLAIMER 
##// 
##// The information contained herein is provided by TSMC on an "AS IS" basis 
##// without any warranty, and TSMC has no obligation to support or otherwise 
##// maintain the information.  TSMC disclaims any representation that the 
##// information does not infringe any intellectual property rights or proprietary 
##// rights of any third parties.  There are no other warranties given by TSMC, 
##// whether express, implied or statutory, including, without limitation, implied 
##// warranties of merchantability and fitness for a particular purpose. 
##// 
##// STATEMENT OF USE 
##// 
##// This information contains confidential and proprietary information of TSMC. 
##// No part of this information may be reproduced, transmitted, transcribed, 
##// stored in a retrieval system, or translated into any human or computer 
##// language, in any form or by any means, electronic, mechanical, magnetic, 
##// optical, chemical, manual, or otherwise, without the prior written permission 
##// of TSMC.  This information was prepared for informational purpose and is for 
##// use by TSMC's customers only.  TSMC reserves the right to make changes in the 
##// information at any time and without notice. 
##// 
##// NOTICE
##// 
##// This file usually contains the super set of device extraction rule at TSMC
##// processes. However, all of device in basic deck may not be offered at current
##// SPICE model. PLEASE ALWAYS REFER TO THE CORRESPONDING SPICE MODEL DOCUMENT
##// FOR ANY DEVICE YOU WOULD LIKE USE.
##// 
##//////////////////////////////////////////////////////////////////////////////// 

## ===========================================================================
##         User Defined Variables
## ===========================================================================
set tcl_precision         12  ; # tcl precision
set ::g_unit               1  ; # unit of net list (default is 1 meter, set 1e-6 for um)
set ::g_dio_lw_ratio      10  ; # diode length/width ratio, used to calculate diode perimeter from area
set ::g_trace_limit       10  ; # maximum distance to trace a path type to source net (must be > 0)
set ::g_result_limit   5000 ; # maximum number of reported devices in some rule checks (set 0 to show all)
set ::g_int_pwr_limit  10000  ; # net with more than this number of devices connected will be recognized as internal power

set ::g_perc_sum    "perc.sum"          ; # perc summary report
set ::g_ldl_rep     "perc.rep.ldl"      ; # LDL-DRC report file
set ::g_ldl_rdb     "perc.rep.ldl.rdb"  ; # LDL-DRC result database
set ::g_p2p_sum     "perc.rep.p2p.sum"  ; # LDL-P2P summary report
set ::g_p2p_rdb     "TSMC.ESD.P2P.rdb"  ; # Refined LDL-P2P report database
set ::g_esd_mark    "TSMC.ESD.MARK.gds" ; # Marker Layer GDS for ESD.14.6~8gU, ESD.CDM.P.10gU checks

## ===========================================================================
##         Device Table
## ===========================================================================
set ::g_core_nmos_ncs {nch_lvt_mac nch_svt_mac nch_ulvt_mac nch_lvt_dnw_mac nch_svt_dnw_mac nch_ulvt_dnw_mac}

set ::g_core_pmos_pcs {pch_lvt_mac pch_svt_mac pch_ulvt_mac}

set ::g_io_nmos_n1 {nch_hia18_mac}

set ::g_io_nmos_n4 {nch_hia18_mac}

set ::g_io_nmos_n1a {nch_hia18_mac}

set ::g_io_nmos_n1b {nch_18_mac}

set ::g_io_nmos_n4a {nch_hia18_mac}

set ::g_io_nmos_n4b {nch_18_mac}

set ::g_io_nmos_ncs {nch_18_mac nch_18ud12_mac nch_18ud15_mac nch_lvt15_mac nch_lvt15ud12_mac nch_18_dnw_mac nch_18ud12_dnw_mac nch_18ud15_dnw_mac \
        nch_lvt15_dnw_mac nch_lvt15ud12_dnw_mac}

set ::g_io_pmos_pcs {pch_18_mac pch_18ud12_mac pch_18ud15_mac pch_lvt15_mac pch_lvt15ud12_mac}

set ::g_pdio_d1 {pdio_hia18_mac}

set ::g_ndio_d2 {ndio_hia18_mac}

set ::g_pdio_d3 {pdio_hia18_mac}

set ::g_ndio_d4 {ndio_hia18_mac}

set ::g_dio_b2b {ndio_hia18_mac pdio_hia18_mac}

set ::g_res_esd {rhim_nw rhim_psub}

set ::g_hia_dio {ndio_hia18_mac pdio_hia18_mac}

set ::g_res_3t_expr {_(m|nw|psub)$}

set ::g_io_vol_list {18 15 12}

# =========================================================================
#   I/O pad 1st protection
# =========================================================================
array set ::g_1st_esd   ""
set ::g_1st_esd(type)   "1st"
set ::g_1st_esd(protection)     {nm cn dd cdd}
set ::g_1st_esd(lc_protection)  {dd cdd}
# ---------------------------------------
#   device types
# ---------------------------------------
# a. diode-based
set ::g_1st_esd(pdio)       $::g_pdio_d1
set ::g_1st_esd(ndio)       $::g_ndio_d2
set ::g_1st_esd(lc_pdio)    $::g_pdio_d1
set ::g_1st_esd(lc_ndio)    $::g_ndio_d2
# b. single mos-based
set ::g_1st_esd(nmos)       $::g_io_nmos_n1
set ::g_1st_esd(pmos)       {NA}
# c. cascoded
set ::g_1st_esd(cas1_nmos)  $::g_io_nmos_n1a
set ::g_1st_esd(cas2_nmos)  $::g_io_nmos_n1b
set ::g_1st_esd(cas1_pmos)  {}
set ::g_1st_esd(cas2_pmos)  {}
set ::g_1st_esd(cas1_pdio)  $::g_pdio_d1
set ::g_1st_esd(cas2_pdio)  $::g_pdio_d1
set ::g_1st_esd(cas1_ndio)  [concat $::g_pdio_d1 $::g_ndio_d2]
set ::g_1st_esd(cas2_ndio)  $::g_ndio_d2
# ---------------------------------------
#   rule values
# ---------------------------------------
set ::g_1st_esd(count)     {ESD.NET.1gU  >   0}             ; # protection is required
set ::g_1st_esd(stack)     {ESD.NET.1gU  <=  2}             ; # cascoded stack number
set ::g_1st_esd(mn_w)      {ESD.18g      >=  490}           ; # total MN channel width
set ::g_1st_esd(mp_w)      {ESD.NET.1gU  ==  0}             ; # total MP channel width (not allowed)
set ::g_1st_esd(mn_18_l)   {ESD.20g      >=  0.135}         ; # 1.8V MN channel length
set ::g_1st_esd(mp_18_l)   {ESD.NET.1gU  ==  0}             ; # 1.8V MP channel length (not allowed)
set ::g_1st_esd(mn_15_l)   {ESD.NET.1gU  ==  0}             ; # 1.5V MN channel length (not allowed)
set ::g_1st_esd(mp_15_l)   {ESD.NET.1gU  ==  0}             ; # 1.5V MP channel length (not allowed)
set ::g_1st_esd(mn_core_l) {ESD.NET.1gU  ==  0}             ; # Core MN channel length (not allowed)
set ::g_1st_esd(mp_core_l) {ESD.NET.1gU  ==  0}             ; # Core MP channel length (not allowed)
set ::g_1st_esd(dio_p)     {ESD.NET.1gU  ==  0}             ; # total diode perimeter (not allowed)
set ::g_1st_esd(hia_w)     {HIA.1g       =~  {0.334 0.550}} ; # HIA diode Active region width
set ::g_1st_esd(hia_p)     {HIA.3g       >=  6.428}           ; # total HIA diode perimeter
set ::g_1st_esd(hia_a)     {HIA.3.1g     >=  1.3}            ; # total HIA diode area -->tbd
set ::g_1st_esd(lc_hia_w)  {ESD.LC.1g    ==  0.157}         ; # LC HIA diode Active region width
set ::g_1st_esd(lc_hia_p)  {ESD.LC.3g    >=  6.428 {$p - $l/2}} ; # total LC HIA diode perimeter
set ::g_1st_esd(lc_hia_a)  {ESD.LC.3.1g  >=  1.3}            ; # total LC HIA diode area -->tbd

set ::g_1st_esd(cas_mn_w)      {ESD.27g      >=  24}       ; # total cascoded MN channel width #updated to 540->24->deactivate 15/12/2020 according K.Domanski NR update
set ::g_1st_esd(cas_mp_w)      {ESD.NET.1gU  >=  0}         ; # total cascoded MP channel width (don't care)
set ::g_1st_esd(cas_mn_18_l)   {ESD.29g      >=  0.135}     ; # 1.8V cascoded MN channel length
set ::g_1st_esd(cas_mp_18_l)   {ESD.NET.1gU  >=  0}         ; # 1.8V cascoded MP channel length (don't care)
set ::g_1st_esd(cas_mn_15_l)   {ESD.NET.1gU  ==  0}         ; # 1.5V cascoded MN channel length (not allowed)
set ::g_1st_esd(cas_mp_15_l)   {ESD.NET.1gU  >=  0}         ; # 1.5V cascoded MP channel length (don't care)
set ::g_1st_esd(cas_mn_core_l) {ESD.NET.1gU    ==  0}        ; # Core cascoded MN channel length (not allowed)
set ::g_1st_esd(cas_mp_core_l) {ESD.NET.1gU    >=  0}        ; # Core cascoded MP channel length (don't care)
set ::g_1st_esd(forbid_types) {{ESD.NET.1.1gU >= 3.3 {nm}}} ; # for 3.3V application, single-stage NMOS esd is not allowed

# =========================================================================
#   I/O pad 2nd protection  [ESD.8gU ~ ESD.9gU]
# =========================================================================
array set ::g_2nd_esd   ""
set ::g_2nd_esd(type)   "2nd"
set ::g_2nd_esd(gox_path)       {gate sd}
set ::g_2nd_esd(gox_path_excl)  {nhia}
set ::g_2nd_esd(protection)     {nm cn dd}
# ---------------------------------------
#   device types
# ---------------------------------------
# a. diode-based
set ::g_2nd_esd(pdio)   $::g_pdio_d3
set ::g_2nd_esd(ndio)   $::g_ndio_d4
# b. single mos-based
set ::g_2nd_esd(nmos)   $::g_io_nmos_n4
set ::g_2nd_esd(pmos)   {NA}
# c. cascoded
set ::g_2nd_esd(cas1_nmos)  $::g_io_nmos_n4a
set ::g_2nd_esd(cas2_nmos)  $::g_io_nmos_n4b
set ::g_2nd_esd(cas1_pmos)  {}
set ::g_2nd_esd(cas2_pmos)  {}
set ::g_2nd_esd(cas1_pdio)  {NA}
set ::g_2nd_esd(cas2_pdio)  {NA}
set ::g_2nd_esd(cas1_ndio)  {NA}
set ::g_2nd_esd(cas2_ndio)  {NA}
# d. resistor
set ::g_2nd_esd(res)    $::g_res_esd
# ---------------------------------------
#   rule values
# ---------------------------------------
set ::g_2nd_esd(count)     {ESD.9.0gU    >   0}     ; # protection is required
set ::g_2nd_esd(stack)     {ESD.9.0gU    <=  2}     ; # cascoded stack number
set ::g_2nd_esd(mn_18_l)   {ESD.9.1gU    ==  0.135} ; # 1.8V MN channel length
set ::g_2nd_esd(mp_18_l)   {ESD.9.0gU    ==  0}     ; # 1.8V MP channel length (not allowed)
set ::g_2nd_esd(mn_18_w)   {ESD.9.1.1gU  >=  8}     ; # total 1.8V MN channel width
set ::g_2nd_esd(mn_18_wi)  {ESD.9.1.2gU  ==  0.578} ; # unit  1.8V MN channel width
set ::g_2nd_esd(mp_18_w)   {ESD.9.0gU    ==  0}     ; # total 1.8V MP channel width (not allowed)
set ::g_2nd_esd(mn_15_l)   {ESD.9.0gU    ==  0}     ; # 1.5V MN channel length (not allowed)
set ::g_2nd_esd(mp_15_l)   {ESD.9.0gU    ==  0}     ; # 1.5V MP channel length (not allowed)
set ::g_2nd_esd(mn_15_w)   {ESD.9.0gU    ==  0}     ; # total 1.5V MN channel width (not allowed)
set ::g_2nd_esd(mp_15_w)   {ESD.9.0gU    ==  0}     ; # total 1.5V MP channel width (not allowed)
set ::g_2nd_esd(mn_core_l) {ESD.9.0gU    ==  0}     ; # core MN channel length (not allowed)
set ::g_2nd_esd(mp_core_l) {ESD.9.0gU    ==  0}     ; # core MP channel length (not allowed)
set ::g_2nd_esd(mn_core_w) {ESD.9.0gU    ==  0}     ; # total core MN channel width (not allowed)
set ::g_2nd_esd(mp_core_w) {ESD.9.0gU    ==  0}     ; # total core MP channel width (not allowed)
set ::g_2nd_esd(dio_p)     {ESD.9.3gU    >=  4}     ; # total diode perimeter
set ::g_2nd_esd(res_r)     {ESD.8gU      >=  200}   ; # total resistance value
set ::g_2nd_esd(res_waive) {ESD.8gU      >   0}     ; # total resistance value with RES200
set ::g_2nd_esd(res_w)     {ESD.8.1gU    >=  1.85}  ; # total resistance width
set ::g_2nd_esd(res_dev)   {LUP.WARN.4U  >=  200}   ; # total resistance value to internal device
set ::g_2nd_esd(pro_type)  {ESD.1.1gU    ==  core}  ; # not use I/O to protect Core device
set ::g_2nd_esd(forbid_types) {{ESD.9.0.1gU >= 3.3 {nm}}} ; # for 3.3V application, single-stage NMOS esd is not allowed
set ::g_2nd_esd(mm_io_wxr)    {ESD.9.0gU   >= 100}  ; # constant value to exempt single stage junction-first gate oxide ESD path (io) through IO gate to VSS
set ::g_2nd_esd(cas_mm_wxr)   {ESD.9.0gU   >= 100}  ; # constant value to exempt 2-stage junction-first gate oxide ESD path (io/core) through core gate to VDD/VSS

set ::g_2nd_esd(cas_mn_w)      {ESD.9.1.1gU  >=  8}     ; # total cascoded MN channel width
set ::g_2nd_esd(cas_mn_wi)     {ESD.9.1.2gU  ==  0.578} ; # unit  cascoded MN channel width
set ::g_2nd_esd(cas_mp_w)      {ESD.9.0gU    >=  0}     ; # total cascoded MP channel width (don't care)
set ::g_2nd_esd(cas_mn_18_l)   {ESD.9.1gU    >=  0.135} ; # 1.8V cascoded MN channel length
set ::g_2nd_esd(cas_mp_18_l)   {ESD.9.0gU    >=  0}     ; # 1.8V cascoded MP channel length (don't care)
set ::g_2nd_esd(cas_mn_15_l)   {ESD.9.0gU    ==  0}     ; # 1.5V cascoded MN channel length (not allowed)
set ::g_2nd_esd(cas_mp_15_l)   {ESD.9.0gU    >=  0}     ; # 1.5V cascoded MP channel length (don't care)
set ::g_2nd_esd(cas_mn_core_l) {ESD.9.0gU    ==  0}     ; # Core cascoded MN channel length (not allowed)
set ::g_2nd_esd(cas_mp_core_l) {ESD.9.0gU    >=  0}     ; # Core cascoded MP channel length (don't care)

# =========================================================================
#   Cross-Domain protection  [ESD.45gU ~ ESD.47gU]
# =========================================================================
array set ::g_cdm_esd   ""
set ::g_cdm_esd(type)   "cdm"
set ::g_cdm_esd(protection) {dd}
# ---------------------------------------
#   device types
# ---------------------------------------
# a. diode-based
set ::g_cdm_esd(pdio)   $::g_pdio_d3
set ::g_cdm_esd(ndio)   $::g_ndio_d4
# b. single mos-based
set ::g_cdm_esd(nmos)   {NA}
set ::g_cdm_esd(pmos)   {NA}
# c. resistor
set ::g_cdm_esd(res)    $::g_res_esd
# ---------------------------------------
#   rule values
# ---------------------------------------
set ::g_cdm_esd(count)     {ESD.45.0gU  >   0}      ; # protection is required
set ::g_cdm_esd(mn_w)      {ESD.45.0gU  ==  0}      ; # total MN channel width (not allowed)
set ::g_cdm_esd(mp_w)      {ESD.45.0gU  ==  0}      ; # total MP channel width (not allowed)
set ::g_cdm_esd(mn_l)      {ESD.45.0gU  ==  0}      ; # MN channel length (not allowed)
set ::g_cdm_esd(mp_l)      {ESD.45.0gU  ==  0}      ; # MP channel length (not allowed)
set ::g_cdm_esd(dio_p)     {ESD.45.1gU  >=  4}      ; # total diode perimeter
set ::g_cdm_esd(res_r)     {ESD.47gU    >=  200}    ; # total resistance value
set ::g_cdm_esd(pro_type)  {ESD.1.1gU   ==  core}   ; # not use I/O to protect Core device

# =========================================================================
#   Power-Clamp protection  [ESD.40g ~ ESD.43gU]
# =========================================================================
# ---------------------------------------
#   device types
# ---------------------------------------
set ::g_pc(nmos)        [concat $::g_core_nmos_ncs $::g_io_nmos_ncs]
set ::g_pc(pmos)        [concat $::g_core_pmos_pcs $::g_io_pmos_pcs]
set ::g_pc(mos)         [concat $::g_pc(nmos) $::g_pc(pmos)]
set ::g_pc(cas_nmos)    $::g_io_nmos_ncs
set ::g_pc(cas_pmos)    $::g_io_pmos_pcs
set ::g_pc(ron_core)    {800 w}
set ::g_pc(ron_18)      {1200 w}
set ::g_pc(ron_15)      {1200 w}
# ---------------------------------------
#   rule values
# ---------------------------------------
set ::g_pc(count)           {ESD.43gU      >      0}          ; # power-clamp is required
set ::g_pc(mm_io_w)         {ESD.40g       >=   210}          ; # total finger width of io n/pmos #updated by TEG
set ::g_pc(mm_core_w)       {ESD.40.1g     >=   173}          ; # total finger width of core n/pmos #updated TEG
set ::g_pc(cas_mn_io_w)     {ESD.40.2gU    >=  2200}          ; # total finger width of cascoded io nmos
set ::g_pc(group_w)         {ESD.40.3.1gU  >=  172}          ; # total finger width of unit cell #updated TEG
set ::g_pc(mm_io_l)         {ESD.42g       =~  {0.135 0.240}} ; # channel length of io n/pmos
set ::g_pc(mm_core_l)       {ESD.42.2g     =~  {0.072 0.135}} ; # channel length of core n/pmos #updated TEG
set ::g_pc(cas_mn_io_l)     {ESD.42.1gU    =~  {0.150 0.240}} ; # channel length of cascoded io nmos
set ::g_pc(group_distance)  5                                 ; # distance of device for groupping
set ::g_pc(group_filter)    100                               ; # min. total width filter for groupping
set ::g_pc(group_width)     173                              ; # min. total width of closest groups #updated TEG
set ::g_pc(use_vol)         "high"                            ; # use high voltage

# =========================================================================
#   LC PAD Power-Clamp protection  [ESD.LC.5gU]
# =========================================================================
set ::g_lc_pc(stack)        {ESD.LC.5gU    ==  1}             ; # cascoded power-clamp is not allowed

# =========================================================================
#   Hi-CDM rules
# =========================================================================
# ---------------------------------------
#   ESD.CDM.1gU (snapback)
# ---------------------------------------
set ::g_hc_sb_vic(default)                    [list ESD.CDM.1gU >= {0 -1}]
# 1-stack
set ::g_hc_sb_vic(mn_io_prim_gnd_wxr)         [list ESD.CDM.1gU >= {0.135 0 0 -1}]
set ::g_hc_sb_vic(mn_io_esd_gnd_wxr)          [list ESD.CDM.1gU >= {0 1600}]
set ::g_hc_sb_vic(mn_io_wxr)                  [list ESD.CDM.1gU >= {0 0}]
set ::g_hc_sb_vic(mp_io_fnw_wxr)              [list ESD.CDM.1gU >= {0 0}]
# 2-stack
set ::g_hc_sb_vic(cas_mn_io_gnd_wxr)          [list ESD.CDM.1gU >= {0.135 2000 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mn_io_pwr_wxr)          [list ESD.CDM.1gU >= {0.135 2000 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mn_io_hia_gnd_wxr)      [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mn_io_hia_pwr_wxr)      [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mp_io_2nw_gnd_wxr)      [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mp_io_2nw_pwr_wxr)      [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mn_io_wxr)              [list ESD.CDM.1gU >= {0 0}]
set ::g_hc_sb_vic(cas_mp_io_fnw_wxr)          [list ESD.CDM.1gU >= {0 0}]
set ::g_hc_sb_vic(cas_mm_io_fnw_wxr)          [list ESD.CDM.1gU >= {0 0}]
# 3-stack
set ::g_hc_sb_vic(stack_mn_io_gnd_wxr)        [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_pwr_wxr)        [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_wxr)            [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_hia_gnd_wxr)    [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_hia_pwr_wxr)    [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_hia_wxr)        [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_2nw_gnd_wxr)    [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_2nw_pwr_wxr)    [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_2nw_wxr)        [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_3nw_gnd_wxr)    [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_3nw_pwr_wxr)    [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_3nw_wxr)        [list ESD.CDM.1gU >= {0.135 0 0 -1} "ldl"]

# ---------------------------------------
#   ESD.CDM.1.1gU (cascoded snapback)
# ---------------------------------------
set ::g_hc_cassb_vic(default)                 [list ESD.CDM.1.1gU >= {0 -1}]
# 1-stack
set ::g_hc_cassb_vic(mn_io_wxr)               [list ESD.CDM.1.1gU >= {0 0}]
set ::g_hc_cassb_vic(mp_io_fnw_wxr)           [list ESD.CDM.1.1gU >= {0 0}]
# 2-stack
set ::g_hc_cassb_vic(cas_mn_io_prim_gnd_wxr)  [list ESD.CDM.1.1gU >= {0.135 0 0 -1}]
set ::g_hc_cassb_vic(cas_mn_io_esd_gnd_wxr)   [list ESD.CDM.1.1gU >= {0.135 1600 0 -1}]
set ::g_hc_cassb_vic(cas_mn_io_wxr)           [list ESD.CDM.1.1gU >= {0 0}]
set ::g_hc_cassb_vic(cas_mp_io_fnw_wxr)       [list ESD.CDM.1.1gU >= {0 0}]
set ::g_hc_cassb_vic(cas_mm_io_fnw_wxr)       [list ESD.CDM.1.1gU >= {0 0}]
# 3-stack
set ::g_hc_cassb_vic(stack_mn_io_hia_gnd_wxr) [list ESD.CDM.1.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mn_io_hia_pwr_wxr) [list ESD.CDM.1.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mn_io_hia_wxr)     [list ESD.CDM.1.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mp_io_3nw_gnd_wxr) [list ESD.CDM.1.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mp_io_3nw_pwr_wxr) [list ESD.CDM.1.1gU >= {0.135 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mp_io_3nw_wxr)     [list ESD.CDM.1.1gU >= {0.135 0 0 -1} "ldl"]

# ---------------------------------------
#   ESD.CDM.2gU (dual diode)
# ---------------------------------------
set ::g_hc_dd_vic(default)                 [list ESD.CDM.2gU >= {0 -1}]
set ::g_hc_dd_vic(mn_io_hia_gnd_wxr)       [list ESD.CDM.2gU >= {0 1600}                        ]
set ::g_hc_dd_vic(mn_io_hia_pwr_wxr)       [list ESD.CDM.2gU >= {0 732}                         ]
set ::g_hc_dd_vic(mn_io_gnd_wxr)           [list ESD.CDM.2gU >= {0.135 1645 0 1334}             ]
set ::g_hc_dd_vic(mn_io_pwr_wxr)           [list ESD.CDM.2gU >= {0.135 732 0 601}               ]
set ::g_hc_dd_vic(mp_io_gnd_wxr)           [list ESD.CDM.2gU >= {0.135 1516 0 44776}            ]
set ::g_hc_dd_vic(mp_io_pwr_wxr)           [list ESD.CDM.2gU >= {0.135 471 0 18371}             ]
set ::g_hc_dd_vic(mn_core_gnd_wxr)         [list ESD.CDM.2gU >= {0.072 2289 0.02 15033 0 10714} ]
set ::g_hc_dd_vic(mn_core_pwr_wxr)         [list ESD.CDM.2gU >= {0.072 1511 0.02 10380 0 8495}  ]
set ::g_hc_dd_vic(mp_core_gnd_wxr)         [list ESD.CDM.2gU >= {0.072 4411 0.02 17024 0 10316} ]
set ::g_hc_dd_vic(mp_core_pwr_wxr)         [list ESD.CDM.2gU >= {0.072 2680 0.02 11588 0 6983}  ]
set ::g_hc_dd_vic(mn_io_hia_wxr)           [list ESD.CDM.2gU >= {0 0}                           ]
set ::g_hc_dd_vic(mn_io_wxr)               [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(mp_io_wxr)               [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(mn_core_wxr)             [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(mp_core_wxr)             [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mn_io_hia_gnd_wxr)   [list ESD.CDM.2gU >= {0 3191}                        "topo_ldl"]
set ::g_hc_dd_vic(cas_mn_io_hia_pwr_wxr)   [list ESD.CDM.2gU >= {0 1125}                        "topo_ldl"]
set ::g_hc_dd_vic(cas_mn_io_gnd_wxr)       [list ESD.CDM.2gU >= {0.135 3191 0 3191}             "topo_ldl"]
set ::g_hc_dd_vic(cas_mn_io_pwr_wxr)       [list ESD.CDM.2gU >= {0.135 1125 0 1125}             "topo_ldl"]
set ::g_hc_dd_vic(cas_mp_io_gnd_wxr)       [list ESD.CDM.2gU >= {0.135 2074 0 2074}             "topo_ldl"]
set ::g_hc_dd_vic(cas_mp_io_pwr_wxr)       [list ESD.CDM.2gU >= {0.135 0 0 0}                   "topo_ldl"]
set ::g_hc_dd_vic(cas_mm_io_gnd_wxr)       [list ESD.CDM.2gU >= {0.135 1645 0 44776}            ]
set ::g_hc_dd_vic(cas_mm_io_pwr_wxr)       [list ESD.CDM.2gU >= {0.135 732 0 18371}             ]
set ::g_hc_dd_vic(cas_mn_core_gnd_wxr)     [list ESD.CDM.2gU >= {0.072 5518 0.02 5518 0 5518}   ]
set ::g_hc_dd_vic(cas_mn_core_pwr_wxr)     [list ESD.CDM.2gU >= {0.072 0 0.02 632 0 2562}       ]
set ::g_hc_dd_vic(cas_mp_core_gnd_wxr)     [list ESD.CDM.2gU >= {0.072 3000 0.02 7945 0 9042}   ]
set ::g_hc_dd_vic(cas_mp_core_pwr_wxr)     [list ESD.CDM.2gU >= {0.072 789 0.02 4320 0 4855}    ]
set ::g_hc_dd_vic(cas_mm_core_gnd_wxr)     [list ESD.CDM.2gU >= {0.072 4411 0.02 17024 0 17024} ]
set ::g_hc_dd_vic(cas_mm_core_pwr_wxr)     [list ESD.CDM.2gU >= {0.072 2680 0.02 11588 0 11588} ]
set ::g_hc_dd_vic(cas_mn_mix_gnd_wxr)      [list ESD.CDM.2gU >= {0.072 5518 0.02 5518 0 5518}   ]
set ::g_hc_dd_vic(cas_mn_mix_pwr_wxr)      [list ESD.CDM.2gU >= {0.072 0 0.02 632 0 2562}       ]
set ::g_hc_dd_vic(cas_mp_mix_gnd_wxr)      [list ESD.CDM.2gU >= {0.072 3000 0.02 7945 0 9042}   ]
set ::g_hc_dd_vic(cas_mp_mix_pwr_wxr)      [list ESD.CDM.2gU >= {0.072 789 0.02 4320 0 4855}    ]
set ::g_hc_dd_vic(cas_mm_mix_gnd_wxr)      [list ESD.CDM.2gU >= {0.072 4411 0.02 17024 0 17024} ]
set ::g_hc_dd_vic(cas_mm_mix_pwr_wxr)      [list ESD.CDM.2gU >= {0.072 2680 0.02 11588 0 11588} ]
set ::g_hc_dd_vic(cas_mn_io_hia_wxr)       [list ESD.CDM.2gU >= {0 0}                           ]
set ::g_hc_dd_vic(cas_mn_io_wxr)           [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(cas_mp_io_wxr)           [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(cas_mm_io_wxr)           [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(cas_mn_core_wxr)         [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mp_core_wxr)         [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mm_core_wxr)         [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mn_mix_wxr)          [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mp_mix_wxr)          [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mm_mix_wxr)          [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(stack_mn_io_hia_gnd_wxr) [list ESD.CDM.2gU >= {0 2892}                        "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_io_hia_pwr_wxr) [list ESD.CDM.2gU >= {0 0}                           "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_io_gnd_wxr)     [list ESD.CDM.2gU >= {0.135 2892 0 2892}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_io_pwr_wxr)     [list ESD.CDM.2gU >= {0.135 0 0 454}                 "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_io_gnd_wxr)     [list ESD.CDM.2gU >= {0.135 4240 0 4240}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_io_pwr_wxr)     [list ESD.CDM.2gU >= {0.135 0 0 0}                   "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_io_gnd_wxr)     [list ESD.CDM.2gU >= {0.135 3191 0 44776}            ]
set ::g_hc_dd_vic(stack_mm_io_pwr_wxr)     [list ESD.CDM.2gU >= {0.135 1125 0 18371}            ]
set ::g_hc_dd_vic(stack_mn_core_gnd_wxr)   [list ESD.CDM.2gU >= {0.072 5518 0.02 5518 0 5518}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_core_pwr_wxr)   [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_core_gnd_wxr)   [list ESD.CDM.2gU >= {0.072 3000 0.02 3000 0 12353}  "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_core_pwr_wxr)   [list ESD.CDM.2gU >= {0.072 789 0.02 789 0 4079}     "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_core_gnd_wxr)   [list ESD.CDM.2gU >= {0.072 5518 0.02 17024 0 17024} ]
set ::g_hc_dd_vic(stack_mm_core_pwr_wxr)   [list ESD.CDM.2gU >= {0.072 2680 0.02 11588 0 11588} ]
set ::g_hc_dd_vic(stack_mn_mix_gnd_wxr)    [list ESD.CDM.2gU >= {0.072 5518 0.02 5518 0 5518}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_mix_pwr_wxr)    [list ESD.CDM.2gU >= {0.072 0 0.02 0 0 0}            "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_mix_gnd_wxr)    [list ESD.CDM.2gU >= {0.072 3000 0.02 3000 0 12353}  "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_mix_pwr_wxr)    [list ESD.CDM.2gU >= {0.072 789 0.02 789 0 4079}     "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_mix_gnd_wxr)    [list ESD.CDM.2gU >= {0.072 5518 0.02 17024 0 17024} ]
set ::g_hc_dd_vic(stack_mm_mix_pwr_wxr)    [list ESD.CDM.2gU >= {0.072 2680 0.02 11588 0 11588} ]
set ::g_hc_dd_vic(stack_mn_io_hia_wxr)     [list ESD.CDM.2gU >= {0 2892}                        "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_io_wxr)         [list ESD.CDM.2gU >= {0.135 2892 0 2892}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_io_wxr)         [list ESD.CDM.2gU >= {0.135 4240 0 4240}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_io_wxr)         [list ESD.CDM.2gU >= {0.135 3191 0 44776}            ]
set ::g_hc_dd_vic(stack_mn_core_wxr)       [list ESD.CDM.2gU >= {0.072 5518 0.02 5518 0 5518}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_core_wxr)       [list ESD.CDM.2gU >= {0.072 3000 0.02 3000 0 12353}  "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_core_wxr)       [list ESD.CDM.2gU >= {0.072 5518 0.02 17024 0 17024} ]
set ::g_hc_dd_vic(stack_mn_mix_wxr)        [list ESD.CDM.2gU >= {0.072 5518 0.02 5518 0 5518}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_mix_wxr)        [list ESD.CDM.2gU >= {0.072 3000 0.02 3000 0 12353}  "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_mix_wxr)        [list ESD.CDM.2gU >= {0.072 5518 0.02 17024 0 17024} ]

# ---------------------------------------
#   ESD.CDM.1/1.1/2gU key map
# ---------------------------------------
set ::g_key_map(cas) "cascoded"
set ::g_key_map(stack) "3-stack"
set ::g_key_map(mn) "nmos"
set ::g_key_map(mp) "pmos"
set ::g_key_map(mm) "n/pmos"
set ::g_key_map(io) "io"
set ::g_key_map(core) "core"
set ::g_key_map(mix) "core/io"
set ::g_key_map(hia) "hia"
set ::g_key_map(esd) "esd hia"
set ::g_key_map(prim) "primary hia"
set ::g_key_map(gnd) "tie to ground"
set ::g_key_map(pwr) "tie to power"
set ::g_key_map(int_pwr) "tie to internal power"
set ::g_key_map(1nw) ""
set ::g_key_map(2nw) ""
set ::g_key_map(3nw) ""
set ::g_key_map(fnw) ""
set ::g_key_map(wxr) ""

# ---------------------------------------
#   ESD.CDM.*
# ---------------------------------------
set ::g_hc_pc(hia_a)        {ESD.CDM.4gU    >=  1.3}     ; # extra reverse HIA diode area for cascoded(3.3V) power-clamp (HIA.3.1g)
set ::g_hc_pc(core_vol)     {ESD.CDM.6g     <=  1.115}  ; # core power-clamp max. operation voltage
set ::g_hc_pc(io_vol)       {ESD.CDM.6.1g   <=  1.98}   ; # io(1.8v) power-clamp max. operation voltage

set ::g_hc_glo_b2b(count)   {ESD.CDM.B.1gU  >   0}      ; # global back-to-back diode is required
set ::g_hc_glo_b2b(dio_p)   {ESD.CDM.B.1gU  ==  0}      ; # total general diode perimeter (not allowed) #updated TEG
set ::g_hc_glo_b2b(hia_p)   {ESD.CDM.B.1gU  >=  6.428}    ; # total HIA diode perimeter (HIA.3g) #updated TEG

set ::g_hc_cdm_b2b(count)   {ESD.CDM.B.2gU  >   0}      ; # cross-domain back-to-back diode is required
set ::g_hc_cdm_b2b(dio_p)   {ESD.CDM.B.2gU  ==  0}      ; # total general diode perimeter (not allowed)
set ::g_hc_cdm_b2b(hia_p)   {ESD.CDM.B.2gU  >=  6.428}    ; # total HIA diode perimeter (HIA.3g)  #updated TEG

# =========================================================================
#   Back-to-Back Diode protection  [ESD.15gU]
# =========================================================================
# ---------------------------------------
#   device types
# ---------------------------------------
set ::g_b2b(type)   "b2b"
set ::g_b2b(dio)    $::g_dio_b2b
# ---------------------------------------
#   rule values
# ---------------------------------------
set ::g_b2b(count)  {ESD.15gU  >   0}   ; # back-to-back diode is required
set ::g_b2b(dio_p)  {ESD.15gU  ==  0}   ; # total general diode perimeter (not allowed)
set ::g_b2b(hia_p)  {ESD.15gU  6.428} ; # total HIA diode perimeter (HIA.3g) #updated TEG


# =========================================================================
#   Others
# =========================================================================

# ================================================
#   Sheet resistance table; R = tho * L / W
# ================================================
array set ::g_tho_tbl ""
set ::g_tho_tbl(rhim_nw)    {612.3178845  -0.0367545  -0.00889775  0}
set ::g_tho_tbl(rhim_psub)  {612.3178845  -0.0367545  -0.00889775  0}

proc get_res_value { type w l s } {
    set tho $::g_tho_tbl($type)
    if { [llength $tho] == 4 } {
        lassign $tho rsh dl dw a
        return [expr $rsh*($l*$s-$dl)/($w*$s-$dw) + 2*$a/($w*$s)]
    } elseif { [llength $tho] == 5 } {
        lassign $tho rsh dl dw a b
        return [expr $rsh*($l*$s-$dl)/($w*$s-$dw) + 2*$a/($w*$s) + $b/($w*$s)]
    }
    return 1.0e-5
}

# ================================================
#   Fin Pitch & Width
# ================================================
set ::g_fin_pitch           [expr 0.030/1e6/$::g_unit]
set ::g_fin_width           [expr 0.008/1e6/$::g_unit]

# ================================================
#   Move Probe Halo Region
# ================================================
set ::g_move_probe(pdio) 1.0
set ::g_move_probe(ndio) 1.0

## ===========================================================================
##         For LDL-DRC Checks
## ===========================================================================
set ::g_n_strap_layer           "nplug"
set ::g_p_strap_layer           "pplug"
set ::g_mdsti_layer             "MD_STI_ALL"
set ::g_nwell_layer             "nxwell"
set ::g_psub_layer              "psub"
set ::g_n_mos_terminal_layer    "tndiff"
set ::g_n_hia_terminal_layer    "tndiff_sdi"
set ::g_p_mos_terminal_layer    "tpdiff"

set ::g_ldl_var(PICKUP_SOU)       0.098 ; # Pick-up Ring/Strap Size Over-Under #updated TEG
set ::g_ldl_var(LUP.2)            0.3    ; # N/PMOS space to OD injector #updated TEG
set ::g_ldl_var(LUP.2.1)          0.3    ; # NW space to OD injector #updated TEG
set ::g_ldl_var(LUP.2.1.S)        0.3    ; # P+Active to NW space #updated TEG
set ::g_ldl_var(LUP.4.2)          0.098 ; # Pick-up Strap width
set ::g_ldl_var(ESD.CDM.C.2gU)    5000  ; # Power-Clamp Size up #updated TEG
set ::g_ldl_var(ESD.CDM.C.3.1gU)  5000  ; # Power-Clamp Size up #updated TEG
set ::g_ldl_var(ESD.CDM.C.3.2gU)  5000  ; # Power-Clamp Size up #updated TEG

set ::g_ldl_types {POWER_NET GROUND_NET SIGNAL_PATH VIRTUAL_POWER_NET SINGLE_PWR_CLAMP PWR_CLAMP GND_CLAMP CORE_PWR_CLAMP IO_PWR_CLAMP \
    CAS_N1 CAS_N2 SEC_ESD CORE_PG_MOS IO_PG_MOS LC_VIC1 LC_VIC2 LC_VIC3 HC_SB_VIC1 HC_SB_VIC2 HC_SB_VIC3 HC_CASSB_VIC1 HC_CASSB_VIC2 HC_CASSB_VIC3 \
    HC_DD_VIC1 HC_DD_VIC2 HC_DD_VIC3 DIOS_UP DIOS_DN IO_GROUND_RES IO_POWER_RES SIGNAL_PATH_GOX IO_PATH FAIR_PWR_CLAMP B2B_DIO \
    XDM_TXP XDM_TXN XDM_RXP XDM_RXN XDM_TRXN LDL_DATA}

## ===========================================================================
##         For LDL-CD/P2P Checks
## ===========================================================================
set ::g_Itest(ESD.CD.1gu) 11  ; # ESD.CD.1gu, primary ESD discharge path current (1.3A))#update TEG CDM 5V 40mA
set ::g_Itest(ESD.CD.1.1gu) 11 ; # ESD.CD.1.1gu, reverse HIA diode discharge path current (1.3A))#update TEG
set ::g_Itest(ESD.CD.2gu)   12  ; # ESD.CD.2gu, secondary ESD discharge path current (12mA)

set ::g_Rmax(ESD.14.3gu) 3.0    ; # resistance of the power/ground bus line from IO pad to the closest Power clamp #updated TEG
set ::g_Rmax(ESD.14.4gu) 2.0    ; # resistance of the bus line from Power pad to the closest GND pad #updated TEG
set ::g_Rmax(ESD.14.5gu) 10.0   ; # resistance of the power/ground bus line from 2nd ESD diode to the closest Power clamp
set ::g_Rmax(ESD.14.6gu) 1.5    ; # resistance of the power/ground bus line from pick-up ring of LUP.1 to the closest Pad #updated TEG
set ::g_Rmax(ESD.14.7gu) 10.0   ; # resistance of the power/ground bus line from pick-up strap of LUP.2, LUP.2.1U to the closest Pad
set ::g_Rmax(ESD.14.8gu) 10.0   ; # resistance of the power/ground bus line from guard-ring of LUP.14.0.1U to the closest Pad

set ::g_Rmax(ESD.LCP2P.1.0gu)   4.2   ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R0)
set ::g_Rmax(ESD.LCP2P.1gu)       1.0   ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY #updated TEG
set ::g_Rmax(ESD.LCP2P.2gu)       2.5   ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp #updated TEG
set ::g_Rmax(ESD.CDM.P.1.0gu)   4.2   ; # resistance of IOPAD to Primary ESD (R0)
set ::g_Rmax(ESD.CDM.P.1gu)       74  ; # resistance of IOPAD to Primary ESD #)#update TEG
set ::g_Rmax(ESD.CDM.P.1.1gu)     16   ; # resistance of Primary ESD to closest Pad #)#update TEG
set ::g_Rmax(ESD.CDM.P.2gu)       7.5   ; # resistance of Primary ESD to power-clamp #)#update TEG
set ::g_Rmax(ESD.CDM.P.2.1gu)   2.55   ; # resistance of Primary ESD to reverse diode -->tbf
set ::g_Rmax(ESD.CDM.P.3gu)       16   ; # resistance of Power/Ground pad to core (0.75V) power-clamp #)#update TEG
set ::g_Rmax(ESD.CDM.P.4gu)       16   ; # resistance of Power/Ground pad to IO (1.8V) power-clamp #)#update TEG
set ::g_Rmax(ESD.CDM.P.5gu)       16   ; # resistance of Power/Ground pad to cascoded (3.3V) power-clamp #)#update TEG
set ::g_Rmax(ESD.CDM.P.5.1gu)   3.5   ; # resistance of Power/Ground pad to reverse diode
set ::g_Rmax(ESD.CDM.P.7gu)       4.0   ; # resistance of I/O power-clamp to power-clamp
set ::g_Rmax(ESD.CDM.P.7.1.1gu) 1.0   ; # resistance of Core power-clamp to power-clamp on power net
set ::g_Rmax(ESD.CDM.P.7.1.2gu) 1.0   ; # resistance of Core power-clamp to power-clamp on ground net
set ::g_Rmax(ESD.CDM.P.7.2gu)     4.0   ; # resistance of Cascoded power-clamp to power-clamp
set ::g_Rmax(ESD.CDM.P.7.3gu)     4.0   ; # resistance of I/O power-clamp to Cascoded power-clamp
set ::g_Rmax(ESD.CDM.P.7.4gu)     4.0   ; # resistance of I/O power-clamp to Core power-clamp
set ::g_Rmax(ESD.CDM.P.7.5gu)     1.0   ; # resistance of Core power-clamp to Cascoded power-clamp
set ::g_Rmax(ESD.CDM.P.8gu)       16   ; # resistance of back-to-back (B2B) diode to ground pad #)#update TEG
set ::g_Rmax(ESD.CDM.P.9gu)       16   ; # resistance of back-to-back (B2B) diode to power-clamp #)#update TEG
set ::g_Rmax(ESD.CDM.P.10gu)     10.0   ; # resistance of guard-rings of ESD.CDM.1gU, ESD.CDM.1.1gU, ESD.CDM.2gU
set ::g_Rmax(ESD.DISTP2P.1.0gu)   4.2   ; # resistance of ESD diode to power/ground Pad through core power-clamp (R0)
set ::g_Rmax(ESD.DISTP2P.1gu)     2.0   ; # resistance of ESD diode to power/ground Pad through core power-clamp #updated TEG
set ::g_Rmax(ESD.DISTP2P.1.1.0gu)   4.2   ; # resistance of ESD diode to power/ground Pad through IO power-clamp (R0)
set ::g_Rmax(ESD.DISTP2P.1.1gu)   1.3   ; # resistance of ESD diode to power/ground Pad through IO power-clamp
set ::g_Rmax(ESD.DISTP2P.1.2.0gu)   4.2   ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp (R0)
set ::g_Rmax(ESD.DISTP2P.1.2gu)   0.6   ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp
set ::g_Rmax(ESD.DISTP2P.1.3.0gu)   4.2   ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp (R0)
set ::g_Rmax(ESD.DISTP2P.1.3gu)   1.1   ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp

set ::g_Rmax(multi) {ESD.14.3gu ESD.14.4gu}  ; # rules need to summarize total resistance of multiple nets
set ::g_Rmax(r1)    {ESD.CDM.P.1gu   ESD.LCP2P.1gu   ESD.DISTP2P.1gu   ESD.DISTP2P.1.1gu   ESD.DISTP2P.1.2gu   ESD.DISTP2P.1.3gu  } ;        # rules need to check R1 (R-R0)
set ::g_Rmax(r0)    {ESD.CDM.P.1.0gu ESD.LCP2P.1.0gu ESD.DISTP2P.1.0gu ESD.DISTP2P.1.1.0gu ESD.DISTP2P.1.2.0gu ESD.DISTP2P.1.3.0gu} ;        # rules need to check R0
set ::g_Rmax(victim) {MN MP D R}                        ; # victim device types to identify branch point

    set ::g_ldl_var(ESD.CDM.C.4gU)       0  ; # cross-domian interface to power-clamp distance
    set ::g_ldl_var(ESD.CDM.C.4.1gU)     0  ; # cross-domian interface to back-to-back diode distance
    set ::g_ldl_var(ESD.CDM.C.5gU)       0  ; # mos connected to small power/ground domain to power-clamp distance
