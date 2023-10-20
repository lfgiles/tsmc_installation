#!/usr/intel/bin/python3.6.3a

import UsrIntel.R1 # to use pre-installed package see: https://soco.intel.com/blogs/linux_tool_tips/2018/07/09/how-to-run-python-and-use-third-party-packages-at-intel-as-of-2018ww28
import os
import errno
import re
from collections import namedtuple



class RsffileGenerator:
    '''
    TODO:
    - [ ] rework the how the attirbute 'self.copy_obj_file' is manage through th methode.  
          confusion between string and list.

    Class to parse template rsf and create the right rsf file for ams and dig flow
    - update perc report name
    - update variable power and ground
    - update input file and svrf if only on topo
    - update include file
    - ams
        - add at the beginnig !#tvf + tvf::VERBATIM {}
        - add the hidden switch for every DEFINE
        - setup switc according to the parameter
        - set oasis or schematic
        - setup_path to include file
        - update variable power and ground
        - think about how to manage pad_info
    - r2g
        - template on the top
        - add at the beginnig !#tvf + tvf::VERBATIM {}
        - setup_path to include file with lync
        - add the hidden switch for every DEFINE + comment every switch
        - manage pad_info
    '''
    def __init__(self, path_to_rsf_template, metalStack, **kwargs):        
        self.metalStack = metalStack
        self.template_path = path_to_rsf_template
        self.rsfdir_path = os.path.dirname(self.template_path)
        os.chdir(self.rsfdir_path)
        with open(self.template_path, 'rt') as infile:
            self.copy_obj_file = infile.read() # !!! Need to be rework since I change the type of this attribut with a methode :-(
            self.template_txt = self.copy_obj_file  
        infile.closed
        self.__dict__.update(kwargs)
        #for key, value in kwargs.items:
        #    setattr(self, key, value)

    def update_with_header_footer(self, header, footer, file = None):
        '''
        Return a copy of the attribut self.copy_obj_file with header and footer added
        '''
        if file is None:
            file = self.copy_obj_file
        self.copy_obj_file = header + file + footer
        return self.copy_obj_file
    def update_svrf_define_ams(self, file = None):
        '''
        update switch ("#DEFINE") statement inside the rsf file according the dictionary params_rsf
        !!! The type of 'self.copy_obj_file' is change here from string to list
        '''
        if file is None:            
            file = self.copy_obj_file
        copy_obj_file2 = [] #to be write        
        for line in file.split("\n"):
            ## --- RSF DEFINE SWITCH ---
            # should match svrf code line suche as: '//#DEFINE CD    // Turn on to enable CD(Current Density) checks'
            pattern_define = '^(\/\/)?#DEFINE (\w+) *(\/\/(.*))?'
            #pattern_define = '\/\/?#DEFINE'            
            match_define = re.match(pattern_define, line)
            if match_define is not None:                                
                svrf_switch = match_define.group(2) # key for the dictionnary "switches" like "TOPO"

                if svrf_switch in self.switches.keys():
                    #activ_switch = match.group(1) # match "//"if return None then the switch is activ
                    if match_define.group(3) is not None:
                        svrf_comments = match_define.group(3)  #match the comment if there is comment
                    else:
                        svrf_comments = ""
                    # get activ switch from the dictionnaryimport re
                    if self.switches.get(svrf_switch):
                        newline = "#DEFINE " + svrf_switch + " " + svrf_comments
                    else:
                        newline = "//#DEFINE " + svrf_switch + " " + svrf_comments
                    copy_obj_file2.append(newline + '\n')                    
            else:
                copy_obj_file2.append(line + '\n')
        self.copy_obj_file = copy_obj_file2        
        return self.copy_obj_file
    def update_svrf_include_ams(self, file = None):
        '''
        adapt INCLUDE PATH to the structure of the TP
        '''
        runset_path = 'runset/PERC/TSMC'
        if file is None:            
            file = self.copy_obj_file
        copy_obj_file2 = [] #to be written        
        for line in file:
            pattern_include = r'(^ *INCLUDE )"(\S*)"'
            match_include = re.match(pattern_include, line)
            if match_include is not None:
                indent_include = match_include.group(1)
                path_to_include_file = match_include.group(2)
                if "tsmc_lib" in path_to_include_file:
                    #add a tvf section inside the svrf part
                    newline = '}\n\n' + indent_include + '"' + re.sub('\.', runset_path, path_to_include_file,1) +'"' + '    //EXPLICIT_RUNSET' + '\n\n' + 'tvf::VEBATIM {\n'
                else:
                    pattern_path = '\./' + self.metalStack.percName.upper() 
                    newline = indent_include + '"' + re.sub(pattern_path, runset_path, path_to_include_file,1) + '"' + '    //EXPLICIT_RUNSET\n'                    
                copy_obj_file2.append(newline)
            else:
                copy_obj_file2.append(line)
        self.copy_obj_file = copy_obj_file2        
        return self.copy_obj_file
    def update_power_ground(self, file = None):
        '''
        update the svrf variable POWER_NAME and GROUND_NAME
        '''
        runset_path = 'runset/PERC/TSMC'
        if file is None:            
            file = self.copy_obj_file
        copy_obj_file2 = [] #to be written        
        for line in file:
            pattern_svrf_power = r'(^ *VARIABLE POWER_NAME )'
            power_list = ["VDD", "vdd", "vcc", "AHVDD", "AHVDDB", "AHVDDG", "AHVDDR", "AHVDDWELL", "AVDD", "AVDDB", "AVDDBG", "AVDDG", "AVDDR", "AVDWELL", "DHVDD", "DVDD", "HVDDWELL", "TACVDD", "TAVD33", "TAVD33PST", "TAVDD", "TAVDDPST", "TVDD", "VD33", "VDD?", "VDD5V", "VDDESD", "VDDG", "VDDM", "VDDPST", "VDDSA", "VDWELL", "vdd?", "vcc?", "VCC?"]
            pattern_svrf_ground = r'(^ *VARIABLE GROUND_NAME )'
            ground_list = ["VSS", "vss", "gnd", "AGND", "AHVSS", "AHVSSB", "AHVSSG", "AHVSSR", "AHVSSUB", "AVSS", "AVSSB", "AVSSBG", "AVSSG", "AVSSR", "AVSSUB", "DHVSS", "DVSS", "GND", "HVSSUB", "TACVSS", "TAVSS", "TAVSSPST", "TVSS", "VS33", "VSS?", "VSSESD", "VSSG", "VSSM", "VSSPST", "VSSUB", "vss?"]
            match_power = re.match(pattern_svrf_power, line)
            match_ground = re.match(pattern_svrf_ground, line)
            if match_power is not None:
                newline = 'VARIABLE POWER_NAME ' + '"' + '" "'.join(power_list) + '"' + '\n'
                copy_obj_file2.append(newline)
            elif match_ground is not None:
                newline = 'VARIABLE GROUND_NAME ' + '"' + '" "'.join(ground_list) + '"' + '\n'
                copy_obj_file2.append(newline)
            else:
                copy_obj_file2.append(line)
        self.copy_obj_file = copy_obj_file2        
        return self.copy_obj_file
    def create_new_file(self, file = None):
        if file is None:
            file = self.copy_obj_file
        if self.r2g:
            rsf_filename = os.path.join(self.rsfdir_path,"RSF_digital_" + "perc_" + self.name)
        else: 
            rsf_filename = os.path.join(self.rsfdir_path,"RSF_" + "perc_" + self.name)        
        with open(rsf_filename, 'wt') as outfile:
            outfile.writelines(file)
