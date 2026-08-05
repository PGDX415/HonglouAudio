#!/usr/bin/env python3
"""
Generate paragraph timestamps for HongLouMeng audio files.

Uses faster-whisper for segment-level transcription (fast), then aligns
original text paragraphs with transcribed segments using fuzzy matching.

Usage:
    python3 generate_timestamps.py single <audio> <text> [-o output]
    python3 generate_timestamps.py batch --text-dir DIR --audio-dir DIR
"""

import os, re, json, sys, argparse, logging
from faster_whisper import WhisperModel
from rapidfuzz import fuzz, process

logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
log = logging.getLogger(__name__)


def load_paragraphs(text_path: str) -> list:
    with open(text_path, 'r', encoding='utf-8') as f:
        text = f.read()
    paragraphs = re.split(r'\n\s*\n', text.strip())
    return [p.strip().replace('\n', '') for p in paragraphs if p.strip()]


def clean_cjk(text: str) -> str:
    return re.sub(r'[^一-鿿]', '', text)


def transcribe_segments(audio_path: str, model_size: str = "medium",
                         device: str = "auto", compute_type: str = "int8"):
    log.info(f"  Loading model '{model_size}'...")
    model = WhisperModel(model_size, device=device, compute_type=compute_type)
    
    log.info(f"  Transcribing (segment-level)...")
    segments, info = model.transcribe(
        audio_path, beam_size=5, word_timestamps=False,
        language="zh", vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=500),
    )
    log.info(f"  Duration: {info.duration:.0f}s, language: {info.language}")
    
    seg_data = []
    for seg in segments:
        seg_data.append({'text': seg.text.strip(), 'start': seg.start, 'end': seg.end})
    
    log.info(f"  Got {len(seg_data)} segments")
    return seg_data


def build_char_time_map(segments: list) -> tuple:
    """Build transcribed text string and per-character timestamp list."""
    all_text = ''
    char_times = []
    for seg in segments:
        seg_text = clean_cjk(seg['text'])
        n = len(seg_text)
        if n == 0:
            continue
        duration = seg['end'] - seg['start']
        char_dur = duration / n
        for i, ch in enumerate(seg_text):
            all_text += ch
            char_times.append(seg['start'] + i * char_dur)
    return all_text, char_times


