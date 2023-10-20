#!/usr/local/bin/perl -w

use strict;
use Cwd;
use Cwd 'abs_path';
use Term::ANSIColor qw(:constants);
use File::Basename;
use Data::Dumper;

my $TECHNOLOGY = 'N03';
my %TSMC_METAL_OPTIONS = ( 'N03' => [ 'x', 'xb', 'xc', 'xd', 'ya', 'yb', 'y', 'yy', 'yx', 'z', 'r', 'u' ] );
my %TSMC_FILE_STRUCTURE = ( 'TOP' => "perc_".lc $TECHNOLOGY.".top", 'LVS' => "perc_".lc $TECHNOLOGY.".lvs", 'MAP' => "perc_".lc $TECHNOLOGY.".map", 'PEXMAP' => "pex_map.rules", 'PAD' => 'pad_info.rules', 'RO' => "perc_".lc $TECHNOLOGY.".ro" );
my $libdir = "tsmc_lib";

my $usage = "Usage: $0 <user configuration file>";
my $pkgdir = dirname $0;

&showErrorAndExit( $usage ) if( @ARGV == 0 );
my $config = $ARGV[ 0 ];
&showErrorAndExit( "\"$config\" does not exist.\n        $usage" ) if( !-e $config );

my $usrdb = &getConfiguration( $config );
my $progdb = undef;
##print Data::Dumper -> Dump( [ $usrdb ], [ "*usrdb" ] );

# sanity check
my @must_items = ( 'METAL_SCHEME', 'INSTALLATION_PATH', 'LVS_(FILE|PACKAGE_DIRECTORY)' );
my $missing_items = &checkItemExistence( $usrdb, \@must_items );
&showErrorAndExit( "Please confirm the following items: @$missing_items" ) if( @$missing_items > 0 );

my $package_path = abs_path($pkgdir) ;
my $install_path = $usrdb->{INSTALLATION_PATH} ;
my $sub_path = index($install_path, $package_path) ;
&showErrorAndExit( "INSTALLATION_PATH cannot under Package path:\nPackage: $package_path\nInstall: $install_path\n" ) if( $sub_path != -1 );

# follow up check
#&showErrorAndExit( "$usrdb->{INSTALLATION_PATH} exists, please confirm it" ) if( -e $usrdb -> { 'INSTALLATION_PATH' } );
if( defined $usrdb -> { 'LVS_FILE' } ) {
  &showErrorAndExit( "'MAP_FILE' is not defined" ) unless( defined $usrdb->{ 'MAP_FILE' } );
  @{ $progdb -> { 'METAL_SCHEME' } } = uc $usrdb -> { 'METAL_SCHEME' };
  &showErrorAndExit( "Multiple metal scheme is not allowed: $usrdb->{ 'METAL_SCHEME' }" ) if( $usrdb->{ 'METAL_SCHEME' } =~ /,/ );
}
if( defined $usrdb -> { 'LVS_PACKAGE_DIRECTORY' } ) {
  @{ $progdb -> { 'METAL_SCHEME' } } = split( /\s*,\s*/, uc $usrdb -> { 'METAL_SCHEME' } );
}

foreach my $mt ( @{ $progdb -> { 'METAL_SCHEME' } } ) {
  my @mts_errors = &checkMetalScheme( $mt, $TSMC_METAL_OPTIONS{ $TECHNOLOGY } );
  &showErrorAndExit( "Please confirm @mts_errors" ) if( @mts_errors > 0 );
  #&showErrorAndExit( "$usrdb->{INSTALLATION_PATH}/$mt exists, please confirm it" ) if( -e "$usrdb->{INSTALLATION_PATH}/$mt" );
}

