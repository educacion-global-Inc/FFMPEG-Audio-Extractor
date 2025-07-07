# 🎵 FFMPEG Audio Extractor

A powerful, feature-rich bash script for extracting audio from video files using FFMPEG. Supports multiple audio formats, quality presets, and advanced extraction options.

## 📁 Project Structure

```
FFMPEG/
├── extract_audio.sh    # Main extraction script
├── input/             # Place your video files here
├── output/            # Extracted audio files will be saved here
└── README.md          # This documentation
```

## 🚀 Features

- **Multi-Format Support**: mp3, wav, aac, flac, ogg, m4a
- **Quality Presets**: low, medium, high, lossless
- **Time Range Extraction**: Extract specific segments
- **Custom Audio Settings**: Sample rate and bitrate control
- **Smart Format Detection**: Auto-detects from file extension
- **Input Validation**: Comprehensive file and format checking
- **Overwrite Protection**: Prevents accidental file overwrites
- **Dry Run Mode**: Preview commands before execution
- **Colored Output**: Easy-to-read status messages
- **Progress Tracking**: Verbose logging options

## 📋 Requirements

- **FFMPEG**: Must be installed and accessible in PATH
- **Bash**: Compatible with bash/zsh shells
- **macOS/Linux**: Tested on Unix-based systems

### Installing FFMPEG

```bash
# macOS (using Homebrew)
brew install ffmpeg

# Ubuntu/Debian
sudo apt update && sudo apt install ffmpeg

# CentOS/RHEL
sudo yum install ffmpeg
```

## 🛠 Installation

1. Clone or download the script
2. Make it executable:
   ```bash
   chmod +x extract_audio.sh
   ```
3. Ensure FFMPEG is installed
4. Create input and output directories if they don't exist:
   ```bash
   mkdir -p input output
   ```

## 📖 Usage

### Basic Syntax

```bash
./extract_audio.sh [OPTIONS] INPUT_FILE OUTPUT_FILE
```

### Quick Start Examples

```bash
# Basic extraction (MP3, medium quality)
./extract_audio.sh input/video.mp4 output/audio.mp3

# High quality WAV extraction
./extract_audio.sh -q high input/movie.mkv output/soundtrack.wav

# Extract specific time range
./extract_audio.sh -s 00:01:30 -d 00:02:00 input/concert.mp4 output/song.mp3

# Custom high-quality settings
./extract_audio.sh -q high -b 320k -r 48000 input/recording.mov output/hq_audio.mp3
```

### Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-q, --quality` | Quality preset: low, medium, high, lossless | `-q high` |
| `-f, --format` | Force output format: mp3, wav, aac, flac, ogg, m4a | `-f wav` |
| `-s, --start` | Start time (HH:MM:SS or seconds) | `-s 00:01:30` |
| `-d, --duration` | Duration to extract (HH:MM:SS or seconds) | `-d 00:02:00` |
| `-r, --sample-rate` | Audio sample rate | `-r 48000` |
| `-b, --bitrate` | Audio bitrate (for lossy formats) | `-b 320k` |
| `-y, --overwrite` | Overwrite existing output files | `-y` |
| `-n, --dry-run` | Preview command without executing | `-n` |
| `-v, --verbose` | Enable verbose output | `-v` |
| `-h, --help` | Show detailed help message | `-h` |

## 🎯 Supported Formats

### Audio Formats

| Format | Extension | Type | Best Use Case |
|--------|-----------|------|---------------|
| **MP3** | `.mp3` | Lossy | General purpose, small files |
| **WAV** | `.wav` | Lossless | Professional audio, editing |
| **AAC** | `.aac`, `.m4a` | Lossy | High quality, Apple ecosystem |
| **FLAC** | `.flac` | Lossless | Archival, audiophile quality |
| **OGG** | `.ogg` | Lossy | Open source alternative |

### Quality Presets

| Preset | Description | File Size | Encoding Speed |
|--------|-------------|-----------|----------------|
| **low** | Fast encoding | Larger | Fastest |
| **medium** | Balanced (default) | Medium | Fast |
| **high** | Better quality | Smaller | Slower |
| **lossless** | No quality loss | Largest | Slowest |

## 💡 Advanced Usage Examples

### Batch Processing with Find

