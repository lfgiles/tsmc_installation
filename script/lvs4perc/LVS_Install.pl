#!/usr/bin/env perl

$CAL  = 1;		# define CALIBRE mode
$HER  = 2;		# define Hercules mode
$ASU  = 4;		# define Assura mode
$CCI  = 8;              # define CCI mode
$QCI  = 16;             # define QCI mode
$PVS  = 32;             # define PVS mode
$ICV  = 64;             # define ICV mode
$LVS_DECK  = 128;       # define Uni-Calibre Package mode
$Pegasus   = 256;       # define Pegasus mode

$inpath = "profile"; 	# default input deck path
$outpath = "MAIN_DECK";	# default output deck path
$mfile = "$inpath/mfile";	# all supported metal schemes in DRM
$tempdeck = "_temp.c"; 		# the temporary file for temporary output
$debug_flag = 0;		# debug mode is default off
$genWrapperProgram = "GEN_Wrapper.pl";    # for generating wrapper file
$reserved_layers = "reserved_layers"; 	  # reserved layers information

$INTFILE = "LVS_Install.int";	# file for IT integration check
$success_msg = "**INFO: Install Successfully!";	# successful message for int file
$fail_msg = "ERROR";		# fail message for int file
$untarTreeFile = "untar_tree_files.txt";
$cfg2xml = "/net/hera9/home17/CDSSD/release/tDesignPlatform/bin/cfg2xml.pl";
$color_flag = 0;           # reserved layer flag
$rhim_flag  = 0;           # rhim flag
$rhim_flag_n22 = 0;        #rhim flag for N22, 2020.06.12
$split_fname_by_metal_scheme = 0;
my $mx_mz_n22 = {};        #mx_mz flag for N22, 2020.06.15. record the metal scheme is MxMz (x and z is neighbor)
$RL_msg = "*** Those layers are reserved layers for pseudo color layers, please do not use them. ***\n\n"; # color message
$w_mimcap_flag = 0;        # flag for warning message of mimcap
$w_mimcap_msg  = "**WARNING: No specified setting for mimcap. Use default setting : No mimcap!";    # warning message for mimcap
$w_shpmimcap_flag = 0;     # flag for warning message of shpmimcap
$w_shpmimcap_msg  = "**WARNING: No specified setting for SHPmimcap. Use default setting : No mimcap!";    # warning message for SHPmimcap
$w_shdmimcap_flag = 0;     # flag for warning message of shdmimcap
$w_shdmimcap_msg  = "**WARNING: No specified setting for SHDmimcap. Use default setting : No SHDmimcap!";    # warning message for SHDmimcap
$w_multi_flag  = 0;        # flag for warning message of multi_device_extraction
$w_multi_msg   = "**WARNING: No specified setting for MULTI_DEVICE_EXTRACTION. Use default setting : Off!";        # warning message for multi device
$w_flick_flag  = 0;        # flag for warning message of flicker_corner_extraction
$w_flick_msg   = "**WARNING: No specified setting for FLICKER_CORNER_EXTRACTION. Use default setting : Off!";      # warning message for multi device
$w_mTotal_flag  = 0;        # flag for warning message of MOM_PARALLEL_MISMATCH_FLAG
$w_mTotal_msg   = "**WARNING: No specified setting for MOM_PARALLEL_MISMATCH_FLAG. Use default setting : Off!";      # warning message for MOM_PARALLEL_MISMATCH_FLAG
$w_she_flag    = 0;        # flag for warning message of self_heating_effect_extraction
$w_she_msg     = "**WARNING: No specified setting for SELF_HEATING_EFFECT_EXTRACTION. Use default setting : Off!"; # warning message for multi device
$w_soic_flag    = 0;        # flag for warning message of SOIC_TYPE
$w_soic_msg     = "**WARNING: No specified setting for SOIC_TYPE. Use default setting : Off!";                       # warning message for SOIC_TYPE
$icv_issue_msg.= "\n*****************************************************************************************\n"; # notice message for ICV
$icv_issue_msg.= "*                                   KNOWN ISSUE ALERT                                   *\n";
$icv_issue_msg.= "*      This ICV contains a known tool issue which may cause device missing.             *\n";
$icv_issue_msg.= "*      Please carefully read \"TSMC_DOC_WM/ICV_Device_Missing.pdf\" for further details.  *\n";
$icv_issue_msg.= "*****************************************************************************************\n";
$icv_issue_msg.= "I have read and understood this alert (Yes/No):";

$TOOLMSG{$CAL} = "Calibre + xRC (or xACT)";
$TOOLMSG{$CCI} = "Calibre + StarRC ( CCI flow )";
$TOOLMSG{$QCI} = "Calibre + QRC ( QCI flow )";
$TOOLMSG{$HER} = "Hercules";
$TOOLMSG{$PVS} = "PVS";
$TOOLMSG{$Pegasus} = "Pegasus";
$TOOLMSG{$ASU} = "Assura";
$TOOLMSG{$ICV} = "ICV";
$TOOLMSG{$LVS_DECK} = "Uni-Calibre";


%DNTable = (
"T-N03-CL-SP-005", "N3" ,
);
            
# for different deck, do different things
# hence, identify what kind of deck CAL/HER/ASU/PVS/Pegasus/ICV it is
$mode = &getMode();

# get process information from deck 
my $mergeMimcapOption = &isMergeMimcapOption($DN); #2020.07.31 add merge mimcap option function
my $no_need_mimcap_ques = &isNoNeedMimcapQues($DN);
($DN, $DN2, $process, $VER, $mimProb, $shpmimProb, $shdmimProb, $edramProb, $multiProb, $flickProb, $mTotalProb, $sheProb, $soicProb) = &getProcessInfo( $mode );
$wrapper = &isWrapper($DN);
$additional = &isAdditional($DN);
$wlcspmode = &getWlcspMode($DN);
my $keep_rmx_hard_name = &isRmxHardName($DN);
my $mimCapQuesVer = &getMimcapQuesVer($DN);


%toolVerHash = &getEDAVersion();

if( $process =~ "N45GS" ) {
	@parr = ( "N45GS(=N40G)", 
                  "N40GLP", 
                  "N40GPLUS" );
}
if( $process =~ "N28HP" ) {
	@parr = ( "N28HP/N28HPA/N28HPS     # Turn off HPL_PROCESS, HPM_PROCESS & HPP_PROCESS switch. (Default) ",
                  "N28HPL                  # Turn on HPL_PROCESS switch. ",
                  "N28HPM                  # Turn on HPM_PROCESS switch. ",
                  "N28HP+(=N28HPPLUS)      # Turn on HPP_PROCESS switch. ",
                  "N28HPC                  # Turn on HPC_PROCESS switch. ",
                  "N28ULP                  # Turn on ULP_PROCESS switch. ",
                  "N28HPC_PLUS             # Turn on HPC_PLUS_PROCESS switch. "
                ); 
}

if( $wlcspmode ) {
	$wlcsp = "n";	# default wlcsp flag, will be updated by command line or config file
}
if( $wlcspmode == 16003 ) {
	$clvr  = "n";	# default clvr flag, will be updated by command line or config file
}

#$edram = "y";	# default edram flag, will be updated by command line or config file
$edram = ($edramProb)?"y":"n";
$mimcap = 0 ;   # default mim flag, will be updated by command line or config file
$shpmimcap = 0 ;# default shp mim flag, will be updated by command line or config file
$shdmimcap = 0 ;# default shd mim flag, will be updated by command line or config file
$shdmimcap = -1 if($no_need_mimcap_ques); # keep default deck
$multiDev = 0;  # default multi_device_extraction if off.
$flickDev = 0;  # default flicker_corner_extraction if off.
$mTotalDev = 0;  # default MOM_PARALLEL_MISMATCH_FLAG if off.
$sheDev = 0;    # default self_heating_effect_extraction if off.
$soicDev = 0;   # default SOIC_TYPE if off.
$gplus = "n";   # set y to extract N40GP 8T Readport SRAM as different devices
$glp   = "n";   # set y to translate to N40GLP process
$hpl   = "n";   # set y to translate to N28HPL process
$hpm   = "n";   # set y to translate to N28HPM process
$hpp   = "n";   # set y to translate to N28HPP process
$hpc   = "n";   # set y to translate to N28HPC process
$ulp   = "n";   # set y to translate to N28ULP process
$hpcp  = "n";   # set y to translate to N28HPC_PLUS process


# default metal schemes supported by DRM 
@support = &readMfile();

# defaul output .cfg file 
$outcfg  = "LVS_Install.cfg";
$outcfg2 = "LVS_Install.summary";
system("rm -f $outcfg2") if(-e $outcfg2);
$cfg_msg = "\n**INFO: Summary LVS Installation =>  $outcfg2\n";

# search the deck name (use metal schemem match)
if( $mode & $LVS_DECK ) {
    ($cal_all_deck, $poly_num) = &getDeckName( "$inpath/LVS_DECK" );
} else {
    ($caldeck, $poly_num) = &getDeckName( "$inpath/CALIBRE_FLOW" ) if( $mode & $CAL );
    ($ccideck, $poly_num) = &getDeckName( "$inpath/CCI_FLOW" ) if( $mode & $CCI );
    ($qcideck, $poly_num) = &getDeckName( "$inpath/QCI_FLOW" ) if( $mode & $QCI );
}
($herdeck, $poly_num) = &getDeckName( "$inpath" ) if( $mode & $HER );
($asudeck, $poly_num) = &getDeckName( "$inpath" ) if( $mode & $ASU );
($pvsdeck, $poly_num) = &getDeckName( "$inpath/PVS_FLOW" ) if( $mode & $PVS );
($pegasusdeck, $poly_num) = &getDeckName( "$inpath/PEGASUS_FLOW" ) if( $mode & $Pegasus );
($icvdeck, $poly_num) = &getDeckName( "$inpath/ICV_FLOW" ) if( $mode & $ICV );

# Three possible inputs: (1) from STD  (2) -m metal_scheme (3) -cfg config_file
# Output: ( 4M_3X1Z, .... ) 
@comb = &getComb($poly_num);


# check if the given combination is correct
&checkComb( $process, @comb );

# the new create deck will be generated to the $outpath folder
system("rm -rf $outpath") if( -e $outpath );
if( !$GENMODE ) {
	system("mkdir $outpath");
	if( $mode & $LVS_DECK ) { system("mkdir $outpath/LVS_DECK"); }
	if( $mode & $CAL      ) { system("mkdir $outpath/CALIBRE_FLOW"); }
	if( $mode & $CCI      ) { system("mkdir $outpath/CCI_FLOW");     }
	if( $mode & $QCI      ) { system("mkdir $outpath/QCI_FLOW");     }
	if( $mode & $PVS      ) { system("mkdir $outpath/PVS_FLOW");     }
	if( $mode & $Pegasus  ) { system("mkdir $outpath/PEGASUS_FLOW"); }
}

# generate deck to the specific path
&genDeck( $mode, $LVS_DECK, $cal_all_deck, "$inpath/LVS_DECK"    , "$outpath/LVS_DECK"    , @comb ) if( $mode & $LVS_DECK && $cal_all_deck );
&genDeck( $mode, $CAL,	    $caldeck,      "$inpath/CALIBRE_FLOW", "$outpath/CALIBRE_FLOW", @comb ) if( $mode & $CAL && $caldeck );
&genDeck( $mode, $CCI, 	    $ccideck,      "$inpath/CCI_FLOW"    , "$outpath/CCI_FLOW"    , @comb ) if( $mode & $CCI && $ccideck );
&genDeck( $mode, $QCI, 	    $qcideck,      "$inpath/QCI_FLOW"    , "$outpath/QCI_FLOW"    , @comb ) if( $mode & $QCI && $qcideck );
&genDeck( $mode, $HER, 	    $herdeck,      "$inpath"             , "$outpath"             , @comb ) if( $mode & $HER );
&genDeck( $mode, $ASU, 	    $asudeck,      "$inpath"             , "$outpath"             , @comb ) if( $mode & $ASU );
&genDeck( $mode, $PVS, 	    $pvsdeck,      "$inpath/PVS_FLOW"    , "$outpath/PVS_FLOW"    , @comb ) if( $mode & $PVS );
&genDeck( $mode, $Pegasus,  $pegasusdeck,  "$inpath/PEGASUS_FLOW", "$outpath/PEGASUS_FLOW", @comb ) if( $mode & $Pegasus );
&genDeck( $mode, $ICV, 	    $icvdeck,      "$inpath/ICV_FLOW"    , "$outpath"             , @comb ) if( $mode & $ICV );

if( $GENMODE == 1 ) {
	&printEDAVersion(\%toolVerHash);
	&printSelfTest();
	&genUntarTreeFile();
	&translateToXML();
	close(QLOG);
	exit;
}

&genXACT( "$inpath/CALIBRE_FLOW/XACT_MAP", "$outpath/CALIBRE_FLOW", @comb) if( $mode & $CAL );
&genXACT( "$inpath/CALIBRE_FLOW/XRC_MAP", "$outpath/CALIBRE_FLOW", @comb) if( $mode & $CAL );

# generate starrcxt_mapping files
&genStar( "$inpath/CCI_FLOW/STAR_MAP", "$outpath/CCI_FLOW", @comb ) if( $mode & $CCI && ($cal_all_deck or $ccideck) );
&genStar( "$inpath/STAR_MAP"         , "$outpath"         , @comb ) if( $mode & $HER );

# generate X_DEV.cmd 
&genXDEV( "$inpath", "$outpath" ) if( $mode & $HER );

# generate lvsfile
&genLVSFILE( "$inpath/QCI_FLOW/LVSFILE", "$outpath/QCI_FLOW", @comb) if( $mode & $QCI && ($cal_all_deck or $qcideck) );
&genLVSFILE( "$inpath/PVS_FLOW/LVSFILE", "$outpath/PVS_FLOW", @comb) if( $mode & $PVS && $pvsdeck );
&genLVSFILE( "$inpath/PEGASUS_FLOW/LVSFILE", "$outpath/PEGASUS_FLOW", @comb) if( $mode & $Pegasus && $pegasusdeck );

# generate layer_setup and capgen
&genLayerSetupCapGen( "$inpath/QCI_FLOW", "$outpath/QCI_FLOW", @comb) if( $mode & $QCI && ($cal_all_deck or $qcideck) );
&genLayerSetupCapGen( "$inpath/PVS_FLOW", "$outpath/PVS_FLOW", @comb) if( $mode & $PVS && $pvsdeck );
&genLayerSetupCapGen( "$inpath/PEGASUS_FLOW", "$outpath/PEGASUS_FLOW", @comb) if( $mode & $Pegasus && $pegasusdeck );

# copy the necessary files to the $inpath directory
&copyFiles( $mode, "$inpath/LVS_DECK"    , "$outpath/LVS_DECK"    , 0, 0 ) if( $mode & $LVS_DECK );
&copyFiles( $mode, "$inpath/CALIBRE_FLOW", "$outpath/CALIBRE_FLOW", 0, 0 ) if( $mode & $CAL && ($cal_all_deck or $caldeck));
&copyFiles( $mode, "$inpath/CCI_FLOW"    , "$outpath/CCI_FLOW"    , 1, 0 ) if( $mode & $CCI && ($cal_all_deck or $ccideck));
&copyFiles( $mode, "$inpath/QCI_FLOW"    , "$outpath/QCI_FLOW"    , 0, 1 ) if( $mode & $QCI && ($cal_all_deck or $qcideck));
&copyFiles( $mode, "$inpath"             , "$outpath"             , 0, 0 ) if( $mode & $HER );
&copyFiles( $mode, "$inpath/PVS_FLOW"    , "$outpath/PVS_FLOW"    , 0, 0 ) if( $mode & $PVS );
&copyFiles( $mode, "$inpath/PEGASUS_FLOW", "$outpath/PEGASUS_FLOW", 0, 0 ) if( $mode & $Pegasus );
&copyFiles( $mode, "$inpath/ICV_FLOW"    , "$outpath"             , 0, 0 ) if( $mode & $ICV );
&copyFile("$inpath/SFT_FLOW", "$outpath/SFT_FLOW") if(&isSFT());

&genWrapper() if( $wrapper );

print $w_mimcap_msg,"\n" if( $mimProb && $w_mimcap_flag );
print $w_shpmimcap_msg,"\n" if( $shpmimProb && $w_shpmimcap_flag );
print $w_shdmimcap_msg,"\n" if( $shdmimProb && $w_shdmimcap_flag );
print $w_multi_msg,"\n"  if( $multiProb && $w_multi_flag ); 
print $w_flick_msg,"\n"  if( $flickProb && $w_flick_flag ); 
print $w_mTotal_msg,"\n"  if( $mTotalProb && $w_mTotal_flag ); 
print $w_she_msg,"\n"    if( $sheProb && $w_she_flag ); 
print $w_soic_msg,"\n"   if( $soicProb && $w_soic_flag ); 
print $success_msg,"\n"; 
print $cfg_msg,"\n"      if($print_cfg_msg);

sub genDeck {
	my( $mode, $tool, $deck, $inp, $outp, @comb ) = @_;
	my( $xm );
	if( $GENMODE == 1 ){
		if( $mode & $tool ) {
			print QLOG "$TOOLMSG{$tool} @\n";		# the message should be the same as installation
			print QLOG "SearchFile( METAL_SCHEME ) @ 1\n";
		}
	} 
	for my $c ( @comb ) {
		chomp($c);
		$c =~ /(\d+M)/i;
		$xm = $1;
		if( $deck =~ /(\d+M)/ )    { $xm = uc($xm); }
		elsif( $deck =~ /(\d+m)/ ) { $xm = lc($xm); }
		$tdeck = $mdeck = $deck; 
		$tdeck =~ s/\d+M/$xm/i;				# get the name of deck wi "1P$xm"
		$mdeck =~ s/\d+M/$c/i;				# get the name of metal combination deck
		if( $GENMODE == 1 ){
			print QLOG "PACKAGE_PATH/$outp/$mdeck\n";
		} elsif( -e "$inp/$tdeck" ) {
			$additional_file=&FindAdditional($xm, $c, "$inpath/ADDITIONAL_ERC_CHECK/", $outp) if( $additional );
			system("\\cp -r $inp/$tdeck $outp/$mdeck");	# create a metal combination deck 
			&modifyDeck( $mode, "$outp/$mdeck", $c, $outp );# modify the resistor by the combination
			print "**INFO: Generate deck $mdeck at $outp\n";
		} else{
		    print "Error : $inp/$tdeck does not exist!\n";
		}
		#system("\\mv $mdeck $path");
		#push( @decks, "$mdeck" );		# save all the generated deck to @decks
	}
}

sub modifyXDEV {
	my( $xdev ) = @_;
	my $line;
	open( XDEV, "$xdev" ) || print "**ERROR: Can not find \"$xdev\" file! (in modifyXDEV)\n";
	open( OUT, ">$tempdeck" );
	while( $line = <XDEV> ) {
		if( $line !~ /HN_NETLIST_MODEL_NAME:\s+rm\d+w/i 
                 && $line !~ /HN_NETLIST_MODEL_NAME:\s+rmAP/i) {
			print OUT $line;
		}
	}
	close( XDEV );
	close( OUT );
	system("\\mv $tempdeck $xdev");
}

sub genXDEV {
	my( $inp, $outp ) = @_;
	&copyFile( "$inp/X_DEV.cmd", "$outp" );
	&modifyXDEV( "$outp/X_DEV.cmd" );
}

sub modifyFileForMulit {
	my( $inFile, $ctrl ) = @_;
	my $line;
	open( IN, "$inFile" ) || print "**ERROR: Can not find \"$inFile\" file! (in modifyQueryCmd)\n";
	open( OUT, ">$tempdeck" );
	while( $line = <IN> ) {
                if( $ctrl == 1 && $line =~ /LAYOUT\s+NETLIST\s+PIN\s+LOCATIONS\s+YES/i ){
                    next;
                }elsif( $line =~ /uncomment_for_MULTI_DEVICE_EXTRACTION/i ) {
		    $line =~ s/uncomment_for_MULTI_DEVICE_EXTRACTION//i;
                    $line =~ s/#//g;
                    print OUT "$line";
                }else{
                    print OUT $line;
                }
	}
	close( IN );
	close( OUT );
	print "**INFO: Modify $inFile for MULTI_DEVICE_EXTRACTION turn on.\n";
	system("\\mv $tempdeck $inFile");
}

sub genLVSFILE {
	my( $inp, $outp, @comb ) = @_;
	my $xm;
	my @star = ();
	my %lvsfilehash = ();
	for my $c ( @comb ) {
		$c =~ /(\d+)M/i;
		$lvsfilehash{$1} = 1;
	}
	for my $m ( sort keys %lvsfilehash ) {
		$lvsfile = "lvsfile${m}m";
		if( -e "$inp/$lvsfile" ) {
			&copyFile( "$inp/$lvsfile", "$outp/$lvsfile" );
		}
	}
}