# LVS
if( defined $usrdb -> { 'LVS_FILE' } ) {
##print "$usrdb->{METAL_SCHEME}\n";
  $progdb -> { 'LVS_FILE' } -> { uc $usrdb -> { 'METAL_SCHEME' } } = abs_path( $usrdb -> { 'LVS_FILE' } );
  $progdb -> { 'MAP_FILE' } -> { uc $usrdb -> { 'METAL_SCHEME' } } = abs_path( $usrdb -> { 'MAP_FILE' } );
}
if( defined $usrdb -> { 'LVS_PACKAGE_DIRECTORY' } ) {
  foreach my $mt ( @{ $progdb -> { 'METAL_SCHEME' } } ) {
    my $mt_ = $mt;
    $mt_ =~ s/_sh[dp]mim\d?//i;
    $mt_ =~ s/_ut-/_/i;
    my $lvs_deck = &getLVSDeckByMetalScheme( $usrdb -> { 'LVS_PACKAGE_DIRECTORY' }, $mt_ );
    if( !defined $lvs_deck ) {
      &showErrorAndExit( "$mt\'s corresponding LVS deck does not exist" );
    } else {
      $progdb -> { 'LVS_FILE' } -> { $mt } = abs_path( $lvs_deck );
    }
    $mt_ =~ s/_[^_]+rdl//i;
    my $map_file = &getMapFileByMetalScheme( $usrdb -> { 'LVS_PACKAGE_DIRECTORY' }, $mt_ );
    if( !defined $map_file ) {
      &showErrorAndExit( "$mt\'s corresponding Map file does not exist" );
    } else {
      $progdb -> { 'MAP_FILE' } -> { $mt } = abs_path( $map_file );
    }
  }
}
##print Data::Dumper -> Dump( [ $usrdb ], [ "*usrdb" ] );
##print Data::Dumper -> Dump( [ $progdb], [ "*progdb" ] );

# R-only
foreach my $mt ( @{ $progdb -> { 'METAL_SCHEME' } } ) {
  &showErrorAndExit( "RDL type is not defined in '$mt'" ) unless($mt =~ /rdl$/i);
  my $ro_file = &getRoFileByMetalScheme( $usrdb -> { 'LVS_PACKAGE_DIRECTORY' }, $mt );
  if( !defined $ro_file ) {
    &showErrorAndExit( "$mt\'s corresponding R-only file does not exist" );
  } else {
    $progdb -> { 'RO_FILE' } -> { $mt } = abs_path( $ro_file );
  }
}

# prepare database
system("mkdir -p $usrdb->{INSTALLATION_PATH}" ) if( !-d $usrdb -> { 'INSTALLATION_PATH' } );
my $self = $0;
$self =~ s/^.*\///;
foreach my $e ( glob( "$pkgdir/*" ) ) {
  next if ($e =~ /$self/);
  system( "cp -rf $e $usrdb->{INSTALLATION_PATH}" );
}

# replace reserved file path
foreach my $file ( glob( "$usrdb->{INSTALLATION_PATH}/$libdir/*" ) ) {
  foreach my $item ( 'INSTALLATION_PATH' ) {
    if( `grep  '<$item>' $file` !~ /^\s*$/ ) {
        system "sed -i 's:<$item>:$usrdb->{$item}:g' $file";
    }
  }
}

foreach my $mt ( @{ $progdb -> { 'METAL_SCHEME' } } ) {
  my $dir = "$usrdb->{INSTALLATION_PATH}/$mt";
  system( "rm -rf $dir" ) if( -d $dir );
  system( "mkdir $dir" );
  # modify LVS/MAP/Ro deck
  &modifyLVSDeck( $progdb -> { 'LVS_FILE' } -> { $mt } , "$usrdb->{INSTALLATION_PATH}/$mt/$TSMC_FILE_STRUCTURE{LVS}", "$usrdb->{SKIP_NET_SPLITTER}", "$usrdb->{SKIP_INDUCTOR}", "$usrdb->{SKIP_MOM_CAPACITOR}", "$usrdb->{SKIP_MIM_CAPACITOR}" );
  &modifyMapFile( $progdb -> { 'MAP_FILE' } -> { $mt } , "$usrdb->{INSTALLATION_PATH}/$mt/$TSMC_FILE_STRUCTURE{MAP}" );
  &modifyRoFile( $progdb -> { 'RO_FILE' } -> { $mt } , "$usrdb->{INSTALLATION_PATH}/$mt/$TSMC_FILE_STRUCTURE{RO}" );
  # modify PEX MAP file
  &modifyPEXMAPDeck( "$usrdb->{INSTALLATION_PATH}/$libdir/$TSMC_FILE_STRUCTURE{PEXMAP}", "$usrdb->{INSTALLATION_PATH}/$mt/$TSMC_FILE_STRUCTURE{PEXMAP}", $mt );
  ##system( "rm $usrdb->{INSTALLATION_PATH}/$libdir/$TSMC_FILE_STRUCTURE{PEXMAP}");
  # modify top rule
  &modifyTopDeck( $mt, "$usrdb->{INSTALLATION_PATH}/$libdir/$TSMC_FILE_STRUCTURE{TOP}", "$usrdb->{INSTALLATION_PATH}/$mt/$TSMC_FILE_STRUCTURE{TOP}", '<METAL_SCHEME>', $mt );
  ##system( "rm $usrdb->{INSTALLATION_PATH}/$libdir/$TSMC_FILE_STRUCTURE{TOP}");
  # modify pad file
  &modifyPadInfo( "$usrdb->{INSTALLATION_PATH}/$libdir/$TSMC_FILE_STRUCTURE{PAD}", "$usrdb->{INSTALLATION_PATH}/$mt/$TSMC_FILE_STRUCTURE{PAD}", "$usrdb->{PORT_LAYER}", "$usrdb->{TOP_PORT_ONLY}", $mt );
  ##system( "rm $usrdb->{INSTALLATION_PATH}/$libdir/$TSMC_FILE_STRUCTURE{PAD}");

}













