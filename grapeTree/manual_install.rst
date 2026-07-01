

pip3 install on BigMac2 (arm) didn't work, brew/pip dependencies not resolved.

it is python flask , so trying on a linux machine instead.

bofh24:
python3 -m venv ./.VENV
source ./.VENV/bin/activate
pip3 install grapetree
same problem as bigMac2

 import numpy as np, json, pandas as pd, re, requests, tempfile, os
ModuleNotFoundError: No module named 'pandas'


(the github compiled packages are for intel mac, not arm.  what compiler did they use?)

///

cd ~/git_repos
git clone https://github.com/achtman-lab/GrapeTree.git

cd GrapeTree
///

pip3 install -r ~/git_repos/GrapeTree/requirements.txt
# that thing did not list pandas 

pip3 install pandas app requests 
# then it works.
grapetree
# inside tmux, still launched a firefox over ssh to wsl, laggish, but at least have feedback and see it is doing things


# weasel socks5 firefox ssh bofh24 
http://localhost:8000
works, but still node are all the same size.  missing some step?  I think I tried everything!  need an older version?



mac, disable the block of running app from unknown developer.  (else it prompts a gaziilion times for each .so files needed, can't finish that list)
(base) zyzyxia3:GrapeTree_2018 jr$ sudo spctl --master-disable

finally got grapetree to run on zyzyxia3 (intel mac) using the github download .zip file, but same problem, node size ae static.

# revert the changes
(base) zyzyxia3:GrapeTree_2018 jr$ sudo spctl --master-enable

