#!/bin/bash

# Educacion Global, Inc. 2025.
# Enhanced Audio Extraction Script
# Supports multiple formats, quality settings, and advanced options

# Default values
QUALITY="medium"
OVERWRITE=false
DRY_RUN=false
VERBOSE=false
START_TIME=""
DURATION=""
SAMPLE_RATE=""
BITRATE=""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    cat << EOF
Enhanced Audio Extraction Script

USAGE:
    $0 [OPTIONS] INPUT_FILE OUTPUT_FILE

ARGUMENTS:
    INPUT_FILE      Input video file
    OUTPUT_FILE     Output audio file (format detected from extension)

OPTIONS:
    -q, --quality LEVEL     Quality preset: low, medium, high, lossless (default: medium)
    -f, --format FORMAT     Force output format: mp3, wav, aac, flac, ogg, m4a
    -s, --start TIME        Start time (e.g., 00:01:30 or 90)
    -d, --duration TIME     Duration to extract (e.g., 00:02:00 or 120)
    -r, --sample-rate RATE  Sample rate (e.g., 44100, 48000)
    -b, --bitrate RATE      Audio bitrate (e.g., 128k, 320k)
    -y, --overwrite         Overwrite output file if it exists
    -n, --dry-run           Show command without executing
    -v, --verbose           Verbose output
    -h, --help              Show this help message

SUPPORTED FORMATS:
    mp3     - MPEG Audio Layer 3 (lossy)
    wav     - Waveform Audio File Format (lossless)
    aac     - Advanced Audio Coding (lossy)
    flac    - Free Lossless Audio Codec (lossless)
    ogg     - Ogg Vorbis (lossy)
    m4a     - MPEG-4 Audio (lossy)

QUALITY PRESETS:
    low         - Fast encoding, larger file size
    medium      - Balanced quality and size (default)
    high        - Better quality, slower encoding
    lossless    - No quality loss, largest files

EXAMPLES:
    $0 video.mp4 audio.mp3
    $0 -q high -f wav input.mkv output.wav
    $0 -s 00:01:30 -d 00:02:00 movie.mp4 clip.mp3
    $0 -b 320k -r 48000 concert.mp4 high_quality.mp3
    $0 --dry-run --verbose input.avi output.flac

EOF
}

# Function to log messages
log() {
    local level=$1
    shift
    local message="$*"
    
    case $level in
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "INFO")
            if [[ $VERBOSE == true ]]; then
                echo -e "${BLUE}[INFO]${NC} $message"
            fi
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get file extension
get_extension() {
    echo "${1##*.}" | tr '[:upper:]' '[:lower:]'
}

# Function to detect output format from extension
detect_format() {
    local ext=$(get_extension "$1")
    case $ext in
        mp3) echo "mp3" ;;
        wav) echo "wav" ;;
        aac|m4a) echo "aac" ;;
        flac) echo "flac" ;;
        ogg) echo "ogg" ;;
        *) echo "mp3" ;; # default
    esac
}

# Function to get codec and options based on format and quality
get_codec_options() {
    local format=$1
    local quality=$2
    
    case $format in
        mp3)
            case $quality in
                low) echo "-acodec libmp3lame -q:a 7" ;;
                medium) echo "-acodec libmp3lame -q:a 2" ;;
                high) echo "-acodec libmp3lame -q:a 0" ;;
                lossless) echo "-acodec flac" ;;
            esac
            ;;
        wav)
            echo "-acodec pcm_s16le"
            ;;
        aac)
            case $quality in
                low) echo "-acodec aac -b:a 96k" ;;
                medium) echo "-acodec aac -b:a 128k" ;;
                high) echo "-acodec aac -b:a 256k" ;;
                lossless) echo "-acodec flac" ;;
            esac
            ;;
        flac)
            case $quality in
                low) echo "-acodec flac -compression_level 0" ;;
                medium) echo "-acodec flac -compression_level 5" ;;
                high|lossless) echo "-acodec flac -compression_level 12" ;;
            esac
            ;;
        ogg)
            case $quality in
                low) echo "-acodec libvorbis -q:a 3" ;;
                medium) echo "-acodec libvorbis -q:a 5" ;;
                high) echo "-acodec libvorbis -q:a 8" ;;
                lossless) echo "-acodec flac" ;;
            esac
            ;;
    esac
}