```bash
# Extract all MP4 files from input directory
find input -name "*.mp4" -exec ./extract_audio.sh {} output/{}.mp3 \;

# Extract with high quality for all video files
find input -name "*.mkv" -exec ./extract_audio.sh -q high {} output/{}.flac \;
```

### Time-based Extraction

```bash
# Extract first 30 seconds
./extract_audio.sh -d 30 input/video.mp4 output/preview.mp3

# Extract from 1:30 to 3:45
./extract_audio.sh -s 00:01:30 -d 00:02:15 input/long_video.mp4 output/segment.mp3

# Extract last 2 minutes (if you know the duration)
./extract_audio.sh -s -120 input/video.mp4 output/ending.mp3
```

### Custom Audio Settings

```bash
# CD-quality audio
./extract_audio.sh -f wav -r 44100 input/music_video.mp4 output/cd_quality.wav

# High-resolution audio
./extract_audio.sh -f flac -r 96000 input/studio_recording.mov output/hi_res.flac

# Podcast-optimized
./extract_audio.sh -f mp3 -b 64k -r 22050 input/interview.mp4 output/podcast.mp3
```

## 🔧 Workflow Recommendations

### 1. Organize Your Files

```bash
# Recommended directory structure
FFMPEG/
├── input/
│   ├── movies/
│   ├── music_videos/
│   └── recordings/
├── output/
│   ├── mp3/
│   ├── wav/
│   └── flac/
└── extract_audio.sh
```

### 2. Quality Guidelines

- **Podcasts/Speech**: `-q low -b 64k -r 22050`
- **Music (portable)**: `-q medium -b 192k`
- **Music (high quality)**: `-q high -b 320k`
- **Archival/Professional**: `-q lossless -f flac`

### 3. Testing New Files

Always use dry-run first for important files:

```bash
# Preview the command
./extract_audio.sh --dry-run --verbose input/important_video.mp4 output/audio.mp3

# Then execute if satisfied
./extract_audio.sh input/important_video.mp4 output/audio.mp3
```

## 🐛 Troubleshooting

### Common Issues

**Script won't run:**
```bash
# Make sure it's executable
chmod +x extract_audio.sh

# Check if ffmpeg is installed
ffmpeg -version
```

**"File already exists" error:**
```bash
# Use overwrite flag
./extract_audio.sh -y input/video.mp4 output/audio.mp3
```

**Poor audio quality:**
```bash
# Try higher quality preset
./extract_audio.sh -q high input/video.mp4 output/audio.mp3

# Or custom high bitrate
./extract_audio.sh -b 320k input/video.mp4 output/audio.mp3
```

**Large file sizes:**
```bash
# Use lower quality for smaller files
./extract_audio.sh -q low input/video.mp4 output/audio.mp3

# Or specific bitrate
./extract_audio.sh -b 128k input/video.mp4 output/audio.mp3
```

### Error Messages

| Error | Solution |
|-------|----------|
| `ffmpeg: command not found` | Install FFMPEG using your package manager |
| `Input file does not exist` | Check file path and ensure file exists |
| `Invalid quality: xyz` | Use: low, medium, high, or lossless |
| `Output file already exists` | Use `-y` flag to overwrite or choose different name |

## 📊 Performance Tips

1. **SSD vs HDD**: Use SSD for faster processing
2. **RAM**: More RAM helps with large files
3. **CPU**: Multi-core CPUs process faster
4. **Format Choice**: 
   - WAV/FLAC: CPU intensive
   - MP3/AAC: Faster encoding
5. **Quality vs Speed**: Lower quality = faster processing

## 🔗 Additional Resources

- [FFMPEG Documentation](https://ffmpeg.org/documentation.html)
- [Audio Format Comparison](https://en.wikipedia.org/wiki/Comparison_of_audio_coding_formats)
- [FFMPEG Audio Filters](https://ffmpeg.org/ffmpeg-filters.html#Audio-Filters)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Key permissions:**
- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use

**Requirements:**
- Include copyright notice
- Include license text

## 🤝 Contributing

Found a bug or want to add a feature? 
1. Test your changes thoroughly
2. Ensure backward compatibility
3. Update documentation as needed

---

**Last Updated**: July 7, 2025  
**Version**: 2.0  
**Author**: Educacion Global, Inc.