sub genLayerSetupCapGen {
    my( $inp, $outp, @comb ) = @_;
    my $xm;
    my @star = ();
    my %layer_setuphash = ();
    my %mhash = ();
    my $mtop;

    for my $c ( @comb ) {
        $c =~ /(\d+M)/i;
        $xm = lc($1);        
        if( $color_flag || $split_fname_by_metal_scheme ){
            $mhash{$c} = 1;
        } else {
            $mhash{$xm} = 1;
        }
    }
    # If package has "LAYER_SETUP" directory, layer_setup files are divided to different metal scheme.
    # If package has only one layer_setup file, it is super-set layer_setup file.
    if( -d "$inp/LAYER_SETUP" ) {
        for my $m ( sort keys %mhash ) {
            my $ori_mtop = $m;
            $ori_mtop =~ /(\d+M)/i;
            $ori_mtop = lc($1);
            @layer_setup = &getLayerSetupName( "$inp/LAYER_SETUP", $ori_mtop );
            for my $lay ( @layer_setup ) {
                my $olay = $lay;
                $mtop = $ori_mtop;
                if( $color_flag || $split_fname_by_metal_scheme) {
                    $olay =~ s/(\d+M)/$m/i;
                }
                &copyFile( "$inp/LAYER_SETUP/$lay",  "$outp/$olay"            );
                &modifyLayerSetup("$outp/$olay",$m);
                print "**INFO: Generate layer_setup file $lay at $outp/$olay\n";
                if( -e "$inp/CAPGEN_CMD/capgen_$mtop.cmd" ) {
                    if( $color_flag || $split_fname_by_metal_scheme ) {
                        &copyFile( "$inp/CAPGEN_CMD/capgen_$mtop.cmd", "$outp/capgen_$m.cmd" );
                        &modifyCapGen( "$outp/capgen_$m.cmd", $olay, $m);
                    } else {
                        if( $process =~ "N55HV|N40HV" && $mimcap > 0 ) {
                            &copyFile( "$inp/CAPGEN_CMD/capgen_$mtop.cmd.ctm", "$outp/capgen_$mtop.cmd" );
                        } else {
                            &copyFile( "$inp/CAPGEN_CMD/capgen_$mtop.cmd", "$outp/capgen_$mtop.cmd" );
                        }
                    }
                } else {
                    if( $split_fname_by_metal_scheme ) {
                        &copyFile( "$inp/capgen.cmd", "$outp/capgen_$m.cmd" );
                        &modifyCapGen( "$outp/capgen_$m.cmd", $olay, $m);
                    }else{
                        if( $process =~ "N55HV|N40HV|N55BCD|N40LP" && $mimcap > 0 ) {
                            &copyFile( "$inp/capgen.cmd.ctm", "$outp/capgen_$mtop.cmd" );
                        }else{
                            &copyFile( "$inp/capgen.cmd", "$outp/capgen_$mtop.cmd" );
                        }
                        &modifyCapGen( "$outp/capgen_$mtop.cmd", $olay, $m);
                    }
                    
                }
            }
        }    
    } elsif( -e "$inp/layer_setup" ) {
        &copyFile( "$inp/layer_setup", "$outp" );
        &copyFile( "$inp/capgen.cmd",  "$outp" );
    }
}

sub modifyLayerSetup {
    my( $layer_setup, $mcomb) = @_;
    my $line;
    my @expectRmLayers = ( );
    my @rmlayers = ( );
    open(IN,  "$layer_setup") || print "**ERROR: Can not find \"$layer_setup\" file! (in modifylayerSetup)";
    open(OUT, ">$tempdeck");
    @expectRmLayers = &getExpectRmLayers($mcomb);

    my $mxtop=&calculateMx($mcomb);
    my $mleetop=&calculateMlee($mcomb);
    my $mya_myb=&calculateMy($mcomb,$mxtop);
    my @isColorList = &getMetalColor($mcomb, $process, $DN2);
    
    while( $line = <IN> ) {
        $remove = 0;
        for( my $i = 0; $i < @expectRmLayers; $i ++ ) {
            if($line =~ /\s*(ext_layer|ext_cont)\s*=\s*(\S+)\s*/i) {
                my $tmp_lay=$2;
                if(lc($tmp_lay) eq lc($expectRmLayers[$i])){
                    push( @rmlayers, $tmp_lay );
                    $remove = 1;
                    last;
                }
            }
        }
        if( $color_flag ) {
            if( $line =~ /^\s*pro_layer\s*=\s*M(\d+)\s+pro_color\s*=/i ) { # find the color keyword
                my $metal=$1;
                next if( $isColorList[$metal] eq '0' || ($metal > $mleetop && $line =~ /lee_marker/i) );
            } elsif( $line =~ /^\s*pro_layer\s*=\s*M(\d+)\s+ext_layer\s*=/i ) { # find the color keyword
                my $metal=$1;
                next if( $isColorList[$metal] eq '1' || ($metal > $mleetop && $line =~ /lee_marker/i) );
            }
        }
        if( $rhim_flag ){
            if( $line =~ /^\s*pro_layer\s*=\s*RH_TN_(\d+)\s+ext_layer\s*=/i ) { # find the color keyword
                my $metal=$1;
                next if( $metal != $mya_myb );
            } elsif( $line =~ /^\s*pro_cont\s*=\s*VTIN_(\d+)\s+ext_cont\s*=/i ) { # find the color keyword
                my $metal=$1;
                next if( $metal != $mya_myb-1 );
            }
        }
        if( $rhim_flag_n22 ){
            if($mx_mz_n22->{$mcomb}==1){ #when mx and mz is neighbor, retain the top mx layer
                if($line =~ /^\s*pro_layer\s*=\s*TFR_(\d+)\s*/i){
                    my $metal = $1;
                    if ($metal != ( $mxtop +1) ){
                        $remove = 1;
                    }
                }elsif($line =~ /^\s*pro_cont\s*=\s*TFR_VIA(\d+)\s*/i){
                    my $metal = $1;
                    if ($metal !=  $mxtop ){
                        $remove = 1;
                    }                            
                }
            }else{ #when mx and mz isn't neighbor, remove all specific layer
                if($line =~ /^\s*pro_layer\s*=\s*TFR_(\d+)\s*/i){
                    $remove = 1;
                }elsif($line =~ /^\s*pro_cont\s*=\s*TFR_VIA(\d+)\s*/i){
                    $remove = 1;
                }
            }
        }
        print OUT $line if( !$remove );
    }
    
    if( $shpmimProb ) {
        for( my $i = 0; $i < @rmlayers; $i ++ ) {
            if($rmlayers[$i] =~ /(TPC_|MPC_|BPC_|_TPC|_MPC|_BPC)/i) {
                my $sTmp = "delete_layer=$rmlayers[$i]\n";
                print OUT $sTmp;
            }
        }
    }
    
    close(IN);
    close(OUT);
    system("\\mv $tempdeck $layer_setup");
#    print "**INFO: Modify layer_setup command file $layer_setup\n";
}

sub modifyCapGen {
    my( $capgen, $layer_setup, $mcomb) = @_;
    my $line;
    my $mxtop=&calculateMx($mcomb);
    my $mleetop=&calculateMlee($mcomb);
    my $mya_myb=&calculateMy($mcomb,$mxtop);
    my @isColorList = &getMetalColor($mcomb, $process, $DN2);
    my @expectRmLayers =  &getExpectRmLayers($mcomb);
    open(IN,  "$capgen") || print "**ERROR: Can not find \"$capgen\" file! (in modifyCapGen)";
    open(OUT, ">$tempdeck");
    while( $line = <IN> ) {
        if( $line =~ /\s+layer_setup\S*\s+/i ) {
            $line =~ s/\s+layer_setup\S*\s+/ $layer_setup /;
        }
        if( $line =~ /(^\s*-canonical_res_(cap|rc)_by_device\s+)(\S+)(.*)/i ) {
            my ($ori_words1,$rbody,$ori_words2)=($1,$3,$4);
            my @layers=split(/\,/,$rbody);
            $line = $ori_words1;
            foreach my $layer (@layers){
                if( $color_flag ){
                    if($layer =~ /mt(\d+)res_(a|b)/i){
                        my $metal_layer=$1;
                        next if( $isColorList[$metal_layer] eq '0' );
                    }
                    elsif($layer =~ /mt(\d+)res_noab/i){
                        my $metal_layer=$1;
                        next if( $isColorList[$metal_layer] eq '1' );
                    }
                }
                if( $rhim_flag ){
                    if($layer =~ /rhim_r(\d+)/i){
                        my $metal_layer=$1;
                        next if( $metal_layer != $mya_myb );
                    }
                }
                if( $rhim_flag_n22 ){
                    if($mx_mz_n22->{$mcomb}==1){ #when mx and mz is neighbor, retain the top mx layer
                       if($layer =~ /rhim_(r|serp_r)(\d+)/i){
                            my $metal_layer=$2;
                            next if( $metal_layer != ($mxtop+1) );
                        } 
                    }else{ #when mx and mz is not neighbor, remove all specific layer
                        next if ($layer =~ /rhim_(r|serp_r)(\d+)/i); 
                    }
                }
                $line = $line."$layer,";
            }
            $line =~ s/\,$//;
            $line .= $ori_words2."\n";
        }
        
        #-lvs_blocking xxx,yyy \
        #-blocking xxx:0.001,aaa,bbb,ccc \
        my $rmflag = 0;
        foreach my $i (@expectRmLayers) {
            if($line =~ /-blocking\s+(\w+):/){
                if(lc($1) eq lc($i)){
                    $rmflag = 1;
                    last;
                }
            }elsif($line =~ /-lvs_blocking\s+(.*)$/){
                my $tmp=$1;
                $tmp =~ s/(\s|\\)//g;
                my @lay_arr = split(",",$tmp);
                foreach(@lay_arr){
                    if(lc($_) eq lc($i)){
                        $rmflag = 1;
                        last;
                    }
                }
            }
            last if($rmflag);
        }
        if ($rmflag) {
            next;
        }
        print OUT $line;
    }
    close(IN);
    close(OUT);
    system("\\mv $tempdeck $capgen");
    print "**INFO: Modify capgen command file $capgen\n";
}

sub getLayerSetupName {
	my( $inp, $m ) = @_;
	my $file ;
	my @farr = ();
	opendir( DIR, "$inp" ) || die( "**ERROR: Can not find \"$inp\" directory! (in getLayerSetupName)\n" );
	while( $file = readdir( DIR ) ) {
		next if( $file =~ /^\./ || $file =~ /^\.\./ );
		if( $file =~ /(?<!\d)$m$/i ) {
			#print "getLayerSetupName: $file\n";
			push( @farr, $file );
		}
	}
	closedir( DIR );
	return @farr;
}

sub genStar {
	my( $inp, $outp, @comb ) = @_;
	my $xm;
	my @star = ();
	my %mhash = ();
	for my $c ( @comb ) {
#		$c =~ /(\d+M)/i;
#		$xm = lc($1);		
#		$mhash{$xm} = 1;
		$mhash{$c} = 1;
	}
	for my $mcomb ( sort keys %mhash ) {
		my $mtop = $mcomb; 
		$mtop =~ /(\d+M)/i; 
		$mtop = lc($1);
		@star = &getStarName( "$inp", $mtop );
		for my $s ( @star ) {
			my $os = $s;
			$os =~ s/(\d+M)/$mcomb/i;
			&copyFile( "$inp/$s", "$outp/$os" );
			&modifyStar( "$outp/$os", $mcomb );
			print "**INFO: Generate Star-RCXT mapping file $s at $outp/$os\n";
		}
	}
}

sub genXACT {
	my( $inp, $outp, @comb ) = @_;
	my @xact = ();
	my %mhash = ();
	return if ( ! -d $inp );
	for my $c ( @comb ) {
#		$c =~ /(\d+M)/i;
#		$xm = lc($1);
#		$mhash{$xm} = 1;
		$mhash{$c} = 1;
	}
	for my $m ( sort keys %mhash ) {
		my $mtop = $m;
		$mtop =~ /(\d+M)/i;
		$mtop = lc($1);
		@xact = &getXactName( "$inp", $mtop );
		for my $x ( @xact ) {
			my $ox = $x;
			if( $color_flag ) { #|| ($split_fname_by_metal_scheme && $all) ) { --> no need handle 
				$ox =~ s/(\d+M)/$m/i;
			} elsif ( $x =~ /xrc/i && $x =~ /(\S+)_\d+m/i ) {
				$ox = $1;
			}
			&copyFile( "$inp/$x", "$outp/$ox" );
			&modifyXact( "$outp/$ox", $m );
			print "**INFO: Generate XACT mapping file $ox at $outp\n";
		}
	}
}

sub modifyXact {
	my ( $xact, $m ) = @_;
	my @rmlayers = ( );
	my @expectRmLayers = ( );
	my $remove_section = 0;
	my $mxtop = 0;
	my $mleetop = 0;
	my $mya_myb = 0;

	open( XACT, "$xact" );
	open( OUT, ">$tempdeck" );
	@expectRmLayers = &getExpectRmLayers($m);
	$mxtop=&calculateMx($m);
	$mleetop=&calculateMlee($m);
	$mya_myb=&calculateMy($m,$mxtop);
	my @isColorList = &getMetalColor($m, $process, $DN2);

	while( $line = <XACT> ) {
		$remove = 0;
		for( my $i = 0; $i < @expectRmLayers; $i ++ ) {
			if( $line =~ /^\s*PEX\s+MAP\s+\S+\s+$expectRmLayers[$i]\b|^\s*PEX\s+IGNORE\s+CAPACITANCE\s+(?:INTRINSIC\s+)?ALL\s+.*?\b$expectRmLayers[$i]\b/i) {
				$remove = 1;
				last;	
			}
		}
		if( $color_flag ) { # for N10 color mapping
			if( $line =~ /^\s*PEX\s+MAP\s+M(\d+)\s+(\S+)\s*\(\d+\)\s+/i ) {
				my ($metal, $layer) = ($1,$2);
				if( $isColorList[$metal] eq '0' ) {
					$remove = 1;
				}
			}
			elsif( $line =~ /^\s*PEX\s+MAP\s+M(\d+)\s+(\S+)\b/i ) {
				my ($metal, $layer) = ($1,$2);
				if( $isColorList[$metal] eq '1' ) {
					$remove = 1;
				}
			}
			elsif( $line =~ /^\s*PEX\s+MAP\s+M(\d+)_MOM\s+(\S+)\s*\(\d+\)\s+/i ) {
				my ($metal, $layer) = ($1,$2);
				if( $isColorList[$metal] eq '0' ) {
					$remove = 1;
				} elsif( $metal > $mleetop ) {
					$remove = 1;
				}
			}
			elsif( $line =~ /^\s*PEX\s+MAP\s+M(\d+)_MOM\s+(\S+)\b/i ) {
				my ($metal, $layer) = ($1,$2);
				if( $isColorList[$metal] eq '1' ) {
					$remove = 1;
				} elsif( $metal > $mleetop ) {
					$remove = 1;
				}
			}
			elsif( $line =~ /^\s*PEX\s+REPLACE\s+M(\d+)\S+\s+(\S+)/i ) {
				my ($metal, $layer) = ($1,$2);
				if( $isColorList[$metal] eq '0' ) {
					$remove = 1;
				} elsif( $metal > $mleetop ) {
					$remove = 1;
				}
			}
			elsif( $line =~ /^\s*PEX\s+REPLACE\s+M(\d+)\s+(\S+)/i ) {
				my ($metal, $layer) = ($1,$2);
				if( $isColorList[$metal] eq '1' ) {
					$remove = 1;
				} elsif( $metal > $mleetop ) {
					$remove = 1;
				}
			}
		}
		if( $rhim_flag ){
			if( $line =~ /^\s*PEX\s+MAP\s+(RH_TN_|rhim_r)(\d+)\s+(\S+)\b/i ) {
				my ($metal, $layer) = ($2,$3);
				if( $metal != $mya_myb ) {
					$remove = 1;
				}
			}
			elsif( $line =~ /^\s*PEX\s+IGNORE\s+RESISTANCE\s+RH_TN_(\d+)\b/i ) {
				my $metal=$1;
				if( $metal != $mya_myb ) {
					$remove = 1;
				}
			}
		}

                if ($rhim_flag_n22){ 
                    if($mx_mz_n22->{$m}==1){ #when mx and mz is neighbor, retain the top mx layer
                        if($line =~ /^\s*PEX\s+MAP\s+TFR_(\d+)\s+(TFR_|rhim_r|rhim_serp_r)\d+\b/i){ #N22 using, remove "PEX MAP TFR_"
                            my $metal = $1;
               	            if( $metal != ($mxtop+1) ) {#only reserve the neighbor metal larger number
     		   		$remove = 1;
     		   	    }
                        }elsif($line =~ /^\s*PEX\s+IGNORE\s+RESISTANCE\s+(rhim_r|rhim_serp_r)(\d+)\s*\b/i){ #N22 using, remove "PEX IGNORE RESISTANCE rhim_r" or "PEX IGNORE RESISTANCE rhim_serp_r"
                            my $metal = $2;
     		   	    if( $metal != ($mxtop+1) ) {#only reserve the neighbor metal larger number
     		   		$remove = 1;
     		   	    }
                        }
                    }else{ #when mx and mz is not neighbor, remove all specific layer
                        if($line =~ /^\s*PEX\s+MAP\s+TFR_(\d+)\s+(TFR_|rhim_r|rhim_serp_r)\d+\b/i){ #N22 using, remove "PEX MAP TFR_"
     		   	    $remove = 1;     		   	    
                        }elsif($line =~ /^\s*PEX\s+IGNORE\s+RESISTANCE\s+(rhim_r|rhim_serp_r)(\d+)\s*\b/i){ #N22 using, remove "PEX IGNORE RESISTANCE rhim_r" or "PEX IGNORE RESISTANCE rhim_serp_r"
     		   	    $remove = 1;
                        }
                    }
                }

		print OUT "$line" if( !$remove );
	}
	close( XACT );
	close( OUT );
	system("\\mv $tempdeck $xact");
}

sub getXactName {
	my ( $inp, $m ) = @_;
	my $file ;
	my @farr = ();
	opendir( DIR, "$inp" ) || die( "**ERROR: Can not find \"$inp\" directory! (in getXactName)\n" );
	while( $file = readdir( DIR ) ) {
		next if( $file =~ /^\./ || $line =~ /^\.\./ );
		if( $file =~ /(?<!\d)$m/i ) {
			push( @farr, $file );
		}
	}
	closedir( DIR );
	if( $debug_flag ) {
		print "**DEBUG: (getXactName) xACT files: ", join(" ", @farr), "\n";
	}
	return @farr;
}

sub getStarName {
	my ( $inp, $m ) = @_;
	my $file ;
	my @farr = ();
	if( !opendir( DIR, "$inp" ) ) { 
		print ( "**ERROR: Can not find \"$inp\" directory! (in getStarName)\n" );
		return @farr;
	}
	while( $file = readdir( DIR ) ) {
		next if( $file =~ /^\./ || $line =~ /^\.\./ );
			if( $file =~ /(?<!\d)$m/i ) {
				push( @farr, $file );
			}
	}
	closedir( DIR );
	if( $debug_flag ) {
		print "**DEBUG: (getStarName) star files: ", join(" ", @farr), "\n";
	}
	return @farr;
}

