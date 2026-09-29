#!/usr/bin/env python3
"""Static project-integrity checks, NOT MATLAB execution."""
from pathlib import Path
import ast, json, re
from html.parser import HTMLParser
from urllib.parse import urlparse, unquote
R=Path(__file__).resolve().parents[1]
errors=[]; checked=0
class Links(HTMLParser):
    def __init__(self): super().__init__(); self.urls=[]
    def handle_starttag(self,tag,attrs):
        for key,val in attrs:
            if key in ('href','src') and val: self.urls.append(val)
def check_link(file,url):
    global checked
    if url.startswith(('#','data:','http:','https:','mailto:')): return
    target=unquote(url.split('#')[0]); checked+=1
    if target and not (file.parent/target).exists(): errors.append(f'{file.relative_to(R)} -> {target}')
for p in R.rglob('*.md'):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text()): check_link(p,target)
for p in R.rglob('*.html'):
    parser=Links(); parser.feed(p.read_text())
    for target in parser.urls: check_link(p,target)
for p in R.rglob('*.py'):
    try: ast.parse(p.read_text())
    except SyntaxError as e: errors.append(f'{p}: {e}')
for p in R.rglob('*.m'):
    text=p.read_text(); first=next((line for line in text.splitlines() if line.startswith('function ')),None)
    if not first: errors.append(f'{p}: missing primary function')
    else:
        expr=first[9:].strip(); expr=expr.split('=',1)[-1].strip(); name=re.split(r'[ (]',expr)[0]
        if name != p.stem: errors.append(f'{p}: primary function {name} differs from filename')
    for name in re.findall(r'\bsm\.([A-Za-z][A-Za-z0-9_]*)\s*\(',text):
        if not (R/'src'/'+sm'/f'{name}.m').exists(): errors.append(f'{p}: missing sm.{name}')
valid={'basic','gfsk','oqpsk','ofdm','wifi_nonht','wifi_ht','wifi_vht','wifi_he','wifi_eht','ble','bt_classic','thread','lte_dl','lte_ul','nr_dl','nr_ul'}
for p in (R/'configs').glob('*.json'):
    obj=json.loads(p.read_text()); assert obj['Protocol'] in valid
    assert isinstance(obj['Seed'],int)
    if obj['Protocol']=='thread': assert obj['CenterFrequencyHz']==(2405+5*(obj['Channel']-11))*1e6
    if obj['Protocol']=='nr_ul' and obj.get('TransformPrecoding'): assert obj['PRBSet']==list(range(48))
report={'scope':'Static local project integrity; not MATLAB runtime', 'matlab_files':len(list(R.rglob('*.m'))),'json_presets':len(list((R/'configs').glob('*.json'))),'markdown_files':len(list(R.rglob('*.md'))),'html_files':len(list(R.rglob('*.html'))),'local_links_checked':checked,'errors':errors}
(R/'reports'/'project_audit.json').write_text(json.dumps(report,indent=2,ensure_ascii=False))
print(json.dumps(report,indent=2,ensure_ascii=False))
if errors: raise SystemExit(1)