# Function to build ffmpeg command
build_ffmpeg_command() {
    local input="$1"
    local output="$2"
    local format="$3"
    local quality="$4"
    
    local cmd="ffmpeg"
    
    # Input options
    if [[ $OVERWRITE == true ]]; then
        cmd="$cmd -y"
    else
        cmd="$cmd -n"
    fi
    
    cmd="$cmd -i \"$input\""
    
    # Time options
    if [[ -n $START_TIME ]]; then
        cmd="$cmd -ss $START_TIME"
    fi
    
    if [[ -n $DURATION ]]; then
        cmd="$cmd -t $DURATION"
    fi
    
    # Audio options
    cmd="$cmd -vn" # No video
    
    # Get codec options
    local codec_opts=$(get_codec_options "$format" "$quality")
    cmd="$cmd $codec_opts"
    
    # Custom sample rate
    if [[ -n $SAMPLE_RATE ]]; then
        cmd="$cmd -ar $SAMPLE_RATE"
    fi
    
    # Custom bitrate (only for lossy formats)
    if [[ -n $BITRATE && $format != "wav" && $format != "flac" ]]; then
        cmd="$cmd -b:a $BITRATE"
    fi
    
    # Remove metadata
    cmd="$cmd -map_metadata -1"
    
    # Progress option
    if [[ $VERBOSE == true ]]; then
        cmd="$cmd -progress pipe:1"
    else
        cmd="$cmd -loglevel warning"
    fi
    
    cmd="$cmd \"$output\""
    
    echo "$cmd"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quality)
            QUALITY="$2"
            if [[ ! "$QUALITY" =~ ^(low|medium|high|lossless)$ ]]; then
                log "ERROR" "Invalid quality: $QUALITY. Use: low, medium, high, lossless"
                exit 1
            fi
            shift 2
            ;;
        -f|--format)
            FORCE_FORMAT="$2"
            if [[ ! "$FORCE_FORMAT" =~ ^(mp3|wav|aac|flac|ogg|m4a)$ ]]; then
                log "ERROR" "Invalid format: $FORCE_FORMAT. Use: mp3, wav, aac, flac, ogg, m4a"
                exit 1
            fi
            shift 2
            ;;
        -s|--start)
            START_TIME="$2"
            shift 2
            ;;
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -r|--sample-rate)
            SAMPLE_RATE="$2"
            shift 2
            ;;
        -b|--bitrate)
            BITRATE="$2"
            shift 2
            ;;
        -y|--overwrite)
            OVERWRITE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log "ERROR" "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z $INPUT ]]; then
                INPUT="$1"
            elif [[ -z $OUTPUT ]]; then
                OUTPUT="$1"
            else
                log "ERROR" "Too many arguments"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$INPUT" ]] || [[ -z "$OUTPUT" ]]; then
    log "ERROR" "Missing required arguments"
    show_help
    exit 1
fi

# Check if ffmpeg is installed
if ! command_exists ffmpeg; then
    log "ERROR" "ffmpeg is not installed or not in PATH"
    log "INFO" "Install with: brew install ffmpeg (macOS) or apt install ffmpeg (Linux)"
    exit 1
fi

# Validate input file
if [[ ! -f "$INPUT" ]]; then
    log "ERROR" "Input file does not exist: $INPUT"
    exit 1
fi

# Check if input file is a video (basic check)
if ! ffprobe -v quiet -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$INPUT" >/dev/null 2>&1; then
    log "WARNING" "Input file may not contain video streams"
fi

# Determine output format
if [[ -n $FORCE_FORMAT ]]; then
    FORMAT="$FORCE_FORMAT"
else
    FORMAT=$(detect_format "$OUTPUT")
fi

log "INFO" "Detected output format: $FORMAT"

# Check if output file exists
if [[ -f "$OUTPUT" ]] && [[ $OVERWRITE == false ]]; then
    log "ERROR" "Output file already exists: $OUTPUT"
    log "INFO" "Use -y or --overwrite to overwrite existing files"
    exit 1
fi

# Build and execute command
FFMPEG_CMD=$(build_ffmpeg_command "$INPUT" "$OUTPUT" "$FORMAT" "$QUALITY")

log "INFO" "Input: $INPUT"
log "INFO" "Output: $OUTPUT"
log "INFO" "Format: $FORMAT"
log "INFO" "Quality: $QUALITY"
if [[ -n $START_TIME ]]; then
    log "INFO" "Start time: $START_TIME"
fi
if [[ -n $DURATION ]]; then
    log "INFO" "Duration: $DURATION"
fi

if [[ $DRY_RUN == true ]]; then
    echo
    log "INFO" "Dry run mode - command that would be executed:"
    echo "$FFMPEG_CMD"
    exit 0
fi

echo
log "INFO" "Starting audio extraction..."

# Execute ffmpeg command
if eval "$FFMPEG_CMD"; then
    echo
    log "SUCCESS" "Audio extracted successfully to: $OUTPUT"
    
    # Show file size
    if command_exists du; then
        SIZE=$(du -h "$OUTPUT" | cut -f1)
        log "INFO" "Output file size: $SIZE"
    fi
else
    echo
    log "ERROR" "Audio extraction failed"
    exit 1
fi