sub modifyICVPEX {
	my ($deck, $mcomb ) = @_;
	my @expectRmLayers = ( );
	@expectRmLayers = &getExpectRmLayers($mcomb);
	my $mxtop=&calculateMx($mcomb);
	my $mleetop=&calculateMlee($mcomb);
	my $mya_myb=&calculateMy($mcomb,$mxtop);
	my @isColorList = &getMetalColor($mcomb, $process, $DN2);
	open( ICV, "$deck" );
	open( OUT, ">$tempdeck" );
	$pool = "";
	while ( $line = <ICV> ) {
		if( $line =~ /pex_conducting_layer_map/i || $line =~ /pex_via_layer_map/ || $line =~ /pex_unconnected_layer_map/ 
                 || $line =~ /pex_marker_layer_map/      || $line =~ /pex_ignore_cap_layer_map/ ) {
			$pool = $line;
			while( $line = <ICV> ) {
				$pool .= $line;
				last if( $line =~ /;/ );
			}
			for( my $i = 0; $i < @expectRmLayers; $i ++ ) {
				if( $pool =~ /layer1\s*=\s*$expectRmLayers[$i],/i ){
					$pool  = "pex_remove_layer_map(\n";
					$pool .= "	matrix = pex_matrix,\n";
					$pool .= "	layer1 = $expectRmLayers[$i],\n";
					$pool .= "	tagname = \"$expectRmLayers[$i]\"\n";
					$pool .= ");\n";
					last;
				}
				if( $pool =~ /ignore_cap_layer_list\s*=\s*{$expectRmLayers[$i]}/ || $pool =~ /ignore_cap_layer_list\s*=\s*{$expectRmLayers[$i],/ ){
					$pool = "";
					last;
				}
			}
			if( $color_flag ) {
				if( $pool =~ /process_layer\s*=\s*\"M(\d+)\",/i ){
					my $metal=$1;
					my $mask_set=0;
					my $layer="";
					my $remove=0;
					$mask_set=1 if( $pool =~ /append_string\s*=\s*\"MASK\s*=/i ); # find the color mapping
					$layer=$1 if( $pool =~ /layer1\s*=\s*(\S+)\s*,/i );

					if( $isColorList[$metal] eq '0' and $mask_set ){
					    $remove=1; # found the color mapping
					} elsif ( $isColorList[$metal] eq '1' and !$mask_set ) {
					    $remove=1; # not found the color mapping
					}
					if( $remove ){
						$pool  = "pex_remove_layer_map(\n";
						$pool .= "	matrix = pex_matrix,\n";
						$pool .= "	layer1 = $layer,\n";
						$pool .= "	tagname = \"$layer\"\n";
						$pool .= ");\n";
					}
				}
				if( $pool =~ /pex_unconnected_layer_map/ && $pool =~ /append_string\s*=\s*\"ITF=M(\d+)\s*MASK=\S*\",/i ){
					my $metal=$1;
					my $mask_set=0;
					my $layer="";
					my $remove=0;
					$mask_set=1 if( $pool =~ /layer1\s*=\s*{(\S+)\s*,\s*M\S+_\S+/i );
					$layer=$1 if( $pool =~ /layer1\s*=\s*{(\S+)\s*,/i );

					if( $isColorList[$metal] eq '0' and $mask_set ){
					    $remove=1; # found the color mapping
					} elsif ( $isColorList[$metal] eq '1' and !$mask_set) {
					    $remove=1; # not found the color mapping
					} elsif ($metal > $mleetop && $layer =~ /_MOM/i) {
					    $remove=1;
					}
					if( $remove ){
						$pool  = "pex_remove_layer_map(\n";
						$pool .= "	matrix = pex_matrix,\n";
						$pool .= "	layer1 = $layer,\n";
						$pool .= "	tagname = \"$layer\"\n";
						$pool .= ");\n";
					}
				}
			}
			if( $rhim_flag ) {
				if( $pool =~ /process_layer\s*=\s*\"(RH_TN|VTIN)_(\d+)\",/i ){
					my $metal=$2;
					my $layer=$1 if( $pool =~ /layer1\s*=\s*(\S+)\s*,/i );
					my $gold_metal = ($layer =~ /VTIN/i) ? $mya_myb-1 : $mya_myb ;
					if( $metal != $gold_metal ){
						$pool  = "pex_remove_layer_map(\n";
						$pool .= "	matrix = pex_matrix,\n";
						$pool .= "	layer1 = $layer,\n";
						$pool .= "	tagname = \"$layer\"\n";
						$pool .= ");\n";
					}
				}
			}

			if( $rhim_flag_n22 ){
			    if( $pool =~ /process_layer\s*=\s*\"(TFR_|TFR_VIA)(\d+)\",/i ){
			        my $tfr_name=$1;
			        my $metal_layer=$2;
			        my $isVia=($tfr_name =~/VIA/i) ? 1 : 0;
			        my $layer=$1 if( $pool =~ /layer1\s*=\s*(\S+)\s*,/i );
			        unless($mx_mz_n22->{$mcomb}==1 && ((!$isVia && $metal_layer == ($mxtop+1)) || ($isVia && $metal_layer == $mxtop))){ #retain the top mx layer
			            $pool  = "pex_remove_layer_map(\n";
			            $pool .= "	matrix = pex_matrix,\n";
			            $pool .= "	layer1 = $layer,\n";
			            $pool .= "	tagname = \"$layer\"\n";
			            $pool .= ");\n";
			        }
			    }
			}

			$line = $pool;
		}
		print OUT "$line";
	}
	close( ICV );
	close( OUT );
	system("\\mv $tempdeck $deck");
}

# ============================================================================
# procedure getExpectRmLayers
# input: a complete metal scheme (for example: 7M_5X1Z)
# output: an array contains all expected remove layers
# description: 
#   This function is used to get the expected remove layers for star or ICV.
#   The layers expected to be removed are based on the current metal scheme.
#   The purpose to input a complete metal scheme is to enable special RC techfile support.
# ============================================================================

sub getExpectRmLayers {
	my ($mcomb) = @_;
	my @expectRmLayers = ( );
	my ($mtop1, $mtop);
	$mtop1 = $mcomb;
	$mtop1 =~ /(\d+)M/i;
	$mtop  = $1;

	if( $edram =~ /n/i ) {
		push( @expectRmLayers, "p3" );
		push( @expectRmLayers, "p3Cont" );
		push( @expectRmLayers, "blc" );
		push( @expectRmLayers, "n_blc" );
		push( @expectRmLayers, "p_blc" );
		push( @expectRmLayers, "crown" );
	}
	if( $wlcspmode == 16003 ) {
		if(    ( $wlcsp =~ /n/i ) && ( $clvr =~ /n/i )) {
			push( @expectRmLayers, "CU_PPI"         );
			push( @expectRmLayers, "CB2"            );
			push( @expectRmLayers, "CU_PPI_pin"     );
			push( @expectRmLayers, "UBM"            );
			push( @expectRmLayers, "UBM_pin"        );
			push( @expectRmLayers, "indcuppi_p1"    );
			push( @expectRmLayers, "indcuppi_p2"    );
			push( @expectRmLayers, "indcuppi_p3"    );
			push( @expectRmLayers, "indcuppi_p4"    );
			push( @expectRmLayers, "PM_VIA"         );
			push( @expectRmLayers, "UBM_VIA"        );
		}elsif(( $wlcsp =~ /n/i ) && ( $clvr =~ /y/i )) {
			push( @expectRmLayers, "CB2"            );
                }elsif(( $wlcsp =~ /y/i ) && ( $clvr =~ /n/i )) {
			push( @expectRmLayers, "UBM"            );
			push( @expectRmLayers, "UBM_pin"        );
			push( @expectRmLayers, "indcuppi_p1"    );
			push( @expectRmLayers, "indcuppi_p2"    );
			push( @expectRmLayers, "indcuppi_p3"    );
			push( @expectRmLayers, "indcuppi_p4"    );
			push( @expectRmLayers, "PM_VIA"         );
			push( @expectRmLayers, "UBM_VIA"        );
                }
	}
	#print "MTOP = $mtop\n";
	my $mtopm1 = $mtop - 1;
	my $mtopm2 = $mtop - 2;
	#print "mimcap option: $mimcap\n";
	if( $mimcap == 0 || $mimcap == 1 ) {
		push( @expectRmLayers, "ctm_$mtopm1" );
		push( @expectRmLayers, "cbm_$mtopm1" );
		push( @expectRmLayers, "hd_ctm_$mtopm1" );
		push( @expectRmLayers, "hd_cbm_$mtopm1" );
		push( @expectRmLayers, "M${mtopm1}_cbm" );
		push( @expectRmLayers, "M${mtopm1}_cbm_pin" );
		push( @expectRmLayers, "ctm_via$mtopm2" );
		push( @expectRmLayers, "cbm_via$mtopm2" );
		push( @expectRmLayers, "VIA${mtopm1}_cbm" );
	}
	if( $mimcap == 0 || $mimcap == 2 ) {
		push( @expectRmLayers, "ctm_$mtop" );
		push( @expectRmLayers, "cbm_$mtop" );
		push( @expectRmLayers, "hd_ctm_$mtop" );
		push( @expectRmLayers, "hd_cbm_$mtop" );
		push( @expectRmLayers, "M${mtop}_cbm" );
		push( @expectRmLayers, "M${mtop}_cbm_pin" );
		push( @expectRmLayers, "ctm_via$mtopm1" );
		push( @expectRmLayers, "cbm_via$mtopm1" );
		push( @expectRmLayers, "RV_cbm" );
		push( @expectRmLayers, "ctm_${mtop}_3d" );
		push( @expectRmLayers, "cbm_${mtop}_3d" );
		push( @expectRmLayers, "ctm_via${mtopm1}_3d" );
		push( @expectRmLayers, "cbm_via${mtopm1}_3d" );
	}
	if( $process =~ "N40HV" && $mimcap == 0 ) {
		push( @expectRmLayers, "ctm" );
		push( @expectRmLayers, "cbm_2t" );
		push( @expectRmLayers, "cbm_3t" );
		push( @expectRmLayers, "ctm_via" );
		push( @expectRmLayers, "cbm_via_2t" );
		push( @expectRmLayers, "cbm_via_3t" );
	}
    if( $process =~ "N40LP" && $mimcap == 0 ) {
        push( @expectRmLayers, "ctm" );
        push( @expectRmLayers, "cbm_2t" );
        push( @expectRmLayers, "ctm_via" );
        push( @expectRmLayers, "cbm_via_2t" );
    }
    if( $process =~ "N55HV|N55BCD" && $mimcap == 0 ) {
        push( @expectRmLayers, "ctm" );
        push( @expectRmLayers, "cbm" );
        push( @expectRmLayers, "cbm_2t" );
        push( @expectRmLayers, "cbm_3t" );
        push( @expectRmLayers, "ctm_via" );
        push( @expectRmLayers, "cbm_via" );
        push( @expectRmLayers, "cbm_via_2t" );
        push( @expectRmLayers, "cbm_via_3t" );
    }

    if($shpmimProb){
        if( $shpmimcap == 0 ) {
            push( @expectRmLayers, "TPC" );
            push( @expectRmLayers, "MPC" );
            push( @expectRmLayers, "BPC" );
            push( @expectRmLayers, "TPC_GND_1" );
            push( @expectRmLayers, "MPC_LV_1" );
            push( @expectRmLayers, "BPC_GND_1" );
            push( @expectRmLayers, "BPC_LV_1" );
            push( @expectRmLayers, "BPC_HV1_1" );
            push( @expectRmLayers, "TPC_GND_2" );
            push( @expectRmLayers, "MPC_LV_2" );
            push( @expectRmLayers, "BPC_GND_2" );
            push( @expectRmLayers, "BPC_LV_2" );
            push( @expectRmLayers, "BPC_HV2_2" );
            #push( @expectRmLayers, "BPC_HV2_LV_2" );#RC layer for layer_setup
            push( @expectRmLayers, "RV_TPC_RDL" );
            push( @expectRmLayers, "RV_MPC_RDL" );
            push( @expectRmLayers, "RV_BPC_TPC" );
            push( @expectRmLayers, "RV_MTOP_BPC" );
            push( @expectRmLayers, "RV_MTOP_MPC" );
            push( @expectRmLayers, "RV_MTOP_BPC_BOT" );
            push( @expectRmLayers, "RV_BPC_BOT_MPC" );
            push( @expectRmLayers, "RV_BPC_BOT_RDL" );

            push( @expectRmLayers, "RV_MTOP_TPC" );
            #Dummy layer for recognition device
            push( @expectRmLayers, "TPC_GND_DMY_1" );
            push( @expectRmLayers, "MPC_LV_DMY_1" );
            push( @expectRmLayers, "BPC_GND_DMY_1" );
            push( @expectRmLayers, "BPC_LVHV_DMY_1" );
            push( @expectRmLayers, "TPC_GND_DMY_2" );
            push( @expectRmLayers, "MPC_LV_DMY_2" );
            push( @expectRmLayers, "BPC_GND_DMY_2" );
            push( @expectRmLayers, "BPC_LVHV_DMY_2" );
            
        }elsif( $shpmimcap == 1 ) {
            push( @expectRmLayers, "TPC_GND_1" );
            push( @expectRmLayers, "MPC_LV_1" );
            push( @expectRmLayers, "BPC_GND_1" );
            push( @expectRmLayers, "BPC_LV_1" );
            push( @expectRmLayers, "BPC_HV1_1" );
            push( @expectRmLayers, "TPC_GND_2" );
            push( @expectRmLayers, "MPC_LV_2" );
            push( @expectRmLayers, "BPC_GND_2" );
            push( @expectRmLayers, "BPC_LV_2" );
            push( @expectRmLayers, "BPC_HV2_2" );
            #push( @expectRmLayers, "BPC_HV2_LV_2" );#RC layer for layer_setup
            push( @expectRmLayers, "RV_MTOP_BPC_BOT" );
            push( @expectRmLayers, "RV_BPC_BOT_MPC" );
            push( @expectRmLayers, "RV_BPC_BOT_RDL" );
            
            push( @expectRmLayers, "RV_MTOP_TPC" );
            #Dummy layer for recognition device
            push( @expectRmLayers, "TPC_GND_DMY_1" );
            push( @expectRmLayers, "MPC_LV_DMY_1" );
            push( @expectRmLayers, "BPC_GND_DMY_1" );
            push( @expectRmLayers, "BPC_LVHV_DMY_1" );
            push( @expectRmLayers, "TPC_GND_DMY_2" );
            push( @expectRmLayers, "MPC_LV_DMY_2" );
            push( @expectRmLayers, "BPC_GND_DMY_2" );
            push( @expectRmLayers, "BPC_LVHV_DMY_2" );
         
        }elsif( $shpmimcap == 2 ) {
            push( @expectRmLayers, "TPC" );
            push( @expectRmLayers, "MPC" );
            push( @expectRmLayers, "BPC" );
            push( @expectRmLayers, "TPC_GND_2" );
            push( @expectRmLayers, "MPC_LV_2" );
            push( @expectRmLayers, "BPC_GND_2" );
            push( @expectRmLayers, "BPC_LV_2" );
            push( @expectRmLayers, "BPC_HV2_2" );
            #push( @expectRmLayers, "BPC_HV2_LV_2" );#RC layer for layer_setup
            
            #Dummy layer for recognition device
            push( @expectRmLayers, "TPC_GND_DMY_2" );
            push( @expectRmLayers, "MPC_LV_DMY_2" );
            push( @expectRmLayers, "BPC_GND_DMY_2" );
            push( @expectRmLayers, "BPC_LVHV_DMY_2" );
            
        }elsif( $shpmimcap == 3 ) {
            push( @expectRmLayers, "TPC" );
            push( @expectRmLayers, "MPC" );
            push( @expectRmLayers, "BPC" );
            push( @expectRmLayers, "TPC_GND_1" );
            push( @expectRmLayers, "MPC_LV_1" );
            push( @expectRmLayers, "BPC_GND_1" );
            push( @expectRmLayers, "BPC_LV_1" );
            push( @expectRmLayers, "BPC_HV1_1" );
            
            #Dummy layer for recognition device
            push( @expectRmLayers, "TPC_GND_DMY_1" );
            push( @expectRmLayers, "MPC_LV_DMY_1" );
            push( @expectRmLayers, "BPC_GND_DMY_1" );
            push( @expectRmLayers, "BPC_LVHV_DMY_1" );
        }
    }else{
        if( $shdmimcap == 0 ) {
            push( @expectRmLayers, "TPC" );
            push( @expectRmLayers, "MPC" );
            push( @expectRmLayers, "BPC" );
            push( @expectRmLayers, "RV_TPC_RDL" );
            push( @expectRmLayers, "RV_BPC_TPC" );
            push( @expectRmLayers, "RV_MTOP_BPC" );
            push( @expectRmLayers, "RV_MPC_RDL" );
            push( @expectRmLayers, "RV_MTOP_MPC" );
            push( @expectRmLayers, "RV_BPC_RDL" );
        }
    }

	# 2013.03.08 Do not remove gptap.
	#if( &procNum($process) == 20 ) {
	#	if( $mcomb =~ /9M_2Xa1Xd3Xe1Yz1Z/ ) {
	#		# special metal scheme to support gptap
	#	} else {
	#		push( @expectRmLayers, "n_gptap" );
	#		push( @expectRmLayers, "p_gptap" );
	#	}
	#} 
	if( $debug_flag ) {
		print "**DEBUG: (getExpectRmLayers) M combination: $mcomb\n";
		print "**DEBUG: (getExpectRmLayers) Expected remove layers: ", join(" ", @expectRmLayers), "\n";
	}
	return @expectRmLayers;	
}

sub modifyStar {
	my ( $star, $m ) = @_;
	my @rmlayers = ( );
	my @expectRmLayers = ( );
	my $remove_section = 0;
	my $ignore_section = 0;
	my $mxtop = 0;
	my $mleetop = 0;
	my $mya_myb = 0;

	open( STAR, "$star" );
	open( OUT, ">$tempdeck" );
	@expectRmLayers = &getExpectRmLayers($m);
	$mxtop=&calculateMx($m);
	$mleetop=&calculateMlee($m);
	$mya_myb=&calculateMy($m,$mxtop);
	my @isColorList = &getMetalColor($m, $process, $DN2);
	

	while( $line = <STAR> ) {
		if( ($toolvar{ZERO_NRS_NRD} eq "on" || $toolvar{ZERO_NRS_NRD} == 1 ) && $line =~ /^t[np]diff\s+\S+\s+RPSQ=/i ) {
			$line =~ s/RPSQ=\S+//i;
		} 
		if( $line =~ /^\s*remove_layers/i ) {
			$remove_section = 1;
			print OUT $line;
			for( my $i = 0; $i < @rmlayers; $i ++ ) {
				print OUT "$rmlayers[$i]\n";	
			}
		} else {
			if( $line =~ /^\s*ignore_cap_layers/i ) {
				$ignore_section = 1;
			}

			if( $line =~ /_layers\s*$/ ) { $remove_section = 0; }
			$remove = 0;
			for( my $i = 0; $i < @expectRmLayers; $i ++ ) {
				if( $line =~ /^\s*$expectRmLayers[$i]\s+/i && !$remove_section && !$ignore_section ) {
					push( @rmlayers, $expectRmLayers[$i] );
					$remove = 1;
					last;	
				}
				if( $line =~ /^\s*$expectRmLayers[$i]\s+/i && !$remove_section && $ignore_section ) {
					$remove = 1;
					last;	
				}
			}
			if( $color_flag ) { # for N10 color mapping
				if( $line =~ /^\s*(\S+)\s+M(\d+)_\S+\s*ITF=M\d+\s*MASK=/i ) {
					my ($layer, $metal) = ($1,$2);
					if( $isColorList[$metal] eq '0' ) {
						push( @rmlayers, $layer );
						$remove = 1;
					} elsif( $metal > $mleetop ) {
						push( @rmlayers, $layer );
						$remove = 1;
					}
				} elsif( $line =~ /^\s*(\S+)\s+M(\d+)\s*ITF=M\d+\s*MASK=/i ) {
					my ($layer, $metal) = ($1,$2);
					if( $isColorList[$metal] eq '1' ) {
						push( @rmlayers, $layer );
						$remove = 1;
					} elsif( $metal > $mleetop ) {
						push( @rmlayers, $layer );
						$remove = 1;
					}
				} elsif( $line =~ /^\s*(\S+)\s+M(\d+)\s+MASK=/i ) {
					my ($layer, $metal) = ($1,$2);
					if( $isColorList[$metal] eq '0' ) {
						push( @rmlayers, $layer );
						$remove = 1;
					}
				} elsif( $line =~ /^\s*(\S+)\s+M(\d+)\b/i ) {
					my ($layer, $metal) = ($1,$2);
					if( $isColorList[$metal] eq '1' ) {
						push( @rmlayers, $layer );
						$remove = 1;
					}
				}
			}
			if( $rhim_flag ){
				if( $line =~ /^\s*(\S+)\s+(RH_TN_|rhim_r)(\d+)\b/i ) {
					my ($layer, $metal) = ($1,$3);
					if( $metal != $mya_myb ) {
						push( @rmlayers, $layer );
						$remove = 1;
					}
				}elsif( $line =~ /^\s*(\S+)\s+VTIN_(\d+)\b/i ) {
					my ($layer, $metal) = ($1,$2);
					if( $metal != $mya_myb-1 ) {
						push( @rmlayers, $layer );
						$remove = 1;
					}
				}
			}

                        if( $rhim_flag_n22){
                            if($mx_mz_n22->{$m}==1){ #when mx and mz is neighbor, retain the top mx layer
                                if($line =~ /^\s*(\S+)\s+(TFR_)(\d+)\s*\S*\b/i){ #N22 using, remove "TFR__"
                                    my $layer = $1;
                                    my $metal = $3;
                                    if( $metal != ($mxtop+1) ) {#only reserve the neighbor metal larger number
                                        push( @rmlayers, $layer );
                                	$remove = 1;
                                    }
                                }elsif($line =~ /^\s*(\S+)\s+(TFR_VIA)(\d+)\s*\S*\b/i){ #N22 using, remove "TFR_VIA_"
                                    my $layer = $1;
                                    my $metal = $3;
                                    if( $metal != $mxtop ) {#only reserve the neighbor metal smaller number
                                        push( @rmlayers, $layer );
                                	$remove = 1;
                                    }
                                }
                            }else{ #when mx and mz is not neighbor, remove all specific layer
                                if($line =~ /^\s*(\S+)\s+(TFR_)(\d+)\s*\S*\b/i){ #N22 using, remove "TFR__"
                                    my $layer = $1;
                                    push( @rmlayers, $layer );
         		   	    $remove = 1;     		   	    
                                }elsif($line =~ /^\s*(\S+)\s+(TFR_VIA)(\d+)\s*\S*\b/i){ #N22 using, remove "TFR_VIA_"
                                    my $layer = $1;
                                    push( @rmlayers, $layer );
     	        	   	    $remove = 1;
                                }
                            }                        
                        }

			print OUT "$line" if( !$remove );
		}
	}
	close( STAR );
	close( OUT );
	system("\\mv $tempdeck $star");
}

sub getComb {
    my ($poly_num) =@_;
    my @carr = ();
    my $tool;
        my $m, $cfg, $all = 0, $help = 0;
    if( @ARGV == 0 ) {
        @carr = &query($poly_num);
    } elsif ( $ARGV[0] =~ /^-int$/) {
        $GENMODE = 1;
        open(QLOG, ">$INTFILE");
        &query($poly_num);
        @carr = @support;
    } else {
        $w_mimcap_flag = 1; $w_shpmimcap_flag = 1; $w_shdmimcap_flag = 1; $w_multi_flag = 1; $w_flick_flag = 1; $w_mTotal_flag = 1; $w_she_flag = 1;
        while($ARGV[0])
        {
            if( $ARGV[0] =~ /^-m$/          ) { $m = $ARGV[1];     shift(@ARGV); } 
            elsif( $ARGV[0] =~ /^-cfg$/     ) { $cfg = $ARGV[1];   shift(@ARGV); }
            elsif( $ARGV[0] =~ /^-all$/     ) { die "**WARN: -all has been phase out, please don't use this option, thank you.\n" }
            elsif( $ARGV[0] =~ /^-noedram$/ ) { $edram = "n";                    }
            elsif( $ARGV[0] =~ /^-wlcsp$/ && $wlcspmode ) { $wlcsp = "y";                    }
            elsif( $ARGV[0] =~ /^-clvr$/  && $wlcspmode ) { $clvr  = "y";                    }
            elsif( $ARGV[0] =~ /^-gplus$/   ) { $gplus = "y";                    }
            elsif( $ARGV[0] =~ /^-glp$/     ) { $glp = "y";                      }
            elsif( $ARGV[0] =~ /^-28hpl$/   ) { $hpl = "y";                      }
            elsif( $ARGV[0] =~ /^-28hpm$/   ) { $hpm = "y";                      }
            elsif( $ARGV[0] =~ /^-28hpp$/   ) { $hpp = "y";                      }
            elsif( $ARGV[0] =~ /^-28ulp$/   ) { $ulp = "y";                      }
            elsif( $ARGV[0] =~ /^-28hpc_plus$/   ) { $hpcp = "y";                }
            elsif( $ARGV[0] =~ /^-28hpc$/   ) { $hpc = "y";                      }
            elsif( $ARGV[0] =~ /^-mimcap$/  ) { $mimcap = $ARGV[1]; shift(@ARGV); $w_mimcap_flag = 0;}
            elsif( $ARGV[0] =~ /^-shpmimcap$/  ) { $shpmimcap = $ARGV[1]; shift(@ARGV); $w_shpmimcap_flag = 0;}
            elsif( $ARGV[0] =~ /^-shdmimcap$/  ) { $shdmimcap = $ARGV[1]; shift(@ARGV); $w_shdmimcap_flag = 0;}
            elsif( $ARGV[0] =~ /^-multi_device_extraction$/  ) { $multiDev = 1; $w_multi_flag = 0;}
            elsif( $ARGV[0] =~ /^-flicker_corner_extraction$/) { $flickDev = 1; $w_flick_flag = 0;}
            elsif( $ARGV[0] =~ /^-mom_parallel_mismatch_flag$/) { $mTotalDev = $ARGV[1]; shift(@ARGV); $w_mTotal_flag = 0;}
            elsif( $ARGV[0] =~ /^-self_heating_effect_extraction$/) { $sheDev = 1; $w_she_flag = 0;}
            elsif( $ARGV[0] =~ /^-soic$/    ) { $soicDev = 1; $w_soic_flag = 0;  }
            elsif( $ARGV[0] =~ /^-h$/       ) { $help = 1;                       }
            elsif( $ARGV[0] =~ /^-internal_check$/     ) { $all = 1;             }
            elsif( $ARGV[0] =~ /^-help$/    ) { $help = 1;                       }
            shift( @ARGV );
        }
        &printUsage() if( $help == 1 );
        &printUsage() if( !$m && !$cfg && !$all );
        &printUsage() if( $m && $cfg );
#        &printUsage() if( $mimcap ne "" && ($mimcap !~ /^0$/ && $mimcap !~ /^1$/ && $mimcap !~ /^2$/) );
        if( $m ) {
            chomp( $m );
            push( @carr, $m );
        } elsif( $cfg ) {
            @carr = &readCfg( $cfg );
        } elsif( $all == 1 ) {
            @carr = @support;
        }
    }
    return @carr;
}

sub modifyDeck {
        my ( $mode, $deck, $c, $outp ) = @_;
        my ( $m, $xs, $xt, $x, $xa, $xb, $xc, $xg, $xh, $xd, $xe, $xf, $xy, $ya, $yb,$yc, $y, $yy, $ys, $yx, $yu, $yz, $z, $r, $u, $yt );
        my ( $mxtop, $mxall, $mya_myb );    # Mx
        $c =~ s/\s+//;
        
        
        $m  = $1 if ( $c =~ /(\d+)m_/i );
        $xs = $1 if ( $c =~ /(\d+)xs(\d+|$)/i );
        $xt = $1 if ( $c =~ /(\d+)xt(\d+|$)/i );
        $x  = $1 if ( $c =~ /(\d+)x(\d+|$)/i );
        $xa = $1 if ( $c =~ /(\d+)xa(\d+|$)/i );
        $xb = $1 if ( $c =~ /(\d+)xb(\d+|$)/i );
        $xc = $1 if ( $c =~ /(\d+)xc(\d+|$)/i );
        $xg = $1 if ( $c =~ /(\d+)xg(\d+|$)/i );
        $xh = $1 if ( $c =~ /(\d+)xh(\d+|$)/i );
        $xd = $1 if ( $c =~ /(\d+)xd(\d+|$)/i );
        $xe = $1 if ( $c =~ /(\d+)xe(\d+|$)/i );
        $xf = $1 if ( $c =~ /(\d+)xf(\d+|$)/i );
        $xy = $1 if ( $c =~ /(\d+)xy(\d+|$)/i );
        $ya = $1 if ( $c =~ /(\d+)ya(\d+|$)/i );
        $yb = $1 if ( $c =~ /(\d+)yb(\d+|$)/i );
        $yc = $1 if ( $c =~ /(\d+)yc(\d+|$)/i );
        $y  = $1 if ( $c =~ /(\d+)y(\d+|$)/i );
        $yy = $1 if ( $c =~ /(\d+)yy(\d+|$)/i );
        $ys = $1 if ( $c =~ /(\d+)ys(\d+|$)/i );
        $yx = $1 if ( $c =~ /(\d+)yx(\d+|$)/i );
        $yu = $1 if ( $c =~ /(\d+)yu(\d+|$)/i );
        $yz = $1 if ( $c =~ /(\d+)yz(\d+|$)/i );
        $z  = $1 if ( $c =~ /(\d+)z(\d+|$)/i );
        $r  = $1 if ( $c =~ /(\d+)r(\d+|$)/i );
        $u  = $1 if ( $c =~ /(\d+)u(\d+|$)/i );

        # identify mx and mz metal to control rhim
        if ( &procNum($process) == 22 ) { #2020.06.12 N22 support TFR resistor handling
            $rhim_flag_n22 = 1;
            $mxtop = &calculateMx($c);
            if ( $c =~ /(\d+)x(\d+)z(\d+|$)/i ){
                $mx_mz_n22->{$c} = 1; #metal scheme is MxMz
            }else{
                print "**INFO: Mx is not the neighbor of Mz ! There is no rhim support in this metal scheme ($c)!\n";
            }
        }
        
        $split_fname_by_metal_scheme=1 if ( &procNum($process) == 22 );
         
        # identify X-metal
        if ( &procNum($process) <= 10) {
                @isColorList = &getMetalColor($c, $process, $DN2);
                $color_flag = 1;
                print "\n<SPECIAL NOTICE> : Please do not use reserved layers (refer to $outp/reserved_layers_$c)!\n\n";
                my $mxall = $xs + $xt + $x + $xa + $xb + $xc + $xg + $xh + $xd + $xe + $xf + $xy + 1;
                $mxtop = &calculateMx($c);
                if ( $mxtop != $mxall ) { die "**ERROR: Mx layer parsing error ! \n"; }
        }

	# identify Ya-metal to control rhim put in mya & my
	if (&procNum($process) <= 5) {
		$rhim_flag = 1;
	        $mya_myb = &calculateMy( $c, $mxtop );
		if ( $mya_myb < 0 ) { print "**INFO: MYa is not the neighbor of Myb ! There is no rhim support in this metal scheme ($c)!\n\n"; }
	}

        # identify Y-metal is inter-metal or top metal
        if ( $z == 0 && $r == 0 && $u == 0 && $yz == 0 && $yu == 0 ) {
                if ( &procNum($process) <= 45 && $process !~ "N45CIS" && $process !~ "N28CIS" ) {
                        $yt = $y;
                        $y  = 0;
                }
        }
        for ( my $i = $m ; $i > 1 ; $i-- ) {
                if ( $u != 0 ) {
                        if ( &procNum($process) >= 40 && $process !~ "N40SOI" ) { #2020.07.02 N40SOI using rmu flow
                                $marray[$i] = "rmt";
                        } else {
                                $marray[$i] = "rmuw";
                        }
                        $u--; next; }
                ############################################################################
                # Notice : Please be careful the order, add metal scheme by reverse order. #
                ############################################################################
                if ( $r != 0 )  { $marray[$i] = "rmrw";  $r--;  next; }
                if ( $z != 0 )  { $marray[$i] = "rmzw";  $z--;  next; }
                if ( $yz != 0 ) { $marray[$i] = "rmyzw"; $yz--; next; }
                if ( $yu != 0 ) { $marray[$i] = "rmyuw"; $yu--; next; }
                if ( $yx != 0 ) { $marray[$i] = "rmyxw"; $yx--; next; }
                if ( $ys != 0 ) { $marray[$i] = "rmysw"; $ys--; next; }
                if ( $yy != 0 ) { $marray[$i] = "rmyyw"; $yy--; next; }
                if ( $y != 0 )  { $marray[$i] = "rmyw";  $y--;  next; }
                if ( $yt != 0 ) { $marray[$i] = "rmytw"; $yt--; next; }
                if ( $yc != 0 ) { $marray[$i] = "rmycw"; $yc--; next; }
                if ( $yb != 0 ) { $marray[$i] = "rmybw"; $yb--; next; }
                if ( $ya != 0 ) { $marray[$i] = "rmyaw"; $ya--; next; }
                if ( $xy != 0 ) { $marray[$i] = "rmxyw"; $xy--; next; }
                if ( $xe != 0 ) { $marray[$i] = "rmxew"; $xe--; next; }
                if ( $xf != 0 ) { $marray[$i] = "rmxfw"; $xf--; next; }
                if ( $xd != 0 ) { $marray[$i] = "rmxdw"; $xd--; next; }
                if ( $xh != 0 ) { $marray[$i] = "rmxhw"; $xh--; next; }
                if ( $xg != 0 ) { $marray[$i] = "rmxgw"; $xg--; next; }
                if ( $xc != 0 ) { $marray[$i] = "rmxcw"; $xc--; next; }
                if ( $xb != 0 ) { $marray[$i] = "rmxbw"; $xb--; next; }
                if ( $xa != 0 ) { $marray[$i] = "rmxaw"; $xa--; next; }
                if ( $x != 0 )  { $marray[$i] =($keep_rmx_hard_name)? "rm${i}w" : "rmxw"; $x--; next; }
                if ( $xt != 0 ) { $marray[$i] = "rmxtw"; $xt--; next; }
                if ( $xs != 0 ) { $marray[$i] = "rmxsw"; $xs--; next; }
        }
        
        #N6 M2 Hardcode rule
        $marray[2]='rm2w' if($process eq 'N6');

        if ( $mode & $CAL ) { &modifyCal( $deck, $c, $outp, $mxtop, $mya_myb, @marray ); return; }
        if ( $mode & $HER ) { &modifyHer( $deck, @marray ); return; }
        if ( $mode & $ASU ) { &modifyAsu( $deck, @marray ); return; } # give a directory name for assura
        if ( $mode & $CCI ) { &modifyCal( $deck, $c, $outp, $mxtop, $mya_myb, @marray ); return; }
        if ( $mode & $QCI ) { &modifyCal( $deck, $c, $outp, $mxtop, $mya_myb, @marray ); return; }
        if ( $mode & $PVS ) { &modifyPVS( $deck, $c, $outp, $mxtop, $mya_myb, @marray ); return; }
        if ( $mode & $Pegasus ) { &modifyPVS( $deck, $c, $outp, $mxtop, $mya_myb, @marray ); return; }
        if ( $mode & $ICV ) { &modifyICV( $deck, $c, $outp, $mxtop, $mya_myb, @marray ); return; }
}

sub procNum {
	if( $process =~ /N(\d+)/i ) {
		return $1;
	} else {
		print "**ERROR: Can not get process number information! (in procNum) \n";
		print "**ERROR: Set process number as 0! \n";
		system("rm -rf $outpath");
		exit;
	}
}

sub setProcFlag {
	if(keys %toolvar >= 1 ){
		foreach my $tmpvar ( sort keys %toolvar ) {
			@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});
			$gplus = "y" if( ($tmpvar =~ /GPLUS_PROCESS/) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$glp   = "y" if( ($tmpvar =~ /GLP_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$hpl   = "y" if( ($tmpvar =~ /HPL_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$hpm   = "y" if( ($tmpvar =~ /HPM_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$hpp   = "y" if( ($tmpvar =~ /HPP_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$hpc   = "y" if( ($tmpvar =~ /HPC_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$ulp   = "y" if( ($tmpvar =~ /ULP_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
			$hpcp  = "y" if( ($tmpvar =~ /HPC_PLUS_PROCESS/  ) && ($tmpvar2[0] =~ /1/ || $tmpvar2[0] =~ /on/i) );
		}
	}
	if( $debug_flag ) {
		print "**DEBUG: (setProcFlag) gplus = $gplus\n"; 
		print "**DEBUG: (setProcFlag) glp   = $glp\n"; 
		print "**DEBUG: (setProcFlag) hpl   = $hpl\n"; 
		print "**DEBUG: (setProcFlag) hpm   = $hpm\n"; 
		print "**DEBUG: (setProcFlag) hpp   = $hpp\n"; 
		print "**DEBUG: (setProcFlag) hpc   = $hpc\n"; 
		print "**DEBUG: (setProcFlag) ulp   = $ulp\n"; 
		print "**DEBUG: (setProcFlag) hpcp  = $hpcp\n"; 
	}	
}

sub modifyAsu {
	my ( $deck, @marray ) = @_;
	&modifyExt( $deck, @marray );
	&modifylvsfile( $deck, @marray );
	&modifyRSF( $deck );
	if( $DN =~ /T-N40-CL-SP-068/ ) {
		&copyFile( "lpe_confile" ,  "$deck" );
	}
}

sub modifylvsfile {
	my ( $deck, @marray ) = @_;
	my $lvsfile = "$deck/lvsfile";
	open( LVSFILE, "$lvsfile" );
	open( OUT, ">$tempdeck" );
	while( $line = <LVSFILE> ) {
		if( $line =~ /^\s*model=generic\[rm(\d+)w],(rm\Sw)/ ) {
			$res = $1;
			if( $res == 1 ) {

			} else {
				$line =~ s/$2/$marray[$res]/;
			}
		}
		print OUT $line;
	}
	close( LVSFILE);
	close( OUT );
	system("\\mv $tempdeck $lvsfile");
	print "**INFO: Modify lvsfile $lvsfile\n";
}

sub modifyExt {
	my ( $deck, @marray ) = @_;
	my $ext = "$deck/extract.rul";
	open( EXT, "$ext" );
	open( OUT, ">$tempdeck" );
	my $res = 0;
	while( $line = <EXT> ) {
		if( $line =~ /^\s*extractDevice\("rm(\d+)w"/ ) {
			$res = $1;
			if( $res == 1 ) {

			} else {
				print OUT $line;	# print extractDevice ("rmxw" ... )
				$line = <EXT>;
				if( $line =~ /spiceModel\("rm\Sw"\)/ ) {
					$line =~ s/rm\Sw/$marray[$res]/;
				} else {
					print "ERROR: Can't find spiceModel of rm${res}w\n";
				}
			}
		}
		if( $line =~ /saveProperty\( mt(\d+)res "model" "rm\Sw"\)/ ) {
			$res = $1;
			if( $res == 1 ) {

			} else {
				$line =~ s/rm\Sw/$marray[$res]/;
			}
		}
		print OUT $line;
	}
	close( EXT );
	close( OUT );
	system("\\mv $tempdeck $ext");

}

sub modifyHer {
	my ( $deck, @marray ) = @_;
	open( DECK, "$deck" );
	open( OUT, ">$tempdeck" );
	my $res = 0;
	while( $line = <DECK> ) {
		if( $line =~ /^\s*RES\s+rm\Sw\s+mt(\d+)res/i ) {
			$res = $1;
			if( $res == 1 ) {

			} else {
				$line =~ s/^\s*RES\s+rm\Sw/RES $marray[$res]/i;
			}
		}
        if( $process =~ "N55HV" ) {
    		if( $line =~ /^\s*EQUATE\s+RES\s+rm(\d+)=rm\Sw/i ) {
	    		$res = $1;
		    	if( $res == 1 ) {
			    } else {
				    $line =~ s/=rm\Sw/=$marray[$res]/i;
			    }
		    }
        } else {
    		if( $line =~ /^\s*EQUATE\s+RES\s+rm(\d+)w=rm\Sw/i ) {
	    		$res = $1;
		    	if( $res == 1 ) {
			    } else {
    				$line =~ s/=rm\Sw/=$marray[$res]/i;
	    		}
		    }
        }

		if(keys %toolvar >= 1 ){
			foreach my $tmpvar ( sort keys %toolvar ) {
				@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});
				next if( $tmpvar =~ /MIMCAP_TYPE/ );
				$line =~ s/(^\s*VARIABLE\s+STRING\s+$tmpvar\s*\=\s*\")\S+\"/$1$tmpvar2[0]\"/i;
				$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+$tmpvar\s*\=\s*)\S+\s*\;/$1$tmpvar2[0]\;/i;
			}
		}
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+GPLUS_PROCESS\s*\=\s*)\S+\s*\;/${1}1 ;/i if( $gplus =~ /y/ ) ;
		$line =~ s/(^\s*DFM_TABLE_LOOKUP_FILE\s*\=\s*DFM\/table\/)\S+\s*/${1}N40GP_HER_DFM.table.en\n /i if( $gplus =~/y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+GLP_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $glp =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+HPL_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $hpl =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+HPM_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $hpm =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+HPP_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $hpp =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+HPC_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $hpc =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+ULP_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $ulp =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+HPC_PLUS_PROCESS\s*\=\s*)\S+\s*\;/${1}1;/i if( $hpcp =~ /y/ );
		$line =~ s/(^\s*VARIABLE\s+DOUBLE\s+MIMCAP_TYPE\s*\=\s*)\S+\s*\;/${1}1;/i if( $mimcap == 2 );

		print OUT "$line"; 
	}
	close(OUT);
	close(DECK);
	system("\\mv $tempdeck $deck");
}

sub modifyICV {
	my ( $deck, $mcomb, $outp, $mxtop, $mya_myb, @marray ) = @_;
	open( DECK, "$deck" );
	open( OUT, ">$tempdeck" );
	my $res = 0;
	my $res_detect = 0;
	my $simulation_model_name = "";
	my $color_conflict = "";
	if( $color_flag ) {
	    open( RL, ">$outp/$reserved_layers\_$mcomb" );
	    print RL $RL_msg;
	}
	while( $line = <DECK> ) {
		if( $color_flag ) { # for N10 color layer modification
			if( $line =~ /^\s*(DU)?M(\d+)i\S*\s*=\s*assign\(/i ) {
				my $metal_layer = $2;
				if( $isColorList[$metal_layer] eq '1' ) {
					$line=&modifyDataType("icv",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /^\s*(DU)?M(\d+)_(A|B)i\S*\s*=\s*assign\(/i ) {
				my $metal_layer = $2;
				if( $isColorList[$metal_layer] eq '0' ) {
					$line=&modifyDataType("icv",$line); # cancel Mx AB layer usage
				}
			}elsif( $line =~ /(color_conflict_layers\w*)/i ) { # for color conflict layer
				$color_conflict="color_db = $1({";
			}
			if($color_conflict){
			    $line =~ s/\s*,\s*/,/g;
			    $line =~ s/\},\{/\} , \{/g;
			    my @words=split(/\s+/,$line);
			    foreach my $word (@words){
				$word =~ s/,\s*$//;
				if($word =~ /{M(\d+)_(A|B),(\S+)}/){
				    my $metal_layer = $1;
				    if( $isColorList[$metal_layer] eq '1' ){ # cancel Mx noAB layer usage
					$word =~ s/,/, /g;
					$color_conflict .= " $word," ;
				    }
				}
				if($word =~ /\;/){
				    $color_conflict =~ s/,$//;
				    $color_conflict .= " });\n";
				    $line = $color_conflict;
				    $color_conflict = "";
				}
			    }
			    next if($color_conflict);
			}
		}
		if( $rhim_flag ){
			if( $line =~ /^\s*RHDMY(\d+)i\s*=\s*assign\(/i ) {
				my $metal_layer = $1;
				if( $metal_layer != $mya_myb ) { 
					$line=&modifyDataType("icv",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /(^\s*\/\/\s*\*\s*RHDMYn\s*=\s*).+/i ) {
				$line = $1."RHDMY${mya_myb}i\n" if($mya_myb > 0);
			}
		}

		if($rhim_flag_n22){
		    if( $line =~ /^\s*TFRDUMMY_(\d+)\s*=\s*assign\(/i ) { #For rhim and rhim_serp device
		        my $metal_layer = $1;
		        unless($mx_mz_n22->{$mcomb}==1 && $metal_layer == ($mxtop+1)){
		            $line=&modifyDataType("icv",$line);
		        }
		    }
		}

		if( $line =~ /^\s*device_name\s+=\s+\"rm(\d+)(w)?\"/i ) {
			$res = $1;
			if( $res == 1 || $res == 0 ) {
			} else {
				$res_detect = 1;
				$simulation_model_name = $marray[$res];
			}
		}
		if( $line =~ /simulation_model_name\s+=\s+\"rm\S+(w)?\"/ && $res_detect == 1 ) {
			$line =~ s/rm\Sw/$simulation_model_name/;
			$res_detect = 0;
		}
		if(keys %toolvar >= 1 ){
			foreach my $tmpvar ( sort keys %toolvar ) {
				@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});

				if( $tmpvar2[0] eq "on" ){
					$line =~ s/^\/\/\s*(#define\s+$tmpvar)/$1/i;
				}elsif( $tmpvar2[0] eq "off" ){
					$line =~ s/(^\s*#define\s+$tmpvar)/\/\/$1/i;
				}
			}
		}
		$line =~ s/^\/\/\s*(#define\s+GPLUS_PROCESS)/$1/i if( $gplus =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+GLP_PROCESS)/$1/i if( $glp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPL_PROCESS)/$1/i if( $hpl =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPM_PROCESS)/$1/i if( $hpm =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPP_PROCESS)/$1/i if( $hpp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPC_PROCESS)/$1/i if( $hpc =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+ULP_PROCESS)/$1/i if( $ulp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPC_PLUS_PROCESS)/$1/i if( $hpcp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+MIMCAP_TYPE)/$1/i if( $mimcap == 2 );
		$line =~ s/^\/\/\s*(#define\s+MULTI_DEVICE_EXTRACTION)/$1/i if( $multiDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+FLICKER_CORNER_EXTRACTION)/$1/i if( $flickDev == 1 );
		$line =~ s/^\s*(#define\s+MOM_PARALLEL_MISMATCH_FLAG)/\/\/$1/i if( $mTotalDev == 0 );
		$line =~ s/^\/\/\s*(#define\s+MOM_PARALLEL_MISMATCH_FLAG)/$1/i if( $mTotalDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+SELF_HEATING_EFFECT_EXTRACTION)/$1/i if( $sheDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+SOIC_TYPE)/$1/i                      if( $soicDev == 1 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHPMIM_client)/\/\/$1/i if( $shpmimcap == 2 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHPMIM_server)/\/\/$1/i if( $shpmimcap == 3 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHDMIM)/\/\/$1/i if( $shdmimcap == 1 );
		
		if( $wlcspmode ) {
			$line =~ s/^\/\/\s*(#define\s+WLCSP)/$1/i if( $wlcsp =~ /y/ );
			$line =~ s/^\/\/\s*(#define\s+CLVR)/$1/i  if( $clvr  =~ /y/ );
		}

		print OUT "$line"; 
	}
	close(RL) if( $color_flag );
	close(OUT);
	close(DECK);
	system("\\mv $tempdeck $deck");
	# modify pex section in ICV deck here
	&modifyICVPEX($deck, $mcomb);
}

sub modifyRSF {
	my ( $rsf_path ) = @_;
	open ( RSF_IN , "$inpath/../LVS.rsf" );
	open ( RSF_OUT , ">$rsf_path/LVS.rsf" );
	while ( $line = <RSF_IN> ) {
		
		if(keys %toolvar >= 1 ){
			foreach my $tmpvar ( sort keys %toolvar ) {
				@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});
				if( $tmpvar2[0] eq "on" ){
					$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"$tmpvar\")/$1/i;
				}elsif( $tmpvar2[0] eq "off" ){
					$line =~ s/^\s*(\?\s*set\s*\(\"$tmpvar)/\; $1/i;
				}
			}
		}
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"GPLUS_PROCESS\")/$1/i if( $gplus =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"GLP_PROCESS\")/$1/i if( $glp =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"HPL_PROCESS\")/$1/i if( $hpl =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"HPM_PROCESS\")/$1/i if( $hpm =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"HPP_PROCESS\")/$1/i if( $hpp =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"HPC_PROCESS\")/$1/i if( $hpc =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"ULP_PROCESS\")/$1/i if( $ulp =~ /y/ );
		$line =~ s/^\s*\;\s*(\?\s*set\s*\(\"HPC_PLUS_PROCESS\")/$1/i if( $hpcp =~ /y/ );

		print RSF_OUT $line;
	}
	close ( RSF_OUT );
	close ( RSF_IN ); 
}

sub modifyCal {
	my ( $deck, $mcomb, $outp, $mxtop, $mya_myb, @marray ) = @_;
	open( DECK, "$deck" );
	open( OUT, ">$tempdeck" );
	my $res = 0;
	my $erc_region = 0;
	my $color_conflict = "";

	my %toolvar_use;

	if( $color_flag ) {
	    open( RL, ">$outp/$reserved_layers\_$mcomb" );
	    print RL $RL_msg;
	}
	while( $line = <DECK> ) {
		if( $color_flag ) { # for N10 color layer modification

			if( $line =~ /LAYER\s+(DU)?M(\d+)i\S*\s+/i ) {
				my $metal_layer = $2;
				if( $isColorList[$metal_layer] eq '1' ) {
					$line=&modifyDataType("cal",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /LAYER\s+(DU)?M(\d+)_(A|B)i\S*\s+/i ) {
				my $metal_layer = $2;
				if( $isColorList[$metal_layer] eq '0' ) { 
					$line=&modifyDataType("cal",$line); # cancel Mx A/B layer usage
				}
			}elsif( $line =~ /^\s*PEX\s+EXTRACT\s+RESISTOR\s+mt(\d+)res_(a|b)/i ){
				my $metal_layer = $1;
				$line="" if( $isColorList[$metal_layer] eq '0' ); # cancel mt A/B resistor 
			}elsif( $line =~ /^\s*PEX\s+EXTRACT\s+RESISTOR\s+mt(\d+)res_noab/i ){
				my $metal_layer = $1;
				$line="" if( $isColorList[$metal_layer] eq '1' ); # cancel mt noAB resistor 
			}elsif( $line =~ /^\s*\{\s*M(\d+)_(A|B)\s+M(\d+)_(A|B)\s*\}/i ) { # for color conflict layer
				my $metal_layer = $1;
				$line="" if( $isColorList[$metal_layer] eq '0' ); # cancel Mx noAB layer usage
			}elsif( $line =~ /^\s*include\s+xact_mapping/i ) {
				$line="include xact_mapping_$mcomb\n"; # change xact_mapping file name
			}elsif( $line =~ /(\s*)erc::assign_conflict_layer/i ) { # for color conflict layer
				$color_conflict=$1."erc::assign_conflict_layer { ";
			}
			if($color_conflict){
				if($line =~ /\:/i){
				    my @words=split(/\"/,$line);
				    for(my $i=0; $i <= @words ; $i++ ){
                        if($words[$i] =~ /M(\d+)_(A|B)\s*\,\s*M(\d+)_(A|B)/i){
                            my $metal_layer = $1;
                            # for color aware >=N5
                            if( $isColorList[$metal_layer] eq '1') { # cancel Mx noAB layer usage
                                $color_conflict .= "\"$words[$i]\"$words[$i+1]";
                            }
                        }
                        if($words[$i] =~ /\}/){
                            $color_conflict .= " }\n";
                            $line = $color_conflict;
                            $color_conflict = "";
                        }
                    }
				}
				next if($color_conflict);
			}
		}
		if( $rhim_flag ){
			if( $line =~ /LAYER\s+RHDMY(\d+)i\s+/i ) {
				my $metal_layer = $1;
				if( $metal_layer != $mya_myb ) { 
					$line=&modifyDataType("cal",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /(^\s*\/\/\s*\*\s*RHDMYn\s*=\s*).+/i ) {
				$line = $1."RHDMY${mya_myb}i\n" if($mya_myb > 0);
			}
		}

                if($rhim_flag_n22){
                    if($mx_mz_n22->{$mcomb}==1){ #when mx and mz is neighbor, retain the top mx layer
                        if($line =~ /LAYER\s+TFRDUMMY_(\d+)/i){ #N22 using, replace datatype value of "TFRDUMMY_"
                            my $metal_layer = $1;
    		            if( $metal_layer != ($mxtop+1) ) {#only reserve the neighbor metal larger number
    		                $line=&modifyDataType("cal",$line);
    		            } 
                        }
                    }else{ #when mx and mz is not neighbor, remove all specific layer
                        if($line =~ /LAYER\s+TFRDUMMY_(\d+)/i){ #N22 using, replace datatype value of "TFRDUMMY_"
    		            $line=&modifyDataType("cal",$line);
                        }
                    }
                }

		if( $additional && $additional_file) {
			if( $line =~ /^\s*\/\/\s*\#\s*ERC\s+CHECK\s*\#/i ) {
				$erc_region = 1;
			}
			if( $erc_region && $line =~ /###############/ ) {
				$line .= "INCLUDE ./$additional_file\n";
			}
		}
		
		if( $line =~ /DEVICE\s+rm(\d+)(w)?/i ) {
			$res = $1;
			if( $res == 1 || $res == 0 ) { 
				
			} else {
                            if($process =~ "N40SOI"){ #2020.07.02 add for N40SOI 
                                if ($marray[$res] =~/w$/i){  #last word is "w", remove.
                                    $marray[$res] = substr $marray[$res],0, -1;
                                }
                                $line =~ s/netlist\s+model\s+rm\S/netlist model $marray[$res]/i; 
                            }else{
			        $line =~ s/netlist\s+model\s+rm\Sw/netlist model $marray[$res]/i;
                            }
			}
		}
		
		if(keys %toolvar >= 1 ){
			foreach my $tmpvar ( sort keys %toolvar ) {
				@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});

				if ( $line =~ /#define\s+$tmpvar/i ) {
					if( $tmpvar2[0] eq "on" && !$toolvar_use{$tmpvar} ){
						$line =~ s/^\/\/\s*(#define\s+$tmpvar)/$1/i;
						$toolvar_use{$tmpvar} = 1;
					}elsif( $tmpvar2[0] eq "off" && !$toolvar_use{$tmpvar} ){
						$line =~ s/(^\s*#define\s+$tmpvar)/\/\/$1/i;
						$toolvar_use{$tmpvar} = 1;
					}
				}
			}
		}
		$line =~ s/^\/\/\s*(#define\s+GPLUS_PROCESS)/$1/i if( $gplus =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+GLP_PROCESS)/$1/i if( $glp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPL_PROCESS)/$1/i if( $hpl =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPM_PROCESS)/$1/i if( $hpm =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPP_PROCESS)/$1/i if( $hpp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPC_PROCESS)/$1/i if( $hpc =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+ULP_PROCESS)/$1/i if( $ulp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPC_PLUS_PROCESS)/$1/i if( $hpcp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+MIMCAP_TYPE)/$1/i if( $mimcap == 2 );
		$line =~ s/^\/\/\s*(#define\s+MULTI_DEVICE_EXTRACTION)/$1/i if( $multiDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+FLICKER_CORNER_EXTRACTION)/$1/i if( $flickDev == 1 );
		$line =~ s/^\s*(#define\s+MOM_PARALLEL_MISMATCH_FLAG)/\/\/$1/i if( $mTotalDev == 0 );
		$line =~ s/^\/\/\s*(#define\s+MOM_PARALLEL_MISMATCH_FLAG)/$1/i if( $mTotalDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+SELF_HEATING_EFFECT_EXTRACTION)/$1/i if( $sheDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+SOIC_TYPE)/$1/i                       if( $soicDev == 1 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHPMIM_client)/\/\/$1/i if( $shpmimcap == 2 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHPMIM_server)/\/\/$1/i if( $shpmimcap == 3 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHDMIM)/\/\/$1/i if( $shdmimcap == 1 );

		if( $wlcspmode ) {
			$line =~ s/^\/\/\s*(#define\s+WLCSP)/$1/i if( $wlcsp =~ /y/ );
			$line =~ s/^\/\/\s*(#define\s+CLVR)/$1/i  if( $clvr  =~ /y/ );
		}

		print OUT "$line"; 
	}
	if( $color_flag ) {
	    close(RL);
	}
	close(OUT);
	close(DECK);
	system("\\mv $tempdeck $deck");
}

sub modifyPVS {
	my ($deck, $mcomb, $outp, $mxtop, $mya_myb, @marray ) = @_;
	open( DECK, "$deck" );
	open( OUT, ">$tempdeck" );
	my $res = 0;
	my $color_conflict = "";
	if( $color_flag ) {
	    open( RL, ">$outp/$reserved_layers\_$mcomb" );
	    print RL $RL_msg;
	}
	while( $line = <DECK> ) {
		if( $color_flag ) { # for N10 color layer modification
			if( $line =~ /LAYER_DEF\s+(DU)?M(\d+)i\S*\s+/i ) {
				my $metal_layer = $2;
				if( $isColorList[$metal_layer] eq '1' ) { 
					$line=&modifyDataType("pvs",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /LAYER_DEF\s+(DU)?M(\d+)_(A|B)i\S*\s+/i ) {
				my $metal_layer = $2;
				if( $isColorList[$metal_layer] eq '0' ) { 
					$line=&modifyDataType("pvs",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /lvs_assign_conflict_layer/i ) { # for color conflict layer
				$color_conflict="lvs_assign_conflict_layer ";
			}
			if($color_conflict){
			    if($line =~ /-group/i){
				my @words=split(/\s+-group\s+/,$line);
			    	foreach my $word (@words){
			    	    if($word =~ /M(\d+)_(A|B)\s+M(\d+)_(A|B)/){
			    	        my $metal_layer = $1;
			    	        if( $isColorList[$metal_layer] eq '1' ){ # cancel Mx noAB layer usage
					    $color_conflict .= "-group $word " ;
			    	        }
			    	    }
			    	    if($word =~ /\;/){
			    	        $color_conflict .= " ;\n";
			    	        $line = $color_conflict;
			    	        $color_conflict = "";
			    	    }
			    	}
			    }elsif($line =~ /\:/i){
				my @words=split(/\"/,$line);
			    	for(my $i=0; $i <= @words ; $i++ ){
			    	    if($words[$i] =~ /M(\d+)_(A|B)\s*\,\s*M(\d+)_(A|B)/i){
			    	        my $metal_layer = $1;
			    	        if( $isColorList[$metal_layer] eq '1' ){ # cancel Mx noAB layer usage
					    $color_conflict .= "\"$words[$i]\"$words[$i+1]";
			    	        }
			    	    }
			    	    if($words[$i] =~ /\;/){
			    	        $color_conflict .= ";\n";
			    	        $line = $color_conflict;
			    	        $color_conflict = "";
			    	    }
			    	}
			    }
			    next if($color_conflict);
			}
		}
		if( $rhim_flag ){
			if( $line =~ /LAYER_DEF\s+RHDMY(\d+)i\s+/i ) {
				my $metal_layer = $1;
				if( $metal_layer != $mya_myb ) { 
					$line=&modifyDataType("pvs",$line); # cancel Mx noAB layer usage
				}
			}elsif( $line =~ /(^\s*\/\/\s*\*\s*RHDMYn\s*=\s*).+/i ) {
				$line = $1."RHDMY${mya_myb}i\n" if($mya_myb > 0);
			}
		}

		if($rhim_flag_n22){
		    if($line =~ /LAYER_DEF\s+TFRDUMMY_(\d+)/i){ #For rhim and rhim_serp device
		        my $metal_layer = $1;
		        unless($mx_mz_n22->{$mcomb}==1 && $metal_layer == ($mxtop+1)){
		            $line=&modifyDataType("pvs",$line);
		        }
		    }
		}

		if( $line =~ /DEVICE\s+rm(\d+)(w)?/i ) {
			$res = $1;
			if( $res == 1 || $res == 0) { 
				
			} else {
				$line =~ s/\-model\s+rm\Sw/-model $marray[$res]/i;
			}
		}

		if(keys %toolvar >= 1 ){
			foreach my $tmpvar ( sort keys %toolvar ) {
				@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});

				if( $tmpvar2[0] eq "on" ){
					$line =~ s/^\/\/\s*(#define\s+$tmpvar)/$1/i;
				}elsif( $tmpvar2[0] eq "off" ){
					$line =~ s/(^\s*#define\s+$tmpvar)/\/\/$1/i;
				}
			}
		}
		$line =~ s/^\/\/\s*(#define\s+GPLUS_PROCESS)/$1/i if( $gplus =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+GLP_PROCESS)/$1/i if( $glp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPL_PROCESS)/$1/i if( $hpl =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPM_PROCESS)/$1/i if( $hpm =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPP_PROCESS)/$1/i if( $hpp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPC_PROCESS)/$1/i if( $hpc =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+ULP_PROCESS)/$1/i if( $ulp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+HPC_PLUS_PROCESS)/$1/i if( $hpcp =~ /y/ );
		$line =~ s/^\/\/\s*(#define\s+MIMCAP_TYPE)/$1/i if( $mimcap == 2 );
		$line =~ s/^\/\/\s*(#define\s+MULTI_DEVICE_EXTRACTION)/$1/i if( $multiDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+FLICKER_CORNER_EXTRACTION)/$1/i if( $flickDev == 1 );
		$line =~ s/^\s*(#define\s+MOM_PARALLEL_MISMATCH_FLAG)/\/\/$1/i if( $mTotalDev == 0 );
		$line =~ s/^\/\/\s*(#define\s+MOM_PARALLEL_MISMATCH_FLAG)/$1/i if( $mTotalDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+SELF_HEATING_EFFECT_EXTRACTION)/$1/i if( $sheDev == 1 );
		$line =~ s/^\/\/\s*(#define\s+SOIC_TYPE)/$1/i                      if( $soicDev == 1 );		
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHPMIM_client)/\/\/$1/i if( $shpmimcap == 2 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHPMIM_server)/\/\/$1/i if( $shpmimcap == 3 );
		$line =~ s/^\s*(#define\s+unexpected_device_checking_SHDMIM)/\/\/$1/i if( $shdmimcap == 1 );

		if( $wlcspmode ) {
			$line =~ s/^\/\/\s*(#define\s+WLCSP)/$1/i if( $wlcsp =~ /y/ );
			$line =~ s/^\/\/\s*(#define\s+CLVR)/$1/i  if( $clvr  =~ /y/ );
		}

		print OUT "$line"; 
	}
	close(RL) if( $color_flag );
	close(OUT);
	close(DECK);
	system("\\mv $tempdeck $deck");
}

sub isSupport {
	my ( $c ) = @_;
	my $find = 0;
	for my $drcc ( @support ) {
		if( $c =~ /$drcc/i ) {
			$find = 1;
			last;	
		}
	}
	return ($find==1)?1:0;	
}

sub checkComb {
	my ($process,@comb) = @_;
	for my $c ( @comb ) {
		my $error = 0;
		$c =~ s/\s+//; # remove space
		$m = $xs = $xt = $x = $xa = $xc = $xg = $xh = $xd = $xe = $xf = $xy = $ya = $y = $yb = $yc = $yy = $ys = $yx = $yz = $yu = $z = $r = $u = 0;
		$m = $1 if( $c =~ /(\d+)m_/i );
		$xs= $1 if( $c =~ /(\d+)xs(\d+|$)/i  );
		$xt= $1 if( $c =~ /(\d+)xt(\d+|$)/i  );
		$x = $1 if( $c =~ /(\d+)x(\d+|$)/i  );
		$xa= $1 if( $c =~ /(\d+)xa(\d+|$)/i );
		$xb= $1 if( $c =~ /(\d+)xb(\d+|$)/i );
		$xc= $1 if( $c =~ /(\d+)xc(\d+|$)/i );
		$xg= $1 if( $c =~ /(\d+)xg(\d+|$)/i );
		$xh= $1 if( $c =~ /(\d+)xh(\d+|$)/i );
		$xd= $1 if( $c =~ /(\d+)xd(\d+|$)/i );
		$xe= $1 if( $c =~ /(\d+)xe(\d+|$)/i );
		$xf= $1 if( $c =~ /(\d+)xf(\d+|$)/i );
		$xy= $1 if( $c =~ /(\d+)xy(\d+|$)/i );
		$ya= $1 if( $c =~ /(\d+)ya(\d+|$)/i );
		$yb= $1 if( $c =~ /(\d+)yb(\d+|$)/i );
		$yc= $1 if( $c =~ /(\d+)yc(\d+|$)/i );
		$y = $1 if( $c =~ /(\d+)y(\d+|$)/i  );
		$yy= $1 if( $c =~ /(\d+)yy(\d+|$)/i );
		$ys= $1 if( $c =~ /(\d+)ys(\d+|$)/i );
		$yx= $1 if( $c =~ /(\d+)yx(\d+|$)/i );
		$yz= $1 if( $c =~ /(\d+)yz(\d+|$)/i );
		$yu= $1 if( $c =~ /(\d+)yu(\d+|$)/i );
		$z = $1 if( $c =~ /(\d+)z(\d+|$)/i );
		$r = $1 if( $c =~ /(\d+)r(\d+|$)/i );
		$u = $1 if( $c =~ /(\d+)u(\d+|$)/i );

		$extra_num = ( $process =~ /N01/i ) ? 2 : 1 ;
		if ( $m != $xs + $xt + $x + $xa + $xb + $xc + $xg + $xh + $xd + $xe + $xf + $xy + $ya + $yb + $yc + $y + $yy + $ys +$yx + $yz + $yu + $z + $r + $u + $extra_num ) {
			#print "X: $x Xa : $xa Xc : $xc Xd : $xd Xe : $xe Xy : $xy Ya : $ya Yb : $yb Yc : $yc Y : $y Yy: $yy Ys: $ys Yx: $yx Yz : $yz Yu : $yu Z : $z R : $r U : $u\n";
			print "**ERROR: M != Xs+Xt+X+Xa+Xb+Xc+Xg+Xh+Xd+Xe+Xf+Xy+Ya+Yb+Yc+Y+Yy+Ys+Yx+Yz+Yu+Z(R)+U+1 ( $c )\n"; 
			$error = 1;
		} elsif ( ! &isSupport( $c ) ) {
			print "**ERROR: The metal scheme \"$c\" is not supported by DRM\n";
			$error = 1;
		}
		exit if ( $error );
	}
}

sub printUsage {
	print "Usage: LVS_Install.pl -m one_metal_scheme     (Specify the metal scheme)\n";
	print "                      -cfg config_file        (Use config file)\n";
	print "                      -noedram                (Not using edram RC techfile)\n";
	if( $wlcspmode == 16003) {
		print "                      -wlcsp                  (Using WLCSP RC techfile)\n";
		print "                      -clvr                   (Using CLVR  RC techfile)\n";
	}
	print "                      -glp                    (For N40GLP process)\n";
	print "                      -gplus                  (For N40GP process)\n";
	print "                      -28hpl                  (For N28HPL process)\n";
	print "                      -28hpm                  (For N28HPM process)\n";
	print "                      -28hpp                  (For N28HP+ process)\n";
	print "                      -28hpc                  (For N28HPC process)\n";
	print "                      -mimcap [0|1]           (0: Not using mimcap RC techfile)\n";
	print "                                              (1: Use mimcap RC techfile. mimcap is placed between Top & Top-1)\n";
	print "                      -shpmimcap [0|1|2|3]    (0: Not using mimcap RC techfile)\n";
	print "                                              (1: Use shdmimcap RC techfile)\n";
	print "                                              (2: Use shpmimcap of client-type RC techfile)\n";
	print "                                              (3: Use shpmimcap of server-type RC techfile)\n";
	print "                      -shdmimcap [0|1]        (0: Not using shdmimcap RC techfile; 1: Use mimcap RC techfile)\n";
#	print "                                              (2: Use mimcap RC techfile. mimcap is placed between Top-1 & Top-2)\n";
	print "                      -multi_device_extraction        [0|1]           (1: Extract properties)\n";
	print "                      -flicker_corner_extraction      [0|1]           (1: Extract properties)\n";
	print "                      -mom_parallel_mismatch_flag     [0|1]           (1: Extract properties)\n";
	print "                      -self_heating_effect_extraction [0|1]           (1: Extract properties)\n";
	print "                      -int                    (For library integration)\n";
	print "\n";
	print "1. metal_scheme format: ?M_?Xs?Xt?X?Xa?Xb?Xc?Xg?Xh?Xd?Xe?Xf?Xy?Ya?Yb?Yc?Y?Yy?Ys?Yx?Yz?Yu?Z?R?U\n";
	print "   ex: 4M_2X1Z\n";
	print "   ex: 5M_3X1Z\n";
	print "2. The config_file will be generated by performing ineteractive mode once\n";
	print "   >LVS_Install.pl (Press Enter)\n";
	exit;
}

sub queryOne {
	my ( $question, $auto, $gmode, @options ) = @_;
	my ( $answer, $metals, $input );
	my $valid = 0;
	my $indexmin = 999;
	my %mhash = () ;
	if( $gmode == 1 ) {
		$question =~ s/:/ @/;
		print QLOG "$question\n";
		for( my $i = 0; $i < @options; $i++ ) {
			my $index = ( $auto && ($options[$i] =~ /^(\d+)/) )? $1: $i;
			printf QLOG " %s >> %2d \n", $options[$i], $index;
		}
		return 0;
	}
	while( $valid == 0 ) {
		print "$question\n";
		for( my $i = 0; $i < @options; $i++ ) {
			my $index = ( $auto && ($options[$i] =~ /^(\d+)/) )? $1: $i;
			$indexmin = $index if ($i == 0);
			printf " %2d. %s\n", $index, $options[$i];
			$mhash{$index}=$i;
		}
		print ">";
		$input = <STDIN>;
		chomp( $input );
		#$answer = $input - $indexmin;	# real answer index in options
		if( !exists($mhash{$input}) ) {
			print "**ERROR: Option $input is invalid, please select again.\n";
		} else {
			$valid = 1;
		}
	}
	$metals = $options[$mhash{$input}];
	$metals =~ s/#.*//;
	return $metals; 
}

sub queryOne2 {
	my ( $question, $auto, @options ) = @_;
	my ( $answer, $metals, $input );
	my $valid = 0;
	my $indexmin = 999;
	my %mhash = () ;
	while( $valid == 0 ) {
		print "$question\n";
		for( my $i = 0; $i < @options; $i++ ) {
			my $index = ( $auto && ($options[$i] =~ /^(\d+)/) )? $1: $i;
			$indexmin = $index if ($i == 0);
			printf " %2d. %s\n", $index, $options[$i];
			$mhash{$index}=$i;
		}
		print ">";
		$input = <STDIN>;
		chomp( $input );
		#$answer = $input - $indexmin;	# real answer index in options
		if( !exists($mhash{$input}) ) {
			print "**ERROR: Option $input is invalid, please select again.\n";
		} else {
			$valid = 1;
		}
	}
	$metals = $options[$mhash{$input}];
	$metals =~ s/#.*//;
	return $metals; 
}

sub queryMarr {
	my ( $question, @options ) = @_;
	my @mcount ;
	my $valid = 0;
	my $indexmin = 999;
	my %mhash = () ;
	print QLOG "$question\n";
	for( my $i = 0; $i < @options; $i++ ) {
		my $index = ( $options[$i] =~ /^(\d+)/ )? $1: $i;
		if( exists $mcount[$index] ) {
			$mcount[$index]++;
		} else {
			$mcount[$index] = 0;
		}
		printf QLOG " %s >> %2d \n", $options[$i], $mcount[$index];
	}
}


sub queryYN {
	my ( $question, $gmode, $ans_y, $ans_n ) = @_;
	my $input, $output = "";
	my $valid = 0;
	$ans_y = "y" if(!$ans_y);
	$ans_n = "n" if(!$ans_n);
	if( $gmode == 1 ) {
		print QLOG "$question\n";
		print QLOG " Yes >> y \n";
		print QLOG " No >> n \n";
		return 0;
	}
	while( $valid == 0 ) {
		print "$question\n";
		print ">";
		$input = <STDIN>;
		chomp($input);
		if( $input =~/$ans_y/i ) {
			$output = "YES";
			$valid = 1;
		} elsif ( $input =~/$ans_n/i ) {
			$output = "NO";
			$valid = 1;
		} else {
			print "**ERROR: Option $input is invalid, please select again.\n";
		}
	}
	return $output;
}

sub queryIndex {
	my( $question, $gmode, @options ) = @_;
	my $valid = 0;
	if( $gmode == 1 ) {
		$question =~ s/:/ @/;
		print QLOG "$question\n";
		for( my $i = 0; $i < @options; $i++ ) {
			my $index = $i;
			printf QLOG " %s >> %2d\n", $options[$i], $index;
		}
		return 0;
	}
	while( $valid == 0 ) {
		print "$question\n";		
		for( my $i = 0; $i < @options; $i++ ) {
			my $index = $i;
			printf " %2d. %s\n", $index, $options[$i];
		}
		print ">";
		$input = <STDIN>;
		chomp( $input );
		if( $input < 0 || $input >= @options || $input !~ /^\d+$/ ) {
			print "**ERROR: Option $input is invalid, please select again.\n";
		} else {
			$valid = 1;
		}
	}
	return $input; 
}


#sub queryOF {
#	my ( $question ) = @_;
#	my $input, $output = "";
#	my $valid = 0;
#	while( $valid == 0 ) {
#		print "$question\n";
#		print ">";
#		$input = <STDIN>;
#		chomp($input);
#		if( $input =~/^\s*1\s*$/i ) {
#			$output = "On";
#			$valid = 1;
#		} elsif ( $input =~/^\s*2\s*$/i ) {
#			$output = "Off";
#			$valid = 1;
#		} else {
#			print "**ERROR: Option $input is invalid, please select again.\n";
#		}
#	}
#	return $output;
#}

sub query {
    my ($poly_num) =@_;
	my( $tool, $m );
	my $ans = "n" ;
	my $m, $c ;
	my @marr = ();
	my $subprocess = "";
	##setting switch
	print QLOG "Installation\n";
	print QLOG "Program : LVS_Install.pl\n";

	while( $ans !~ /y/i ) {
		if( $process =~ /N45GS/i ) {
			$subprocess = &queryOne("Please select the process:", 0, $GENMODE, @parr );
			$gplus = "y" if( $subprocess =~ /N40GPLUS/ );
			$glp  = "y" if( $subprocess =~ /N40GLP/ );
		}
		if( $process =~ /N28HP/i ) {
			$subprocess = &queryOne("Please select the process:", 0, $GENMODE, @parr );
			$hpl = "y" if( $subprocess =~ /N28HPL/ );
			$hpm = "y" if( $subprocess =~ /N28HPM/ );
			$hpp = "y" if( $subprocess =~ /N28HPP/ );
			$ulp = "y" if( $subprocess =~ /N28ULP/ );
			if( $subprocess =~ /N28HPC_PLUS/ ) {
            		    $hpcp = "y";
            		} elsif( $subprocess =~ /N28HPC/ ) {
            		    $hpc = "y";
            		}
		}
		if( $debug_flag ) {
			print "**DEBUG: (query) subprocess = $subprocess\n";
		}
		# tool option
		if( $cal_all_deck ){
		    $tool = $TOOLMSG{$LVS_DECK};
		} else {
		    $tool =  ((keys %toolarr) > 1 )? &queryOne("Please select the tool:", 0, $GENMODE, reverse sort keys %toolarr ) : ( each %toolarr ); 
		}
		# tool mode
		$tool = $toolarr{$tool};
		@marr = &getMetal();
		if( $GENMODE == 1 ) {
			$m = &queryOne("\$METAL_LAYER @", 1, $GENMODE, @marr );
		} else {
			$m = &queryOne("Please select the number of metal:", 1, $GENMODE, @marr );
		}
		@avail = &getAvail($m);
		if( $GENMODE == 1 ) {
			&queryMarr("\$METAL_SCHEME @", @support );
		} else {
			$c = &queryOne2("Please select the metal scheme:", 0, @avail  );
		}

		$edram = &queryYN("Use eDRAM RC techfile? (Y/N):", $GENMODE ) if ( $edramProb );
		#if( $wlcspmode ) {
		#	$wlcsp = &queryYN("Use WLCSP RC techfile? (Y/N):");
		#}
		if( $wlcspmode == 16003 ) {

    	    		    	@wlcspOpt = (
	    		                       "Use non WLCSP/CLVR RC techfile",
	    		                       "Use WLCSP RC techfile",
	    		                       "Use CLVR  RC techfile"
    	    		    	);
	    			$n_wlcspOpt = &queryIndex("Use what kind of RC techfile?:", $GENMODE, @wlcspOpt );
                                $wlcsp = "n";
                                $clvr  = "n";
                                if ($n_wlcspOpt == 1){
                                    $wlcsp = "y";
                                }
                                if ($n_wlcspOpt == 2){
                                    $clvr  = "y";
                                }
		}

        if( $mimProb ) {
            if($mimCapQuesVer eq 'V2'){
                @mimOpt = (
                   "No",
                   "Yes. Use mimcap device in design and use mimcap RC techfile",
                );
                $mimcap = &queryIndex("Use mimcap device in design and use mimcap RC techfile?:", $GENMODE, @mimOpt );
            }elsif( $process =~ "N55HV|N40HV|N55BCD|N40SOI" ) {   #2020.07.02 add for N40SOI 
                @mimOpt = (
                   "No",
                   "Yes. RC techfile has mimcap placed between Top metal & Top-1 metal",
                   "Yes, RC techfile has mimcap placed between Top-1 metal & Top-2 metal"
                );
                $mimcap = &queryIndex("Use mimcap RC techfile?:", $GENMODE, @mimOpt );
            } else {
                @mimOpt = (
                   "No",
                   "Yes. RC techfile has mimcap placed between Top metal & Top-1 metal",
                );
                $mimcap = &queryIndex("Use mimcap RC techfile?:", $GENMODE, @mimOpt );
            }
        }
        
        if( $shpmimProb ) {
            @shpmimOpt = (
                "No",
                "Yes. RC techfile has SHDMIM.",
                "Yes. RC techfile has SHPMIM of client-type.",
                "Yes. RC techfile has SHPMIM of server-type.",
            );
            $shpmimcap = &queryIndex("Use mimcap RC techfile?:", $GENMODE, @shpmimOpt );
        }

		if( $shdmimProb ) {
                    if($mergeMimcapOption){   #2020.07.31 add merge mimcap option function
                	@shdmimOpt = (
	                       "No",
	                       "Yes. RC techfile has mimcap.",
			);
			$shdmimcap = &queryIndex("Use mimcap RC techfile?:", $GENMODE, @shdmimOpt );
                    }else{
			@shdmimOpt = (
	                       "No",
	                       "Yes. RC techfile has shdmimcap.",
			);
			$shdmimcap = &queryIndex("Use shdmimcap RC techfile?:", $GENMODE, @shdmimOpt );
                    }
		}

		if( $multiProb ) {
			@multiOpt = (
	                       "No",
	                       "Yes. Enable MULTI_DEVICE_EXTRACTION. ",
			);
			$multiDev = &queryIndex("Turn on MULTI_DEVICE_EXTRACTION?:", $GENMODE, @multiOpt );
		}

		if( $flickProb ) {
			@flickOpt = (
	                       "No",
	                       "Yes. Enable FLICKER_CORNER_EXTRACTION. ",
			);
			$flickDev = &queryIndex("Turn on FLICKER_CORNER_EXTRACTION?:", $GENMODE, @flickOpt );
		}

		if( $mTotalProb ) {
			@mTotalOpt = (
	                       "No",
	                       "Yes. Enable MOM_PARALLEL_MISMATCH_FLAG. ",
			);
			$mTotalDev = &queryIndex("Turn on MOM_PARALLEL_MISMATCH_FLAG?:", $GENMODE, @mTotalOpt );
		}

		if( $sheProb ) {
			@sheOpt = (
	                       "No",
	                       "Yes. Enable SELF_HEATING_EFFECT_EXTRACTION. ",
			);
			$sheDev = &queryIndex("Turn on SELF_HEATING_EFFECT_EXTRACTION?:", $GENMODE, @sheOpt );
		}

		if( $soicProb ) {
			@soicOpt = (
	                       "bot-chip check: Mtop-BPVB-BPMB. (Turn off SOIC_TYPE switch)",
	                       "top-chip check: APS-RVS-MB2S-VB1S-MB1S-TSV-Mtop-1-Vtop-1-Mtop-BPVT-BPMT. (Turn on SOIC_TYPE switch)",
			);
			$soicDev = &queryIndex("Please select SOIC top-chip or bot-chip check:", $GENMODE, @soicOpt );
		}

		#print "mimcap selection: $mimcap\n";
		if( $subprocess eq "") {
			print "* Process is $process\n" if( !$GENMODE );
		} else {
			print "* Process is $subprocess\n" if( !$GENMODE );

		}
		print "* Metal scheme is ".uc($poly_num)."$c\n" if( !$GENMODE );
		if( $edramProb ) {
			if( $edram =~ /y/i ) {
				print "* Use eDRAM RC techfile\n" if( !$GENMODE );
			} else {
				print "* Not using eDRAM RC techfile\n" if( !$GENMODE );
			}
		}
		if( $wlcspmode == 16003 ) {
			($wlcsp =~ /y/i )? print "* Use WLCSP RC techfile\n" : print "* Not using WLCSP RC techfile\n";
			($clvr  =~ /y/i )? print "* Use CLVR RC techfile\n"  : print "* Not using CLVR RC techfile\n";
		}
		if( $mimProb ) {
			if( $mimcap == 0 ) {
				print "* Not using mimcap RC techfile\n" if( !$GENMODE );
			}
			if( $mimcap == 1 ) {
				print "* Use mimcap RC techfile. mimcap is placed between Top & Top-1\n" if( !$GENMODE );
			}
			if( $mimcap == 2 ) {
				print "* Use mimcap RC techfile. mimcap is placed between Top-1 & Top-2\n" if( !$GENMODE );
			}
		}
        if( $shpmimProb ) {
            if( $shpmimcap == 0 ) {
                print "* Not using mimcap RC techfile\n" if( !$GENMODE );
            }elsif( $shpmimcap == 1 ) {
                print "* Using shdmimcap RC techfile\n" if( !$GENMODE );
            }elsif( $shpmimcap == 2 ) {
                print "* Using shpmimcap of client-type RC techfile\n" if( !$GENMODE );
            }elsif( $shpmimcap == 3 ) {
                print "* Using shpmimcap of server-type RC techfile\n" if( !$GENMODE );
            }
        }
		if( $shdmimProb ) {
                    if($mergeMimcapOption){
                        if( $shdmimcap == 0 ) {
				print "* Not using mimcap RC techfile\n" if( !$GENMODE );
			}
			if( $shdmimcap == 1 ) {
				print "* Use mimcap RC techfile\n" if( !$GENMODE );
			}
                    }else{
			if( $shdmimcap == 0 ) {
				print "* Not using shdmimcap RC techfile\n" if( !$GENMODE );
			}
			if( $shdmimcap == 1 ) {
				print "* Use shdmimcap RC techfile\n" if( !$GENMODE );
			}
                    }
		}
		if( $multiProb ) {
			if( $multiDev == 0 ) {
				print "* MULTI_DEVICE_EXTRACTION : off\n" if( !$GENMODE );
			}
			if( $multiDev == 1 ) {
				print "* MULTI_DEVICE_EXTRACTION : on\n" if( !$GENMODE );
			}
		}
		if( $flickProb ) {
			if( $flickDev == 0 ) {
				print "* FLICKER_CORNER_EXTRACTION : off\n" if( !$GENMODE );
			}
			if( $flickDev == 1 ) {
				print "* FLICKER_CORNER_EXTRACTION : on\n" if( !$GENMODE );
			}
		}
		if( $mTotalProb ) {
			if( $mTotalDev == 0 ) {
				print "* MOM_PARALLEL_MISMATCH_FLAG : off\n" if( !$GENMODE );
			}
			if( $mTotalDev == 1 ) {
				print "* MOM_PARALLEL_MISMATCH_FLAG : on\n" if( !$GENMODE );
			}
		}
		if( $sheProb ) {
			if( $sheDev == 0 ) {
				print "* SELF_HEATING_EFFECT_EXTRACTION : off\n" if( !$GENMODE );
			}
			if( $sheDev == 1 ) {
				print "* SELF_HEATING_EFFECT_EXTRACTION : on\n" if( !$GENMODE );
			}
		}
		if( $soicProb ) {
			if( $soicDev == 0 ) {
				print "* SOIC_TYPE : off\n" if( !$GENMODE );
			}
			if( $soicDev == 1 ) {
				print "* SOIC_TYPE : on\n" if( !$GENMODE );
			}
		}
		if( $GENMODE == 1 ) {
			print QLOG "\$Is it correct? @ y \n";
			$ans = "y";
		} else {
			$ans = &queryYN( "Is it correct? (Y/N):", 0 );
		}

	}
	
	if($GENMODE) {
		print QLOG "SuccessMessage : $success_msg\n";
		print QLOG "ErrorMessage : $fail_msg\n";
		print QLOG "\n";
		print QLOG "TechFiles\n";
		print QLOG "Document_Number : $DN\n";
		print QLOG "Version : ",$VER,"\n";
		print QLOG "Suffix_Display : .txt .pdf README\n";
		print QLOG "Verify_Techfiles : ./$untarTreeFile\n";
		print QLOG "Display_Techfiles :\n";
	}

	#
	&getSwitch( $tool, $m );
	if( $tool eq "Hercules" ) {
		$toolvar{"GPLUS_PROCESS"} = 1    if( $gplus =~ /y/); 
		$toolvar{"GLP_PROCESS"}   = 1    if( $glp   =~ /y/);
		$toolvar{"HPL_PROCESS"}   = 1    if( $hpl   =~ /y/);
		$toolvar{"HPM_PROCESS"}   = 1    if( $hpm   =~ /y/);
		$toolvar{"HPP_PROCESS"}   = 1    if( $hpp   =~ /y/);
		$toolvar{"HPC_PROCESS"}   = 1    if( $hpc   =~ /y/);
		$toolvar{"ULP_PROCESS"}   = 1    if( $ulp   =~ /y/);
		$toolvar{"HPC_PLUS_PROCESS"}   = 1    if( $hpcp   =~ /y/);
	} else {
		$toolvar{"GPLUS_PROCESS"} = "on" if( $gplus =~ /y/);
		$toolvar{"GLP_PROCESS"}   = "on" if( $glp   =~ /y/);
		$toolvar{"HPL_PROCESS"}   = "on" if( $hpl   =~ /y/);
		$toolvar{"HPM_PROCESS"}   = "on" if( $hpm   =~ /y/);
		$toolvar{"HPP_PROCESS"}   = "on" if( $hpp   =~ /y/);
		$toolvar{"HPC_PROCESS"}   = "on" if( $hpc   =~ /y/);
		$toolvar{"ULP_PROCESS"}   = "on" if( $ulp   =~ /y/);
		$toolvar{"HPC_PLUS_PROCESS"}   = "on" if( $hpcp   =~ /y/);
		if( $wlcspmode == 16003 ) {
			if($wlcsp =~ /y/i){
				$toolvar{"WLCSP"}= "on";
			}else{
				$toolvar{"WLCSP"}= "off";
			}
			if($clvr =~ /y/i){
				$toolvar{"CLVR"} = "on";
			}else{
				$toolvar{"CLVR"} = "off";
			}
		}
	}
	&setProcFlag();

	# write output config file
	if( !$GENMODE ) {
		&gencfg($outcfg,$tool,$c);
		&gencfg($outcfg2,$tool,$c);
	}

	$mode = $CAL	  if ( $tool eq "Calibre" );
	$mode = $CCI 	  if ( $tool eq "CCI" );
	$mode = $QCI 	  if ( $tool eq "QCI" );
	$mode = $HER 	  if ( $tool eq "Hercules" );
	$mode = $ASU 	  if ( $tool eq "Assura" );
	$mode = $PVS 	  if ( $tool eq "PVS" );
	$mode = $Pegasus  if ( $tool eq "Pegasus" );
	$mode = $ICV 	  if ( $tool eq "ICV" );

	return ( $c );
}

sub gencfg{
    my ($out,$tool,$c)=@_;
    open( OUT, ">$out" );
    print OUT "TOOL: $tool\n";
    print OUT "METAL_SCHEME: $c\n";
    print OUT "USE_EDRAM: $edram\n";
    print OUT "MIMCAP_OPTION: $mimcap\n";
    print OUT "SHPMIMCAP_OPTION: $shpmimcap\n";
    print OUT "SHDMIMCAP_OPTION: $shdmimcap\n";
    print OUT "MULTI_DEVICE_EXTRACTION_OPTION: $multiDev\n" if( $multiProb );
    print OUT "FLICKER_CORNER_EXTRACTION_OPTION: $flickDev\n" if( $flickProb );
    print OUT "MOM_PARALLEL_MISMATCH_FLAG_OPTION: $mTotalDev\n" if( $mTotalProb );
    print OUT "SELF_HEATING_EFFECT_EXTRACTION_OPTION: $sheDev\n" if( $sheProb );
    print OUT "SOIC_TYPE_OPTION: $soicDev\n" if( $soicProb );
    print OUT "SWITCH:\n";
    if(( $multiProb ) && ($multiDev == 1)){
        $toolvar{"MULTI_DEVICE_EXTRACTION"} = "on";
    }
    if(( $flickProb ) && ($flickDev == 1)){
        $toolvar{"FLICKER_CORNER_EXTRACTION"} = "on";
    }
    if(( $mTotalProb ) && ($mTotalDev == 1)){
        $toolvar{"MOM_PARALLEL_MISMATCH_FLAG"} = "on";
    }    
    if(( $sheProb ) && ($sheDev == 1)){
        $toolvar{"SELF_HEATING_EFFECT_EXTRACTION"} = "on";
    }
    if(( $soicProb ) && ($soicDev == 1)){
        $toolvar{"SOIC_TYPE"} = "on";
    }

	if(keys %toolvar >= 1 ){
		foreach my $tmpvar ( sort keys %toolvar ) {
			@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});
			if($tmpvar2[0] eq "freeze" && $out =~ /summary/i){
				printf OUT "%-45s %-20s\n", "$tmpvar $tmpvar2[0]","(default $deck_switch_def{$tmpvar})";
			} else {
				print OUT "$tmpvar $tmpvar2[0]\n";
			}
		}
	}
	$print_cfg_msg=1;
	close( OUT );
}

# ============================================================================
# procedure getSwitch
# input: tool, given metal level
# output: toolvar (global), process variables (global)
# description: 
#   Get all the switches and save those switch informations in toolvar hash 
#   When some process switches are detected as on (1), set process variables
#   as "y"
# ============================================================================

sub getSwitch {
	my( $tool, $m ) = @_;
	# get switch information
	%toolvar = &getVarName( "$inpath/LVS_DECK",     "$m" ,     $tool ) if ( $tool eq "Uni-Calibre" );
	%toolvar = &getVarName( "$inpath/CALIBRE_FLOW", "$m" ,     $tool ) if ( $tool eq "Calibre" );
	%toolvar = &getVarName( "$inpath/CCI_FLOW",     "$m" ,     $tool ) if ( $tool eq "CCI" );
	%toolvar = &getVarName( "$inpath/QCI_FLOW",     "$m" ,     $tool ) if ( $tool eq "QCI" );
	%toolvar = &getVarName( "$inpath",              "$m" ,     $tool ) if ( $tool eq "Hercules" );
	%toolvar = &getVarName( "./",                   "LVS.rsf", $tool ) if ( $tool eq "Assura" );
	%toolvar = &getVarName( "$inpath/PVS_FLOW",     "$m" ,     $tool ) if ( $tool eq "PVS" );
	%toolvar = &getVarName( "$inpath/PEGASUS_FLOW", "$m" ,     $tool ) if ( $tool eq "Pegasus" );
	%toolvar = &getVarName( "$inpath/ICV_FLOW",     "$m" ,     $tool ) if ( $tool eq "ICV" );
	if( $debug_flag ) {
		print "**DEBUG: (getSwitch) switches:\n";
		if(keys %toolvar >= 1 ){
			foreach my $tmpvar ( sort keys %toolvar ) {
				@tmpvar2 = split( /\s+/, $toolvar{$tmpvar});
				print "**DEBUG: -- $tmpvar $tmpvar2[0]\n";
			}
		}
	} 
}

sub getMode {
	my $file, $mode = 0;
	opendir( DIR, "$inpath" ) || print "**ERROR: Can not find $inpath directory! (in getMode) \n";
	while( $file = readdir(DIR) ) {
		next if( $file =~ /^\./ || $file =~ /^\.\./ );
		if( $file =~ /calibre/i ) {
			# Detect CALIBRE dir "CALIBRE_FLOW"
			$mode |= $CAL;
			$toolarr{$TOOLMSG{$CAL}}="Calibre";				
		}elsif( $file  =~ /cci/i ) {
			# Detect CCI dir "CCI_FLOW"
			$mode |= $CCI;	
			$toolarr{$TOOLMSG{$CCI}}="CCI";
		}elsif( $file =~ /qci/i ) {
			# Detect QCI dir "QCI_FLOW"
			$mode |= $QCI;
			$toolarr{$TOOLMSG{$QCI}}="QCI";
		}elsif( $file =~ /hercules/i ) {
			# Detect hercules deck "DFM_LVS_RC_HERCULES_ ..."
			$mode |= $HER;	
			$toolarr{$TOOLMSG{$HER}}="Hercules";
		}elsif( $file =~ /pvs/i ) {
			# Detect pvs dir "PVS_FLOW"
			$mode |= $PVS;
			$toolarr{$TOOLMSG{$PVS}}="PVS";
		}elsif( $file =~ /pegasus/i ) {
			# Detect pvs dir "PEGASUS_FLOW"
			$mode |= $Pegasus;
			$toolarr{$TOOLMSG{$Pegasus}}="Pegasus";
		}elsif( $file =~ /icv/i ) {
			# Detect ICV deck "DFM_LVS_RC_ICV_ ... "
			$mode |= $ICV;
			$toolarr{$TOOLMSG{$ICV}}="ICV";
		}
		if( $file  =~ /LVS_DECK/i ) {
			# Detect LVS_DECK dir
			$mode |= $LVS_DECK;
			$toolarr{$TOOLMSG{$LVS_DECK}}="Uni-Calibre";
		}
	}
	# Not all above files, it's Assura
	if( !$mode ) { $mode = $ASU; $toolarr{$TOOLMSG{$ASU}}="Assura"; }
	closedir( DIR );
	print "**INFO: Uni-Calibre Package detected\n" if( $mode & $LVS_DECK );
	print "**INFO: Calibre mode detected\n" if( $mode & $CAL );
	print "**INFO: Hercules mode detected\n" if( $mode & $HER );
	print "**INFO: Assura mode detected\n" if( $mode & $ASU );
	print "**INFO: CCI mode detected\n" if( $mode & $CCI );
	print "**INFO: QCI mode detected\n" if( $mode & $QCI );
	print "**INFO: PVS mode detected\n" if( $mode & $PVS );
	print "**INFO: Pegasus mode detected\n" if( $mode & $Pegasus );
	print "**INFO: ICV mode detected\n" if( $mode & $ICV );
	return $mode;
}

sub getDeckName {
	my ( $path ) = @_;
	my $file;
	opendir( DIR, "$path" ) || print "**WARN: Can not find $path directory! (in getDeckName) \n"; 
	while( $file = readdir( DIR ) ) {
		last if( $file =~ /[013]P\d+M/i );  # 0PXM for N45CIS
	}
	closedir( DIR );
    
    if($file =~ /([013]P)\d+M/i){
        return ($file,$1);
    }else{
        print "**WARN: Can not find any deck at $path\n";
        return 0;    
    }
	return 0;
}

sub getVarName {
	my ( $path, $metal, $tool ) = @_;
	my $file;
	my %deck_switch ;
	undef %deck_switch_def if(%deck_switch_def);

	opendir( DIR, "$path" ) || print "**WARN: Can not find $path directory! (in getVarName) \n"; 
	while( $file = readdir( DIR ) ) {
		last if( $file =~ /(?<!\d)$metal/i );
	}
	closedir( DIR );

	if( $file !~ /$metal/i ) {
		print "**WARN: Can not find any deck at $path\n";
		return 0;	
	} else {

		#print "**INFO: Get the deck name \"$file\"\n";
		open( DECK_IN, "$path\/$file" ) || die("**ERROR: Can not open profile file!\n");
		while( $line = <DECK_IN> ) {
			chomp( $line );
			if( $tool eq "Uni-Calibre" || $tool eq "Calibre" || $tool eq "CCI" || $tool eq "QCI" || $tool eq "PVS" || $tool eq "Pegasus" || $tool eq "ICV" ){
				if( $line =~ /^\/\/\s*#define\s+(\S+)/i && !(defined $deck_switch{$1}) ){
				    $deck_switch{$1}="off on off";
				    $deck_switch_def{$1}="off";
				}
				( $deck_switch{$1}="freeze on off"  ) if( $line =~ /^\/\/\s*#define\s+(\S+)/i && defined $deck_switch{$1} );
				if( $line =~ /^\s*#define\s+(\S+)/i && !(defined $deck_switch{$1}) ){
				    $deck_switch{$1}="on on off";
				    $deck_switch_def{$1}="on";
				}
				( $deck_switch{$1}="freeze on off" ) if( $line =~ /^\s*#define\s+(\S+)/i && defined $deck_switch{$1} );
			}elsif ( $tool eq "Assura" ) {
				( $deck_switch{$1}="off on off" ) if( $line =~ /^\s*\;\s*\?\s*set\s*\(\"(\S+)\"/i );
				( $deck_switch{$1}="on on off" ) if( $line =~ /^\s*\?\s*set\s*\(\"(\S+)\"/i );	
			}elsif ( $tool eq "Hercules" ) {
				( $deck_switch{$1}="$2 $3 $4" ) if( $line =~ /^\s*VARIABLE\s+STRING\s+(\S+)\s*\=\s*\"(\S+)\"\s*\;\s*\/\*\s*(\S+)\s*or\s*(\S+)\s*\*\/\s*$/i );
				( $deck_switch{$1}="$2 $3 $4" ) if( $line =~ /^\s*VARIABLE\s+DOUBLE\s+(\S+)\s*\=\s*(\S+)\s*\;\s*\/\*\s*(\S+)\s*or\s*(\S+)\s*\*\/\s*$/i );
			}
		}
		close( DECK_IN );

		return %deck_switch;
	}
	return 0;
}


sub copyFile {
	my ( $file, $outp ) = @_;
	if( $file =~ /DFM$/ && ! -e $file ) {
		print "**INFO: No DFM effect\n";
	} elsif( ! -e $file ) { 
		print "**ERROR: Can not find $file\n";
	} else {
		print "**INFO: COPY $file to $outp\n";
		system("\\cp -r $file $outp");
	}
}

sub copyFiles {
	my ( $mode, $inp, $outp, $cci_flag, $qci_flag ) = @_;

	my $ctrl = 0;
	if( $cci_flag == 1 ) {
		$ctrl = 1;
	} elsif ( $qci_flag == 1 ) {
		$ctrl = 2;
	}

	&copyFile( "$inp/DFM", "$outp" ) if( $mode & $LVS_DECK and $inp =~ /LVS_DECK/i );
	if( $mode & $CAL && ($cci_flag == 0) && ($qci_flag == 0)) {
		&copyFile( "$inp/DFM", "$outp" ) unless( $mode & $LVS_DECK );
		&copyFile( "$inp/xrc_mapping", "$outp/xrc_mapping" ) if ( -e "$inp/xrc_mapping" );
    		&copyFile( "$inp/BA_mapping", "$outp/BA_mapping" ) if ( -e "$inp/BA_mapping" );
    		&copyFile( "$inp/xcell", "$outp/xcell" ) if ( -e "$inp/xcell" );
        } elsif( $mode & $CCI && ($cci_flag == 1) ) {
            &copyFile( "$inp/DFM"      ,  "$outp" ) unless( $mode & $LVS_DECK );
            &copyFile( "$inp/query_cmd",  "$outp" );
            if( $multiDev == 1 || $flickDev == 1 || $sheDev == 1 ) {  # update query_cmd for MULTI_DEVICE_EXTRACTION
                &modifyFileForMulit( "$outp/query_cmd", $ctrl );
            }
            &copyFile( "$inp/star_cmd" ,  "$outp" );
            &copyFile( "$inp/pin_file.txt", "$outp" ) if ( -e "$inp/pin_file.txt");
            &copyFile( "$inp/device_terminal_mapping.txt", "$outp" ) if ( -e "$inp/device_terminal_mapping.txt");
	} elsif( $mode & $QCI && ($qci_flag == 1) ) {
		&copyFile( "$inp/DFM"      ,  "$outp" ) unless( $mode & $LVS_DECK );
		&copyFile( "$inp/query.cmd",  "$outp" );
		&copyFile( "$inp/qci_qrc_cmd.ccl","$outp" ) if ( -e "$inp/qci_qrc_cmd.ccl" );
                if( $multiDev == 1 || $flickDev == 1 || $sheDev == 1 ) {  # update query_cmd for MULTI_DEVICE_EXTRACTION
		    &copyFile( "qci_qrc_cmd.ccl", "$outp" ) unless( $mode & $LVS_DECK );
	            &modifyFileForMulit( "$outp/query.cmd" , $ctrl );
	            &modifyFileForMulit( "$outp/qci_qrc_cmd.ccl", $ctrl );
		}
		#&copyFile( "$inp/capgen.cmd", "$outp" ); # covered by genLayerSetupCapGen
		#&copyFile( "$inp/layer_setup","$outp" ); # covered by genLayerSetupCapGen
		&copyFile( "$inp/lpe_confile","$outp" ) if ( -e "$inp/lpe_confile" );
		&copyFile( "$inp/hcell_qci","$outp" ) if ( -e "$inp/hcell_qci" );
	} elsif( $mode & $HER ) {
		&copyFile( "$inp/DFM"      ,  "$outp" );
		#&copyFile( "$inp/X_DEV.cmd", "$outp" );
		&copyFile( "$inp/star_cmd" ,  "$outp" );
		&copyFile( "$inp/pin_file.txt", "$outp" ) if ( -e "$inp/pin_file.txt");
		if( $gplus =~ /y/ ) {
			system("\\rm $outp/DFM/table/N40G_HER_DFM.table.en") if( -e "$outp/DFM/table/N40G_HER_DFM.table.en" );
		} else {
			system("\\rm $outp/DFM/table/N40GP_HER_DFM.table.en") if( -e "$outp/DFM/table/N40GP_HER_DFM.table.en" );
		}
	} elsif( $mode & $PVS ) {
		&copyFile( "$inp/DFM"      ,  "$outp" );
#		&copyFile( "$inp/query.cmd",  "$outp" );
#		&copyFile( "$inp/capgen.cmd", "$outp" ); # covered by genLayerSetupCapGen
#		&copyFile( "$inp/layer_setup","$outp" ); # covered by genLayerSetupCapGen
		&copyFile( "$inp/lpe_confile","$outp" ) if ( -e "$inp/lpe_confile" );
	} elsif( $mode & $Pegasus ) {
		&copyFile( "$inp/DFM"      ,  "$outp" );
		&copyFile( "$inp/lpe_confile","$outp" ) if ( -e "$inp/lpe_confile" );
	} elsif( $mode & $ICV ) {
		&copyFile( "$inp/DFM"        ,"$outp" );
		&copyFile( "$inp/star_cmd"   ,"$outp" ) if ( -e "$inp/star_cmd");
		&copyFile( "$inp/pin_file.txt", "$outp" ) if ( -e "$inp/pin_file.txt");
	}
}

sub readMfile {
	my @carr = ();
	my $c;
	open ( IN, "$mfile" ) || die("**ERROR: Can not find Mfile at \"$mfile\"! (in readMfile)\n");
	while( $c = <IN> ) {
		next if ( $c =~ /^\s*$/ );
		$c =~ s/\s+//;
		push(@carr, $c);	
	}
	chomp(@carr);	
	close( IN );
	return @carr;
}

sub readCfg {
	my ( $cfg ) = @_;	
	my $line, $mcomb, $nt ;
	my @carr = ();
	open( CFG, "$cfg" ) || die("**ERROR: Can not open Cfg file!\n");
	while( $line = <CFG> ) {
		chomp( $line );
		if( $line =~ /TOOL:\s*(\S+)\s*/i ){
			$nt=$1;
			$mode = $CAL if ( $nt =~ /^\s*Calibre\s*$/i );
			$mode = $CAL | $CCI | $QCI | $LVS_DECK if ( $nt =~ /^\s*Uni-Calibre\s*$/i );
			$mode = $CCI if ( $nt =~ /^\s*CCI\s*$/i );
			$mode = $HER if ( $nt =~ /^\s*Hercules\s*$/i );
			$mode = $ASU if ( $nt =~ /^\s*Assura\s*$/i );			
			$mode = $PVS if ( $nt =~ /^\s*PVS\s*$/i );			
			$mode = $Pegasus if ( $nt =~ /^\s*Pegasus\s*$/i );
			$mode = $ICV if ( $nt =~ /^\s*ICV\s*$/i );			
		}elsif( $line =~ /METAL_SCHEME:\s*(\d+M_\d+X.*)/i ) {
			$mcomb = $1;
			$mcomb =~ /(\d+M)_/i;
			$m = $1;
			@carr = split( /\s+/, $mcomb );
		}elsif( $line =~ /METAL_SCHEME:\s*ALL/i ) {
			die "**WARN: -all has been phase out, please don't use this option, thank you.\n";
		}elsif( $line =~ /USE_EDRAM:\s*(\S+)/i ) {
			$edram = $1;
		}elsif( $line =~ /SHPMIMCAP_OPTION:\s*(\d+)/i ) {
			$shpmimcap = $1;
			$w_shpmimcap_flag = 0;
		}elsif( $line =~ /SHDMIMCAP_OPTION:\s*(\d+)/i ) {
			$shdmimcap = $1;
			$w_shdmimcap_flag = 0;
		}elsif( $line =~ /MIMCAP_OPTION:\s*(\d+)/i ) {
			$mimcap = $1;
			$w_mimcap_flag = 0;
		}elsif( $line =~ /MULTI_DEVICE_EXTRACTION_OPTION:\s*(\d+)/i ) {
			$multiDev = $1;
			$w_multi_flag = 0;
		}elsif( $line =~ /FLICKER_CORNER_EXTRACTION_OPTION:\s*(\d+)/i ) {
			$flickDev = $1;
			$w_flick_flag = 0;
		}elsif( $line =~ /MOM_PARALLEL_MISMATCH_FLAG_OPTION:\s*(\d+)/i ) {
			$mTotalDev = $1;
			$w_mTotal_flag = 0;
		}elsif( $line =~ /SELF_HEATING_EFFECT_EXTRACTION_OPTION:\s*(\d+)/i ) {
			$sheDev = $1;
			$w_she_flag = 0;
		}elsif( $line =~ /SOIC_TYPE_OPTION:\s*(\d+)/i ) {
			$soicDev = $1;
			$w_soic_flag = 0;
		}elsif( $line =~ /SWITCH:/i ){
			$switch_start=1;
		}elsif( $switch_start == 1 ){
			if( !%toolvar ) {
			    &getSwitch( $nt, $m );
			}
			$line =~ /\s*(\S+)\s+(\S+)/;
			$toolvar{$1}=$2;
			if( $wlcspmode == 16003 ) {
				$wlcsp = "y" if(($1 eq "WLCSP") && $2 eq "on");
				$clvr = "y"  if(($1 eq "CLVR")  && $2 eq "on");
			}
		}
	}
	if( !%toolvar ) {
		&getSwitch( $nt, $m );
	}
	&setProcFlag();
	close( CFG );
	&gencfg($outcfg2,$nt,$mcomb);
	return @carr;
}

sub isInArray {
	my ( $item, @arr ) = @_;
	for $elem ( @arr ) {
		if( lc($item) eq lc($elem) ) {
			return 1;
		}
	}
	return 0 ;
}

sub findDN {
	my ( $file ) = @_;
	my $line;
	my $finish=0;
	my $dn = $pro = $ver = "NIL";
	my %toolver = ();
	open(IN, "$file") || print "**Error: Can not find $file! (in findDN) \n";
	while( $line = <IN> ) {
		if( $line =~ /([T|D]-N\d+\w*-\w+-\w+-\w+-\S+)/ ) { #support new doc number T-N07-CL-LS-XX1
			$dn = $1;
			$dn =~ /([T|D]-N\d+\w*-\w+-\w+-\w+)/;
			$dn2 = $1;
			$pro = $DNTable{$dn2};
			$finish ++;
		}
		if( $line =~ /COMMAND\s+FILE\s+VERSION\s*:\s*(\S+)/i || $line =~ /Tech File Ver:\s*(\S+)/ ) {
			$ver = $1;
			$finish ++;
		}
		if( $finish == 2 ) {
			print "**INFO: $dn ($pro) Version $ver\n";
			die "**ERROR: Can not get process number information, please check DNTable!(in findDN)\n" if(!$pro);
			last;
		}
	}
	close(IN);
	
	&ICV_missing_device_issue($dn) if($ARGV[0] !~ /^-internal_check|-cfg$/);
	
	return ($dn, $dn2, $pro, $ver);
}

sub findMim {
	my ( $file ) = @_;
	my $mim = 0;
	open(IN, "$file") || print "**Error: Can not find $file! (in findMim) \n";
	while( $line = <IN> ) {
		if( $line =~ /#define\s+MIMCAP_TYPE/ || $line =~ /VARIABLE\s+DOUBLE\s+MIMCAP_TYPE/ ) {
			print "**INFO: mimcap device detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);	
	return 0;
}

sub findshpMim {
	my ( $file ) = @_;
	
	open(IN, "$file") || print "**Error: Can not find $file! (in findshpMim) \n";
	while( $line = <IN> ) {
		if( $line =~ /mimcap_shp/i ) {
			print "**INFO: shpmimcap device detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);
	return 0;
}

sub findshdMim {
	my ( $file ) = @_;
	my $shdmim = 0;
	open(IN, "$file") || print "**Error: Can not find $file! (in findshdMim) \n";
	while( $line = <IN> ) {
		if( $line =~ /mimcap_sin_shd|mimcap_sin_fhd/i ) {
			print "**INFO: shdmimcap device detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);	
	return 0;
}

sub findMulti {
	my ( $file ) = @_;
	my $multi = 0;
	open(IN, "$file") || print "**Error: Can not find $file! (in findMulti) \n";
	while( $line = <IN> ) {
		if( $line =~ /#define\s+MULTI_DEVICE_EXTRACTION/  ) {
			print "**INFO: switch MULTI_DEVICE_EXTRACTION detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);	
	return 0;
}

sub findFlick {
	my ( $file ) = @_;
	open(IN, "$file") || print "**Error: Can not find $file! (in findFlick) \n";
	while( $line = <IN> ) {
		if( $line =~ /#define\s+FLICKER_CORNER_EXTRACTION/  ) {
			print "**INFO: switch FLICKER_CORNER_EXTRACTION detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);	
	return 0;
}

sub findMomTotal {
    my ( $file ) = @_;
    open(IN, "$file") || print "**Error: Can not find $file! (in findMomTotal) \n";
    while( $line = <IN> ) {
        if( $line =~ /#define\s+MOM_PARALLEL_MISMATCH_FLAG/  ) {
            print "**INFO: switch MOM_PARALLEL_MISMATCH_FLAG detected\n";
            close(IN);
            return 1; 
        }
    }
    close(IN);	
    return 0;
}

sub findSHE {
	my ( $file ) = @_;
	open(IN, "$file") || print "**Error: Can not find $file! (in findSHE) \n";
	while( $line = <IN> ) {
		if( $line =~ /#define\s+SELF_HEATING_EFFECT_EXTRACTION/  ) {
			print "**INFO: switch SELF_HEATING_EFFECT_EXTRACTION detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);	
	return 0;
}

sub findSOIC {
	my ( $file ) = @_;
	open(IN, "$file") || print "**Error: Can not find $file! (in findSOIC) \n";
	while( $line = <IN> ) {
		if( $line =~ /#define\s+SOIC_TYPE/  ) {
			print "**INFO: switch SOIC_TYPE detected\n";
			close(IN);
			return 1; 
		}
	}
	close(IN);	
	return 0;
}

sub getProcessInfo {
	my ( $mode ) = @_;
	my $deck,$file,$file2;
	my $find = 0;
	my $pro = "NIL";
	my $mim = 0;
	my $shpmim = 0;
	my $shdmim = 0;
	my $multi = 0;
	my $flick = 0;
	my $mTotal = 0;
	my $she = 0;
	my $soic = 0;
	my $dn, $dn2, $ver;
	my $edramProb;
	opendir( DIR, "$inpath" ) || print "**WARN: Can not find $inpath directory! (in getProcessInfo) \n"; 
	while( ($file = readdir(DIR)) && !$find ) {
		next if( $file =~ /^\./ || $file =~ /^\.\./ );
		# parse 2nd level directory
		if( -d "$inpath/$file" ) {
			opendir( DIR2, "$inpath/$file" );
			while( ($file2 = readdir(DIR2)) && !$find) {
				next if( $file2 =~ /^\./ || $file2 =~ /^\.\./ );
				($dn, $dn2, $pro, $ver) = &findDN( "$inpath/$file/$file2" ) ;
				if( $pro ne "NIL" ) {
					$find = 1;
				}
			}
			closedir( DIR2 );
		} else {
			($dn, $dn2, $pro, $ver) = &findDN( "$inpath/$file" );
			if( $pro ne "NIL" ) {
				$find = 1;
			}
		}
	}
	closedir( DIR );

	# For partial mimcap support.
	# For example, 4M deck does not have mimcap device but 5M deck does.
	opendir( DIR, "$inpath" ) || print "**WARN: Can not find $inpath directory! (in getProcessInfo) \n";
	while ( ($file = readdir(DIR)) && !$mim ) {
		next if( $file =~ /^\./ || $file =~ /^\.\./ );
		if( -d "$inpath/$file" ) {
			opendir( DIR2, "$inpath/$file" );
			while( ($file2 = readdir(DIR2)) && !$mim ) {
				next if( $file2 =~ /^\./ || $file2 =~ /^\.\./ );
				$mim = &findMim( "$inpath/$file/$file2" );
			}
			closedir( DIR2 );
		} else {
			$mim = &findMim( "$inpath/$file" );
		}		
	}
	closedir( DIR );

    # For shpmimcap support.
    opendir( DIR, "$inpath" ) || print "**WARN: Can not find $inpath directory! (in getProcessInfo) \n";
    while ( ($file = readdir(DIR)) && !$shpmim ) {
        next if( $file =~ /^\./ || $file =~ /^\.\./ );
        if( -d "$inpath/$file" ) {
            opendir( DIR2, "$inpath/$file" );
            while( ($file2 = readdir(DIR2)) && !$shpmim ) {
                next if( $file2 =~ /^\./ || $file2 =~ /^\.\./ );
                $shpmim = &findshpMim( "$inpath/$file/$file2" );
            }
            closedir( DIR2 );
        } else {
            $shpmim = &findshpMim( "$inpath/$file" );
        }        
    }
    closedir( DIR );
    
    unless($shpmim){
        if($no_need_mimcap_ques){
            $shdmim=0;
        }else{
            # For partial shdmimcap support.
            opendir( DIR, "$inpath" ) || print "**WARN: Can not find $inpath directory! (in getProcessInfo) \n";
            while ( ($file = readdir(DIR)) && !$shdmim ) {
                next if( $file =~ /^\./ || $file =~ /^\.\./ );
                if( -d "$inpath/$file" ) {
                    opendir( DIR2, "$inpath/$file" );
                    while( ($file2 = readdir(DIR2)) && !$shdmim ) {
                        next if( $file2 =~ /^\./ || $file2 =~ /^\.\./ );
                        $shdmim = &findshdMim( "$inpath/$file/$file2" );
                    }
                    closedir( DIR2 );
                } else {
                    $shdmim = &findshdMim( "$inpath/$file" );
                }
            }
            closedir( DIR );
        }
    }

	# Only query edram for the process >= 28 
	if( $pro =~ /(\d+)/ && $1 >= 28 && $pro ne "N40SOI" && $pro ne "N28CIS" && $pro ne "N28HV" && $pro ne "N55BCD" && $pro !~ /SIPH$/ ) { 
		$edramProb = 1;
	} else {
		$edramProb = 0;
	}

	opendir( DIR, "$inpath" ) || print "**WARN: Can not find $inpath directory! (in getProcessInfo) \n";
	while ( ($file = readdir(DIR)) && !($multi or $flick or $mTotal or $she) ) {
	        next if( $file =~ /^\./ || $file =~ /^\.\./ );
		if( -d "$inpath/$file" ) {
			opendir( DIR2, "$inpath/$file" );
			while( ($file2 = readdir(DIR2)) && !($multi or $flick or $mTotal or $she) ) {
				next if( $file2 =~ /^\./ || $file2 =~ /^\.\./ );
				$flick = &findFlick( "$inpath/$file/$file2" );
				$mTotal= &findMomTotal( "$inpath/$file/$file2" );
				$she   = &findSHE( "$inpath/$file/$file2" );
				$multi = &findMulti( "$inpath/$file/$file2" ) if(!($flick or $mTotal or $she));
				$soic  = &findSOIC( "$inpath/$file/$file2" );
			}
			closedir( DIR2 );
		} else {
			$flick = &findFlick( "$inpath/$file" );
			$mTotal= &findMomTotal( "$inpath/$file" );
			$she   = &findSHE( "$inpath/$file" );
			$multi = &findMulti( "$inpath/$file" ) if(!($flick or $mTotal or $she));
			$soic  = &findSOIC( "$inpath/$file" );
		}
	}
	closedir( DIR );
     

	return ($dn, $dn2, $pro, $ver, $mim, $shpmim, $shdmim, $edramProb, $multi, $flick, $mTotal, $she, $soic);
}



sub getMetal {
	my $ms;
	my @mhash = ();
	for my $ms ( @support ) {
		if( $ms =~ /(\d+M)_/i ) {
			$mhash{$1}=1;	
		}
	}
	return sort {$a <=> $b} keys %mhash;
}

sub getAvail {
	my ($m) = @_;
	my @av  = ();
	for my $ms ( @support ) {
		if( $ms =~ /\b${m}_/i ) {
			push( @av, $ms );
		}
	}
	return @av;
}

sub findEDAVersion {
	my ( $file ) = @_;
	my $line;
	my $toolstr;
	open(IN, "$file") || print "**Error: Can not find $file! (in findEDAVersion) \n";
	while( $line = <IN> ) {
		if( $line =~ /EDA\s+TOOL\s+VERSION\s*:\s*(.*)/i ) {
			$toolstr = $1;
			chomp($toolstr);
			return $toolstr;
			close(IN);
			last;
		}
	}
	close(IN);
	return "NIL";
}

sub getEDAVersion {
	my $toolstr = "";
	my @toolarr = ();
	my %toolhash = ();
	my $version;
	opendir( DIR, "$inpath" ) || print "**WARN: Can not find $inpath directory! (in getEDAVersion) \n"; 
	while( ($file = readdir(DIR)) && !$find ) {
		next if( $file =~ /^\./ || $file =~ /^\.\./ );
		# parse 2nd level directory
		if( -d "$inpath/$file" ) {
			opendir( DIR2, "$inpath/$file" );
			while( ($file2 = readdir(DIR2)) && !$find) {
				next if( $file2 =~ /^\./ || $file2 =~ /^\.\./ );
				$version = &findEDAVersion( "$inpath/$file/$file2" ) ;
				if( $version ne "NIL" ){
					$toolstr .= " $version";
			 		last;
				}
			}
			closedir( DIR2 );
		} else {
			$version = &findEDAVersion( "$inpath/$file" );
			if( $version ne "NIL" ) {
				$toolstr .= " $version";
				last;
			}
		}
	}
	closedir( DIR );
	$toolstr =~ s/;/ /g;
	$toolstr =~ s/^\s*//;
	$toolstr =~ s/\s*$//;
	@toolarr = split( /\s+/, $toolstr );
	for( my $i = 0; $i < @toolarr; $i = $i+2 ) {
		my $j = $i + 1;
		my $toolname = $toolarr[$i];
		my $toolversion = $toolarr[$j];
		$toolname = "StarRCXT" if( $toolname =~ /Star/i );
		$toolhash{"$toolname : $toolversion"} = 1;
	}
	return %toolhash;
}

sub printEDAVersion {
	my ( $pt ) = @_;
	my %toolhash = %{$pt};
	print QLOG "\n";
	print QLOG "EDA_Tools\n";
	for $tool (keys %toolhash)  {
		print QLOG "$tool\n";
	}
}

sub printSelfTest {
	print QLOG "\n";
	print QLOG "SELFTEST\n";
	print QLOG "Program : LVS_Verify.pl\n";
	print QLOG "SuccessMessage : PASS\n";
	print QLOG "ErrorMessage : FAIL\n";
}

sub genUntarTreeFile {
	my $line;
	open(UNTAR, ">$untarTreeFile") || die("**ERROR: Can not open $untarTreeFile to write! (in genUntarTreeFile) \n");
	system("find . >& $untarTreeFile.tmp");
	open(FIND, "$untarTreeFile.tmp");
	while( $line = <FIND> ) {
		chomp($line);
		next if( $line =~ /^\.$/ || $line =~ /^\.\.$/ );
		next if( -d $line );
		next if( $line =~ /$untarTreeFile/ );
		next if( $line =~ /\.tar\.gz/ );
		next if( $line =~ /QAReport/i );
		next if( $line =~ /TSMC_DOC_WM/i );
		next if( $line =~ /$INTFILE/i );
		next if( $line =~ /integration_lvs\.xml/i );
		if( $line =~ /^\.\// ) {
			$line =~ s/^\.\//PACKAGE_PATH\//;
		}
		print UNTAR $line,"\n";
	}
	system("\\rm $untarTreeFile.tmp"); 
	close(FIND);	
	close(UNTAR);
}

sub translateToXML {
	if( ! -e $cfg2xml ) {
		die("**ERROR: Can not find $cfg2xml file to do XML translation! (in translateToXML)");
	}
	system("$cfg2xml LVS_Install.int LVS\n");
	system("\\rm LVS_Install.int");
	system("\\rm $untarTreeFile");
}

sub genWrapper {
	system("$genWrapperProgram -process $process -doc $DN") if( -e $genWrapperProgram );
}

sub calculateMx{
    my ( $c ) = @_;
    my $mx;
    while( $c =~ s/(\d+)x[a-z]*//i ){
	    $mx += $1;
    }
    $mx++;
    return $mx;
}

sub calculateMlee{
    my ( $c ) = @_;
    my $mlee;
    while( $c =~ s/(\d+)x[a-z]*//i ){
	    $mlee += $1;
    }
    while( $c =~ s/(\d+)y[a-v]+//i ){
	    $mlee += $1;
    }
    while( $c =~ s/(\d+)y\d+//i ){
	    $mlee += $1;
    }

    $mlee++;
    return $mlee;
}

sub calculateMy{
    my ( $c, $mx ) = @_;
    my ($mya,$myb)=(0,0);
    my %my_info;
    my ($my_high,$my_level)=(0,0);
    $my_high += $mx;
    
    while( $c =~ s/(\d+)(y[a-z]*)//i ){
	    my ($num,$name)=($1,$2);
	    $my_high += $num;
	    $my_info{lc($name)}{level}=$num;
	    $my_info{lc($name)}{high}=$my_high;
    }

    $mya=$my_info{ya}{high};
    $myb=$my_info{yb}{high};
    if( ($mya+$my_info{yb}{level}) !=  $myb){
	    return -1;
    }

    return $mya+1;
}

sub modifyDataType{
	my ( $tool, $line )=@_;
	my $addNum=30000;
	my $out;
	
	if( $tool eq "cal" ){
		my @words=split(/\s+/,$line);
		foreach my $tmp (@words){
			if( $tmp =~ /^(\d+)$/i ){
				my( $ori_dt ) = ( $1 );
				if( $ori_dt <= $addNum ){
					my $dt=$ori_dt+$addNum;
					$line =~ s/(\s+)$ori_dt\b/$1$dt/i;
				}else{
					die "**ERROR: Please do not use layer number bigger than $addNum which are reserved layers.\n";
				}
			}
		}
	} elsif ( $tool eq "pvs" || $tool eq "pegasus" ){
		my @words=split(/\s+/,$line);
		foreach my $tmp (@words){
			if( $tmp =~ /^(\d+)[;]?/i ){
				my( $ori_dt ) = ( $1 );
				if( $ori_dt <= $addNum ){
					my $dt=$ori_dt+$addNum;
					$line =~ s/(\s+)$ori_dt/$1$dt/i;
				}else{
					die "**ERROR: Please do not use layer number bigger than $addNum which are reserved layers.\n";
				}
			}
		}
	} elsif ( $tool eq "icv" ){
		my @words=split(/\}/,$line);
		foreach my $tmp (@words){
			if( $tmp =~ /(\d+)\s*\,\s*(\d+)/i ){
				my ($metal,$ori_dt)=($1,$2);
				if( $ori_dt <= $addNum ){
					my $dt=$ori_dt+$addNum;
					$line =~ s/($metal\s*\,\s*)$ori_dt(\s*\})/$1$dt$2/i;
					$out .= "($metal,$dt) ";
				}else{
					die "**ERROR: Please do not use layer number bigger than $addNum which are reserved layers.\n";
				}
			}
		}
#		printf RL ("**INFO : %-10s  $out\n",$1) if( $line =~ /^\s*(\S+)\s*=\s*assign\(/i ) ;
	}
	print RL "**INFO : $line";
	return $line;
}

sub getWlcspMode {
	my ( $docNum ) = @_;
	if( $docNum =~ /T-N16-CL-LS-003/i ) {
		return 16003;
		#return 1;
	} else {
		return 0;
	}
}

sub FindAdditional{
    my ($metal, $metal_wi_thickness, $path, $out)=@_;
    
    #$metal_wi_thickness => 14M_1X1Xb1Xc1Xd1Ya1Yb3Y2Yy2Z
    #$metal              => 14M
    my $add_thickness=0;    
    opendir( DIR2, $path ) || print "**WARN: Can not find $path directory!\n";
    while( my $file = readdir( DIR2 ) ) {
        if($file =~ /_\d+M_\d/){ #additional_erc_check_14M_1X1Xb1Xc1Xd1Ya1Yb3Y2Yy2Z
            $add_thickness=1;
            last;
        }
    }
    closedir( DIR2 );
    
    my $chk_metal= ($add_thickness)? $metal_wi_thickness : $metal;
    
    opendir( DIR1, $path ) || print "**WARN: Can not find $path directory!\n";
    while( my $file = readdir( DIR1 ) ) {
        next if( $file =~ /^\./ || $file =~ /^\.\./ );
        if( $file =~ /(?<!\d)$chk_metal/i ) {
#	        print "**INFO: Found ADDITIONAL_ERC_CHECK $file\n";
            system("\\cp -rf $path/$file $out");
            $add_file=$file;
            &extraHandle($path, $out);
        }
    }
    closedir( DIR1 );
    return $add_file;
}

sub ICV_missing_device_issue{
    my ($process)=@_;
    if( $process =~ /N(\d+)/i && ( ($1 <= 20 && $1 > 16) || ($1>7 && $1<12 ) ) && $process =~ /\-J/) { #2020.07.20, skip N12/N16 node
	my $icv_ans = &queryYN($icv_issue_msg, $GENMODE, "yes", "no" );
	die "\n**Error: You can not install ICV deck without read and understood this alert! \n\n" if($icv_ans =~ /NO/i);
    }
}


sub getMetalColor{
    my ($metal,$process,$doc) = @_;
    
    my @mList=();     # save metal thick
    my @colorList=(); # judge is color or not, 0:no color, 1: color    
    
    if($metal =~/\d+M_(.*)/i){
        my $metal=$1;
        $mList[0]=-1; #M0
        $mList[1]=-1; #M1
        while( $metal =~ s/(\d+)([a-z]+)//i){
            my $num=$1;
            my $thick=$2;
            for (my $i=0;$i<$num;$i++){
                push @mList, $thick;
            }
        }
        
        if($process =~ /N(\d+)/i && $1 <= 3){ #install no handle
            $colorList[0]=-1;
            $colorList[1]=-1;
        }elsif($doc =~ /^T-N07-CL-LS-00(8|9)$/){ # M0 color + M1 no color
            $colorList[0]=1;
            $colorList[1]=0;
        }else{ # N4~N10 M0/M1 has color, install will remove layer
            $colorList[0]=1; 
            $colorList[1]=1;
        }
        
        for(my $i=2;$i<@mList;$i++){
            if((($process eq 'N3'||$process eq 'N2') && $mList[$i] =~/^x(b|c)$/i) || ($process eq 'N2' && $mList[$i] =~ /^xf$/i) || $mList[$i] =~/^x(s|t)$/i){ #xs for N7Plus
                $colorList[$i]=0;
            }elsif($mList[$i] =~/^x/i){
                $colorList[$i]=1;
            }else{
                $colorList[$i]=0;
            }
        }
    }
        
    return @colorList;
}

sub isWrapper {
    return 0;
}
    
sub isAdditional {
    return 0;
}
    
sub isRmxHardName {
    return 0;
}
    
sub isMergeMimcapOption {
    return 0;
}
    
sub getMimcapQuesVer {
    return "V1";
}
    
sub isSFT {
    return 0;
}
    
sub isNoNeedMimcapQues {
    return 0;
}
    
sub extraHandle{
    my ($path, $out)=@_;
    
}