def find_paragraph_starts(paragraphs: list, trans_text: str,
                           char_times: list) -> list:
    """
    Use fuzzy sliding-window matching to find where each paragraph 
    begins in the transcribed text. Returns list of timestamps.
    """
    clean_paras = [(clean_cjk(p), p) for p in paragraphs]
    clean_paras = [(c, o) for c, o in clean_paras if len(c) >= 3]
    
    timestamps = []
    search_start = 0  # character index in trans_text
    found = 0
    
    for ci, (para_clean, para_orig) in enumerate(clean_paras):
        best_pos = -1
        
        # Use the first 20-40 chars of the paragraph as query
        query_len = min(40, len(para_clean))
        query = para_clean[:query_len]
        
        # Slide a window over transcribed text from search_start
        window_size = query_len
        step = max(1, window_size // 4)
        
        best_score = 0
        best_candidate = -1
        
        max_pos = max(search_start, len(trans_text) - window_size)
        if max_pos < search_start:
            max_pos = search_start
        
        for pos in range(search_start, min(search_start + 3000, max_pos), step):
            if pos + window_size > len(trans_text):
                break
            chunk = trans_text[pos:pos + window_size]
            score = fuzz.ratio(query, chunk)
            if score > best_score:
                best_score = score
                best_candidate = pos
            
            if score > 90:  # Good enough, stop searching
                break
        
        if best_score >= 55:
            best_pos = best_candidate
        
        if best_pos >= 0 and best_pos < len(char_times):
            ts = round(char_times[best_pos], 1)
            timestamps.append(ts)
            search_start = best_pos + max(20, len(para_clean) // 3)
            found += 1
        else:
            log.warning(f"  Para {ci} not matched (best_score={best_score:.0f}): "
                       f"{para_orig[:50]}...")
            if timestamps:
                timestamps.append(round(timestamps[-1] + 0.5, 1))
            else:
                timestamps.append(0.0)
    
    if timestamps and timestamps[0] > 2.0:
        timestamps[0] = 0.0
    
    log.info(f"  Aligned {found}/{len(clean_paras)} ({100*found//max(1,len(clean_paras))}%)")
    return timestamps


def process_one(audio_path: str, text_path: str, output_path: str = None,
                model_size: str = "medium", device: str = "auto"):
    log.info(f"Processing: {os.path.basename(audio_path)}")
    
    paragraphs = load_paragraphs(text_path)
    log.info(f"  Loaded {len(paragraphs)} paragraphs")
    
    segments = transcribe_segments(audio_path, model_size, device)
    trans_text, char_times = build_char_time_map(segments)
    log.info(f"  Transcribed: {len(trans_text)} CJK chars, {len(char_times)} timestamps")
    
    timestamps = find_paragraph_starts(paragraphs, trans_text, char_times)
    
    result = {
        "audioFile": os.path.basename(audio_path),
        "textFile": os.path.basename(text_path),
        "paragraphTimestamps": timestamps,
        "paragraphCount": len(paragraphs),
        "timestampCount": len(timestamps),
    }
    
    if output_path is None:
        output_path = audio_path.rsplit('.', 1)[0] + '_timestamps.json'
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    log.info(f"  Saved to {output_path}")
    return result


def get_parts_from_filename(filename: str):
    m = re.match(r'chapter_(\d+)_(\w+)\.txt', filename)
    if m:
        num = int(m.group(1))
        part_map = {'shang': '上', 'zhong': '中', 'xia': '下'}
        return num, part_map.get(m.group(2), '?')
    return None, None


def find_matching_audio(chapter_num: int, part: str, audio_dir: str) -> str | None:
    cn = ['零','一','二','三','四','五','六','七','八','九','十']
    def num_to_cn(n):
        if n <= 10: return cn[n]
        if n < 20: return '十' + (cn[n-10] if n>10 else '')
        if n < 100:
            t, o = n//10, n%10
            return cn[t] + '十' + (cn[o] if o else '')
        if n == 100: return '一百'
        if n < 110: return '一百零' + cn[n-100]
        if n < 120: return '一百一十' + (cn[n-110] if n>110 else '')
        if n == 120: return '一百二十'
        return str(n)
    
    hui_cn = f'第{num_to_cn(chapter_num)}回'
    for f in sorted(os.listdir(audio_dir)):
        if not f.endswith('.mp3'): continue
        if hui_cn in f:
            name_no_ext = f.rsplit('.', 1)[0]
            if name_no_ext.rstrip().endswith(part):
                return os.path.join(audio_dir, f)
    return None


def batch_process(text_dir: str, audio_dir: str, output_dir: str = None,
                  model_size: str = "medium", device: str = "auto",
                  start_from: int = 1, limit: int = None,
                  skip_existing: bool = True):
    if output_dir is None:
        output_dir = audio_dir
    
    text_files = sorted(f for f in os.listdir(text_dir) if f.endswith('.txt'))
    results, errors = [], []
    processed = 0
    
    for text_file in text_files:
        chapter_num, part = get_parts_from_filename(text_file)
        if chapter_num is None or chapter_num < start_from:
            continue
        if limit is not None and processed >= limit:
            break
        
        audio_path = find_matching_audio(chapter_num, part, audio_dir)
        if audio_path is None:
            log.warning(f"Skip ch{chapter_num}_{part}: no matching audio")
            errors.append((text_file, "no audio"))
            continue
        
        text_path = os.path.join(text_dir, text_file)
        output_name = os.path.basename(audio_path).rsplit('.', 1)[0] + '_timestamps.json'
        output_path = os.path.join(output_dir, output_name)
        
        if skip_existing and os.path.exists(output_path):
            log.info(f"Skip ch{chapter_num}_{part}: already exists")
            continue
        
        try:
            result = process_one(audio_path, text_path, output_path, model_size, device)
            results.append(result)
            processed += 1
        except Exception as e:
            log.error(f"Error ch{chapter_num}_{part}: {e}")
            import traceback
            traceback.print_exc()
            errors.append((text_file, str(e)))
    
    log.info(f"\n{'='*50}")
    log.info(f"Done! Processed: {len(results)}, Errors: {len(errors)}")
    for fname, err in errors:
        log.info(f"  {fname}: {err}")


def main():
    parser = argparse.ArgumentParser(description="Generate paragraph timestamps")
    sub = parser.add_subparsers(dest='mode')
    
    single = sub.add_parser('single')
    single.add_argument('audio')
    single.add_argument('text')
    single.add_argument('--output', '-o', default=None)
    single.add_argument('--model', default='medium',
                        choices=['tiny','base','small','medium','large-v3'])
    single.add_argument('--device', default='auto', choices=['auto','cpu','cuda'])
    
    batch = sub.add_parser('batch')
    batch.add_argument('--text-dir', required=True)
    batch.add_argument('--audio-dir', required=True)
    batch.add_argument('--output-dir', default=None)
    batch.add_argument('--model', default='medium',
                       choices=['tiny','base','small','medium','large-v3'])
    batch.add_argument('--device', default='auto')
    batch.add_argument('--start-from', type=int, default=1)
    batch.add_argument('--limit', type=int, default=None)
    batch.add_argument('--force', action='store_true')
    
    args = parser.parse_args()
    
    if args.mode == 'single':
        process_one(args.audio, args.text, args.output, args.model, args.device)
    elif args.mode == 'batch':
        batch_process(args.text_dir, args.audio_dir, args.output_dir,
                      args.model, args.device, args.start_from, args.limit,
                      skip_existing=not args.force)
    else:
        project_dir = '/Users/gongdexin/Projects/active/HongLouAudio'
        default_text = os.path.join(project_dir, 'HongLouAudio', 'Text')
        default_audio = '/Users/gongdexin/Downloads/红楼梦音频资源'
        log.info("Running batch with defaults...")
        batch_process(default_text, default_audio, default_audio,
                      'medium', 'auto', 1, None)


if __name__ == '__main__':
    main()
