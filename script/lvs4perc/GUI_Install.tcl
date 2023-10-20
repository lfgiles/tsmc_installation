#!/usr/bin/wish
package require BWidget

### check mfile exist
if { ![file exists "profile/mfile"] } {
	puts "no mfile!!"
	exit
}

###get mfile information
set infile [open "profile/mfile" r]
while { [gets $infile line] >= 0 } {
	if { [regexp {(.*)_(.*)} $line match m1 m2] } {
		set metal($m1) $m1
		set metal2 [ format "%s(%s)" $m1 $m2 ]
		set $metal2 $m2
	} else {
		set metal($line) $line
	}
}

close $infile

#foreach {key value} [lsort [array get metal] ] {
#   foreach {key2 value2} [array get $key] {
#	puts "$key  $key2"
#   }
#}

####### get tool mode
set cal_mode 0
set cci_mode 0
set qci_mode 0
set her_mode 0
set asu_mode 0
set pvs_mode 0
set pegasus_mode 0
set icv_mode 0
set all_cal_mode 0
foreach  ln [exec ls "profile"] {
       	if { [regexp {CALIBRE} $ln] } {
		set cal_mode 1
	} 
       	if { [regexp {CCI} $ln] } {
		set cci_mode 1
	} 
       	if { [regexp {QCI} $ln] } {
		set qci_mode 1
	} 
       	if { [regexp {HERCULES} $ln] } {
		set her_mode 1
	} 
	if { [regexp {PVS} $ln] } {
		set pvs_mode 1
	} 
	if { [regexp {PEGASUS} $ln] } {
		set pegasus_mode 1
	} 
	if { [regexp {ICV} $ln] } {
		set icv_mode 1
	}
	if { [regexp {LVS_DECK} $ln] } {
		set all_cal_mode 1
	}
}

if { $all_cal_mode == 1 } {
	set cal_mode 0
	set cci_mode 0
	set qci_mode 0
}

foreach  ln [exec ls "./"] {
       	if { [regexp {LVS.rsf} $ln] } {
		set asu_mode 1
	} 
}

set mode ""
set mode_index 0

if { $all_cal_mode == 1 } {
   append mode "CALIBRE"
   set tool_list($mode_index) "Uni-Calibre"
   incr mode_index
}
if { $cal_mode == 1 } {
   append mode "CALIBRE "
   set tool_list($mode_index) "Calibre"
   incr mode_index
}
if { $cci_mode == 1 } {
   append mode "CCI ";
   set tool_list($mode_index) "CCI"
   incr mode_index
}
if { $qci_mode == 1 } {
   append mode "QCI ";
   set tool_list($mode_index) "QCI"
   incr mode_index
}
if { $asu_mode == 1 } {
   append mode "ASSURA ";
   set tool_list($mode_index) "Assura"
   incr mode_index
}
if { $her_mode == 1 } {
   append mode "HERCULES ";
   set tool_list($mode_index) "Hercules"
   incr mode_index
}
if { $pvs_mode == 1 } {
   append mode "PVS ";
   set tool_list($mode_index) "PVS"
   incr mode_index
}
if { $pegasus_mode == 1 } {
   append mode "PEGASUS ";
   set tool_list($mode_index) "Pegasus"
   incr mode_index
}
if { $icv_mode == 1 } {
   append mode "ICV ";
   set tool_list($mode_index) "ICV"
   incr mode_index
}

