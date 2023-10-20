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
set ::g_int_pwr_limit  10000  ; # net with more than this number of devices connected will be recognized as internal power


set ::g_perc_sum    "perc.sum"          ; # perc summary report
set ::g_ldl_rep     "perc.rep.ldl"      ; # LDL-DRC report file
set ::g_ldl_rdb     "perc.rep.ldl.rdb"  ; # LDL-DRC result database
set ::g_p2p_sum     "perc.rep.p2p.sum"  ; # LDL-P2P summary report
set ::g_p2p_rdb     "TSMC.ESD.P2P.rdb"  ; # Refined LDL-P2P report database
set ::g_esd_mark    "TSMC.ESD.MARK.gds" ; # Marker Layer GDS for ESD.14.6~8gU checks

## ===========================================================================
##         Device Table
## ===========================================================================
set ::g_core_nmos_ncs {nch_ulvt_mac nch_ulvtll_mac nch_lvt_mac nch_lvtll_mac nch_elvt_mac nch_efvt_mac nch_svt_mac}

set ::g_core_pmos_pcs {pch_ulvt_mac pch_ulvtll_mac pch_lvt_mac pch_lvtll_mac pch_elvt_mac pch_efvt_mac pch_svt_mac}

set ::g_io_nmos_n1 {nch_hia12_mac}

set ::g_io_nmos_n4 {nch_hia12_mac}

set ::g_io_nmos_n1a {nch_hia12_mac}

set ::g_io_nmos_n1b {nch_12_mac nch_12od15_mac}

set ::g_io_nmos_n4a {nch_hia12_mac}

set ::g_io_nmos_n4b {nch_12_mac nch_12od15_mac}

set ::g_io_nmos_ncs {nch_12_mac nch_12od15_mac}

set ::g_io_pmos_pcs {pch_12_mac pch_12od15_mac}

set ::g_stack_nmos_ncs {nch_12_mac nch_12od15_mac nch_12_dnw_mac nch_12od15_dnw_mac}

set ::g_stack_pmos_pcs {pch_12_mac pch_12od15_mac}

set ::g_pdio_d1 {pdio_hia12_mac}

set ::g_ndio_d2 {ndio_hia12_mac ndio_hia12_ntn_mac}

set ::g_pdio_d3 {pdio_hia12_mac}

set ::g_ndio_d4 {ndio_hia12_mac ndio_hia12_ntn_mac}

set ::g_dio_b2b {ndio_hia12_mac ndio_hia12_ntn_mac pdio_hia12_mac}

set ::g_res_esd {rhim}

set ::g_hia_dio {pdio_hia12_mac ndio_hia12_mac ndio_hia12_ntn_mac}

set ::g_io_vol_list {15 12}

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
set ::g_1st_esd(mn_12_l)   {ESD.20g      >=  0.135}         ; # 1.2V MN channel length
set ::g_1st_esd(mp_12_l)   {ESD.NET.1gU  ==  0}             ; # 1.2V MP channel length (not allowed)
set ::g_1st_esd(mn_core_l) {ESD.NET.1gU  ==  0}             ; # Core MN channel length (not allowed)
set ::g_1st_esd(mp_core_l) {ESD.NET.1gU  ==  0}             ; # Core MP channel length (not allowed)
set ::g_1st_esd(dio_p)     {ESD.NET.1gU  ==  0}             ; # total diode perimeter (not allowed)
set ::g_1st_esd(hia_w)     {HIA.1g       =~  {0.202 0.594}} ; # HIA diode Active region width
set ::g_1st_esd(lc_hia_w)  {HIA.1g       =~  {0.202 0.594}} ; # LC HIA diode Active region width
set ::g_1st_esd(hia_p)     {HIA.3g       >=  6.428}           ; # total HIA diode perimeter#updated to 180->14.32 22/12/2020 according K.Domanski NR update
set ::g_1st_esd(hia_a)     {HIA.3.1g     >=  1.439688}            ; # total HIA diode area #updated to 36->3.2188 22/12/2020 according K.Domanski NR update
set ::g_1st_esd(lc_hia_p)  {ESD.LC.3g    >=   0}            ; # total LC HIA diode perimeter
set ::g_1st_esd(lc_hia_a)  {ESD.LC.3.1g  >=  1.439688}            ; # total LC HIA diode area#updated to 18->3.2188 22/12/2020 according K.Domanski NR update

set ::g_1st_esd(cas_mn_w)      {ESD.27g        >=  540}      ; # total cascoded MN channel width
set ::g_1st_esd(cas_mp_w)      {ESD.NET.1gU    >=  0}        ; # total cascoded MP channel width (don't care)
set ::g_1st_esd(cas_mn_12_l)   {ESD.29g        >=  0.135}    ; # 1.2V cascoded MN channel length
set ::g_1st_esd(cas_mp_12_l)   {ESD.NET.1gU    >=  0}        ; # 1.2V cascoded MP channel length (don't care)
set ::g_1st_esd(cas_mn_core_l) {ESD.NET.1gU    ==  0}        ; # Core cascoded MN channel length (not allowed)
set ::g_1st_esd(cas_mp_core_l) {ESD.NET.1gU    >=  0}        ; # Core cascoded MP channel length (don't care)
set ::g_1st_esd(forbid_types)     {}
lappend ::g_1st_esd(forbid_types) {ESD.NET.1.1gU >= 1.8 {nm}}                     ; # for 1.8V application, single-stage NMOS esd is not allowed
lappend ::g_1st_esd(forbid_types) {ESD.NET.1.2gU >= 3.3 {nm cn non_ntn_hia_ndio}} ; # for 3.3V application, NMOS esd and non-NT_N N-HIA diode are not allowed

# =========================================================================
#   I/O pad 2nd protection  [ESD.8gU ~ ESD.9gU]
# =========================================================================
array set ::g_2nd_esd   ""
set ::g_2nd_esd(type)   "2nd"
set ::g_2nd_esd(gox_path)       {gate sd tr_gate}
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
set ::g_2nd_esd(mn_12_l)   {ESD.9.1gU    ==  0.135} ; # 1.2V MN channel length
set ::g_2nd_esd(mp_12_l)   {ESD.9.0gU    ==  0}     ; # 1.2V MP channel length (not allowed)
set ::g_2nd_esd(mn_12_w)   {ESD.9.1.1gU  >=  4}     ; # total 1.2V MN channel width
set ::g_2nd_esd(mn_12_wi)  {ESD.9.1.2gU  ==  0.090} ; # unit  1.2V MN channel width
set ::g_2nd_esd(mp_12_w)   {ESD.9.0gU    ==  0}     ; # total 1.2V MP channel width (not allowed)
set ::g_2nd_esd(mn_core_l) {ESD.9.0gU    ==  0}     ; # core MN channel length (not allowed)
set ::g_2nd_esd(mp_core_l) {ESD.9.0gU    ==  0}     ; # core MP channel length (not allowed)
set ::g_2nd_esd(mn_core_w) {ESD.9.0gU    ==  0}     ; # total core MN channel width (not allowed)
set ::g_2nd_esd(mp_core_w) {ESD.9.0gU    ==  0}     ; # total core MP channel width (not allowed)
set ::g_2nd_esd(dio_p)     {ESD.9.3gU    >=  4}     ; # total diode perimeter
set ::g_2nd_esd(res_r)     {ESD.8gU      >=  200}   ; # total resistance value
set ::g_2nd_esd(res_waive) {ESD.8gU      >   0}     ; # total resistance value with RES200
set ::g_2nd_esd(res_w)     {ESD.8.1gU    >=  2.06}  ; # total resistance width
set ::g_2nd_esd(res_dev)   {LUP.WARN.4U  >=  200}   ; # total resistance value to internal device
set ::g_2nd_esd(pro_type)  {ESD.1.1gU    ==  core}  ; # not use I/O to protect Core device
set ::g_2nd_esd(forbid_types)     {}
lappend ::g_2nd_esd(forbid_types) {ESD.9.0.1gU >= 1.8 {nm}}                     ; # for 1.8V application, single-stage NMOS esd is not allowed
lappend ::g_2nd_esd(forbid_types) {ESD.9.0.2gU >= 3.3 {nm cn non_ntn_hia_ndio}} ; # for 3.3V application, NMOS esd and non-NT_N N-HIA diode are not allowed