sub getConfiguration {
  my ( $file ) = @_;
  my $lines = &parseFile( $file );
  my %db = ( 'PORT_LAYER' => '', 'TOP_PORT_ONLY' => 'y', 'SKIP_NET_SPLITTER' => 'y', 'SKIP_INDUCTOR' => 'y', 'SKIP_MOM_CAPACITOR' => 'y', 'SKIP_MIM_CAPACITOR' => 'y' );

  for( my $i = 0; $i < @$lines; ++ $i ) {
    my $line = $$lines[ $i ];
    $line = $1 if( $line =~ /^([^#]*)#/ );
    next if( $line =~ /^\s*$/ );
    $db{ $1 } = $2 if( $line =~ /\s*(\w+)\s*=\s*(.+)/ );
  }
##print Data::Dumper -> Dump( [ \%db ], [ "*db" ] );
  return \%db;
}

sub parseFile {
  my ( $file, $keep ) = @_;
  my @lines = ();
  open FILE, $file or &showErrorAndExit( "Fail to open \"$file\"" );
  while( <FILE> ) {
    chomp;
    $_ =~ s/^\s+|\s+$//g unless ( defined $keep );
##    $_ =~ s/\s+/ /g;
    push @lines, $_;
  }
  close FILE;
  return \@lines;
}

sub writeFile {
  my ( $file, $lines ) = @_;
  open FILE, ">$file" or &showErrorAndExit( "Fail to write to \"$file\"" );
  foreach my $line ( @$lines ) {
    print FILE "$line\n";
  }
  close FILE;
}

sub showInformation {
  my ( $msg, $color ) = @_;
  print $color, $msg, RESET, "\n";
}

sub showErrorAndExit {
  my ( $msg ) = @_;
  &showInformation( "[ERROR] $msg", RED );
  exit 1;
}

sub checkItemExistence {
  my ( $db, $items ) = @_;
  my %items = ();
  my @lack = ();
  foreach my $item ( @$items ) {
    my $bedefined = 0;
    foreach my $prop ( keys %$db ) {
      if( $prop =~ /^$item$/ ) {
        $bedefined = 1;
        last;
      }
    }
    push @lack, $item if( $bedefined != 1 );
  }
  return \@lack;
}

sub checkMetalScheme {
  my ( $mts, $valid_metal_options ) = @_;
  my @errors = ();
  if( $mts !~ /(\d+)p(\d+)m_((\d+[a-z]+)+)/i ) {
    push @errors, "incorrect metal scheme format"
  } else {
    my ( $si, $top_metal, $sch ) = ( $1, $2, $3 );
    my $cnt = 1;
    while( $sch =~ /(\d+)([a-z]+)/ig ) {
      my ( $num, $type ) = ( $1, $2 );
      $cnt += $num;
      push @errors, "$type is not a valid metal option" unless( grep /^$type$/i, @$valid_metal_options );
    }
    push @errors, "Incorrect metal scheme of $mts ( metal count )" if( $top_metal != $cnt );
  }
  return @errors;
}

sub getLVSDeckByMetalScheme {
  my ( $pkg, $metal_scheme ) = @_;
  my $search_path = "$pkg/MAIN_DECK/LVS_DECK";
  $search_path = "$pkg/MAIN_DECK/CALIBRE_FLOW" unless (-d $search_path);
  &showErrorAndExit( "LVS: $search_path does not exist !" ) unless (-d $search_path);
  return &searchFileByRegexp( $search_path, "LVS.*$metal_scheme" );
}

sub getMapFileByMetalScheme {
  my ( $pkg, $metal_scheme ) = @_;
  $metal_scheme =~ s/^\d+P//i ;
  my $search_path = "$pkg/MAIN_DECK/CALIBRE_FLOW";
  &showErrorAndExit( "MAP: $search_path does not exist !" ) unless (-d $search_path);
  return &searchFileByRegexp( $search_path, "map.*$metal_scheme" );
}

sub getRoFileByMetalScheme {
  my ( $pkg, $metal_scheme ) = @_;
  my $search_path = "$pkgdir/tsmc_ro";
  &showErrorAndExit( "R-only: $search_path does not exist !" ) unless (-d $search_path);
  return &searchFileByRegexp( $search_path, "$metal_scheme" );
}

sub searchFileByRegexp {
  my ( $dir, $reg ) = @_;
  my @candidates = glob( "$dir/*" );
  foreach my $candidate ( @candidates ) {
  ##print "cand $candidate [$reg]\n";
    return $candidate if( $candidate =~ /$reg/i );
  }
  return undef;
}

sub mapMetalScheme {
  my ( $mts, $valid_metal_options ) = @_;
  $mts =~ /(\d+)p(\d+)m_((\d+[a-z]+)+)([\w-]*)$/i;
  $mts = $3;
  my $rdl = $5;
  my $mtop = $2;
  ## my $schemes = $TSMC_METAL_SCHEMES{ $TECHNOLOGY } ;
  my $reg_mts = join( '|', sort { length $b <=> length $a } @$valid_metal_options ); $reg_mts = "($reg_mts)";

  my $cnt = 1;
  my %mts = ( 'VD2' => [29, 'VD2', 'VD2'], 'M0' => [30, 'M0', '0'], 'M1' => [31, 'M1', '1'] );
  while( $mts =~ /(\d+)($reg_mts)/ig ) {
    my ( $num, $type ) = ( $1, $2 );
    for( my $i = 1; $i <= $num; ++$i ) {
      ++$cnt;
      my $map = "M".(uc $type);
      $mts{ "M$cnt" } = [($cnt+30), $map, (uc $type)];
      ## &showErrorAndExit( "M$cnt($map) is not supported yet !" ) unless ( grep /^$map$/, @$schemes );
    }
  }
  if ( $rdl =~ /curdl/i ) {
    $mts{ 'Cu_RDL' } = [($mtop+31), "Cu_RDL", "Cu_RDL"];
  } else {
    $mts{ 'AP' } = [($mtop+31), "AP", "AP"];
  }
  $mts{ 'VG' } = [47, "VG", "VC"];
  $mts{ 'VD' } = [48, "VD", "VC"];
  $mts{ 'VIA0' } = [50, "VIA0", "0"];

  $mts{ 'RV_BPC_TPC' } = [$mtop+51, "RV_BPC_TPC", "RV"];
  $mts{ 'RV_MPC_RDL' } = [$mtop+51, "RV_MPC_RDL", "RV"];
  $mts{ 'RV_MTOP_BPC' } = [$mtop+51, "RV_MTOP_BPC", "RV"];
  $mts{ 'RV_MTOP_MPC' } = [$mtop+51, "RV_MTOP_MPC", "RV"];
  $mts{ 'RV_TPC_RDL' } = [$mtop+51, "RV_TPC_RDL", "RV"];
  
  for( my $i = 1; $i < $mtop; ++ $i ) {
    my $j = $i + 1;
    my $map = $mts{ "M$i" }->[1]."__".$mts{ "M$j" }->[1] ;
    $mts{ "VIA$i" } = [($i+50), $map, $mts{ "M$j" }->[2]];
    $mts{ "VTIN_$i" } = [($i+50), $map, $mts{ "M$j" }->[2]] if ( $i != 1 );
    ## &showErrorAndExit( "VIA$i($map) is not supported yet !" ) unless ( grep /^$map$/, @$schemes );
  }
  if ( $rdl =~ /curdl/i ) {
    $mts{ 'Cu_RV' } = [($mtop+50), $mts{ "M$mtop" }->[1]."__".$mts{ 'Cu_RDL' }->[1], "Cu_RV"];
  } else {
    $mts{ 'RV' } = [($mtop+50), $mts{ "M$mtop" }->[1]."__".$mts{ 'AP' }->[1], "RV"];
  }
##print Data::Dumper -> Dump( [ \%mts ], [ "*mts" ] );
  return \%mts;
}

sub modifyLVSDeck {
  my ( $deck_in, $deck_out, $skip_nsp, $skip_ind, $skip_mom, $skip_mim ) = @_;
  my @reg_off = ( '#define\s+(FLICKER_CORNER_EXTRACTION|SELF_HEATING_EFFECT_EXTRACTION|FILTER_MPODE|VT_LOP)',
                  '#define\s+\w+_DFM_RULE', '#define\s+\w+_CHECK',
                  'VARIABLE\s+(POWER|GROUND)', '(TEXT|PORT)\s+DEPTH', 'LVS\s+(ISOLATE|REPORT\s+OPTION\s+S)', 'INCLUDE\s+', 'PEX\s+BA',
                  'LVS\s+PUSH\s+DEVICES', 'VT\w+_lop' );

  my @resistors = () ;
  my @inductors = () ;
  my @diodes = ();
  my @rhims = ();

  $skip_nsp = ( $skip_nsp =~ /y/i ) ? 1 : 0;
  $skip_ind = ( $skip_ind =~ /y/i ) ? 1 : 0;
  $skip_mom = ( $skip_mom =~ /y/i ) ? 1 : 0;
  $skip_mim = ( $skip_mim =~ /y/i ) ? 1 : 0;

  my $counter = 0;
  my $mapped_layer = 0;
  my $lvs = &parseFile( $deck_in );
  foreach my $line ( @$lvs ) {
    # disable LVS options
    foreach my $reg ( @reg_off ) {
      if( $line =~ /^\s*$reg/i ) {
        $line = "//$line"; last;
      }
    }
    # disable net splitter, re-map to 9999
    if( $line =~ /^(\s*LAYER\s+RMDMY\w+)\s+(\d+\s*)/i ) {
      $line = "$1 9999 // $2" if ($skip_nsp);
    }
    # disable inductor, re-map to 9999
    if( $line =~ /^(\s*LAYER\s+INDDMY)\s+(\d+\s*)/i ) {
      $line = "$1 9999 // $2" if ($skip_ind);
    }
    # disable MOM capacitor, re-map to 9999
    if( $line =~ /^(\s*LAYER\s+RTMOMDMY)\s+(\d+\s*)/i || $line =~ /^(\s*LAYER\s+MOMDMY\w+)\s+(\d+\s*)/i) {
      $counter = $counter + 1;
      $mapped_layer = 9999 - $counter;
      $line = "$1 $mapped_layer // $2" if ($skip_mom);
    }
    # disable MIM capacitor, re-map to 9999
    if ($skip_mim) {
      if( $line =~ /^(\s*LAYER\s+TPCDMY_AP)\s+(\d+\s*)/i ) {
        $line = "$1 9999 // $2";
      } elsif( $line =~ /^(\s*LAYER\s+TPCDMY_Cu)\s+(\d+\s*)/i ) {
        $line = "$1 9999 // $2";
      } elsif( $line =~ /^(\s*LAYER\s+PMIM_1)\s+(\d+\s*)/i ) {
        $counter = $counter + 1;
        $mapped_layer = 9999 - $counter;
        $line = "$1 $mapped_layer // $2";
      } elsif( $line =~ /^(\s*LAYER\s+PMIM_2)\s+(\d+\s*)/i ) {
        $counter = $counter + 1;
        $mapped_layer = 9999 - $counter;
        $line = "$1 $mapped_layer // $2";
      } elsif( $line =~ /^(\s*LAYER\s+PMIM_2_1)\s+(\d+\s*)/i ) {
        $counter = $counter + 1;
        $mapped_layer = 9999 - $counter;
        $line = "$1 $mapped_layer // $2";
      }
    }

    # collect net splitter list
    if($line =~ /^\s*DEVICE\s+(rmsp)/i && $skip_nsp) {
      my $res = $1;
      push @resistors, $res unless( grep /^$res$/i, @resistors );
    # collect inductor list
    } elsif($line =~ /^\s*DEVICE\s+(spiral_\w+)/i && $skip_ind) {
      my $ind = $1;
      push @inductors, $ind unless( grep /^$ind$/i, @inductors );
    # collect diode list
    } elsif( $line =~ /^\s*DEVICE\s+((n|p)dio_\w+)/i ) {
      my $dio = $1;
      push @diodes, $dio unless( grep /^$dio$/i, @diodes );
    # collect rhim list
    } elsif( $line =~ /^\s*DEVICE\s+.*\s+RH_TN_(\d+)/i ) {
      my $rhim = $1;
      push @rhims, $rhim unless( grep /^$rhim$/i, @rhims );
    }
  }

  # RC_DFM_RULE/XACT_DFM_RULE option handling for runtime enhancement
  my @opts = ();
  my %optno = ();
  for( my $i = 0; $i < @$lvs; ++ $i ) {
    my $line = $$lvs[ $i ];
    if( $line =~ /^\s*(#IFN?DEF)\s+(\w+)/i ) {
      my $opt = $2;
      push @opts, $opt;
      $optno{ $opt } = $i;
    } elsif( $line =~ /^\s*#ENDIF/i ) {
      my $opt = pop @opts;
      delete $optno{ $opt };
    } elsif( $line =~ /include\s+.+\/dfm_device/i ) {
      $$lvs[ $optno{ 'RC_FLOW' } ] =~ s/RC_FLOW\b/RC_FLOWx/ if (defined $optno{ 'RC_FLOW' });
      $$lvs[ $optno{ 'RC_DFM_RULE' } ] =~ s/RC_DFM_RULE\b/RC_DFM_RULEx/ if (defined $optno{ 'RC_DFM_RULE' });
    }
  }

  # disable metal resistor for netlist input
  push @$lvs, "\ntvf::VERBATIM {";
  push @$lvs, "  RES200_rh = RES200 AND RH_TNi";
  push @$lvs, "  RES200_r$_ = (RES200_rh INTERACT RH_TN_$_) INTERACT VTIN_".($_-1) foreach (@rhims);
  push @$lvs, "  DEVICE RES200_D RES200_r$_ RH_TN_$_(PLUS) RH_TN_$_(MINUS) (PLUS MINUS)" foreach (@rhims);
  push @$lvs, "";
  push @$lvs, "  LVS FILTER $_ SHORT" foreach (@resistors);
  push @$lvs, "  LVS FILTER $_ SHORT TOP BOTTOM" foreach (@inductors);
  push @$lvs, "";
  push @$lvs, "  LVS DEVICE TYPE NMOS LDDN";
  push @$lvs, "  LVS MAP DEVICE rhim rhim(rhim)";
  push @$lvs, "  LVS DEVICE TYPE DIODE @diodes [POS=PLUS NEG=MINUS]";
  push @$lvs, "  LVS MAP DEVICE $_ $_($_)" foreach (@diodes);
  push @$lvs, "}\n";

  &writeFile( $deck_out, $lvs );
}

sub modifyMapFile {
  my ( $deck_in, $deck_out ) = @_;

  my $map = &parseFile( $deck_in );
  foreach my $line ( @$map ) {
    # disable PEX IGNORE
    if( $line =~ /^\s*PEX\s+IGNORE/i ) {
      $line = "// $line";
    } elsif( $line =~ /^\s*PEX\s+MAP\s+(RH_TN_(\d+))\s+(RH_TN_\d+)/i ) {
      $line = "// $line\nPEX MAP M$2 $3" if ( $1 eq $3 );
    }
  }

  &writeFile( $deck_out, $map );
}

sub modifyRoFile {
  my ( $deck_in, $deck_out ) = @_;
  system "cp $deck_in $deck_out" ;
  system "sed -i 's:^\\s*\\(PEX RESISTANCE.*psub\\):// \\1:' $deck_out";
}

sub modifyPEXMAPDeck {
  my ( $deck_in, $deck_out, $mts ) = @_;
  my $bump = "AP";
  $bump = "Cu_RDL" if ( $mts =~ /CURDL/i );
  my $mts_opt = &mapMetalScheme( $mts, $TSMC_METAL_OPTIONS{ $TECHNOLOGY } );
  my @pex = @{ &parseFile( $deck_in ) };

  foreach my $line ( @pex ) {
    $line =~ s/\<BUMP\>/$bump/;
  }
  foreach my $layer ( sort {$mts_opt->{$a}->[0]<=>$mts_opt->{$b}->[0]} keys %$mts_opt ) {
    my $val = "";
    my $type = $mts_opt->{$layer}->[2];
    if( $layer =~ /^M\d+$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_M$type";
      push @pex, "PERC LDL CD $layer\_A CONSTRAINT VALUE IMAX_M$type";
      push @pex, "PERC LDL CD $layer\_B CONSTRAINT VALUE IMAX_M$type";
    } elsif( $layer =~ /^AP$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_$type";
    } elsif( $layer =~ /^Cu_RDL$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_$type";
    } elsif( $layer =~ /^VD(2|R)$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_$type";
    } elsif( $layer =~ /^V(G|D)$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_$type/$type\_W_1/$type\_W_1";
    } elsif( $layer =~ /^VIA\d+$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_VIA$type/VIA$type\_W_1/VIA$type\_W_1";
    } elsif( $layer =~ /^VTIN_\d+$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_VIA$type/VIA$type\_W_1/VIA$type\_W_1";
    } elsif( $layer =~ /^RV/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_$type/$type\_W_1/$type\_W_1";
    } elsif( $layer =~ /^Cu_RV$/i ) {
      push @pex, "PERC LDL CD $layer CONSTRAINT VALUE IMAX_$type/$type\_W_1/$type\_W_1";
    } else {
      &showErrorAndExit( "unknown layer '$layer'\n" );
    }
  }
  push @pex, "";

  &writeFile( $deck_out, \@pex );
}

sub modifyTopDeck {
  my ( $mt, $deck_in, $deck_out, $s1, $s2 ) = @_;
  my $bump = "AP";
  $bump = "Cu_RDL" if ( $mt =~ /CURDL/i );
  my $lines = &parseFile( $deck_in, 1 );
  foreach my $line ( @$lines ) {
    $line =~ s/$s1/$s2/;
    $line =~ s/\<BUMP\>/$bump/;
  }
  $mt =~ s/(\d)([A-Z])([A-Z])/$1.$2.lc($3)/ge ;
  $mt =~ s/(_sh[d|p]mim\d?)?_[^_]+rdl$//i;
  $deck_out =~ s/\.top/_$mt\.top/ ;
  &writeFile( $deck_out, $lines );
  &showInformation( "[INFO] Top file for $mt \"$deck_out\" is generated.....", GREEN );
}

sub modifyPadInfo {
  my ( $deck_in, $deck_out, $ports, $primary_only, $mts ) = @_;
  $ports = [split( /\s+/, $ports)] ;
  my @pad = ();
  my $mtop = $1 if( $mts =~ /\dp(\d+)m/i );
  push @pad, "// =====================================";
  push @pad, "// =  Create Pseudo PAD by Text        =";
  push @pad, "// =====================================";
  push @pad, "\n// Note: This part effect only when 'CREATE_PAD_BY_TEXT' option in '$TSMC_FILE_STRUCTURE{TOP}' is enabled.\n";
  push @pad, "#IFDEF CREATE_PAD_BY_TEXT";

  foreach my $layer ( @$ports ) {
    my $number = ( $layer =~ /^M(\d+)/ )? $1: 0;
    my $lc_layer = lc $layer;
    next if( $number > $mtop );
    my $secondary = ( $primary_only =~ /y/i )? "PRIMARY ONLY": "";
    push @pad, "// $layer Pseudo PAD";
    foreach my $type ( 'SIGNAL', 'POWER', 'GROUND' ) {
      push @pad, "$type\_PAD_$layer = EXPAND TEXT $type\_NAME $layer\_text BY 0.001 $secondary";
    }
    push @pad, "P2P_PAD_$layer = OR SIGNAL_PAD_$layer POWER_PAD_$layer GROUND_PAD_$layer",
               "CONNECT $layer P2P_PAD_$layer",
               "DEVICE PAD_D(d_pseudo_$lc_layer) P2P_PAD_$layer P2P_PAD_$layer (PAD_PIN)";
  }
  push @pad, "#ENDIF\n";
  @pad = () if( @$ports == 0 ) ;

  push @pad, @{ &parseFile( $deck_in ) };
  &writeFile( $deck_out, \@pad );
}