if { $her_mode == 1 } {
  set comment(RC_DECK)               "\[LVS/LPE\] Set 0 for LVS. Set 1 for LPE/RC extraction."  
  set comment(FILTER_DGS_TIED_MOS)   "\[LVS] Set 1 to filter MOS with D, G and S tied together. Set 0 to filter MOS with all pins tied."
  set comment(MULTI_FINGER)          "\[LVS] Set 1 to enable nf extraction and LVS comparision. Please see the README file for the details." 
  set comment(RES_WO_RH)             "\[LVS] Set 1 to ignore RH checking for silicided PO resistors and OD resistors."
  set comment(UNCHECK_MOM_DMFLAG)    "\[LVS] Set 1 to ignore lvs check for dfm_flag parameter of MOM devices."
  set comment(IGNORE_SPARE)          "\[LVS] Set 1 to enable MOS filter function."
  set comment(GLP_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N45GS(=N40G) to N40GLP."
  set comment(GP_PROCESS)            "{NOTE!} \[LVS/LPE] Set 1 to change process from N45GS(=N40G) to N40GP."
  set comment(HPL_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N28HP to N28HPL."
  set comment(HPM_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N28HP to N28HPM."
  set comment(HPP_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N28HP to N28HP+."
  set comment(ULP_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N28HP to N28ULP."
  set comment(HPC_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N28HP to N28HPC."
  set comment(HPC_PLUS_PROCESS)      "{NOTE!} \[LVS/LPE] Set 1 to change process from N28HP to N28HPC+."
  set comment(SOC_PROCESS)           "{NOTE!} \[LVS/LPE] Set 1 to change process from N20G to N20SOC."
  set comment(extract_dnwdio)        "\[LVS/LPE] Set 1 to extract parasitic diodes \"dnwpsub\" and \"pwdnw\" ."
  set comment(NATIVE_N40)            "\[LPE] Set 1 to extract LPE directly from layout size. Set 0 to use shrink flow LPE extraction."
  set comment(SKIP_ODSE)             "\[LPE] Set 1 to skip OD space effect." 
  set comment(SKIP_PLE)              "\[LPE] Set 1 to skip PO length effect."
  set comment(SKIP_PSE)              "\[LPE] Set 1 to skip PO space effect and boundary effect."
  set comment(SKIP_MBE)              "\[LPE] Set 1 to skip metal boundary effect. This switch is provided for engineering evaluation."
#  set comment(SKIP_XVTMBE)           "\[LPE] Set 1 to XVT MBE effect. This switch is provided for engineering evaluation."
  set comment(STD_LIB)               "\[LPE] Set 1 to estimate 9 track WPE on STD cell."
  set comment(STD_LIB_9_TRACK)       "\[LPE] Set 1 to estimate 9 track WPE on STD cell."
  set comment(STD_LIB_11_TRACK)      "\[LPE] Set 1 to estimate 11 track WPE on STD cell."
  set comment(ZERO_NRS_NRD)          "\[LPE] Set 1 to set nrs, nrd to zero. Let RC tool to extract the parasitics. Recommend to turn on!!"
  set comment(extract_dnwpsub)       "\[LPE] Set \"yes\" to extract parasitic diode \"dnwpsub\" (the model name is dnwpsub)."
  set comment(extract_pnwdio)        "\[LPE] Set \"yes\" to extract parasitic diode \"pnwdio\" (the model name is nwdio)."
  set comment(extract_pwdnw)         "\[LPE] Set \"yes\" to extract parasitic diode \"pwdnw\" (the model name is pwdnw)."
  set comment(extract_compact_model) "\[LPE] Set 1 to extract mos without LVSDMY as compact model (ex: nch)."
  set comment(DFM_RULE)              "\[LPE/DFM] Set 1 to enable LPE to consider DFM effect. Only valid when turn on RC_DECK. Recommend to turn on."
  set comment(SKIP_COP)              "\[LPE/DFM] Set 1 to skip DFM contact placement effect. This switch is provided for engineering evaluation."
  set comment(SKIP_POR)              "\[LPE/DFM] Set 1 to skip DFM PO rounding effect. This switch is provided for engineering evaluation."
  set comment(SKIP_ODR)              "\[LPE/DFM] Set 1 to skip DFM OD rounding effect. This switch is provided for engineering evaluation."
  set comment(SKIP_EFLOD)            "\[LPE/DFM] Set 1 to skip edge finger LOD effect. This switch is provided for engineering evaluation."
#  set comment(SKIP_OJE)              "\[LPE/DFM] Turn on to skip OD Jog effect. This switch is provided for engineering evaluation."
  set comment(PATH_CHECK)            "\[ERC] Set 1 to enable ERC path check. Please see the usage file for the details."
  set comment(DS_TO_PG_CHECK)        "\[ERC] Set 1 to highlight if drain connects to power and source connects to ground."
  set comment(FLOATING_GATE_CHECK)   "\[ERC] Set 1 to check floating gate." 
  set comment(FLOATING_WELL_CHECK)   "\[ERC] Set 1 to highlight if well does not connect to power or ground." 
  set comment(GATE_TO_PG_CHECK)      "\[ERC] Set 1 to highlight if a mos gate directly connects to power or ground."
  set comment(WELL_TO_PG_CHECK)      "\[ERC] Set 1 to highlight if nwell connects to ground or psub connects to power."
  set comment(NW_RING)               "\[ERC] Set 1 to enable NW ring to separate the node from BULK."
#  set comment(MPODE_SD_ABUT_CHECK)   "\[ERC] Set 1 to highlight if MPODE source, gate and drain are not tied together."
  set comment(extract_as_ad)         "\[LVS] Set 1 to extract mos parameter as, ad in LVS deck."
  set comment(DECK_TYPE)             "\[LPE] Set \"LVS_DECK\" for LVS. Set \"RC_DECK\" for LPE/RC extraction."
  set comment(CROSS_REFERENCE)       "\[LVS/LPE] Set \"yes\" for layout and schematic cross reference."
  set comment(HIGH_RESOLUTION)       "\[LVS/LPE] Set 1 for gate-biasing (PowerTrim and WLD usage) resolution to 0.1nm accuracy. Turn off for 1nm resolution."
  set comment(MIMCAP_TYPE)           "\[LVS/LPE] Set 0 to set mimcap inserted between Mtop-1 & Mtop-2 and 1 for between Mtop & Mtop-1 ."
  set comment(WELL_TEXT)             "\[LVS/LPE] Set 1 to use NW/PSUB text."
} else {
  set comment(RC_DECK)               "\[LVS/LPE] Turn off for LVS. Turn on for LPE/RC extraction."  
  set comment(LVS_DECK)              "\[LVS/LPE] Turn on for CCI FLOW LVS comparison."
  set comment(RC_DFM_RULE)           "\[LVS/LPE] Turn off for LVS. Turn on for DFM LPE/RC extraction."
  set comment(CCI_DECK)              "\[LVS/LPE] Turn on for CCI FLOW LPE/RC extraction."
  set comment(CCI_DFM_RULE)          "\[LVS/LPE] Turn on for CCI FLOW DFM LPE/RC extraction."
  set comment(XACT_DFM_RULE)         "\[LVS/LPE] Turn on for XACT FLOW DFM LPE/RC extraction."
  set comment(LVSDMY4_CHECK)         "\[LVS] Turn on to highlight if LVSDMY4 without DNW region interact NMOS."
  set comment(QCI_DECK)              "\[LVS/LPE] Turn on for QCI FLOW LPE/RC extraction."
  set comment(QCI_DFM_RULE)          "\[LVS/LPE] Turn on for QCI FLOW DFM LPE/RC extraction."
  set comment(FILTER_DGS_TIED_MOS)   "\[LVS] Turn on to filter MOS with D, G and S tied together. Turn off to filter MOS with all pins tied."
  set comment(MULTI_FINGER)          "\[LVS] Turn on to enable nf extraction and LVS comparision. Please see the README file for the details." 
  set comment(UNCHECK_MOM_DMFLAG)    "\[LVS] Turn on to ignore lvs check for dfm_flag parameter of MOM devices."
  set comment(RES_WO_RH)             "\[LVS] Turn on to ignore RH checking for silicided PO resistors and OD resistors."
  set comment(IGNORE_SPARE)          "\[LVS] Turn on to enable MOS filter function."
  set comment(USER_EQUIV_FILE)       "\[LVS] Turn on to input a equiv file instead of automatical-generated equiv file."
  set comment(SERIES_RES_REDUCTION)  "\[LVS] Turn on to enable series reduction of resistor devices."
  set comment(LVS_REDUCE_SPLIT_GATES) "\[LVS] Turn on to enable MOS split gate reduction."
  set comment(LVS_REDUCE_PARALLEL_MOS)  "\[LVS] Turn on to enable MOS parallel reduction"
  set comment(FILTER_PODE)           "\[LVS] Turn on to filter PODE devices (3T PODE, MPODE)."
  set comment(GLP_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N45GS(=N40G) to N40GLP."
  set comment(GP_PROCESS)            "{NOTE!} \[LVS/LPE] Turn on to change process from N45GS(=N40G) to N40GP."
  set comment(HPL_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N28HP to N28HPL."
  set comment(HPM_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N28HP to N28HPM."
  set comment(HPP_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N28HP to N28HP+."
  set comment(ULP_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N28HP to N28ULP."
  set comment(HPC_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N28HP to N28HPC."
  set comment(HPC_PLUS_PROCESS)      "{NOTE!} \[LVS/LPE] Turn on to change process from N28HP to N28HPC+."
  set comment(SOC_PROCESS)           "{NOTE!} \[LVS/LPE] Turn on to change process from N20G to N20SOC."
  set comment(extract_dnwdio)        "\[LVS/LPE] Turn on to extract parasitic diodes \"dnwpsub\" and \"pwdnw\" ."
  set comment(CROSS_REFERENCE)       "\[LVS/LPE] Turn on for layout and schematic cross reference."
  set comment(NATIVE_N40)            "\[LPE] Turn on to extract LPE directly from layout size. Turn off to use shrink flow LPE extraction."
  set comment(SKIP_ODSE)             "\[LPE] Turn on to skip OD space effect." 
  set comment(SKIP_PLE)              "\[LPE] Turn on to skip PO length effect."
  set comment(SKIP_PSE)              "\[LPE] Turn on to skip PO space effect and boundary effect."
  set comment(SKIP_MBE)              "\[LPE] Turn on to skip metal boundary effect. This switch is provided for engineering evaluation."
  set comment(SKIP_PXE)              "\[LPE] Turn on to skip poly extension effect. This switch is provided for engineering evaluation."
  set comment(SKIP_XVTMBE)           "\[LPE] Turn on to skip XVT MBE effect. This switch is provided for engineering evaluation."
  set comment(STD_LIB)               "\[LPE] Turn on to estimate 9 track WPE on STD cell."
  set comment(STD_LIB_9_TRACK)       "\[LPE] Turn on to estimate 9 track WPE on STD cell."
  set comment(STD_LIB_11_TRACK)      "\[LPE] Turn on to estimate 11 track WPE on STD cell."
  set comment(ZERO_NRS_NRD)          "\[LPE] Turn on to set nrs, nrd to zero. Let RC tool to extract the parasitics. Recommend to turn on!!"
  set comment(extract_dnwpsub)       "\[LPE] Turn on to extract parasitic diode \"dnwpsub\" (the model name is dnwpsub)."
  set comment(extract_pnwdio)        "\[LPE] Turn on to extract parasitic diode \"pnwdio\" (the model name is nwdio)."
  set comment(extract_pwdnw)         "\[LPE] Turn on to extract parasitic diode \"pwdnw\" (the model name is pwdnw)."
  set comment(extract_compact_model) "\[LPE] Turn on to extract mos without LVSDMY as compact model (ex: nch)."
  set comment(COLOR_AWARE_RC)        "\[LPE] Turn on to enable color-awared RC (double patterning)."
  set comment(EXTRACT_W)             "\[LPE] Turn on to extract MOS width parameter."
  set comment(DFM_RULE)              "\[LPE/DFM] Turn on to enable LPE to consider DFM effect. Only valid when turn on RC_DECK. Recommend to turn on."
  set comment(SKIP_COP)              "\[LPE/DFM] Turn on to skip DFM contact placement effect. This switch is provided for engineering evaluation."
  set comment(SKIP_POR)              "\[LPE/DFM] Turn on to skip DFM PO rounding effect. This switch is provided for engineering evaluation."
  set comment(SKIP_ODR)              "\[LPE/DFM] Turn on to skip DFM OD rounding effect. This switch is provided for engineering evaluation."
  set comment(SKIP_EFLOD)            "\[LPE/DFM] Turn on to skip edge finger LOD effect. This switch is provided for engineering evaluation."
  set comment(SKIP_OJE)              "\[LPE/DFM] Turn on to skip OD Jog effect. This switch is provided for engineering evaluation."
  set comment(MATCHFLAG)             "\[LPE/DFM] Turn on to extract matchingflag and edgeflag for high sensitivy mismatching design."
  set comment(PATH_CHECK)            "\[ERC] Turn on to enable ERC path check. Please see the usage file for the details."
  set comment(DS_TO_PG_CHECK)        "\[ERC] Turn on to highlight if drain connects to power and source connects to ground."
  set comment(FLOATING_GATE_CHECK)   "\[ERC] Turn on to check floating gate." 
  set comment(FLOATING_WELL_CHECK)   "\[ERC] Turn on to highlight if well does not connect to power or ground." 
  set comment(GATE_TO_PG_CHECK)      "\[ERC] Turn on to highlight if a mos gate directly connects to power or ground."
  set comment(WELL_TO_PG_CHECK)      "\[ERC] Turn on to highlight if nwell connects to ground or psub connects to power."
  set comment(MPODE_SD_ABUT_CHECK)   "\[ERC] Turn on to highlight if MPODE source, gate and drain are not tied together."
  set comment(NW_RING)               "\[ERC] Turn on to enable NW ring to separate the node from BULK."
  set comment(extract_as_ad)         "\[LVS] Turn on to extract mos parameter as, ad in LVS deck."
  set comment(DECK_TYPE)             "\[LVS/LPE] Set \"LVS_DECK\" for LVS. Set \"RC_DECK\" for LPE/RC extraction."
  set comment(ZERO_NRDS)                "\[LPE] Turn on to set nrs, nrd to zero. Let RC tool to extract the parasitics. Recommend to turn on!!"
  set comment(spice_extraction)         "\[LPE] Turn on to omit saveProperty about model name for spice extraction."
  set comment(Skip_Soft_Connect_Checks) "\[ERC] Turn on to skip soft connect check."
  set comment(HIGH_RESOLUTION)       "\[LVS/LPE] Turn on for gate-biasing (PowerTrim and WLD usage) resolution to 0.1nm accuracy. Turn off for 1nm resolution."
  set comment(MIMCAP_TYPE)           "\[LVS/LPE] Turn on to have mimcap inserted between Mtop-1 & Mtop-2 and turn off for between Mtop & Mtop-1 ."
  set comment(WELL_TEXT)             "\[LVS/LPE] Turn on to use NW/PSUB text ."
  set comment(SKIP_CPO)              "\[LPE/DFM] Turn on to skip DFM CPO effect."
  set comment(THROUGH_ONE_PULLUP_PULLDOWN_MOS)  "\[ERC] Detail usage, please refer to PODE.pdf."
  set comment(SELF_HEATING_EFFECT_EXTRACTION)   "\[LPE/DFM] Turn on to enable self heating effect extraction. Only allow enable in RC extraction mode."
  set comment(FLICKER_CORNER_EXTRACTION)        "\[LPE/DFM] Turn on to enable flicker corner extraction. Only allow enable in RC extraction mode."
  set comment(PODE_MIN_LENGTH_CHECK)            "\[ERC] Turn on to check PODE devices with length less than min length 0.01um."
  set comment(METAL_POINT_TOUCH_CHECK)          "\[ERC] Turn on to do metal point touch checking."
  set comment(METAL_NOCOLOR_CHECK)              "\[ERC] Turn on to check no-color metal routing."
  set comment(METAL_COLOR_TOUCH)                "\[ERC] Turn on to check M1_A/Mx_A touch M1_B/Mx_B."
  set comment(COLOR_AWARE_CHECK)                "\[LVS] Turn on to do the metal color-aware checking."
  set comment(unrecognized_device_checking)     "\[ERC] Turn on to do unrecognized device checking."
  set comment(LVS_REDUCE_PARALLEL_MIMCAP)       "\[LVS] Turn on to enable MIMCAP parallel reduction."
  set comment(FIN_GEN_DFM_SPEC_FILL)            "\[LVS] Turn on to control the generation method of fin_lay."
  set comment(SKIP_LDE_CORNER_FACTOR)           "\[LPE] Turn on to skip LDE corner factor."
  set comment(WLCSP)                            "\[LVS/LPE] Turn on to enable WLCSP connection. (default off : for flip-chip/wire-bond)."  
  set comment(extract_dnwpsub_ntn)              "\[LPE] Set \"yes\" to extract parasitic diode \"dnwpsub_ntn\" (the model name is dnwpsub_ntn)."
  set comment(extract_pwdnw_ntn)                "\[LPE] Set \"yes\" to extract parasitic diode \"pwdnw_ntn\" (the model name is pwdnw_ntn)."
  set comment(FORWARD_BIAS_CHECK)               "\[ERC] Turn on to highlight if p-type well voltage larger than n-type well."
  set comment(PSUB2_ERC_CHECK)                  "\[ERC] Turn off to disable SR_DOD cut PSUB2 checking."
  set comment(PICKUP_CHECK)                     "\[ERC] Turn off to disable dummy pickup checking."
  set comment(FILTER_MPODE)                     "\[ERC] Turn on to filter both layout and source mpode device at LVS comparison stage."
  set comment(FILTER_FLRMOS)                    "\[ERC] Turn on to filter both layout and source flrmos device at LVS comparison stage."
}

wm title . "DECK INSTALL"

### tool selection
labelframe .tool -text "Tool" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
listbox .tool.ctrl -height $mode_index -width 57
.tool.ctrl configure -exportselection false 

pack .tool.ctrl  -in .tool -side left -fill y


### metal selection
labelframe .ms -text "Metal Scheme" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
listbox .ms.ctrl -height 5  -width 25 -yscrollcommand ".ms.ys set"
.ms.ctrl configure -exportselection false

scrollbar .ms.ys -command ".ms.ctrl yview" 
pack .ms.ctrl .ms.ys -in .ms -side left -fill y -pady 10 


listbox .ms.ctrl2 -height 5 -width 25   -yscrollcommand ".ms.ys2 set"
.ms.ctrl2 configure -exportselection false

scrollbar .ms.ys2 -command ".ms.ctrl2 yview" 
pack .ms.ctrl2 .ms.ys2 -in .ms -side left -fill y -pady 10 

##### set listbox option
foreach {key value}  [array get tool_list]  {
	.tool.ctrl insert end $value
}
.tool.ctrl selection set 0

foreach {key value} [lsort [array get metal] ] {
	.ms.ctrl insert end $key
}
.ms.ctrl selection set 0

set metal_index [.ms.ctrl get [.ms.ctrl curselection]]

foreach {key value} [lsort [array get $metal_index] ] {
	.ms.ctrl2 insert end $key
}
.ms.ctrl2 selection set 0

###########get default setting####################

set tool_index [.tool.ctrl curselection]
set now_tool $tool_list($tool_index)

set now_metal [.ms.ctrl get [.ms.ctrl curselection]]

set now_tool_setting $now_tool
set now_metal_setting $now_metal
#puts "now_tool : $now_tool"
#puts "now_metal :-$now_metal-"
set mimcap_type 0
set shdmimcap_type 0
set multi_dev_type 0
set flick_corner_type 0
set she_type 0
set now_process 0
set now_doc1    0
set edram_type 0


if { $now_tool eq "Uni-Calibre" } {
	foreach  ln [exec ls "./profile/LVS_DECK"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/LVS_DECK/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					if { $sw1 eq "RC_FLOW" } {
					} else {
						set deck_switch($sw1) off
						set deck_switch_value($sw1) "on off"
					}
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					if { $sw1 eq "RC_FLOW" } {
					} else {
						set deck_switch($sw1) on
						set deck_switch_value($sw1) "on off"
					}
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}


if { $now_tool eq "Calibre" } {
	foreach  ln [exec ls "./profile/CALIBRE_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/CALIBRE_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}

if { $now_tool eq "CCI" } {
	foreach  ln [exec ls "./profile/CCI_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/CCI_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}

if { $now_tool eq "QCI" } {
	foreach  ln [exec ls "./profile/QCI_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/QCI_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}

if { $now_tool eq "PVS" } {
	foreach  ln [exec ls "./profile/PVS_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/PVS_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}

if { $now_tool eq "Pegasus" } {
	foreach  ln [exec ls "./profile/PEGASUS_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/PEGASUS_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}


if { $now_tool eq "Hercules" } {
	foreach  ln [exec ls "./profile"] {
	       	if { [regexp -nocase $now_metal $ln] } {
			set infile2 [open "profile/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^\s*VARIABLE\s*DOUBLE\s*(\S*)\s*=\s*(\S*)\s*;\s*\/\*\s*(\S*)\s*or\s*(\S*)\s*\*\/} $ln2 match sw1 value v1 v2 ] } {
					set deck_switch($sw1) $value
					set deck_switch_value($sw1) $v1
					append deck_switch_value($sw1) " $v2"
				}
				if { [regexp -nocase {^\s*VARIABLE\s*STRING\s*(\S*)\s*=\s*\"(\S*)\"\s*;\s*\/\*\s*(\S*)\s*or\s*(\S*)\s*\*\/} $ln2 match sw1 value v1 v2 ] } {
					set deck_switch($sw1) $value
					set deck_switch_value($sw1) $v1
					append deck_switch_value($sw1) " $v2"
				}
				if { [regexp -nocase {^\s*VARIABLE\s+DOUBLE\s+MIMCAP_TYPE\s+=\s+\d;} $ln2] } {
					set mimcap_type 1
				}
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
					set now_process $num
					set now_doc1    $doc1
				}
			}
			close $infile2
		} 
	}
}

if { $now_tool eq "ICV" } {
	foreach  ln [exec ls "./profile/ICV_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {
			set infile2 [open "profile/ICV_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
 				# find multi_device_extraction switch
				if { [regexp -nocase {^//#define MULTI_DEVICE_EXTRACTION} $ln2 ] } {
					set multi_dev_type 1
				}

				# find flicker_corner_extraction switch
				if { [regexp -nocase {^//#define FLICKER_CORNER_EXTRACTION} $ln2 ] } {
					set flick_corner_type 1
				}

				# find self_heating_effect_extraction switch
				if { [regexp -nocase {^//#define SELF_HEATING_EFFECT_EXTRACTION} $ln2 ] } {
					set she_type 1
				}

				# find process
				if { [regexp -nocase {T-N(\d+)\S*-\w+-\w+-\d+-\S+} $ln2 match num] } {
					set now_process $num
				}
			}
			close $infile2
		} 
	}
}

if { $now_tool eq "Assura" } {

	set infile2 [open "LVS.rsf" r]
	while { [gets $infile2 ln2] >= 0 } {
		if { [regexp -nocase {^\;\s*\?set\s*\(\s*\"(\S*)\"\s*\)} $ln2 match sw1] } {
			set deck_switch($sw1) off
			set deck_switch_value($sw1) "on off"
		}
		if { [regexp -nocase {^\s*\?set\s*\(\s*\"(\S*)\"\s*\)} $ln2 match sw1] } {
			set deck_switch($sw1) on
			set deck_switch_value($sw1) "on off"
		}
		# find process
	        if { [regexp -nocase {T-N(\d+)\S*-(\w+)-\w+-\d+-\S+} $ln2 match num doc1] } {
	        	set now_process $num
	        	set now_doc1    $doc1
	        }
	}
	close $infile2
}




### tool selection
labelframe .edram -text "eDRAM" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set edram_switch "YES"
radiobutton .edramyes -text "YES" -variable edram_switch -value "YES" -anchor w
radiobutton .edramno -text "NO" -variable edram_switch -value "NO" -anchor w
pack .edramyes .edramno  -in .edram -side left -fill y


labelframe .mimcap -text "MIMCAP" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set mimcap_switch "0"
radiobutton .mimcap0 -text "NO MIMCAP" -variable mimcap_switch -value 0 -anchor w
radiobutton .mimcap1 -text "TOP~TOP-1" -variable mimcap_switch -value 1 -anchor w
pack .mimcap0 .mimcap1 -in .mimcap -side left -fill y


labelframe .mimcap_TWO -text "MIMCAP" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set mimcap_switch "0"
radiobutton .mimcap0t -text "NO MIMCAP" -variable mimcap_switch -value 0 -anchor w
radiobutton .mimcap1t -text "TOP~TOP-1" -variable mimcap_switch -value 1 -anchor w
radiobutton .mimcap2t -text "TOP-1~TOP-2" -variable mimcap_switch -value 2 -anchor w
pack .mimcap0t .mimcap1t .mimcap2t  -in .mimcap_TWO -side left -fill y


labelframe .shdmimcap -text "SHDMIMCAP" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set shdmimcap_switch "0"
radiobutton .shdmimcap0 -text "NO" -variable shdmimcap_switch -value 0 -anchor w
radiobutton .shdmimcap1 -text "YES" -variable shdmimcap_switch -value 1 -anchor w
pack .shdmimcap0 .shdmimcap1 -in .shdmimcap -side left -fill y


labelframe .multi_dev -text "MULTI_DEVICE_EXTRACTION" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set multi_dev_switch "0"
radiobutton .multi_dev_off -text "OFF" -variable multi_dev_switch -value 0 -anchor w
radiobutton .multi_dev_on -text "ON" -variable multi_dev_switch -value 1 -anchor w
pack .multi_dev_off .multi_dev_on  -in .multi_dev -side left -fill y

# FLICKER_CORNER_EXTRACTION
labelframe .flick -text "FLICKER_CORNER_EXTRACTION" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set flick_switch "0"
radiobutton .flick_off -text "OFF" -variable flick_switch -value 0 -anchor w
radiobutton .flick_on -text "ON" -variable flick_switch -value 1 -anchor w
pack .flick_off .flick_on  -in .flick -side left -fill y

# SELF_HEATING_EFFECT_EXTRACTION
labelframe .she -text "SELF_HEATING_EFFECT_EXTRACTION" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
set she_switch "0"
radiobutton .she_off -text "OFF" -variable she_switch -value 0 -anchor w
radiobutton .she_on -text "ON" -variable she_switch -value 1 -anchor w
pack .she_off .she_on  -in .she -side left -fill y

##### deck switch 
labelframe .decksw -text "Deck Switch" -relief ridge -borderwidth 4  -font [ list Helvetica 13 bold ] 

button .gendeck -text "GEN DECK"
button .genalldeck -text "GEN ALL METAL SCHEME DECK"
button .exit -text "EXIT" -command { exit }

### tool selection
labelframe .info -text "Info" -relief ridge -borderwidth 4 -font [ list Helvetica 13 bold ]  
label .info.text -text " "  -font [ list Helvetica 15 bold ]
pack .info.text  -in .info -side left -fill y


if { $now_process >= 28 } {
    set edram_type 1
}


#pack .tool .ms .edram .mimcap .shdmimcap .decksw .gendeck .genalldeck .exit .info -fill x -padx 10 -pady 5    (split to below according to switch)
pack .tool .ms                                  -fill x -padx 10 -pady 5
if { $edram_type            == 1 } {
    pack .edram                                 -fill x -padx 10 -pady 5
}
if { ($mimcap_type          == 1) } {
  if { ($now_process >= 40) && ($now_process <= 55) && ($now_doc1 eq "CV") } {
    pack .mimcap_TWO                            -fill x -padx 10 -pady 5
  } else {
    pack .mimcap                                -fill x -padx 10 -pady 5
  }
}

if { $shdmimcap_type        == 1 } {
    pack .shdmimcap                             -fill x -padx 10 -pady 5
}
if { ($flick_corner_type    == 1) } {
    pack .flick                                 -fill x -padx 10 -pady 5
}
if { ($she_type             == 1) } {
    pack .she                                   -fill x -padx 10 -pady 5
}
if { ($multi_dev_type       == 1) } {
    pack .multi_dev                             -fill x -padx 10 -pady 5
}
pack .decksw .gendeck .exit .info  -fill x -padx 10 -pady 5


set sw [ScrolledWindow .sw]
pack $sw -fill both -expand true -in .decksw
set sf [ScrollableFrame $sw.sf]
$sw setwidget $sf
set uf [$sf getframe]

set i 0
set j 0


foreach op_name [lsort  [array name deck_switch] ] {
    if { [ info exists comment($op_name) ]  } {
	set switch_comment($comment($op_name))   $op_name
    } else {
	set switch_comment($op_name)  $op_name
    }
}

foreach switch_name [lsort -decreasing  [array name switch_comment] ] {
   
    set op_name $switch_comment($switch_name)
    set op_name_old $op_name
    set op_name [string tolower $op_name]
    set op_value deck_switch($op_name)

    if { $op_name_old eq "MIMCAP_TYPE" } { continue }
    if { $op_name_old eq "MULTI_DEVICE_EXTRACTION" } { continue }
    if { $op_name_old eq "FLICKER_CORNER_EXTRACTION" } { continue }
    if { $op_name_old eq "SELF_HEATING_EFFECT_EXTRACTION" } { continue }
    label $uf.label$op_name -text "$op_name_old"  -anchor w -width 30


    grid $uf.label$op_name -row $i -column $j
    ## set default value

    foreach f $deck_switch_value($op_name_old) {
	incr j
        if { $op_name_old eq "CCI_DECK" } {
	    radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(CCI_DECK) eq "on" } { set deck_switch(LVS_DECK) "off" } else { set deck_switch(LVS_DECK) "on" } ; .info.text configure -text " "  }
        } elseif { $op_name_old eq "LVS_DECK" } {
	    if { [ info exists deck_switch(CCI_DECK) ] } {
  	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(LVS_DECK) eq "on" } { set deck_switch(CCI_DECK) "off" } else { set deck_switch(CCI_DECK) "on" } ; .info.text configure -text " "  }
	    } else {
  	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(LVS_DECK) eq "on" } { set deck_switch(CCI_DECK) "off" } else { set deck_switch(CCI_DFM_RULE) "on" } ; .info.text configure -text " "  }
	    }
        } elseif { $op_name_old eq "XACT_DFM_RULE" } {
	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(XACT_DFM_RULE) eq "on" } { set deck_switch(CCI_DFM_RULE) "off" } ; .info.text configure -text " "  }
        } elseif { $op_name_old eq "CCI_DFM_RULE" } {
	    if { [ info exists deck_switch(XACT_DFM_RULE) ] } {
	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(CCI_DFM_RULE) eq "on" } { set deck_switch(XACT_DFM_RULE) "off" } ; .info.text configure -text " "  }
	    } else {
	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(CCI_DFM_RULE) eq "on" } { set deck_switch(LVS_DECK) "off" } else { set deck_switch(LVS_DECK) "on" } ; .info.text configure -text " "  }
	    }
        } else {
	    radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { .info.text configure -text " "   }
	}
        grid $uf.$op_name$f -row $i -column $j

    }
    incr j

    if { [ info exists comment($op_name_old) ]  } {
	label $uf.comment$op_name -text "$comment($op_name_old)" -background gray 
    } else {
	label $uf.comment$op_name -text " " -background gray 
    }

    grid $uf.comment$op_name -row $i -column $j -sticky w 

    incr i
    set j 0
}

bind .tool.ctrl <ButtonRelease> {

	set tool_index [.tool.ctrl curselection]

	exchange_switch
}


bind .ms.ctrl <ButtonRelease> {

	set metal_index [.ms.ctrl get [.ms.ctrl curselection]]
	.ms.ctrl2 delete 0 end 
	foreach {key value} [lsort [array get $metal_index] ] {
		.ms.ctrl2 insert end $key
	}
	.ms.ctrl2 selection set 0

	exchange_switch
}

bind .ms.ctrl2 <ButtonRelease> {
	.info.text configure -text " "
}



bind .genalldeck <Button> {

	global deck_switch

        set tool_index [.tool.ctrl curselection]
	set now_tool $tool_list($tool_index)


	set metal_index [.ms.ctrl get [.ms.ctrl curselection]]
	set metal_index2 [.ms.ctrl2 get [.ms.ctrl2 curselection]]


	set outfile [open "GUI_Install.cfg" w]
	set outline "METAL_SCHEME: ALL "

	if { $now_tool eq "Uni-Calibre" } {
		puts $outfile "TOOL: Uni-Calibre"
	} else {
		puts $outfile "TOOL: $now_tool"
	}
	puts $outfile $outline

	if { $edram_type } {
		puts $outfile "USE_EDRAM: $edram_switch"
	}

	if { $mimcap_type } {
		puts $outfile "MIMCAP_OPTION: $mimcap_switch"
	}

	if { $shdmimcap_type } {
		puts $outfile "SHDMIMCAP_OPTION: $shdmimcap_switch"
	}

	if { $multi_dev_type } {
		puts $outfile "MULTI_DEVICE_EXTRACTION_OPTION: $multi_dev_switch"
                if { $multi_dev_switch } {
		    set deck_switch(MULTI_DEVICE_EXTRACTION) on
                } else {
		    set deck_switch(MULTI_DEVICE_EXTRACTION) off
                }
	}

	if { $flick_corner_type } {
		puts $outfile "FLICKER_CORNER_EXTRACTION_OPTION: $flick_switch"
                if { $flick_switch } {
		    set deck_switch(FLICKER_CORNER_EXTRACTION) on
                } else {
		    set deck_switch(FLICKER_CORNER_EXTRACTION) off
                }
	}

	if { $she_type } {
		puts $outfile "SELF_HEATING_EFFECT_EXTRACTION_OPTION: $she_switch"
                if { $she_switch } {
		    set deck_switch(SELF_HEATING_EFFECT_EXTRACTION) on
                } else {
		    set deck_switch(SELF_HEATING_EFFECT_EXTRACTION) off
                }
	}

	puts $outfile "SWITCH:"

        foreach op_name [lsort  [array name deck_switch] ] {
		puts $outfile "$op_name $deck_switch($op_name)"
        }
	close $outfile

	.info.text configure -text "Gen All Metal Scheme Deck Going" -foreground red -font [ list Helvetica 15 bold ]

}

bind .genalldeck <ButtonRelease> {

##      FOR SH  combine the LVS_Install.pl example
##
##      tt is test.pl stdout result
##
	set install_result [ exec "./LVS_Install.pl" -cfg GUI_Install.cfg]

	.info.text configure -text "Gen All Metal Scheme Deck Done" -foreground blue -font [ list Helvetica 15 bold ]

}


bind .gendeck <Button> {

	global deck_switch


        set tool_index [.tool.ctrl curselection]
	set now_tool $tool_list($tool_index)


	set metal_index [.ms.ctrl get [.ms.ctrl curselection]]
	set metal_index2 [.ms.ctrl2 get [.ms.ctrl2 curselection]]
#	puts "$metal_index $metal_index2"


#	[exec rm -rf GUI_install.cfg]

	set outfile [open "GUI_Install.cfg" w]
#	set outline [ format "METAL_SCHEME:%s_%s" $metal_index $metal_index2 ] 
	set outline "METAL_SCHEME: "
	append outline "$metal_index"
	append outline "_"
	append outline "$metal_index2"

	puts $outfile "TOOL: $now_tool"
	puts $outfile $outline

	if { $edram_type } {
		puts $outfile "USE_EDRAM: $edram_switch"
	}

	if { $mimcap_type } {
		puts $outfile "MIMCAP_OPTION: $mimcap_switch"
	}

	if { $shdmimcap_type } {
		puts $outfile "SHDMIMCAP_OPTION: $shdmimcap_switch"
	}

	if { $multi_dev_type } {
		puts $outfile "MULTI_DEVICE_EXTRACTION_OPTION: $multi_dev_switch"
                if { $multi_dev_switch } {
		    set deck_switch(MULTI_DEVICE_EXTRACTION) on
                } else {
		    set deck_switch(MULTI_DEVICE_EXTRACTION) off
                }
	}

	if { $flick_corner_type } {
		puts $outfile "FLICKER_CORNER_EXTRACTION_OPTION: $flick_switch"
                if { $flick_switch } {
		    set deck_switch(FLICKER_CORNER_EXTRACTION) on
                } else {
		    set deck_switch(FLICKER_CORNER_EXTRACTION) off
                }
	}

	if { $she_type } {
		puts $outfile "SELF_HEATING_EFFECT_EXTRACTION_OPTION: $she_switch"
                if { $she_switch } {
		    set deck_switch(SELF_HEATING_EFFECT_EXTRACTION) on
                } else {
		    set deck_switch(SELF_HEATING_EFFECT_EXTRACTION) off
                }
	}

	puts $outfile "SWITCH:"

        foreach op_name [lsort  [array name deck_switch] ] {
		puts $outfile "$op_name $deck_switch($op_name)"
        }
	close $outfile

	.info.text configure -text "Gen Deck Going" -foreground red -font [ list Helvetica 15 bold ]
	
}


bind .gendeck <ButtonRelease> {
	
	set install_result [ exec "./LVS_Install.pl" -cfg GUI_Install.cfg]
	
	.info.text configure -text "Gen Deck Done" -foreground blue  -font [ list Helvetica 15 bold ]
}





proc exchange_switch {} {

    global tool_list
    global deck_switch
    global deck_switch_use
    global deck_switch_value
    global comment
    global uf

    set tool_index [.tool.ctrl curselection]

    set now_tool $tool_list($tool_index)

    set now_metal [.ms.ctrl get [.ms.ctrl curselection]]

    global now_tool_setting
    global now_metal_setting

    if {  ($now_tool_setting eq $now_tool) && ($now_metal_setting eq $now_metal) } {
	return 0;
    }

 
    .tool.ctrl configure -state disabled
    .ms.ctrl configure -state disabled
    .ms.ctrl2 configure -state disabled
    .gendeck configure -state disabled
    .exit configure -state disabled
    .edramyes configure -state disabled
    .edramno configure -state disabled

    .info.text configure -text " "

    ###destroy option
    global op_name
    global op_value
    foreach {op_name op_value} [array get deck_switch]  {
        set op_name_old $op_name
        set op_name [string tolower $op_name]
	
        destroy $uf.label$op_name
	
        foreach f $deck_switch_value($op_name_old)  {
  	    destroy $uf.$op_name$f
        }

        destroy $uf.comment$op_name 
    }
    
    set deck_switch("test") 1
    set deck_switch_value("test") 1
    set deck_switch_use("test") 1

    unset deck_switch
    unset deck_switch_use
    unset deck_switch_value
    
    set tool_index [.tool.ctrl curselection]

    set now_tool $tool_list($tool_index)

    set now_metal [.ms.ctrl get [.ms.ctrl curselection]]

    set now_tool_setting $now_tool
    set now_metal_setting $now_metal

    if { $now_tool eq "Uni-Calibre" } {
	foreach  ln [exec ls "./profile/LVS_DECK"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/LVS_DECK/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					if { $sw1 eq "RC_FLOW" } {
					} else {
						set deck_switch($sw1) off
						set deck_switch_value($sw1) "on off"
					}
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					if { $sw1 eq "RC_FLOW" } {
					} else {
						set deck_switch($sw1) on
						set deck_switch_value($sw1) "on off"
					}
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
			}
			close $infile2
		} 
	}
    }
    if { $now_tool eq "Calibre" } {
	foreach  ln [exec ls "./profile/CALIBRE_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/CALIBRE_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
			}
			close $infile2
		}
	}
    }

    if { $now_tool eq "CCI" } {
	foreach  ln [exec ls "./profile/CCI_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/CCI_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				# find mimcap switch
				if { [regexp -nocase {^//#define MIMCAP_TYPE} $ln2 ] } {
					set mimcap_type 1
				}
				# find shdmimcap
				if { [regexp -nocase {mimcap_sin_shd} $ln2 ] } {
					set shdmimcap_type 1
				}
			}
			close $infile2
		}
	}
    }

    if { $now_tool eq "QCI" } {
	foreach  ln [exec ls "./profile/QCI_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/QCI_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] && ![info exists deck_switch_use($sw1)] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
					set deck_switch_use($sw1) 1
				}
			}
			close $infile2
		} 
	}
    }
    
    if { $now_tool eq "PVS" } {
	foreach  ln [exec ls "./profile/PVS_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/PVS_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
				}
			}
			close $infile2
		} 
	}
    }

    if { $now_tool eq "Pegasus" } {
	foreach  ln [exec ls "./profile/PEGASUS_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/PEGASUS_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
				}
			}
			close $infile2
		} 
	}
    }

    if { $now_tool eq "Hercules" } {
	foreach  ln [exec ls "./profile"] {
	       	if { [regexp -nocase $now_metal $ln] } {
		#nputs "$ln"
			set infile2 [open "profile/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^\s*VARIABLE\s*DOUBLE\s*(\S*)\s*=\s*(\S*)\s*;\s*\/\*\s*(\S*)\s*or\s*(\S*)\s*\*\/} $ln2 match sw1 value v1 v2 ] } {
					set deck_switch($sw1) $value
					set deck_switch_value($sw1) $v1
					append deck_switch_value($sw1) " $v2"
				}
				if { [regexp -nocase {^\s*VARIABLE\s*STRING\s*(\S*)\s*=\s*\"(\S*)\"\s*;\s*\/\*\s*(\S*)\s*or\s*(\S*)\s*\*\/} $ln2 match sw1 value v1 v2 ] } {
					set deck_switch($sw1) $value
					set deck_switch_value($sw1) $v1
					append deck_switch_value($sw1) " $v2"
				}
			}
			close $infile2
		} 
	}
    }

    if { $now_tool eq "ICV" } {
	foreach  ln [exec ls "./profile/ICV_FLOW"] {
	       	if { [regexp -nocase $now_metal $ln] } {

			set infile2 [open "profile/ICV_FLOW/$ln" r]
			while { [gets $infile2 ln2] >= 0 } {
				if { [regexp -nocase {^//#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) off
					set deck_switch_value($sw1) "on off"
				}
				if { [regexp -nocase {^#define\s+(\S*)} $ln2 match sw1] } {
					set deck_switch($sw1) on
					set deck_switch_value($sw1) "on off"
				}
			}
			close $infile2
		} 
	}
    }

    if { $now_tool eq "Assura" } {

	set infile2 [open "LVS.rsf" r]
	while { [gets $infile2 ln2] >= 0 } {
		if { [regexp -nocase {^\;\s*\?set\s*\(\s*\"(\S*)\"\s*\)} $ln2 match sw1] } {
			set deck_switch($sw1) off
			set deck_switch_value($sw1) "on off"
		}
		if { [regexp -nocase {^\s*\?set\s*\(\s*\"(\S*)\"\s*\)} $ln2 match sw1] } {
			set deck_switch($sw1) on
			set deck_switch_value($sw1) "on off"
		}
	}
	close $infile2
    }


    set i 0
    set j 0


    foreach op_name [lsort  [array name deck_switch] ] {
        if { [ info exists comment($op_name) ]  } {
	    set switch_comment($comment($op_name))   $op_name
        } else {
   	    set switch_comment($op_name)  $op_name
        }
    }

    foreach switch_name [lsort -decreasing  [array name switch_comment] ] {
        set op_name $switch_comment($switch_name)

        set op_name_old $op_name
        set op_name [string tolower $op_name]
        set op_value deck_switch($op_name)

	if { $op_name_old eq "MIMCAP_TYPE" } { continue }
        if { $op_name_old eq "MULTI_DEVICE_EXTRACTION" } { continue }
        if { $op_name_old eq "FLICKER_CORNER_EXTRACTION" } { continue }
        if { $op_name_old eq "SELF_HEATING_EFFECT_EXTRACTION" } { continue }
        label $uf.label$op_name -text "$op_name_old"  -anchor w -width 22

        grid $uf.label$op_name -row $i -column $j

        foreach f $deck_switch_value($op_name_old)  {
  	    incr j
#	set nm [ format "%s.%s%s" $uf $op_name $f ]
#	puts $nm
        if { $op_name_old eq "CCI_DECK" } {
	    radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(CCI_DECK) eq "on" } { set deck_switch(LVS_DECK) "off" } else { set deck_switch(LVS_DECK) "on" } }
        } elseif { $op_name_old eq "LVS_DECK" } {
	    if { [ info exists deck_switch(CCI_DECK) ] } {
	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(LVS_DECK) eq "on" } { set deck_switch(CCI_DECK) "off" } else { set deck_switch(CCI_DECK) "on" }  }
            } else {
  	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(LVS_DECK) eq "on" } { set deck_switch(CCI_DFM_RULE) "off" } else { set deck_switch(CCI_DFM_RULE) "on" }  }
	    }
        } elseif { $op_name_old eq "XACT_DFM_RULE" } {
  	    radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(XACT_DFM_RULE) eq "on" } { set deck_switch(CCI_DFM_RULE) "off" } }
        } elseif { $op_name_old eq "CCI_DFM_RULE" } {
	    if { [ info exists deck_switch(XACT_DFM_RULE) ] } {
  	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(CCI_DFM_RULE) eq "on" } { set deck_switch(XACT_DFM_RULE) "off" } }
	    } else {
  	        radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w -command { if { $deck_switch(CCI_DFM_RULE) eq "on" } { set deck_switch(LVS_DECK) "off" } else { set deck_switch(LVS_DECK) "on" } }
	    }
        } else {
  	    radiobutton $uf.$op_name$f -text "$f" -variable deck_switch($op_name_old) -value $f -width 3 -anchor w
	}

            grid $uf.$op_name$f -row $i -column $j
        }
        incr j

        if { [ info exists comment($op_name_old) ] } {
		label $uf.comment$op_name -text "$comment($op_name_old)" -background gray 
        } else {
	        label $uf.comment$op_name -text " " -background gray 
	}

        grid $uf.comment$op_name -row $i -column $j -sticky w 

        incr i
        set j 0
    }
    .tool.ctrl configure -state normal
    .ms.ctrl configure -state normal
    .ms.ctrl2 configure -state normal
    .gendeck configure -state normal
    .exit configure -state normal
    .edramyes configure -state normal
    .edramno configure -state normal
}

