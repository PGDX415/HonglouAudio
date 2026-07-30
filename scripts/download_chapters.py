#!/usr/bin/env python3
"""Download HongLouMeng chapter texts from WeChat."""
import urllib.request, re, os, time, ssl

HOME_URL = 'https://mp.weixin.qq.com/mp/homepage?__biz=MzIwMjg5Njg5Nw==&hid=1&sn=2214723b67d9a09f1c6ba6b368f2d284&scene=18'
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), 'HongLouAudio', 'chapter_texts')
HEADERS = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15'}

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def fetch(url):
    req = urllib.request.Request(url, headers=HEADERS)
    resp = urllib.request.urlopen(req, context=ctx, timeout=30)
    return resp.read().decode('utf-8', errors='ignore')

def link_to_filename(link_url):
    mid_m = re.search(r'mid=(\d+)', link_url)
    idx_m = re.search(r'idx=(\d+)', link_url)
    if not mid_m or not idx_m:
        return None
    mid = int(mid_m.group(1))
    idx = int(idx_m.group(1))
    chapter_num = mid - 100000172
    suffix_map = {1: 'shang', 2: 'zhong', 3: 'xia'}
    suffix = suffix_map.get(idx, 'unknown')
    return f'chapter_{chapter_num:02d}_{suffix}.txt'

def extract_text(html):
    m = re.search(r'id="js_content"[^>]*>(.*?)(?:</div>\s*<script|</div>\s*$)', html, re.DOTALL)
    if not m:
        return ''
    text = re.sub(r'<[^>]+>', '', m.group(1))
    text = text.replace('&nbsp;', ' ')
    text = text.replace('&amp;', '&')
    text = text.replace('&lt;', '<')
    text = text.replace('&gt;', '>')
    text = text.replace('&quot;', '"')
    text = text.replace('&#39;', "'")
    text = re.sub(r'\n{3,}', '\n\n', text.strip())
    return text

def get_links(html):
    results = []
    for m in re.finditer(r'"title":"([^"]*)"[^}]*"link":"(http://mp\.weixin\.qq\.com/s\?[^"]*)"', html):
        title = m.group(1)
        link = m.group(2).replace('&amp;', '&')
        results.append((title, link))
    return results

os.makedirs(OUTPUT_DIR, exist_ok=True)

print('Fetching homepage...')
home = fetch(HOME_URL)

all_links = get_links(home)
print(f'Homepage: {len(all_links)} articles')

cids = set()
for m in re.finditer(r'cid[=:]\s*["\']?(\d+)', home):
    cids.add(int(m.group(1)))

for cid in sorted(cids):
    api_url = f'{HOME_URL}&action=appmsg&cid={cid}&begin=0&count=30'
    print(f'Trying cid={cid}...')
    try:
        data = fetch(api_url)
        links = get_links(data)
        print(f'  cid={cid}: {len(links)} articles')
        all_links.extend(links)
    except Exception as e:
        print(f'  cid={cid}: failed ({e})')
    time.sleep(2)

seen = set()
unique = []
for title, link in all_links:
    if link not in seen:
        seen.add(link)
        unique.append((title, link))

print(f'\nTotal unique: {len(unique)}')

for i, (title, link) in enumerate(unique):
    fname = link_to_filename(link)
    if not fname:
        print(f'[{i+1}/{len(unique)}] SKIP (no match): {title}')
        continue
    fpath = os.path.join(OUTPUT_DIR, fname)
    if os.path.exists(fpath):
        print(f'[{i+1}/{len(unique)}] SKIP (exists): {fname}')
        continue
    print(f'[{i+1}/{len(unique)}] Downloading: {title} -> {fname} ...', end=' ')
    try:
        article = fetch(link)
        text = extract_text(article)
        if text:
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(text)
            print(f'OK ({len(text)} chars)')
        else:
            print('WARN: empty text')
    except Exception as e:
        print(f'FAIL: {e}')
    time.sleep(3)

print(f'\nDone! Files saved to: {OUTPUT_DIR}')