set ::g_2nd_esd(cas_mn_w)      {ESD.9.1.1gU  >=  4}     ; # total cascoded MN channel width
set ::g_2nd_esd(cas_mn_wi)     {ESD.9.1.2gU  ==  0.090} ; # unit  cascoded MN channel width
set ::g_2nd_esd(cas_mp_w)      {ESD.9.0gU    >=  0}     ; # total cascoded MP channel width (don't care)
set ::g_2nd_esd(cas_mn_12_l)   {ESD.9.1gU    >=  0.135} ; # 1.2V cascoded MN channel length
set ::g_2nd_esd(cas_mp_12_l)   {ESD.9.0gU    >=  0}     ; # 1.2V cascoded MP channel length (don't care)
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
set ::g_pc(cas_nmos)    $::g_io_nmos_ncs
set ::g_pc(cas_pmos)    $::g_io_pmos_pcs
set ::g_pc(stack_nmos)  $::g_stack_nmos_ncs
set ::g_pc(stack_pmos)  $::g_stack_pmos_pcs
set ::g_pc(ron_core)    {26550 nfin}
set ::g_pc(ron_12)      {33160 nfin}
set ::g_pc(ron_15)      {33160 nfin}
set ::g_pc(stack)       {ncs1 pcs1 ncs2 pcs2 ncs3 pcs3}
# ---------------------------------------
#   rule values
# ---------------------------------------
set ::g_pc(count)           {ESD.43gU      >   0}             ; # power-clamp is required
set ::g_pc(mn_io_fin)       {ESD.40g       >=  76400}         ; # total fin number of io nmos
set ::g_pc(mp_io_fin)       {ESD.40g       >=  76400}         ; # total fin number of io pmos
set ::g_pc(mn_core_fin)     {ESD.40.1g     >=  7128}         ; # total fin number of core nmos #updated to 84000->7128 22/12/2020 according K.Domanski, nrichaud
set ::g_pc(mp_core_fin)     {ESD.40.1g     >=  7128}         ; # total fin number of core pmos #updated to 84000->7128 22/12/2020 according K.Domanski, nrichaud
set ::g_pc(cas_mn_io_fin)   {ESD.40.2gU    >=  7128}         ; # total fin number of cascoded io nmos #updated to 84000->7128 22/12/2020 according K.Domanski, nrichaud
set ::g_pc(cas_mp_io_fin)   {ESD.40.2gU    >=  7128}         ; # total fin number of cascoded io pmos #updated to 84000->7128 22/12/2020 according K.Domanski, nrichaud
set ::g_pc(stack_mn_io_fin) {ESD.40.4gU    >=  143000}        ; # total fin number of 3-stack io nmos
set ::g_pc(stack_mp_io_fin) {ESD.40.4gU    >=  143000}        ; # total fin number of 3-stack io pmos
set ::g_pc(group_fin)       {ESD.40.3.1gU  >=  7128}         ; # total fin number of unit cell #updated to 15200->7128 22/12/2020 according K.Domanski, nrichaud
set ::g_pc(mn_io_l)         {ESD.42g       =~  {0.084 0.135}} ; # channel length of io nmos
set ::g_pc(mp_io_l)         {ESD.42g       =~  {0.084 0.135}} ; # channel length of io pmos
set ::g_pc(mn_core_l)       {ESD.42.2g     =~  {0.084 0.135}} ; # channel length of core nmos
set ::g_pc(mp_core_l)       {ESD.42.2g     =~  {0.084 0.135}} ; # channel length of core pmos
set ::g_pc(cas_mn_io_l)     {ESD.42.1gU    =~  {0.084 0.135}} ; # channel length of cascoded io nmos
set ::g_pc(cas_mp_io_l)     {ESD.42.1gU    =~  {0.084 0.135}} ; # channel length of cascoded io pmos
set ::g_pc(stack_mn_io_l)   {ESD.42.1gU    =~  {0.084 0.135}} ; # channel length of 3-stack io nmos
set ::g_pc(stack_mp_io_l)   {ESD.42.1gU    =~  {0.084 0.135}} ; # channel length of 3-stack io pmos
set ::g_pc(group_distance)  5                                 ; # distance of device for groupping
set ::g_pc(group_filter)    100                               ; # min. total width filter for groupping
set ::g_pc(group_nfin)      76400                             ; # min. total fin number of closest groups
set ::g_pc(use_vol)         "init"                            ; # use initial voltage

