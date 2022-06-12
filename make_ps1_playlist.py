#!/usr/bin/python3

import json
import os

unfound_corepath = "/home/retro/.steam/debian-installation/steamapps/common/RetroArch/cores/pcsx_rearmed_libretro.so"
unfound_corename = "Sony - PlayStation (PCSX ReARMed)"

with open('Sony - PlayStation.lpl', 'r') as jfile:
    playlist = json.load(jfile)

#print(playlist['items'])

for root, dirs, files in os.walk("/home/retro/psx/PLAYSTATION", topdown=True):
    for name in files:
        if name == "name":
            with open(os.path.join(root, name)) as nfile:
                name_contents = nfile.read().rstrip().strip('"')
                # print(name_contents)
                x = any(d['label'] == name_contents for d in playlist['items'])
                if x:
                    print(f"found {name_contents}")
                else:
                    print(f"{name_contents} not found")
                    for nroot, ndirs, nfiles in os.walk(root, topdown=True):
                        for nname in nfiles:
                            if "_ns" not in nname and ".bin" in nname and not os.path.islink(os.path.join(nroot, nname)):
                                print(os.path.join(nroot, nname))
                                new_item = dict()
                                new_item['path'] = os.path.join(nroot, nname)
                                new_item['label'] = name_contents
                                new_item['core_path'] = unfound_corepath
                                new_item['core_name'] = unfound_corename
                                new_item['db_name'] = "Sony - PlayStation.lpl"
                                if os.path.isfile(os.path.join(root, 'crc32')):
                                    with open(os.path.join(root, 'crc32')) as crcfile:
                                        crc32 = crcfile.read().rstrip()
                                else:
                                    crc32 = "00000000|crc"
                                new_item['crc32'] = f'{crc32}|crc'
                                # print(new_item)
                                playlist['items'].append(new_item)

output = json.dumps(playlist, indent=2)
with open('new.pl', 'w') as f:
    f.write(output)

