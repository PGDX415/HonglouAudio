#!/usr/bin/env python3
"""Download chapter texts using browser cookies.
Usage:
  1. Install browser-cookie3: pip3 install browser-cookie3
  2. Open Chrome, visit the WeChat homepage, make sure articles load
  3. Run: python3 download_text_with_cookies.py
"""
import urllib.request, re, os, ssl, json, time, http.cookiejar

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), 'HongLouAudio', 'chapter_texts')
HOME_URL = 'https://mp.weixin.qq.com/mp/homepage?__biz=MzIwMjg5Njg5Nw==&hid=1&sn=2214723b67d9a09f1c6ba6b368f2d284&scene=18'

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

print("Loading Chrome cookies...")
try:
    import browser_cookie3
    cj = browser_cookie3.chrome(domain_name='mp.weixin.qq.com')
    print(f"  Loaded {len(cj)} cookies")
except ImportError:
    print("  browser_cookie3 not found. Install with: pip3 install browser-cookie3")
    print("  Falling back to no cookies...")
    cj = http.cookiejar.CookieJar()

opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx)
)
opener.addheaders = [
    ('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'),
    ('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'),
    ('Accept-Language', 'zh-CN,zh;q=0.9,en;q=0.8'),
]

def fetch(url):
    resp = opener.open(url, timeout=30)
    return resp.read().decode('utf-8', errors='ignore')

def extract_text(html):
    m = re.search(r'id="js_content"[^>]*>(.*?)(?:</div>\s*<script|</div>\s*$)', html, re.DOTALL)
    if not m:
        return ''
    text = re.sub(r'<[^>]+>', '', m.group(1))
    text = text.replace('&nbsp;', ' ').replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>')
    return re.sub(r'\n{3,}', '\n\n', text.strip())

print("\nFetching homepage...")
home = fetch(HOME_URL)

# Get all links from homepage
articles = []
for m in re.finditer(r'"title":"([^"]*)"[^}]*"link":"(https?://mp\.weixin\.qq\.com/s\?[^"]*)"', home):
    title = m.group(1)
    link = m.group(2).replace('&amp;', '&')
    articles.append((title, link))

print(f"Found {len(articles)} articles")

# Filter for chapters 1-60 only
filtered = [(t, l) for t, l in articles if re.search(r'第[一二三四五六七八九十]+回', t)]
print(f"Chapters 1-60: {len(filtered)} articles")

os.makedirs(OUTPUT_DIR, exist_ok=True)

for i, (title, link) in enumerate(filtered):
    # Determine filename from link
    mid_m = re.search(r'mid=(\d+)', link)
    idx_m = re.search(r'idx=(\d+)', link)
    if not mid_m or not idx_m:
        print(f"[{i+1}/{len(filtered)}] SKIP {title}")
        continue
    
    mid = int(mid_m.group(1))
    idx = int(idx_m.group(1))
    chapter_num = mid - 100000172
    suffix = {1: 'shang', 2: 'zhong', 3: 'xia'}.get(idx, 'unknown')
    fname = f'chapter_{chapter_num:02d}_{suffix}.txt'
    fpath = os.path.join(OUTPUT_DIR, fname)
    
    if os.path.exists(fpath):
        print(f"[{i+1}/{len(filtered)}] SKIP (exists): {fname}")
        continue
    
    print(f"[{i+1}/{len(filtered)}] {title} -> {fname} ...", end=' ', flush=True)
    try:
        article_html = fetch(link)
        text = extract_text(article_html)
        if text:
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(text)
            print(f"OK ({len(text)} chars)")
        else:
            print("WARN: empty")
    except Exception as e:
        print(f"FAIL: {e}")
    time.sleep(2)

print(f"\nDone! Files in: {OUTPUT_DIR}")
