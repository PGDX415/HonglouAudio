#!/usr/bin/env python3
"""
Standalone timestamp generator for HongLouMeng audio files (chapters 61-120).
Works WITHOUT reference text - generates sentence-level timestamps from transcription.

Usage:
    python3 generate_timestamps_standalone.py single <audio> [-o output]
    python3 generate_timestamps_standalone.py batch --audio-dir DIR [--start N] [--end N]
"""

import os, re, json, sys, argparse, logging
from faster_whisper import WhisperModel

logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
log = logging.getLogger(__name__)


def clean_cjk(text: str) -> str:
    return re.sub(r'[^一-鿿]', '', text)


def transcribe_segments(audio_path: str, model_size: str = "medium",
                         device: str = "auto", compute_type: str = "int8"):
    log.info(f"  Loading model '{model_size}'...")
    model = WhisperModel(model_size, device=device, compute_type=compute_type)
    
    log.info(f"  Transcribing...")
    segments, info = model.transcribe(
        audio_path, beam_size=5, word_timestamps=False,
        language="zh", vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=500),
    )
    log.info(f"  Duration: {info.duration:.0f}s")
    
    seg_data = []
    for seg in segments:
        seg_data.append({'text': seg.text.strip(), 'start': seg.start, 'end': seg.end})
    
    log.info(f"  Got {len(seg_data)} segments")
    return seg_data


def generate_sentence_timestamps(segments: list) -> list:
    """
    Split transcribed text into sentences (by 。！？) and generate timestamps.
    Returns list of (timestamp, sentence_text) tuples.
    """
    sentences = []  # (start_time, text)
    
    for seg in segments:
        text = seg['text']
        # Split on sentence-ending punctuation but KEEP the punctuation
        parts = re.split(r'(?<=[。！？])', text)
        
        seg_chars = clean_cjk(text)
        if not seg_chars:
            continue
        
        # Character-level time per segment
        seg_duration = seg['end'] - seg['start']
        char_time = seg_duration / len(seg_chars) if seg_chars else 0
        
        # Track character position within segment
        char_pos = 0
        for part in parts:
            part_stripped = part.strip()
            if not part_stripped:
                continue
            part_cjk = clean_cjk(part_stripped)
            if not part_cjk:
                continue
            
            # Find where this part starts in the segment
            part_start_in_seg = clean_cjk(text).find(part_cjk, char_pos)
            if part_start_in_seg < 0:
                part_start_in_seg = char_pos
            
            timestamp = seg['start'] + part_start_in_seg * char_time
            sentences.append((round(timestamp, 1), part_stripped))
            
            char_pos = part_start_in_seg + len(part_cjk)
    
    # Deduplicate and ensure monotonic
    timestamps = []
    for ts, text in sentences:
        if not timestamps or ts > timestamps[-1] + 0.1:
            timestamps.append(ts)
        elif ts < timestamps[-1]:
            timestamps.append(timestamps[-1] + 0.1)
    
    if timestamps and timestamps[0] > 2.0:
        timestamps[0] = 0.0
    
    return timestamps


def process_one(audio_path: str, output_path: str = None,
                model_size: str = "medium", device: str = "auto"):
    log.info(f"Processing: {os.path.basename(audio_path)}")
    
    segments = transcribe_segments(audio_path, model_size, device)
    timestamps = generate_sentence_timestamps(segments)
    
    result = {
        "audioFile": os.path.basename(audio_path),
        "mode": "sentence-level (no reference text)",
        "paragraphTimestamps": timestamps,
        "timestampCount": len(timestamps),
    }
    
    if output_path is None:
        output_path = audio_path.rsplit('.', 1)[0] + '_timestamps.json'
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    log.info(f"  Saved {len(timestamps)} timestamps to {output_path}")
    return result


