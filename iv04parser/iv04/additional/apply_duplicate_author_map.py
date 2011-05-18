#! /usr/bin/python

# Jeff Klingner
# 08 March 2004
# You may do whatever you want with this script.

import re

# Read in the duplicate author map
author_map = {}
for line in open("duplicate_author_map.txt"):
    m = re.match('<(P\d+),([^>]+)> -> <(P\d+),([^>]+)>', line)
    if (m):
        from_auth = (m.group(1), m.group(2))
        to_auth   = (m.group(3), m.group(4))
        author_map[from_auth] = to_auth

# Read in the datafile, correct it, and write it out
corrected_datafile = open("corrected_dataset.xml", 'w')
for line in open("dataset.xml"):
    m = re.search('<author_ref ref="(P\d+)">([^<]+)</author_ref>', line)
    if (m):
        from_auth = (m.group(1), m.group(2))
        if author_map.has_key(from_auth):
            (to_id,to_name) = author_map[from_auth]
            line = re.sub('P\d+', to_id, line)
            line = re.sub('>[^<]+<', '>%s<' % to_name, line)
    corrected_datafile.write(line)
corrected_datafile.close()
        
    

