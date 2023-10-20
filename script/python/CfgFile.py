
import pprint
import copy


class CfgFile(object):

    def __init__(self, cfg_fn):
        fh = open(cfg_fn, 'r')
        self.cfg0 = eval(fh.read())
        fh.close()
        self.cfg1 = dict()
        self.cfg2 = dict()
        self._cfg0_to_cfg1()
        self._cfg1_to_cfg2()

    def get_destpath(self):
        return self.cfg0['GLOBAL']['DESTPATH']

    def get_metalstack_dirs(self):
        ret = []
        for ms in self.cfg0['GLOBAL']['METAL_STACK']:
            ret.append(ms['tpName'])
        return ret

    def get_runsets(self):
        return sorted(self.cfg2.keys())

    def get_cfg_of_runset(self, rst):
        assert rst in self.cfg2
        return self.cfg2[rst]

    def _cfg0_to_cfg1(self):
        # need to be updated!
        for runset in self.cfg0['LOCAL']:
            if runset['R2G']:
                rskey = f"{runset['RSFNAME']}_digital"
            else:
                rskey = f"{runset['RSFNAME']}_analog"
            self.cfg1[rskey] = copy.deepcopy(self.cfg0['GLOBAL'])
            for k in runset:
                if isinstance(runset[k], dict):
                    self.cfg1[rskey][k].update(runset[k])
                elif isinstance(runset[k], list):
                    self.cfg1[rskey][k] = runset[k][:]
                else:
                    self.cfg1[rskey][k] = runset[k]

    def _cfg1_to_cfg2(self):
        for runset in self.cfg1:
            for ms in self.cfg1[runset]['METAL_STACK']:
                runsetms = f"{runset}_M{ms['nbMetal']}"
                self.cfg2[runsetms] = copy.deepcopy(self.cfg1[runset])
                for k in ms:                    
                    self.cfg2[runsetms]['MS' + k] = ms[k]
                del self.cfg2[runsetms]['METAL_STACK']

    def dump_cfg1(self, cfg1_fn):
        fh = open(cfg1_fn, 'w')
        pprint.pprint(self.cfg1, stream=fh)
        fh.close()

    def dump_cfg2(self, cfg2_fn):
        fh = open(cfg2_fn, 'w')
        pprint.pprint(self.cfg2, stream=fh)
        fh.close()
