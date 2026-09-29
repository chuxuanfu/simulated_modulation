#!/usr/bin/env python3
"""Build offline HTML from project Markdown. Requires the markdown package."""
from pathlib import Path
import re, html
import markdown
ROOT=Path(__file__).resolve().parents[1]
CSS=r'''
:root{--ink:#172a3a;--muted:#5c6b78;--accent:#007d83;--line:#dce5ea;--paper:#fff}
*{box-sizing:border-box}body{margin:0;background:#f1f5f7;color:var(--ink);font:16px/1.85 -apple-system,BlinkMacSystemFont,"PingFang SC","Microsoft YaHei",sans-serif}
header{background:#142b3a;color:white;padding:24px 6vw;border-bottom:5px solid #20b7ab}header a{color:#96ede6;text-decoration:none}header .tag{font-size:12px;letter-spacing:2px;color:#adcad7}
.layout{display:grid;grid-template-columns:250px minmax(0,980px);gap:28px;max-width:1330px;margin:32px auto;padding:0 24px}
nav{position:sticky;top:20px;align-self:start;font-size:14px;max-height:90vh;overflow:auto}nav a{display:block;color:#435b6b;padding:5px 10px;text-decoration:none;border-left:2px solid transparent}nav a:hover{background:#e1eef0;border-color:var(--accent)}
main{background:var(--paper);padding:40px 48px;border:1px solid var(--line);border-radius:10px;min-width:0}
h1{font-size:30px;line-height:1.4;margin:0 0 24px}h2{font-size:23px;margin-top:38px;border-bottom:1px solid var(--line);padding-bottom:8px}h3{font-size:19px}a{color:#007b88}p{margin:14px 0}
pre{padding:18px 20px;background:#122b39;color:#dff7f3;overflow:auto;border-radius:7px;line-height:1.65;font-size:13px}code{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}p code,li code,td code{background:#eef3f5;padding:2px 5px;border-radius:3px;font-size:.9em}
table{border-collapse:collapse;width:100%;font-size:14px;display:block;overflow:auto;margin:22px 0}th,td{border:1px solid var(--line);padding:10px 12px;vertical-align:top}th{background:#eaf3f5;text-align:left}tr:nth-child(even){background:#fafcfd}
blockquote{border-left:4px solid var(--accent);margin-left:0;padding:2px 20px;background:#eef9f6}img{max-width:100%;height:auto}footer{padding:24px;color:var(--muted);font-size:13px;text-align:center}.toc{background:#f4f8f9;padding:10px 20px;border-radius:6px;font-size:14px}
@media(max-width:900px){.layout{display:block;padding:0 12px}nav{position:static;max-height:180px;margin-bottom:18px}main{padding:25px 20px}h1{font-size:25px}}
@media print{header,nav,footer,.toc{display:none}.layout{display:block;margin:0;padding:0}main{border:0;padding:0}pre{background:#eee;color:#111;white-space:pre-wrap}table{display:table;font-size:11px}h2,h3{break-after:avoid}img{max-height:85vh}}
'''

def main():
    sources=[ROOT/'README.md']+sorted((ROOT/'docs').glob('*.md'))+sorted((ROOT/'sop').glob('*.md'))+[ROOT/'resources'/'REFERENCES.md',ROOT/'reports'/'VALIDATION.md']
    sources=[p for p in sources if p.exists()]
    titles={p:p.read_text().splitlines()[0].lstrip('# ').strip() for p in sources}
    for source in sources:
        rel=source.relative_to(ROOT); depth=len(rel.parts)-1; base='../'*depth
        md=source.read_text(encoding='utf-8')
        # Change only existing Markdown links, preserving external URLs/fragments.
        def link(match):
            url=match.group(1)
            if '://' not in url and url.split('#')[0].endswith('.md'):
                target=url.split('#')[0]; fragment=('#'+url.split('#',1)[1]) if '#' in url else ''
                if (source.parent/target).resolve() in sources: return ']('+target[:-3]+'.html'+fragment+')'
            return match.group(0)
        md=re.sub(r'\]\(([^)]+)\)',link,md)
        rendered=markdown.markdown(md,extensions=['tables','fenced_code','toc','sane_lists'])
        nav=''.join(f'<a href="{base}{p.relative_to(ROOT).with_suffix(".html").as_posix()}">{html.escape(titles[p])}</a>' for p in sources)
        title=html.escape(titles[source])
        page=f'<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{title}</title><style>{CSS}</style></head><body><header><div class="tag">SIMULATED MODULATION · MATLAB LAB</div><a href="{base}START_HERE.html">无线调制与波形实验室</a></header><div class="layout"><nav>{nav}</nav><main>{rendered}</main></div><footer>1.0.0 · 离线教程 · 运行状态以 reports/VALIDATION 与本机测试为准</footer></body></html>'
        source.with_suffix('.html').write_text(page,encoding='utf-8')
    (ROOT/'START_HERE.html').write_text((ROOT/'README.html').read_text(),encoding='utf-8')
    print(f'Built {len(sources)+1} offline HTML pages.')
if __name__=='__main__': main()