'''
    def _create_perc_RSF_from_params(self):
      
        # --- NAME OF 
        if self.r2g:
            rsf_filename = os.path.join(self.rsfdir_path,"RSF_digital" + self.name)
        else: 
            rsf_filename = os.path.join(self.rsfdir_path,"RSF_" + self.name)
        
        with open(self.rsf_filename, 'wt') as outfile:
            ## --- ADD TVF AND VERBATIM HEADER --- -->need methode for that with argument: file path; header; footer
            
            outfile.write(tvfheader)
            with open(self.template_path, 'rt') as infile:        
                for line in self.template_txt:
                    ## --- RSF DEFINE SWITCH ---
                    pattern_define = r'^(//)?#DEFINE (\w+) *(//(.*))?'
                    match_define = re.match(pattern_define, line)
                    if match_define is not None:
                        svrf_switch = match.group(2) # key for the dictionnary "switches" like "TOPO"
                        if svrf_switch in self.switches.keys():
                            #activ_switch = match.group(1) # match "//"if return None then the switch is activ
                            if match.group(3) is not None:
                                svrf_comments = match.group(3)  #match the comment if there is comment
                            else:
                                svrf_comments = ""
                            
                            if self.switches.get(svrf_switch):
                                newline = "#DEFINE" + svrf_switch + svrf_comments
                            else:
                                newline = "//#DEFINE" + svrf_switch + svrf_comments
                            outfile.write(newline)
                    ### --- adapt INCLUDE PATH ---
                    pattern_include = r'(^ *INCLUDE )"(\S*)"'
                    match_include = re.match(pattern_include, line)
                    elif match_include is not None:
                        indent_include = match_include.group(1)
                        path_to_include_file = match_include.group(2)
                        if "tsmc_lib" in path_to_include_file:
                            newline = indent_include + '"' + re.sub('\.','runset/PERC/TSMC' ,path_to_include_file,1) +'"' + '    //EXPLICIT_RUNSET'
                        elif ".rules" in path_to_include_file:
                            = indent_include + '"' + re.sub('\.','runset/PERC/TSMC' ,path_to_include_file,1) +'"' + '    //EXPLICIT_RUNSET'
                            continue
                        else:
                            pattern_path = '\./' + self.metalStack.percName.upper() 
                            newline = indent_include + '"' + re.sub(pattern_path,'runset/PERC/TSMC' ,path_to_include_file,1) +'"' + '    //EXPLICIT_RUNSET'
                        outfile.write(newline)
                    ### --- NO CHANGE ON THE LINE NEEDED ---
                    else:
                        outfile.write(line)

            outfile.write(tvfheader)
'''
# create tmp <metalstack> with top file by running perl install user+config
#def create_install_rundir(metalstack)


