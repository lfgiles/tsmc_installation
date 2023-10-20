import pprint
import copy
import re
import os


class TplGenRunset(object):

    def __init__(self, cfgdict):
        self.cfg = copy.deepcopy(cfgdict)
        self.tpl_lines = []        
        self.lines0 = []
        self.lines1 = []
        self.lines2 = []
        self.lines3 = []
        self.lines4 = []
        self.lines5 = []
        self.lines6 = []
        self.lines7 = []
        fh = open(self.cfg['TEMPLATE'], 'r')
        for line in fh:
            self.tpl_lines.append(line[:-1])
        fh.close()
        self.switches = set(self.cfg['SWITCHES'].keys())
        self._check_cfgswitches_in_tpl()        
        if self.cfg['R2G']:
            # - [x] add header '#!tvf+ proc INCLUDE...' and footer:}
            self._disable_switches_step0()
            self._add_tev_step1()
            self._update_include_path_r2g_step2()
            # - [x] desactivate include pad_info step5
        else:
            # - [x] add header '#!tvf+ proc INCLUDE...' and footer:}
            self._set_switches_step0()
            self._add_tev_step1()
            # - [x] add '//hidden switch' option for define not in
            #self.lines1 = self.lines0[:]
            self._update_include_path_ams_step2()
        self._update_power_ground_step3()
        self._update_report_step4()
        self._update_layout_format_step5()
        self._disable_pad_info_step6()
        self._update_input_step7()
        
        # - [x] set oasis
        # - [ ] set for schematic -> new input

        # - [ ] directory structure for tp

    def _find_switch_in_line(self, line):
        if '#DEFINE' not in line:
            return ''
        a0 = line.split('#DEFINE')
        a1 = a0[1].split()
        return a1[0]


    def _check_cfgswitches_in_tpl(self):
        chk_dict = dict()
        for k in self.cfg['SWITCHES']:
            chk_dict[k] = 0
        for line in self.tpl_lines:
            sw = self._find_switch_in_line(line)
            if sw == '':
                continue
            for k in chk_dict:
                if k == sw:
                    chk_dict[k] += 1
        for k in chk_dict:
            if chk_dict[k] == 0:
                print(f'Error: key {k} not found in template')
            if chk_dict[k] > 1:
                print(f'Error: key {k} found more than once')

    def _disable_switches_step0(self):
        for line in self.tpl_lines:
            sw = self._find_switch_in_line(line)
            if sw == '':
                self.lines0.append(line)
                continue
            elif sw not in self.switches:                
                self.lines0.append(line)
                continue
            else:
                if not line.startswith('//'):
                    self.lines0.append('//' + line)
                else:
                    self.lines0.append(line)

    def _set_switches_step0(self):
        key_for_flow_hidden = 'hidden switch'
        key_for_flow_off = 'default_off '
        key_for_flow_on = 'default_on '
        for line in self.tpl_lines:
            sw = self._find_switch_in_line(line)
            if sw == '':
                self.lines0.append(line)
                continue
            elif sw not in self.switches:
                # need to add svrf comment "//hidden switch for the ams flow"
                if line.startswith('//'):
                    self.lines0.append(line.replace(sw,sw + ' //' + key_for_flow_off + key_for_flow_hidden))
                else:
                    self.lines0.append(line.replace(sw,sw + ' //' + key_for_flow_on + key_for_flow_hidden))
                continue
            else:
                sw_flag = self.cfg['SWITCHES'][sw]
                if line.startswith('//'):
                    line = line.lstrip('/')

                if sw_flag == True:
                    self.lines0.append(line.replace(sw,sw + ' //' + key_for_flow_on,1))
                else:
                    self.lines0.append('//' + line.replace(sw, sw + ' //' + key_for_flow_off,1))
                continue

    def _add_tev_step1(self):
        sepnum = 60
        self.lines1.append('#!tvf')
        self.lines1.append('')
        if self.cfg['R2G']:
            self.lines1.append('## ' + '-' * sepnum)
            self.lines1.append('## TEV_START')
            self.lines1.append('## ' + '-' * sepnum)
            self.lines1.append('')
            for sw in self.cfg['SWITCHES']:
                self.lines1.append(f'## NAME: TEV(RS_SWITCH_{sw})')
                self.lines1.append(f'## TYPE: boolean')
                self.lines1.append(f'## INFO:')
                self.lines1.append(f'## * Turn on-off TSMC switch "{sw}"')
                if self.cfg['SWITCHES'][sw]:
                    self.lines1.append(f'set TEV(RS_SWITCH_{sw}) "1"')
                else:
                    self.lines1.append(f'set TEV(RS_SWITCH_{sw}) "0"')
                self.lines1.append('')
            self.lines1.append(f'## NAME: TEV(RS_PATH_PAD_INFO)')
            self.lines1.append(f'## TYPE: path to txt file')
            self.lines1.append(f'## INFO:')
            self.lines1.append(f'## * set pad voltage & pad text. template available in calibre/<metalstack>/runset/PERC/TSMC')
            self.lines1.append(f'set TEV(RS_PAD_INFO) ""')
            self.lines1.append('')
            self.lines1.append('## ' + '-' * sepnum)
            self.lines1.append('## TEV_STOP')
            self.lines1.append('## ' + '-' * sepnum)
        self.lines1.append('')
        self.lines1.append('')
        self.lines1.append('namespace import tvf::*')
        self.lines1.append('')
        self.lines1.append('proc INCLUDE {path {comment "dummy"}} {')
        self.lines1.append('    puts "sourcing $path"')
        self.lines1.append('    if [catch {uplevel "source $path"} msg] {')
        self.lines1.append('        puts $msg')
        self.lines1.append('        exit 1')
        self.lines1.append('    }')
        self.lines1.append('}')
        self.lines1.append('')
        self.lines1.append('tvf::VERBATIM {')
        for line in self.lines0:
            self.lines1.append(line)
        self.lines1.append('}')

    def _update_include_path_ams_step2(self):
        runset_path = self.cfg['INCLUDE_AMS_BASEDIR']
        pattern_path = '\./' + self.cfg['MSpercName'].upper()
        pattern_include = r'(^ *INCLUDE )"(\S*)"'
        for line in self.lines1:
            if not re.match(pattern_include,line):
                self.lines2.append(line)
                continue
            else:
                match_include = re.match(pattern_include, line)
                print(line)
                indent_include = match_include.group(1)                
                path_to_include_file = match_include.group(2)
                if "tsmc_lib" in path_to_include_file:
                    # add a tvf section inside the svrf part
                    newline = '}\n' \
                        + indent_include \
                        + '"' \
                        + re.sub('\.', runset_path, path_to_include_file, 1) \
                        + '"' \
                        + '    ;#//EXPLICIT_RUNSET //default_on' + '\n\n' + 'tvf::VERBATIM {\n'
                else:
                    newline = indent_include \
                        + '"' \
                        + re.sub(pattern_path, runset_path, path_to_include_file, 1) \
                        + '"' \
                        + '    //EXPLICIT_RUNSET //default_on\n'
                self.lines2.append(newline)                    

    def _update_include_path_r2g_step2(self):
        runset_path_r2g_tvf = self.cfg['INCLUDE_R2G_BASEDIR'] + self.cfg['MStpName'] + '/'
        runset_path_r2g_svrf = self.cfg['INCLUDE_R2G_BASEDIR'].replace("env(","").replace(")","") + self.cfg['MStpName'] + '/'
        runset_path = self.cfg['INCLUDE_AMS_BASEDIR']
        pattern_path = '\./' + self.cfg['MSpercName'].upper()
        pattern_include = r'(^ *INCLUDE )"(\S*)"'
        for line in self.lines1:
            if not re.match(pattern_include,line):
                self.lines2.append(line)
                continue
            else:
                match_include = re.match(pattern_include, line)
                indent_include = match_include.group(1)
                path_to_include_file = match_include.group(2)
                if "tsmc_lib" in path_to_include_file:
                    # add a tvf section inside the svrf part
                    newline = '}\n' \
                        + indent_include \
                        + '"' \
                        + runset_path_r2g_tvf \
                        + re.sub('\.', runset_path, path_to_include_file, 1) \
                        + '"\n\n' \
                        + 'tvf::VERBATIM {'
                else:
                    newline = indent_include \
                        + '"' \
                        + runset_path_r2g_svrf \
                        + re.sub(pattern_path, runset_path, path_to_include_file, 1) \
                        + '"\n'
                self.lines2.append(newline)

    def _update_power_ground_step3(self):
        '''
        update the svrf variable POWER_NAME and GROUND_NAME
        '''
        pattern_svrf_power = r'(^ *VARIABLE POWER_NAME )'
        pattern_svrf_ground = r'(^ *VARIABLE GROUND_NAME )'
        power_list = self.cfg['POWER']
        ground_list = self.cfg['GROUND']
        
        for line in self.lines2:
            if 'VARIABLE' not in line:
                self.lines3.append(line)
                continue
            match_power = re.match(pattern_svrf_power, line)
            match_ground = re.match(pattern_svrf_ground, line)
            if match_power is not None:
                newline = 'VARIABLE POWER_NAME ' + '"' + '" "'.join(power_list) + '"  ' + '//default_on' +'\n'
                self.lines3.append(newline)
            elif match_ground is not None:
                newline = 'VARIABLE GROUND_NAME ' + '"' + '" "'.join(ground_list) + '"  ' + '//default_on' +'\n'
                self.lines3.append(newline)
            else:
                self.lines3.append(line)

    def _update_report_step4(self):        
        for line in self.lines3:
            if 'perc.rep' in line:
                if self.cfg['R2G']:
                    new_report_name = f"perc_digital_{self.cfg['RSFNAME']}.rep"
                else:
                    new_report_name = f"perc_{self.cfg['RSFNAME']}.rep"
                newline = re.sub('perc.rep', new_report_name, line)
                self.lines4.append(newline)
            else:
                self.lines4.append(line)

    def _update_layout_format_step5(self, layout_format='OASIS'):
        for line in self.lines4:
            if 'LAYOUT SYSTEM GDSII' not in line:
                self.lines5.append(line)
            else:
                newline = re.sub('GDSII', layout_format, line)
                self.lines5.append(newline)

    def _disable_pad_info_step6(self):
        for line in self.lines5:            
            if 'pad_info.rules' not in line:
                self.lines6.append(line)                
                continue
            if self.cfg['R2G']:
                if not line.startswith('##'):                    
                    self.lines6.append('//' + line)
            else:
                self.lines6.append(line)

    def _update_input_step7(self):
        for line in self.lines6:
            if self.cfg['R2G'] :
                #input in r2g is defined by the flow
                if 'LAYOUT SYSTEM ' in line:
                    self.lines7.append('//' + line)
                    continue
                elif 'LAYOUT PATH ' in line:
                    self.lines7.append('//' + line)
                    continue
                elif 'LAYOUT PRIMARY ' in line:
                    self.lines7.append('//' + line)
                    continue
                elif 'PERC NETLIST LAYOUT' in line:
                    if self.cfg['INPUT'] == 'layout' and self.cfg['RSFNAME'] != 'esd_topo_tsmc':
                        self.lines7.append(line)
                        continue
                    elif self.cfg['RSFNAME'] == 'esd_topo_tsmc':
                        newline2 = 'MASK SVDB DIRECTORY "svdb" QUERY'
                        self.lines7.append('')
                        self.lines7.append(newline2)
                    else:
                        newline = re.sub('LAYOUT', 'SOURCE', line)
                        self.lines7.append(newline)
                        newline2 = 'MASK SVDB DIRECTORY "svdb" QUERY'
                        self.lines7.append('')
                        self.lines7.append(newline2)
                else:
                    self.lines7.append(line)
            else:
                #AMS scenario
                if self.cfg['INPUT'] == 'layout' and self.cfg['RSFNAME'] != 'esd_topo_tsmc':
                    self.lines7.append(line)
                    continue
                elif self.cfg['RSFNAME'] == 'esd_topo_tsmc':
                    if 'PERC NETLIST LAYOUT' in line:
                        newline2 = 'MASK SVDB DIRECTORY "svdb" QUERY'
                        self.lines7.append('')
                        self.lines7.append(newline2)
                    else:
                        self.lines7.append(line)
                elif self.cfg['INPUT'] == 'schematic':
                    if 'LAYOUT SYSTEM ' in line:
                        newline = 'SOURCE SYSTEM SPICE'
                        self.lines7.append(newline)
                    elif 'LAYOUT PATH ' in line:
                        newline = 'SOURCE PATH ""'
                        self.lines7.append(newline)
                    elif 'LAYOUT PRIMARY ' in line:
                        newline = 'SOURCE PRIMARY ""'
                        self.lines7.append(newline)
                    elif 'PERC NETLIST LAYOUT' in line:
                        newline = re.sub('LAYOUT', 'SOURCE', line)
                        self.lines7.append(newline)
                        newline2 = 'MASK SVDB DIRECTORY "svdb" QUERY'
                        self.lines7.append('')
                        self.lines7.append(newline2)
                    else:
                        self.lines7.append(line)
                else:
                    print('error wrong value in cfg for INPUT')
            
    def print_template(self):
        for line in self.tpl_lines:
            print(line)

    def print_cfg(self, fn):
        fh = open(fn, 'w')
        pprint.pprint(self.cfg, stream=fh)
        fh.close()

    def dump_rsf(self):
        #fn = f"{self.cfg['DESTPATH']}/calibre/{self.cfg['MStpName']}/rsf/"
        fn = f"{self.cfg['DESTPATH']}/"
        assert os.path.exists(fn)
        if self.cfg['R2G']:
            fn += f"RSF_digital_perc_{self.cfg['RSFNAME']}"
        else:
            fn += f"RSF_perc_{self.cfg['RSFNAME']}"
        print(f'dumping Runset {fn}')
        fh = open(fn, 'w')
        for line in self.lines7:
            print(line, file=fh)
        fh.close()