# =========================================================================
#   Hi-CDM rules
# =========================================================================
# ---------------------------------------
#   ESD.CDM.1gU (snapback)
# ---------------------------------------
set ::g_hc_sb_vic(default)                    [list ESD.CDM.1gU >= {0 -1}]
# 1-stack
set ::g_hc_sb_vic(mn_io_prim_gnd_wxr)         [list ESD.CDM.1gU >= {0.135 0 0 -1}]
set ::g_hc_sb_vic(mn_io_esd_gnd_wxr)          [list ESD.CDM.1gU >= {0.135 3200 0 -1}]
set ::g_hc_sb_vic(mn_io_wxr)                  [list ESD.CDM.1gU >= {0 0}]
set ::g_hc_sb_vic(mp_io_fnw_wxr)              [list ESD.CDM.1gU >= {0 0}]
# 2-stack
set ::g_hc_sb_vic(cas_mn_io_esd_gnd_wxr)      [list ESD.CDM.1gU >= {0 -1}]
set ::g_hc_sb_vic(cas_mn_io_gnd_wxr)          [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mn_io_pwr_wxr)          [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(cas_mn_io_wxr)              [list ESD.CDM.1gU >= {0 0}]
set ::g_hc_sb_vic(cas_mp_io_fnw_wxr)          [list ESD.CDM.1gU >= {0 0}]
set ::g_hc_sb_vic(cas_mm_io_fnw_wxr)          [list ESD.CDM.1gU >= {0 0}]
# 3-stack
set ::g_hc_sb_vic(stack_mn_io_esd_gnd_wxr)    [list ESD.CDM.1gU >= {0 -1}]
set ::g_hc_sb_vic(stack_mn_io_gnd_wxr)        [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_pwr_wxr)        [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_2nw_gnd_wxr)    [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_2nw_pwr_wxr)    [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_3nw_gnd_wxr)    [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_3nw_pwr_wxr)    [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mn_io_wxr)            [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_2nw_wxr)        [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_sb_vic(stack_mp_io_3nw_wxr)        [list ESD.CDM.1gU >= {0.084 0 0 -1} "ldl"]

# ---------------------------------------
#   ESD.CDM.1.1gU (cascoded snapback)
# ---------------------------------------
set ::g_hc_cassb_vic(default)                 [list ESD.CDM.1.1gU >= {0 -1}]
# 1-stack
set ::g_hc_cassb_vic(mn_io_wxr)               [list ESD.CDM.1.1gU >= {0 0}]
set ::g_hc_cassb_vic(mp_io_fnw_wxr)           [list ESD.CDM.1.1gU >= {0 0}]
# 2-stack
set ::g_hc_cassb_vic(cas_mn_io_prim_gnd_wxr)  [list ESD.CDM.1.1gU >= {0.135 0 0 -1}]
set ::g_hc_cassb_vic(cas_mn_io_esd_gnd_wxr)   [list ESD.CDM.1.1gU >= {0.135 3200 0 -1}]
set ::g_hc_cassb_vic(cas_mn_io_wxr)           [list ESD.CDM.1.1gU >= {0 0}]
set ::g_hc_cassb_vic(cas_mp_io_fnw_wxr)       [list ESD.CDM.1.1gU >= {0 0}]
set ::g_hc_cassb_vic(cas_mm_io_fnw_wxr)       [list ESD.CDM.1.1gU >= {0 0}]
# 3-stack
set ::g_hc_cassb_vic(stack_mn_io_esd_gnd_wxr) [list ESD.CDM.1.1gU >= {0 -1}]
set ::g_hc_cassb_vic(stack_mn_io_gnd_wxr)     [list ESD.CDM.1.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mn_io_pwr_wxr)     [list ESD.CDM.1.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mp_io_3nw_gnd_wxr) [list ESD.CDM.1.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mp_io_3nw_pwr_wxr) [list ESD.CDM.1.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mn_io_wxr)         [list ESD.CDM.1.1gU >= {0.084 0 0 -1} "ldl"]
set ::g_hc_cassb_vic(stack_mp_io_3nw_wxr)     [list ESD.CDM.1.1gU >= {0.084 0 0 -1} "ldl"]

# ---------------------------------------
#   ESD.CDM.2gU (dual diode)
# ---------------------------------------
set ::g_hc_dd_vic(default)                 [list ESD.CDM.2gU >= {0 -1}]
set ::g_hc_dd_vic(mn_io_hia_gnd_wxr)       [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(mn_io_hia_pwr_wxr)       [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(mn_io_gnd_wxr)           [list ESD.CDM.2gU >= {0.135 1040 0 1714}             ]
set ::g_hc_dd_vic(mn_io_pwr_wxr)           [list ESD.CDM.2gU >= {0.135 626 0 1092}              ]
set ::g_hc_dd_vic(mp_io_gnd_wxr)           [list ESD.CDM.2gU >= {0.135 1517 0 67568}            ]
set ::g_hc_dd_vic(mp_io_pwr_wxr)           [list ESD.CDM.2gU >= {0.135 882 0 42823}             ]
set ::g_hc_dd_vic(mn_core_gnd_wxr)         [list ESD.CDM.2gU >= {0.054 1690 0.02 18097 0 26373} ]
set ::g_hc_dd_vic(mn_core_pwr_wxr)         [list ESD.CDM.2gU >= {0.054 1230 0.02 13368 0 20002} ]
set ::g_hc_dd_vic(mp_core_gnd_wxr)         [list ESD.CDM.2gU >= {0.054 9977 0.02 16837 0 21865} ]
set ::g_hc_dd_vic(mp_core_pwr_wxr)         [list ESD.CDM.2gU >= {0.054 7255 0.02 12614 0 16571} ]
set ::g_hc_dd_vic(mn_io_esd_gnd_wxr)       [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(mn_io_wxr)               [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(mp_io_wxr)               [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(mn_core_wxr)             [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(mp_core_wxr)             [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mn_io_hia_gnd_wxr)   [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(cas_mn_io_hia_pwr_wxr)   [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(cas_mn_io_gnd_wxr)       [list ESD.CDM.2gU >= {0.135 6627 0 7451}             "topo_ldl"]
set ::g_hc_dd_vic(cas_mn_io_pwr_wxr)       [list ESD.CDM.2gU >= {0.135 1055 0 1055}             "topo_ldl"]
set ::g_hc_dd_vic(cas_mp_io_gnd_wxr)       [list ESD.CDM.2gU >= {0.135 3975 0 3975}             "topo_ldl"]
set ::g_hc_dd_vic(cas_mp_io_pwr_wxr)       [list ESD.CDM.2gU >= {0.135 0 0 0}                   "topo_ldl"]
set ::g_hc_dd_vic(cas_mm_io_gnd_wxr)       [list ESD.CDM.2gU >= {0.135 1517 0 67568}            ]
set ::g_hc_dd_vic(cas_mm_io_pwr_wxr)       [list ESD.CDM.2gU >= {0.135 882 0 42823}             ]
set ::g_hc_dd_vic(cas_mn_core_gnd_wxr)     [list ESD.CDM.2gU >= {0.054 2210 0.02 2985 0 11638}  ]
set ::g_hc_dd_vic(cas_mn_core_pwr_wxr)     [list ESD.CDM.2gU >= {0.054 510 0.02 780 0 7213}     ]
set ::g_hc_dd_vic(cas_mp_core_gnd_wxr)     [list ESD.CDM.2gU >= {0.054 191 0.02 5233 0 10808}   ]
set ::g_hc_dd_vic(cas_mp_core_pwr_wxr)     [list ESD.CDM.2gU >= {0.054 0 0.02 2476 0 6808}      ]
set ::g_hc_dd_vic(cas_mm_core_gnd_wxr)     [list ESD.CDM.2gU >= {0.054 9977 0.02 18097 0 26373} ]
set ::g_hc_dd_vic(cas_mm_core_pwr_wxr)     [list ESD.CDM.2gU >= {0.054 7255 0.02 13368 0 20002} ]
set ::g_hc_dd_vic(cas_mn_mix_gnd_wxr)      [list ESD.CDM.2gU >= {0.054 2210 0.02 2985 0 11638}  ]
set ::g_hc_dd_vic(cas_mn_mix_pwr_wxr)      [list ESD.CDM.2gU >= {0.054 510 0.02 780 0 7213}     ]
set ::g_hc_dd_vic(cas_mp_mix_gnd_wxr)      [list ESD.CDM.2gU >= {0.054 191 0.02 5233 0 10808}   ]
set ::g_hc_dd_vic(cas_mp_mix_pwr_wxr)      [list ESD.CDM.2gU >= {0.054 0 0.02 2476 0 6808}      ]
set ::g_hc_dd_vic(cas_mm_mix_gnd_wxr)      [list ESD.CDM.2gU >= {0.054 9977 0.02 18097 0 26373} ]
set ::g_hc_dd_vic(cas_mm_mix_pwr_wxr)      [list ESD.CDM.2gU >= {0.054 7255 0.02 13368 0 20002} ]
set ::g_hc_dd_vic(cas_mn_io_esd_gnd_wxr)   [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(cas_mn_io_wxr)           [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(cas_mp_io_wxr)           [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(cas_mm_io_wxr)           [list ESD.CDM.2gU >= {0.135 0 0 0}                   ]
set ::g_hc_dd_vic(cas_mn_core_wxr)         [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mp_core_wxr)         [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mm_core_wxr)         [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 0}            ]
set ::g_hc_dd_vic(cas_mn_mix_wxr)          [list ESD.CDM.2gU >= {0 0}                           ]
set ::g_hc_dd_vic(cas_mp_mix_wxr)          [list ESD.CDM.2gU >= {0 0}                           ]
set ::g_hc_dd_vic(cas_mm_mix_wxr)          [list ESD.CDM.2gU >= {0 0}                           ]
set ::g_hc_dd_vic(stack_mn_io_hia_gnd_wxr) [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(stack_mn_io_hia_pwr_wxr) [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(stack_mn_io_gnd_wxr)     [list ESD.CDM.2gU >= {0.135 5006 0 5229}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_io_pwr_wxr)     [list ESD.CDM.2gU >= {0.135 605 0 605}               "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_io_gnd_wxr)     [list ESD.CDM.2gU >= {0.135 2440 0 2440}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_io_pwr_wxr)     [list ESD.CDM.2gU >= {0.135 0 0 0}                   "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_io_gnd_wxr)     [list ESD.CDM.2gU >= {0.135 6627 0 67568}            ]
set ::g_hc_dd_vic(stack_mm_io_pwr_wxr)     [list ESD.CDM.2gU >= {0.135 1055 0 42823}            ]
set ::g_hc_dd_vic(stack_mn_core_gnd_wxr)   [list ESD.CDM.2gU >= {0.054 1271 0.02 1276 0 2470}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_core_pwr_wxr)   [list ESD.CDM.2gU >= {0.054 108 0.02 108 0 108}      "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_core_gnd_wxr)   [list ESD.CDM.2gU >= {0.054 778 0.02 778 0 2616}     "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_core_pwr_wxr)   [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 265}          "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_core_gnd_wxr)   [list ESD.CDM.2gU >= {0.054 9977 0.02 18097 0 26373} ]
set ::g_hc_dd_vic(stack_mm_core_pwr_wxr)   [list ESD.CDM.2gU >= {0.054 7255 0.02 13368 0 20002} ]
set ::g_hc_dd_vic(stack_mn_mix_gnd_wxr)    [list ESD.CDM.2gU >= {0.054 1271 0.02 1276 0 2470}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mn_mix_pwr_wxr)    [list ESD.CDM.2gU >= {0.054 108 0.02 108 0 108}      "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_mix_gnd_wxr)    [list ESD.CDM.2gU >= {0.054 778 0.02 778 0 2616}     "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_mix_pwr_wxr)    [list ESD.CDM.2gU >= {0.054 0 0.02 0 0 265}          "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_mix_gnd_wxr)    [list ESD.CDM.2gU >= {0.054 9977 0.02 18097 0 26373} ]
set ::g_hc_dd_vic(stack_mm_mix_pwr_wxr)    [list ESD.CDM.2gU >= {0.054 7255 0.02 13368 0 20002} ]
set ::g_hc_dd_vic(stack_mn_io_esd_gnd_wxr) [list ESD.CDM.2gU >= {0 -1}                          ]
set ::g_hc_dd_vic(stack_mn_io_wxr)         [list ESD.CDM.2gU >= {0.135 5006 0 5229}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_io_wxr)         [list ESD.CDM.2gU >= {0.135 2440 0 2440}             "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_io_wxr)         [list ESD.CDM.2gU >= {0.135 6627 0 67568}            ]
set ::g_hc_dd_vic(stack_mn_core_wxr)       [list ESD.CDM.2gU >= {0.054 1271 0.02 1276 0 2470}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_core_wxr)       [list ESD.CDM.2gU >= {0.054 778 0.02 778 0 2616}     "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_core_wxr)       [list ESD.CDM.2gU >= {0.054 9977 0.02 18097 0 26373} ]
set ::g_hc_dd_vic(stack_mn_mix_wxr)        [list ESD.CDM.2gU >= {0.054 1271 0.02 1276 0 2470}   "topo_ldl"]
set ::g_hc_dd_vic(stack_mp_mix_wxr)        [list ESD.CDM.2gU >= {0.054 778 0.02 778 0 2616}     "topo_ldl"]
set ::g_hc_dd_vic(stack_mm_mix_wxr)        [list ESD.CDM.2gU >= {0.054 9977 0.02 18097 0 26373} ]

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
set ::g_key_map(2nw) ""
set ::g_key_map(3nw) ""
set ::g_key_map(fnw) ""
set ::g_key_map(wxr) ""

# ---------------------------------------
#   ESD.CDM.*
# ---------------------------------------
set ::g_hc_pc(hia_a)        {ESD.CDM.4gU    >=  1.439688}     ; # extra reverse HIA diode area for cascoded(1.8V) power-clamp (HIA.3.1g)#updated to 36->14.32 22/12/2020 according K.Domanski, update NR
set ::g_hc_pc(core_vol)     {ESD.CDM.6g     <=  0.96}   ; # core power-clamp max. operation voltage
set ::g_hc_pc(io_vol)       {ESD.CDM.6.1g   <=  1.65}   ; # io power-clamp max. operation voltage

set ::g_hc_glo_b2b(count)   {ESD.CDM.B.1gU  >   0}      ; # global back-to-back diode is required
set ::g_hc_glo_b2b(dio_p)   {ESD.CDM.B.1gU  ==  0}      ; # total general diode perimeter (not allowed)
set ::g_hc_glo_b2b(hia_p)   {ESD.CDM.B.1gU  >=  6.428}    ; # total HIA diode perimeter (HIA.3g) #updated to 180->14.32 22/12/2020 according K.Domanski, update NR

set ::g_hc_cdm_b2b(count)   {ESD.CDM.B.2gU  >   0}      ; # cross-domain back-to-back diode is required
set ::g_hc_cdm_b2b(dio_p)   {ESD.CDM.B.2gU  ==  0}      ; # total general diode perimeter (not allowed)
set ::g_hc_cdm_b2b(hia_p)   {ESD.CDM.B.2gU  >=  6.428}    ; # total HIA diode perimeter (HIA.3g) #updated to 180->14.32 22/12/2020 according K.Domanski, update NR

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
set ::g_b2b(hia_p)  {ESD.15gU  >=  6.428} ; # total HIA diode perimeter (HIA.3g) #updated to 180->14.32 22/12/2020 according K.Domanski, update NR


# =========================================================================
#   Others
# =========================================================================
set ::g_voltage_type "init"     ; # use initial voltage for under/over-drive device

# ================================================
#   Sheet resistance table; R = tho * L / W
# ================================================
array set ::g_tho_tbl ""
set ::g_tho_tbl(rhim)   {626.6374   -0.041134   0.0071191   0}

# ================================================
#   Fin Pitch & Width
# ================================================
set ::g_fin_pitch   [expr 0.028/1e6/$::g_unit]
set ::g_fin_width   [expr 0.006/1e6/$::g_unit]

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

set ::g_ldl_var(PICKUP_SOU)       0.263 ; # Pick-up Ring/Strap Size Over-Under
set ::g_ldl_var(LUP.2)            15    ; # N/PMOS space to OD injector
set ::g_ldl_var(LUP.2.1)          15    ; # NW space to OD injector
set ::g_ldl_var(LUP.2.1.S)        20    ; # P+Active to NW space
set ::g_ldl_var(LUP.4.2)          0.09  ; # Pick-up Strap width
set ::g_ldl_var(LUP.IHIA.1)       1.705 ; # OD injector size in vertical
set ::g_ldl_var(ESD.7.0.1gU)      1.2   ; # single nmos esd, N+Active to N+Active
set ::g_ldl_var(ESD.7.0.2gU)      1.2   ; # single nmos esd, N+Active to NW
set ::g_ldl_var(ESD.7.0.3gU)      1.2   ; # single nmos esd, P+Active to P+Active
set ::g_ldl_var(ESD.7.0.4gU)      1.2   ; # single nmos esd, P+Active to RW
set ::g_ldl_var(ESD.7.1gU)        1.2   ; # cascoded nmos esd, Pwr/Gnd device search region
set ::g_ldl_var(ESD.7.1.1gU)      1.2   ; # cascoded nmos esd, N+Active to N+Active
set ::g_ldl_var(ESD.7.1.2gU)      1.2   ; # cascoded nmos esd, N+Active to NW
set ::g_ldl_var(ESD.7.1.3gU)      1.2   ; # cascoded nmos esd, P+Active to P+Active
set ::g_ldl_var(ESD.7.1.4gU)      1.2   ; # cascoded nmos esd, P+Active to RW
set ::g_ldl_var(ESD.CD.3gU)       1.0   ; # N-strap search region
set ::g_ldl_var(ESD.CD.3.1gU)     6.0   ; # single nmos esd, res >= 200, P+Active to NW
set ::g_ldl_var(ESD.CD.3.2gU)     6.0   ; # single nmos esd, res  < 200, P+Active to NW
set ::g_ldl_var(ESD.CD.3.3gU)     9.0   ; # cascoded nmos esd, res >= 200, P+Active to NW
set ::g_ldl_var(ESD.CD.3.4gU)     9.0   ; # cascoded nmos esd, res  < 200, P+Active to NW
set ::g_ldl_var(ESD.CDM.C.2gU)    5000  ; # Power-Clamp Size up #intel update 26/07/2019 according K.D
set ::g_ldl_var(ESD.CDM.C.3.1gU)  5000  ; # Power-Clamp Size up #intel update 26/07/2019 according K.D
set ::g_ldl_var(ESD.CDM.C.3.2gU)  5000  ; # Power-Clamp Size up #intel update 26/07/2019 according K.D

set ::g_ldl_types {POWER_NET GROUND_NET SIGNAL_PATH VIRTUAL_POWER_NET DIOS_UP DIOS_DN CAS_N1 CAS_N2 SEC_ESD \
    LC_VIC1 LC_VIC2 LC_VIC3 HC_SB_VIC1 HC_SB_VIC2 HC_SB_VIC3 \
    HC_CASSB_VIC1 HC_CASSB_VIC2 HC_CASSB_VIC3 HC_DD_VIC1 HC_DD_VIC2 HC_DD_VIC3 \
    IO_GROUND_RES IO_POWER_RES SIGNAL_PATH_GOX IO_PATH B2B_DIO XDM_TXP XDM_TXN XDM_RXP XDM_RXN XDM_TRXN \
    LDL_DATA LDL_PG_MOS_CORE LDL_PG_MOS_IO LDL_PWR_CLAMP_CORE LDL_PWR_CLAMP_IO LDL_PWR_CLAMP_CAS LDL_PWR_CLAMP_STACK}


## ===========================================================================
##         For LDL-CD/P2P Checks
## ===========================================================================
set ::g_Itest(ESD.CD.1gu) 11  ; # ESD.CD.1gu, primary ESD discharge path current (1.3A)#updated for D2D by TEG ESD
set ::g_Itest(ESD.CD.1.1gu) 11 ; # ESD.CD.1.1gu, reverse HIA diode discharge path current (1.3A)#updated for D2D by TEG ESD
set ::g_Itest(ESD.CD.2gu)   12  ; # ESD.CD.2gu, secondary ESD discharge path current (12mA)
set ::g_Itest(ESD.CD.3.1gu)  7  ; # ESD.CD.3.1gu, single nmos esd, res >= 200, Pad to P+Active/Nstrap path current
set ::g_Itest(ESD.CD.3.2gu) 12  ; # ESD.CD.3.2gu, single nmos esd, res  < 200, Pad to P+Active/Nstrap path current
set ::g_Itest(ESD.CD.3.3gu) 12  ; # ESD.CD.3.3gu, cascoded nmos esd, res >= 200, Pad to P+Active/Nstrap path current
set ::g_Itest(ESD.CD.3.4gu) 24  ; # ESD.CD.3.4gu, cascoded nmos esd, res  < 200, Pad to P+Active/Nstrap path current

set ::g_Rmax(ESD.14.3.1gu) 1.0  ; # resistance of the power/ground bus line from IO pad to the closest Power clamp
set ::g_Rmax(ESD.14.3.2gu) 1.0  ; # resistance of the power/ground bus line from IO pad to the closest Power clamp
set ::g_Rmax(ESD.14.4gu) 1.0    ; # resistance of the bus line from Power pad to the closest GND pad
set ::g_Rmax(ESD.14.5.1gu) 10.0 ; # resistance of the power/ground bus line from 2nd ESD diode to the closest Power clamp
set ::g_Rmax(ESD.14.5.2gu) 10.0 ; # resistance of the power/ground bus line from 2nd ESD diode to the closest Power clamp
set ::g_Rmax(ESD.14.6gu) 1.0    ; # resistance of the power/ground bus line from pick-up ring of LUP.1 to the closest Pad
set ::g_Rmax(ESD.14.7gu) 10.0   ; # resistance of the power/ground bus line from pick-up strap of LUP.2, LUP.2.1U to the closest Pad
set ::g_Rmax(ESD.14.8gu) 10.0   ; # resistance of the power/ground bus line from guard-ring of LUP.14.0.1U to the closest Pad

set ::g_Rmax(ESD.LCP2P.1.1gu)     0.1  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R1)
set ::g_Rmax(ESD.LCP2P.1.2gu)     0.1  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R1)
set ::g_Rmax(ESD.LCP2P.1.0gu)     4.2  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R0)
set ::g_Rmax(ESD.LCP2P.2.1gu)     0.1  ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp
set ::g_Rmax(ESD.LCP2P.2.2gu)     0.1  ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp
set ::g_Rmax(ESD.CDM.P.1.0gu)     70  ; # resistance of IOPAD to Primary ESD (R0) #updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.0.1gu)   4  ; # resistance of IOPAD to Primary ESD pull-down diode (R3)#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.0.2gu)   4  ; # resistance of IOPAD to Primary ESD pull-up diode (R1)#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.0.3gu)   4  ; # resistance of IOPAD to Primary ESD snapback NMOS (R3)#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.1.0.1gu) 16  ; # resistance of Primary ESD pull-down diode to closest Pad#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.1.0.2gu) 16  ; # resistance of Primary ESD pull-up diode to closest Pad#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.1.0.3gu) 16  ; # resistance of Primary ESD snapback NMOS to closest Pad#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.1.2.0.1gu) 0.1  ; # resistance of Primary ESD pull-down stacked diode
set ::g_Rmax(ESD.CDM.P.1.2.0.2gu) 0.1  ; # resistance of Primary ESD pull-up stacked diode
set ::g_Rmax(ESD.CDM.P.2.0.1gu)   7.5  ; # resistance of Primary ESD pull-down diode to power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.2.0.2gu)   7.5  ; # resistance of Primary ESD pull-up diode to power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.2.0.3gu)   7.5  ; # resistance of Primary ESD snapback NMOS to power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.2.1gu)     7.5  ; # resistance of Primary ESD 2-stage snapback NMOS to reverse diode#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.3.0.1gu)   3.5  ; # resistance of Ground pad to core power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.3.0.2gu)   3.5  ; # resistance of Power pad to core power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.4.0.1gu)   100.2  ; # resistance of Ground pad to IO power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.4.0.2gu)   100.2  ; # resistance of Power pad to IO power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.5.0.1gu)   100.2  ; # resistance of Ground pad to cascoded power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.5.0.2gu)   100.2  ; # resistance of Power pad to cascoded power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.5.1.0.1gu) 100.2  ; # resistance of Ground pad to reverse diode#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.5.1.0.2gu) 100.2  ; # resistance of Power pad to reverse diode#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.7.0.1gu)   2.0  ; # resistance of I/O power-clamp to power-clamp on Ground net
set ::g_Rmax(ESD.CDM.P.7.0.2gu)   2.0  ; # resistance of I/O power-clamp to power-clamp on Power net
set ::g_Rmax(ESD.CDM.P.7.1.0.1gu) 1.0  ; # resistance of Core power-clamp to power-clamp on Ground net
set ::g_Rmax(ESD.CDM.P.7.1.0.2gu) 1.0  ; # resistance of Core power-clamp to power-clamp on Power net
set ::g_Rmax(ESD.CDM.P.7.2.0.1gu) 2.0  ; # resistance of Cascoded power-clamp to power-clamp on Ground net
set ::g_Rmax(ESD.CDM.P.7.2.0.2gu) 2.0  ; # resistance of Cascoded power-clamp to power-clamp on Power net
set ::g_Rmax(ESD.CDM.P.7.3gu)     2.0  ; # resistance of I/O power-clamp to Cascoded power-clamp
set ::g_Rmax(ESD.CDM.P.7.4gu)     1.0  ; # resistance of I/O power-clamp to Core power-clamp
set ::g_Rmax(ESD.CDM.P.7.5gu)     1.0  ; # resistance of Core power-clamp to Cascoded power-clamp
set ::g_Rmax(ESD.CDM.P.8gu)       2  ; # resistance of back-to-back (B2B) diode to ground pad#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.9gu)       2  ; # resistance of back-to-back (B2B) diode to power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.CDM.P.10gu)      10.0 ; # resistance of guard-rings of ESD.CDM.1gU, ESD.CDM.1.1gU, ESD.CDM.2gU
set ::g_Rmax(ESD.DISTP2P.1.0gu)     420   ; # resistance of IOPAD to Primary ESD (R0)#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.0.1gu)   126  ; # resistance of ESD diode to power/ground Pad through core power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.0.2gu)   126  ; # resistance of ESD diode to power/ground Pad through core power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.1.0gu)   420   ; # resistance of IOPAD to Primary ESD (R0)#updated 
set ::g_Rmax(ESD.DISTP2P.1.1.0.1gu) 146  ; # resistance of ESD diode to power/ground Pad through IO power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.1.0.2gu) 146  ; # resistance of ESD diode to power/ground Pad through IO power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.2.0gu)   420   ; # resistance of IOPAD to Primary ESD (R0)#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.2.0.1gu) 106  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.2.0.2gu) 106  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.3.0gu)   420   ; # resistance of IOPAD to Primary ESD (R0)#updated  for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.3.0.1gu) 126  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp#updated for D2D by TEG ESD
set ::g_Rmax(ESD.DISTP2P.1.3.0.2gu) 126  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp#updated for D2D by TEG ESD

set ::g_Rmax(multi) {ESD.14.3.1gu ESD.14.3.2gu ESD.14.4gu}  ; # rules need to summarize total resistance of multiple nets
set ::g_Rmax(r1)    {ESD.CDM.P.1.0.1gu ESD.CDM.P.1.0.2gu ESD.CDM.P.1.0.3gu ESD.LCP2P.1.1gu ESD.LCP2P.1.2gu}  ; # rules need to check R1 (R-R0)
set ::g_Rmax(r0)    {ESD.CDM.P.1.0gu   ESD.CDM.P.1.0gu   ESD.CDM.P.1.0gu   ESD.LCP2P.1.0gu ESD.LCP2P.1.0gu}  ; # rules need to check R0
lappend ::g_Rmax(r1)     ESD.DISTP2P.1.0.1gu ESD.DISTP2P.1.0.2gu ESD.DISTP2P.1.1.0.1gu ESD.DISTP2P.1.1.0.2gu ESD.DISTP2P.1.2.0.1gu ESD.DISTP2P.1.2.0.2gu ESD.DISTP2P.1.3.0.1gu ESD.DISTP2P.1.3.0.2gu
lappend ::g_Rmax(r0)     ESD.DISTP2P.1.0gu   ESD.DISTP2P.1.0gu   ESD.DISTP2P.1.1.0gu   ESD.DISTP2P.1.1.0gu   ESD.DISTP2P.1.2.0gu   ESD.DISTP2P.1.2.0gu   ESD.DISTP2P.1.3.0gu   ESD.DISTP2P.1.3.0gu
set ::g_Rmax(victim) {MN MP D R}                       ; # victim device types to identify branch point

## ===========================================================================
##         For CDM 9A
## ===========================================================================
if { ![catch {tvf::svrf_var CDM_9A}] && [tvf::svrf_var CDM_9A] } {
    set ::g_1st_esd(protection) {dd cdd}
    set ::g_1st_esd(count)      {ESD.CDM9A.NET.1gU   >     0}     ; # protection is required
    set ::g_1st_esd(hia_p)      {HIA.CDM9A.3g        >=  360}     ; # total HIA diode perimeter
    set ::g_1st_esd(hia_a)      {HIA.CDM9A.3.1g      >=   72}     ; # total HIA diode area
    set ::g_1st_esd(lc_hia_p)   {ESD.CDM9A.LC.3g     >=    0}     ; # total LC HIA diode perimeter
    set ::g_1st_esd(lc_hia_a)   {ESD.CDM9A.LC.3.1g   >=   36}     ; # total LC HIA diode area

    set ::g_2nd_esd(protection) {dd}
    set ::g_2nd_esd(count)      {ESD.CDM9A.9.0gU     >      0}    ; # protection is required
    set ::g_2nd_esd(res_w)      {ESD.CDM9A.8.1gU     >=  5.15}    ; # total resistance width

    set ::g_pc(mn_io_fin)       {ESD.CDM9A.40g       >=  145200}  ; # total fin number of io nmos
    set ::g_pc(mp_io_fin)       {ESD.CDM9A.40g       >=  145200}  ; # total fin number of io pmos
    set ::g_pc(mn_core_fin)     {ESD.CDM9A.40.1g     >=  160500}  ; # total fin number of core nmos
    set ::g_pc(mp_core_fin)     {ESD.CDM9A.40.1g     >=  160500}  ; # total fin number of core pmos
    set ::g_pc(cas_mn_io_fin)   {ESD.CDM9A.40.2gU    >=  160500}  ; # total fin number of cascoded io nmos
    set ::g_pc(cas_mp_io_fin)   {ESD.CDM9A.40.2gU    >=  160500}  ; # total fin number of cascoded io pmos
    set ::g_pc(stack_mn_io_fin) {ESD.CDM9A.40.4gU    >=  272000}  ; # total fin number of 3-stack io nmos
    set ::g_pc(stack_mp_io_fin) {ESD.CDM9A.40.4gU    >=  272000}  ; # total fin number of 3-stack io pmos
    set ::g_pc(group_fin)       {ESD.CDM9A.40.3.1gU  >=   45800}  ; # total fin number of unit cell
    set ::g_pc(group_nfin)      145200                            ; # min. total fin number of closest groups

    set ::g_b2b(hia_p)          {ESD.15gU       >=  360}  ; # total HIA diode perimeter (HIA.CDM9A.3g)
    set ::g_hc_pc(hia_a)        {ESD.CDM.4gU    >=   72}  ; # extra reverse HIA diode area for cascoded(1.8V) power-clamp (HIA.CDM9A.3.1g)
    set ::g_hc_glo_b2b(hia_p)   {ESD.CDM.B.1gU  >=  360}  ; # total HIA diode perimeter (HIA.CDM9A.3g)
    set ::g_hc_cdm_b2b(hia_p)   {ESD.CDM.B.2gU  >=  360}  ; # total HIA diode perimeter (HIA.CDM9A.3g)

    foreach {key value} [array get ::g_cdm_esd] {
        if { [lindex $value 0] eq "ESD.45.0gU" } { lset value 0 "ESD.CDM.X.1gU" }
        set ::g_xdm_esd($key) $value
    }
    set ::g_xdm_esd(pc)         {ESD.CDM.X.1gU   >      0} ; # cross-domain power-clamp is required
    set ::g_xdm_esd(res_w)      {ESD.CDM9A.8.1gU >=  5.15} ; # total resistance width

    set ::g_ldl_var(ESD.CDM.C.2gU)    1250  ; # mos connected to power/ground to power-clamp distance
    set ::g_ldl_var(ESD.CDM.C.3.1gU)  1250  ; # core mos between power/ground to power-clamp distance
    set ::g_ldl_var(ESD.CDM.C.3.2gU)  1250  ; # io mos between power/ground to power-clamp distance
    set ::g_ldl_var(ESD.CDM.C.4gU)     410  ; # cross-domian interface to power-clamp distance
    set ::g_ldl_var(ESD.CDM.C.4.1gU)   410  ; # cross-domian interface to back-to-back diode distance
    set ::g_ldl_var(ESD.CDM.C.5gU)    5001  ; # mos connected to small power/ground domain to power-clamp distance#intel update 29/10/2020 according K. from n5p

    set ::g_Itest(ESD.CD.1gu)         2400  ; # ESD.CD.1gu, primary ESD discharge path current (2.4A)
    set ::g_Itest(ESD.CD.1.1gu)       2400  ; # ESD.CD.1.1gu, reverse HIA diode discharge path current (2.4A)
    set ::g_Itest(ESD.CD.2gu)           30  ; # ESD.CD.2gu, secondary ESD discharge path current (30mA)

    set ::g_Rmax(ESD.LCP2P.1.1gu)     0.05  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R1)
    set ::g_Rmax(ESD.LCP2P.1.2gu)     0.05  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R1)
    set ::g_Rmax(ESD.LCP2P.1.0gu)     2.3   ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R0)
    set ::g_Rmax(ESD.LCP2P.2.1gu)     0.05  ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp
    set ::g_Rmax(ESD.LCP2P.2.2gu)     0.05  ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp
    set ::g_Rmax(ESD.CDM.P.1.0gu)     2.3   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.CDM.P.1.0.1gu)   0.05  ; # resistance of IOPAD to Primary ESD pull-down diode (R3)
    set ::g_Rmax(ESD.CDM.P.1.0.2gu)   0.05  ; # resistance of IOPAD to Primary ESD pull-up diode (R1)
    set ::g_Rmax(ESD.CDM.P.1.0.3gu)   0.05  ; # resistance of IOPAD to Primary ESD snapback NMOS (R3)
    set ::g_Rmax(ESD.CDM.P.1.1.0.1gu) 0.5   ; # resistance of Primary ESD pull-down diode to closest Pad
    set ::g_Rmax(ESD.CDM.P.1.1.0.2gu) 0.5   ; # resistance of Primary ESD pull-up diode to closest Pad
    set ::g_Rmax(ESD.CDM.P.1.1.0.3gu) 0.5   ; # resistance of Primary ESD snapback NMOS to closest Pad
    set ::g_Rmax(ESD.CDM.P.1.2.0.1gu) 0.05  ; # resistance of Primary ESD pull-down stacked diode
    set ::g_Rmax(ESD.CDM.P.1.2.0.2gu) 0.05  ; # resistance of Primary ESD pull-up stacked diode
    set ::g_Rmax(ESD.CDM.P.2.0.1gu)   0.17  ; # resistance of Primary ESD pull-down diode to power-clamp
    set ::g_Rmax(ESD.CDM.P.2.0.2gu)   0.17  ; # resistance of Primary ESD pull-up diode to power-clamp
    set ::g_Rmax(ESD.CDM.P.2.0.3gu)   0.17  ; # resistance of Primary ESD snapback NMOS to power-clamp
    set ::g_Rmax(ESD.CDM.P.2.1gu)     0.17  ; # resistance of Primary ESD 2-stage snapback NMOS to reverse diode
    set ::g_Rmax(ESD.CDM.P.3.0.1gu)   0.05  ; # resistance of Ground pad to core power-clamp
    set ::g_Rmax(ESD.CDM.P.3.0.2gu)   0.05  ; # resistance of Power pad to core power-clamp
    set ::g_Rmax(ESD.CDM.P.4.0.1gu)   0.1   ; # resistance of Ground pad to IO power-clamp
    set ::g_Rmax(ESD.CDM.P.4.0.2gu)   0.1   ; # resistance of Power pad to IO power-clamp
    set ::g_Rmax(ESD.CDM.P.5.0.1gu)   0.1   ; # resistance of Ground pad to cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.5.0.2gu)   0.1   ; # resistance of Power pad to cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.5.1.0.1gu) 0.1   ; # resistance of Ground pad to reverse diode
    set ::g_Rmax(ESD.CDM.P.5.1.0.2gu) 0.1   ; # resistance of Power pad to reverse diode
    set ::g_Rmax(ESD.CDM.P.7.0.1gu)   1.0   ; # resistance of I/O power-clamp to power-clamp on Ground net
    set ::g_Rmax(ESD.CDM.P.7.0.2gu)   1.0   ; # resistance of I/O power-clamp to power-clamp on Power net
    set ::g_Rmax(ESD.CDM.P.7.1.0.1gu) 0.5   ; # resistance of Core power-clamp to power-clamp on Ground net
    set ::g_Rmax(ESD.CDM.P.7.1.0.2gu) 1.0   ; # resistance of Core power-clamp to power-clamp on Power net
    set ::g_Rmax(ESD.CDM.P.7.2.0.1gu) 1.0   ; # resistance of Cascoded power-clamp to power-clamp on Ground net
    set ::g_Rmax(ESD.CDM.P.7.2.0.2gu) 1.0   ; # resistance of Cascoded power-clamp to power-clamp on Power net
    set ::g_Rmax(ESD.CDM.P.7.3gu)     1.0   ; # resistance of I/O power-clamp to Cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.7.4gu)     0.5   ; # resistance of I/O power-clamp to Core power-clamp
    set ::g_Rmax(ESD.CDM.P.7.5gu)     0.5   ; # resistance of Core power-clamp to Cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.8gu)       0.17  ; # resistance of back-to-back (B2B) diode to ground pad
    set ::g_Rmax(ESD.CDM.P.9gu)       0.17  ; # resistance of back-to-back (B2B) diode to power-clamp
    set ::g_Rmax(ESD.CDM.P.10gu)      10.0  ; # resistance of guard-rings of ESD.CDM.1gU, ESD.CDM.1.1gU, ESD.CDM.2gU
    set ::g_Rmax(ESD.XDM.P.1gu)       0.12  ; # resistance of back-to-back (B2B) diode to power-clamp of cross domain
    set ::g_Rmax(ESD.DISTP2P.1.0gu)     2.3   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.0.1gu)   0.65  ; # resistance of ESD diode to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.0.2gu)   0.65  ; # resistance of ESD diode to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.1.0gu)   2.3   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.1.0.1gu) 0.76  ; # resistance of ESD diode to power/ground Pad through IO power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.1.0.2gu) 0.76  ; # resistance of ESD diode to power/ground Pad through IO power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.2.0gu)   2.3   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.2.0.1gu) 0.58  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.2.0.2gu) 0.58  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.3.0gu)   2.3   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.3.0.1gu) 0.69  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.3.0.2gu) 0.69  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp

## ===========================================================================
##         For CDM 7A
## ===========================================================================
} elseif { ![catch {tvf::svrf_var CDM_7A}] && [tvf::svrf_var CDM_7A] } {
    set ::g_1st_esd(protection) {dd cdd}
    set ::g_1st_esd(count)      {ESD.CDM7A.NET.1gU   >     0}     ; # protection is required
    set ::g_1st_esd(hia_p)      {HIA.CDM7A.3g        >=  300}     ; # total HIA diode perimeter
    set ::g_1st_esd(hia_a)      {HIA.CDM7A.3.1g      >=   60}     ; # total HIA diode area
    set ::g_1st_esd(lc_hia_p)   {ESD.CDM7A.LC.3g     >=    0}     ; # total LC HIA diode perimeter
    set ::g_1st_esd(lc_hia_a)   {ESD.CDM7A.LC.3.1g   >=   30}     ; # total LC HIA diode area

    set ::g_2nd_esd(protection) {dd}
    set ::g_2nd_esd(count)      {ESD.CDM7A.9.0gU     >      0}    ; # protection is required
    set ::g_2nd_esd(res_w)      {ESD.CDM7A.8.1gU     >=  3.30}    ; # total resistance width

    set ::g_pc(mn_io_fin)       {ESD.CDM7A.40g       >=  122300}  ; # total fin number of io nmos
    set ::g_pc(mp_io_fin)       {ESD.CDM7A.40g       >=  122300}  ; # total fin number of io pmos
    set ::g_pc(mn_core_fin)     {ESD.CDM7A.40.1g     >=  134400}  ; # total fin number of core nmos
    set ::g_pc(mp_core_fin)     {ESD.CDM7A.40.1g     >=  134400}  ; # total fin number of core pmos
    set ::g_pc(cas_mn_io_fin)   {ESD.CDM7A.40.2gU    >=  134400}  ; # total fin number of cascoded io nmos
    set ::g_pc(cas_mp_io_fin)   {ESD.CDM7A.40.2gU    >=  134400}  ; # total fin number of cascoded io pmos
    set ::g_pc(stack_mn_io_fin) {ESD.CDM7A.40.4gU    >=  222000}  ; # total fin number of 3-stack io nmos
    set ::g_pc(stack_mp_io_fin) {ESD.CDM7A.40.4gU    >=  222000}  ; # total fin number of 3-stack io pmos
    set ::g_pc(group_fin)       {ESD.CDM7A.40.3.1gU  >=   38000}  ; # total fin number of unit cell
    set ::g_pc(group_nfin)      122300                            ; # min. total fin number of closest groups

    set ::g_b2b(hia_p)          {ESD.15gU       >=  300}  ; # total HIA diode perimeter (HIA.CDM7A.3g)
    set ::g_hc_pc(hia_a)        {ESD.CDM.4gU    >=   60}  ; # extra reverse HIA diode area for cascoded(1.8V) power-clamp (HIA.CDM7A.3.1g)
    set ::g_hc_glo_b2b(hia_p)   {ESD.CDM.B.1gU  >=  300}  ; # total HIA diode perimeter (HIA.CDM7A.3g)
    set ::g_hc_cdm_b2b(hia_p)   {ESD.CDM.B.2gU  >=  300}  ; # total HIA diode perimeter (HIA.CDM7A.3g)

    foreach {key value} [array get ::g_cdm_esd] {
        if { [lindex $value 0] eq "ESD.45.0gU" } { lset value 0 "ESD.CDM.X.1gU" }
        set ::g_xdm_esd($key) $value
    }
    set ::g_xdm_esd(pc)         {ESD.CDM.X.1gU   >      0} ; # cross-domain power-clamp is required
    set ::g_xdm_esd(res_w)      {ESD.CDM7A.8.1gU >=  3.30} ; # total resistance width

    set ::g_ldl_var(ESD.CDM.C.2gU)    5000  ; # mos connected to power/ground to power-clamp distance #intel update 29/10/2020 according K. from n5p
    set ::g_ldl_var(ESD.CDM.C.3.1gU)  5000  ; # core mos between power/ground to power-clamp distance #intel update 29/10/2020 according K.from n5p
    set ::g_ldl_var(ESD.CDM.C.3.2gU)  5000  ; # io mos between power/ground to power-clamp distance #intel update 29/10/2020 according K.from n5p
    set ::g_ldl_var(ESD.CDM.C.4gU)     500  ; # cross-domian interface to power-clamp distance
    set ::g_ldl_var(ESD.CDM.C.4.1gU)   500  ; # cross-domian interface to back-to-back diode distance
    set ::g_ldl_var(ESD.CDM.C.5gU)    5001  ; # mos connected to small power/ground domain to power-clamp distance #intel update 29/10/2020 according K. from n5p

    set ::g_Itest(ESD.CD.1gu)         1800  ; # ESD.CD.1gu, primary ESD discharge path current (1.8A)
    set ::g_Itest(ESD.CD.1.1gu)       1800  ; # ESD.CD.1.1gu, reverse HIA diode discharge path current (1.8A)
    set ::g_Itest(ESD.CD.2gu)           22  ; # ESD.CD.2gu, secondary ESD discharge path current (22mA)

    set ::g_Rmax(ESD.LCP2P.1.1gu)     0.07  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R1)
    set ::g_Rmax(ESD.LCP2P.1.2gu)     0.07  ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R1)
    set ::g_Rmax(ESD.LCP2P.1.0gu)     3.0   ; # resistance of IOPAD to Primary ESD dual diode inside LC_DMY (R0)
    set ::g_Rmax(ESD.LCP2P.2.1gu)     0.07  ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp
    set ::g_Rmax(ESD.LCP2P.2.2gu)     0.07  ; # resistance of Primary ESD dual diode inside LC_DMY to power-clamp
    set ::g_Rmax(ESD.CDM.P.1.0gu)     3.0   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.CDM.P.1.0.1gu)   0.07  ; # resistance of IOPAD to Primary ESD pull-down diode (R3)
    set ::g_Rmax(ESD.CDM.P.1.0.2gu)   0.07  ; # resistance of IOPAD to Primary ESD pull-up diode (R1)
    set ::g_Rmax(ESD.CDM.P.1.0.3gu)   0.07  ; # resistance of IOPAD to Primary ESD snapback NMOS (R3)
    set ::g_Rmax(ESD.CDM.P.1.1.0.1gu) 0.7   ; # resistance of Primary ESD pull-down diode to closest Pad
    set ::g_Rmax(ESD.CDM.P.1.1.0.2gu) 0.7   ; # resistance of Primary ESD pull-up diode to closest Pad
    set ::g_Rmax(ESD.CDM.P.1.1.0.3gu) 0.7   ; # resistance of Primary ESD snapback NMOS to closest Pad
    set ::g_Rmax(ESD.CDM.P.1.2.0.1gu) 0.07  ; # resistance of Primary ESD pull-down stacked diode
    set ::g_Rmax(ESD.CDM.P.1.2.0.2gu) 0.07  ; # resistance of Primary ESD pull-up stacked diode
    set ::g_Rmax(ESD.CDM.P.2.0.1gu)   0.2   ; # resistance of Primary ESD pull-down diode to power-clamp
    set ::g_Rmax(ESD.CDM.P.2.0.2gu)   0.2   ; # resistance of Primary ESD pull-up diode to power-clamp
    set ::g_Rmax(ESD.CDM.P.2.0.3gu)   0.2   ; # resistance of Primary ESD snapback NMOS to power-clamp
    set ::g_Rmax(ESD.CDM.P.2.1gu)     0.2   ; # resistance of Primary ESD 2-stage snapback NMOS to reverse diode
    set ::g_Rmax(ESD.CDM.P.3.0.1gu)   0.07  ; # resistance of Ground pad to core power-clamp
    set ::g_Rmax(ESD.CDM.P.3.0.2gu)   0.07  ; # resistance of Power pad to core power-clamp
    set ::g_Rmax(ESD.CDM.P.4.0.1gu)   0.14  ; # resistance of Ground pad to IO power-clamp
    set ::g_Rmax(ESD.CDM.P.4.0.2gu)   0.14  ; # resistance of Power pad to IO power-clamp
    set ::g_Rmax(ESD.CDM.P.5.0.1gu)   0.14  ; # resistance of Ground pad to cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.5.0.2gu)   0.14  ; # resistance of Power pad to cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.5.1.0.1gu) 0.14  ; # resistance of Ground pad to reverse diode
    set ::g_Rmax(ESD.CDM.P.5.1.0.2gu) 0.14  ; # resistance of Power pad to reverse diode
    set ::g_Rmax(ESD.CDM.P.7.0.1gu)   1.4   ; # resistance of I/O power-clamp to power-clamp on Ground net
    set ::g_Rmax(ESD.CDM.P.7.0.2gu)   1.4   ; # resistance of I/O power-clamp to power-clamp on Power net
    set ::g_Rmax(ESD.CDM.P.7.1.0.1gu) 0.7   ; # resistance of Core power-clamp to power-clamp on Ground net
    set ::g_Rmax(ESD.CDM.P.7.1.0.2gu) 1.0   ; # resistance of Core power-clamp to power-clamp on Power net
    set ::g_Rmax(ESD.CDM.P.7.2.0.1gu) 1.4   ; # resistance of Cascoded power-clamp to power-clamp on Ground net
    set ::g_Rmax(ESD.CDM.P.7.2.0.2gu) 1.4   ; # resistance of Cascoded power-clamp to power-clamp on Power net
    set ::g_Rmax(ESD.CDM.P.7.3gu)     1.4   ; # resistance of I/O power-clamp to Cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.7.4gu)     0.7   ; # resistance of I/O power-clamp to Core power-clamp
    set ::g_Rmax(ESD.CDM.P.7.5gu)     0.7   ; # resistance of Core power-clamp to Cascoded power-clamp
    set ::g_Rmax(ESD.CDM.P.8gu)       0.2   ; # resistance of back-to-back (B2B) diode to ground pad
    set ::g_Rmax(ESD.CDM.P.9gu)       0.2   ; # resistance of back-to-back (B2B) diode to power-clamp
    set ::g_Rmax(ESD.CDM.P.10gu)      10.0  ; # resistance of guard-rings of ESD.CDM.1gU, ESD.CDM.1.1gU, ESD.CDM.2gU
    set ::g_Rmax(ESD.XDM.P.1gu)       0.17  ; # resistance of back-to-back (B2B) diode to power-clamp of cross domain
    set ::g_Rmax(ESD.DISTP2P.1.0gu)     3.0   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.0.1gu)   0.81  ; # resistance of ESD diode to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.0.2gu)   0.81  ; # resistance of ESD diode to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.1.0gu)   3.0   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.1.0.1gu) 0.97  ; # resistance of ESD diode to power/ground Pad through IO power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.1.0.2gu) 0.97  ; # resistance of ESD diode to power/ground Pad through IO power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.2.0gu)   3.0   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.2.0.1gu) 0.68  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.2.0.2gu) 0.68  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through core power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.3.0gu)   3.0   ; # resistance of IOPAD to Primary ESD (R0)
    set ::g_Rmax(ESD.DISTP2P.1.3.0.1gu) 0.84  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp
    set ::g_Rmax(ESD.DISTP2P.1.3.0.2gu) 0.84  ; # resistance of ESD diode inside LC_DMY to power/ground Pad through IO power-clamp

} else {
    set ::g_ldl_var(ESD.CDM.C.4gU)       0  ; # cross-domian interface to power-clamp distance (N/A)
    set ::g_ldl_var(ESD.CDM.C.4.1gU)     0  ; # cross-domian interface to back-to-back diode distance (N/A)
    set ::g_ldl_var(ESD.CDM.C.5gU)       0  ; # mos connected to small power/ground domain to power-clamp distance (N/A)
}