def cn_to_num(hui_str: str) -> int:
    """Convert Chinese chapter number to integer (e.g., '第六十一回' -> 61)."""
    cn = {'一':1,'二':2,'三':3,'四':4,'五':5,'六':6,'七':7,'八':8,'九':9,
          '十':10, '百':100, '零':0}
    
    # Extract the middle part: 第XXX回
    m = re.search(r'第(.+?)回', hui_str)
    if not m:
        return 0
    s = m.group(1)
    
    result = 0
    if '百' in s:
        parts = s.split('百')
        if parts[0]:
            result += cn.get(parts[0], 0) * 100
        else:
            result += 100
        s = parts[1] if len(parts) > 1 else ''
    if '十' in s:
        parts = s.split('十')
        if parts[0]:
            result += cn.get(parts[0], 0) * 10
        else:
            result += 10
        s = parts[1] if len(parts) > 1 else ''
    if s:
        result += cn.get(s, 0)
    
    return result


def extract_part(filename: str) -> str:
    """Extract 上/中/下 from filename."""
    name_no_ext = filename.rsplit('.', 1)[0]
    if name_no_ext.rstrip().endswith('上'):
        return '上'
    elif name_no_ext.rstrip().endswith('中'):
        return '中'
    elif name_no_ext.rstrip().endswith('下'):
        return '下'
    return ''


def batch_process(audio_dir: str, output_dir: str = None,
                  model_size: str = "medium", device: str = "auto",
                  start_chapter: int = 61, end_chapter: int = 120,
                  skip_existing: bool = True):
    if output_dir is None:
        output_dir = audio_dir
    
    # Get all audio files and filter by chapter range
    audio_files = sorted([f for f in os.listdir(audio_dir) if f.endswith('.mp3')])
    
    results, errors = [], []
    processed = 0
    
    for af in audio_files:
        hui_num = cn_to_num(af)
        if hui_num < start_chapter or hui_num > end_chapter:
            continue
        
        audio_path = os.path.join(audio_dir, af)
        output_name = af.rsplit('.', 1)[0] + '_timestamps.json'
        output_path = os.path.join(output_dir, output_name)
        
        if skip_existing and os.path.exists(output_path):
            log.info(f"Skip ch{hui_num}: already exists")
            continue
        
        try:
            result = process_one(audio_path, output_path, model_size, device)
            results.append(result)
            processed += 1
        except Exception as e:
            log.error(f"Error ch{hui_num}: {e}")
            import traceback
            traceback.print_exc()
            errors.append((af, str(e)))
    
    log.info(f"\n{'='*50}")
    log.info(f"Done! Processed: {len(results)}, Errors: {len(errors)}")
    for fname, err in errors[:10]:
        log.info(f"  {fname}: {err}")


def main():
    parser = argparse.ArgumentParser(description="Standalone timestamp generator (no reference text)")
    sub = parser.add_subparsers(dest='mode')
    
    single = sub.add_parser('single')
    single.add_argument('audio')
    single.add_argument('--output', '-o', default=None)
    single.add_argument('--model', default='medium',
                        choices=['tiny','base','small','medium','large-v3'])
    single.add_argument('--device', default='auto')
    
    batch = sub.add_parser('batch')
    batch.add_argument('--audio-dir', required=True)
    batch.add_argument('--output-dir', default=None)
    batch.add_argument('--model', default='medium',
                       choices=['tiny','base','small','medium','large-v3'])
    batch.add_argument('--device', default='auto')
    batch.add_argument('--start', type=int, default=61)
    batch.add_argument('--end', type=int, default=120)
    batch.add_argument('--force', action='store_true')
    
    args = parser.parse_args()
    
    if args.mode == 'single':
        process_one(args.audio, args.output, args.model, args.device)
    elif args.mode == 'batch':
        batch_process(args.audio_dir, args.output_dir,
                      args.model, args.device, args.start, args.end,
                      skip_existing=not args.force)
    else:
        default_audio = '/Users/gongdexin/Downloads/红楼梦音频资源'
        log.info("Running batch for chapters 61-120 with defaults...")
        batch_process(default_audio, default_audio, 'medium', 'auto', 61, 120)


if __name__ == '__main__':
    main()
