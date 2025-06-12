#!/bin/zsh

# robust_file_copy.sh - A file copy utility with error checking and logging
# Usage: ./robust_file_copy.sh source_file destination_file

# Log file setup
LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/file_operations_$(date +%Y%m%d).log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Also print to console if not INFO level
    if [[ "$level" != "INFO" ]]; then
        echo "[$level] $message"
    fi
}

# Error handling function
handle_error() {
    local exit_code=$1
    local error_message=$2
    
    if [[ $exit_code -ne 0 ]]; then
        log_message "ERROR" "$error_message (Exit code: $exit_code)"
        exit $exit_code
    fi
}

# Check arguments
if [[ $# -ne 2 ]]; then
    log_message "ERROR" "Usage: $0 source_file destination_file"
    exit 1
fi

SOURCE="$1"
DESTINATION="$2"

# Check if source file exists
if [[ ! -f "$SOURCE" ]]; then
    log_message "ERROR" "Source file does not exist: $SOURCE"
    exit 1
fi

# Log start of operation
log_message "INFO" "Starting copy operation: $SOURCE -> $DESTINATION"

# Create destination directory if it doesn't exist
DEST_DIR=$(dirname "$DESTINATION")
if [[ ! -d "$DEST_DIR" ]]; then
    log_message "INFO" "Creating destination directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
    handle_error $? "Failed to create destination directory"
fi

# Perform the copy with error checking
cp "$SOURCE" "$DESTINATION"
handle_error $? "Failed to copy file from $SOURCE to $DESTINATION"

# Verify the copy was successful
if [[ -f "$DESTINATION" ]]; then
    SOURCE_SIZE=$(stat -f%z "$SOURCE")
    DEST_SIZE=$(stat -f%z "$DESTINATION")
    
    if [[ "$SOURCE_SIZE" -eq "$DEST_SIZE" ]]; then
        log_message "INFO" "File copied successfully: $SOURCE -> $DESTINATION (Size: $SOURCE_SIZE bytes)"
    else
        log_message "ERROR" "File size mismatch: Source=$SOURCE_SIZE bytes, Destination=$DEST_SIZE bytes"
        exit 1
    fi
else
    log_message "ERROR" "Destination file not found after copy operation"
    exit 1
fi

exit 0