#!/bin/bash
# ============================================================
# 红楼梦音频压缩脚本
# 将原始 MP3 文件压缩到更小的体积，适合远程下载
#
# 依赖: ffmpeg (brew install ffmpeg)
# 用法: ./compress_audio.sh <输入目录> <输出目录> [比特率]
# ============================================================

set -e

INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./compressed}"
BITRATE="${3:-64k}"        # 默认 64kbps，语音足够清晰
SAMPLE_RATE="${4:-22050}"  # 22.05kHz，语音采样率

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ 需要安装 ffmpeg: brew install ffmpeg"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "🎙️  红楼梦音频压缩"
echo "   输入: $INPUT_DIR"
echo "   输出: $OUTPUT_DIR"
echo "   比特率: $BITRATE"
echo "   采样率: ${SAMPLE_RATE}Hz"
echo "   ---"

# 统计
total=0
compressed=0
original_size=0
compressed_size=0

# 找到所有 MP3 文件
shopt -s nullglob
for file in "$INPUT_DIR"/*.mp3; do
    total=$((total + 1))
    filename=$(basename "$file")
    output="$OUTPUT_DIR/$filename"

    orig_bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)

    echo "  压缩: $filename"

    # ffmpeg 压缩：单声道、指定比特率和采样率
    ffmpeg -i "$file" \
        -ac 1 \
        -ar "$SAMPLE_RATE" \
        -b:a "$BITRATE" \
        -map_metadata -1 \
        -y \
        -loglevel error \
        "$output"

    comp_bytes=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)
    original_size=$((original_size + orig_bytes))
    compressed_size=$((compressed_size + comp_bytes))

    reduction=$((100 - comp_bytes * 100 / orig_bytes))
    echo "     $(echo "scale=1; $orig_bytes/1048576" | bc)MB → $(echo "scale=1; $comp_bytes/1048576" | bc)MB (减小 ${reduction}%)"

    compressed=$((compressed + 1))
done

echo "   ---"
echo "✅ 完成: $compressed/$total 个文件"
echo "   原始大小: $(echo "scale=1; $original_size/1048576" | bc) MB"
echo "   压缩大小: $(echo "scale=1; $compressed_size/1048576" | bc) MB"
reduction_total=$((100 - compressed_size * 100 / original_size))
echo "   总计减小: ${reduction_total}%"

# 按季分目录（可选）
echo ""
echo "💡 提示："
echo "   上传到服务器后，在 App 设置中配置远程地址："
echo "   UserDefaults: audioRemoteBaseURL = 'https://your-cdn.com/honglou/'"
echo ""
echo "   文件命名需与 chapters.json 中 audioFileName 一致"