# create delivery structure parameter: metal stack
# rework .top file to create rsf file

def main():

    MetalStack = namedtuple('MetalStack', 'nbMetal, tpName, lvsName, percName')

    metalStack15 = MetalStack(15,'1P15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R','15M_1X1Xa1Ya5Y2Yy2Yx2R','1p15M_1X1Xa1Ya5Y2Yy2Yx2R')

    path2template = '/nfs/imu/proj/tec/tptest/INandOUT/n7/Greenland/prepare_tsmc_perc/tp/1P15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/rsf/RSF_perc_esd_template'

    params_rsf_ldl = {
        'name': 'esd_ldl_tsmc', 
        #build with .rep for report and RSF_perc, RSF_digital_perc
        'r2g': 0,
        'input': 'layout',
        'switches': {
            'TOPO': 0, #no default
            'LDL': 1, #no default
            'CD': 0, #no default
            'P2P': 0, #no default
            'CD_PRE_CHECK': 1, #no default
            'P2P_PRE_CHECK': 1, #no default
            'CDM_7A': 0,
            'CDM_9A': 0,
            'CDM_14A': 0,
            'Hi_CDM': 1,
            'IN_DIE_MODE': 0, #no default
            'GROUP_PWR_CLAMP': 0, #no default
            'DEFINE SET_PWR_CLAMP_RON': 0,
            'CHECK_FULL_PATH_CD': 0,
            'CHECK_VICTIM_CD': 0,
            'CHECK_FULL_PATH_P2P': 0, #no default
            'CHECK_PICK_UP_P2P': 0,
            'CREATE_PAD_BY_TEXT': 0,
            'DISABLE_IODMY': 0,
            'EXPORT_ONE_VICTIM': 0
        } 
    }

    rsf_header = '''#!tvf

                proc INCLUDE {path {comment "dummy"}} {
                puts "sourcing $path"
                if [catch {uplevel "source $path"} msg] {
                    puts $msg
                    exit 1
                    }
                }

                namespace import tvf::*

                tvf::VEBATIM {
                '''.replace('    ','')
    rsf_footer = '''
                }
                #end of VERBATIM
                '''.replace('    ','')
    
    rsfGen = RsffileGenerator(path2template, metalStack15, **params_rsf_ldl)
    rsfGen.update_with_header_footer(rsf_header, rsf_footer)
    rsfGen.update_svrf_define_ams()
    rsfGen.update_svrf_include_ams()
    rsfGen.update_power_ground()
    rsfGen.create_new_file()
    #- for topo change to schematic input and svdb
    #-
    #os.system('ls')
    os.system('tree ..')


# 1. comment define
# 2. create header for dig
# 3. update include path



if __name__ == '__main__': main()
