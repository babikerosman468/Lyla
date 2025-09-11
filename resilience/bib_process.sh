#!/data/data/com.termux/files/usr/bin/bash
# bib-process.sh - Powerful bibliography processing script for LaTeX documents
# Works with both biber (biblatex) and bibtex (traditional)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEBIAN_ROOT="$HOME/debian-root"
PROOT_CMD="proot-distro login debian -- sh -c"

show_usage() {
    echo -e "${GREEN}Usage:${NC} bib-process.sh [OPTIONS] <filename.tex>"
    echo -e "${GREEN}Options:${NC}"
    echo -e "  -f, --force    Force processing even if no changes detected"
    echo -e "  -v, --verbose  Show detailed output"
    echo -e "  -c, --clean    Clean bibliography auxiliary files after processing"
    echo -e "  -h, --help     Show this help message"
    echo -e "\n${GREEN}Examples:${NC}"
    echo -e "  bib-process.sh main.tex"
    echo -e "  bib-process.sh -v -c paper.tex"
}

run_in_proot() {
    local cmd="$1"
    local dir="$2"
    if [ "$VERBOSE" = true ]; then
        $PROOT_CMD "cd \"$dir\" && $cmd"
    else
        $PROOT_CMD "cd \"$dir\" && $cmd" 2>/dev/null
    fi
}

detect_bibliography_type() {
    local tex_file="$1"
    local base_name="$2"
    local dir_name="$3"
    
    # Check for biblatex usage
    if grep -q "usepackage.*biblatex" "$tex_file" || 
       grep -q "addbibresource" "$tex_file" || 
       grep -q "printbibliography" "$tex_file"; then
        echo "biblatex"
    # Check for traditional bibtex usage
    elif grep -q "bibliography{" "$tex_file" || 
         grep -q "bibdata{" "$dir_name/$base_name.aux" 2>/dev/null; then
        echo "bibtex"
    # Check for .bcf file (biblatex intermediate)
    elif [ -f "$dir_name/$base_name.bcf" ]; then
        echo "biblatex"
    else
        echo "none"
    fi
}

check_bib_changes() {
    local bib_file="$1"
    local base_name="$2"
    local dir_name="$3"
    
    # Check if .bib file exists
    if [ ! -f "$bib_file" ]; then
        echo -e "${RED}Error:${NC} Bibliography file $bib_file not found!"
        return 1
    fi
    
    # Check if .bib file has been modified since last processing
    local last_processed="$dir_name/.$base_name.bib.timestamp"
    if [ -f "$last_processed" ] && [ "$bib_file" -ot "$last_processed" ] && [ "$FORCE" != true ]; then
        echo -e "${YELLOW}Info:${NC} No changes in bibliography file since last processing."
        echo -e "       Use -f to force processing anyway."
        return 1
    fi
    
    touch "$last_processed"
    return 0
}

process_bibliography() {
    local tex_file="$1"
    local base_name="$2"
    local dir_name="$3"
    local bib_type="$4"
    
    case "$bib_type" in
        "biblatex")
            echo -e "${BLUE}Processing biblatex bibliography with biber...${NC}"
            run_in_proot "biber \"$base_name\"" "$dir_name"
            ;;
        "bibtex")
            echo -e "${BLUE}Processing traditional bibliography with bibtex...${NC}"
            run_in_proot "bibtex \"$base_name\"" "$dir_name"
            ;;
        "none")
            echo -e "${YELLOW}Warning:${NC} No bibliography commands detected in document."
            return 1
            ;;
    esac
}

clean_aux_files() {
    local base_name="$1"
    local dir_name="$2"
    
    echo -e "${BLUE}Cleaning bibliography auxiliary files...${NC}"
    local files=(
        "$dir_name/$base_name.bbl"
        "$dir_name/$base_name.blg"
        "$dir_name/$base_name.bcf"
        "$dir_name/$base_name.run.xml"
        "$dir_name/$base_name.aux"  # Keep this if you want to preserve main aux
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            rm -f "$file" && echo -e "🗑️  Deleted: $(basename "$file")"
        fi
    done
}

main() {
    # Parse command line arguments
    VERBOSE=false
    FORCE=false
    CLEAN=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo -e "${RED}Error:${NC} Unknown option $1"
                show_usage
                exit 1
                ;;
            *)
                TEXFILE=$(realpath "$1")
                shift
                ;;
        esac
    done
    
    if [ -z "$TEXFILE" ]; then
        echo -e "${RED}Error:${NC} No .tex file specified!"
        show_usage
        exit 1
    fi
    
    if [ ! -f "$TEXFILE" ]; then
        echo -e "${RED}Error:${NC} File $TEXFILE not found!"
        exit 1
    fi
    
    BASENAME=$(basename "$TEXFILE" .tex)
    DIRNAME=$(dirname "$TEXFILE")
    
    echo -e "${GREEN}Processing bibliography for:${NC} $TEXFILE"
    echo -e "${GREEN}Working directory:${NC} $DIRNAME"
    
    # Detect bibliography type
    BIB_TYPE=$(detect_bibliography_type "$TEXFILE" "$BASENAME" "$DIRNAME")
    echo -e "${GREEN}Bibliography type detected:${NC} $BIB_TYPE"
    
    if [ "$BIB_TYPE" = "none" ]; then
        exit 1
    fi
    
    # Try to find .bib file
    BIB_FILE=""
    if [ -f "$DIRNAME/$BASENAME.bib" ]; then
        BIB_FILE="$DIRNAME/$BASENAME.bib"
    elif [ -f "$DIRNAME/ref.bib" ]; then
        BIB_FILE="$DIRNAME/ref.bib"
    elif [ -f "$DIRNAME/references.bib" ]; then
        BIB_FILE="$DIRNAME/references.bib"
    else
        echo -e "${YELLOW}Warning:${NC} No .bib file found in document directory."
    fi
    
    # Check for changes if .bib file exists
    if [ -n "$BIB_FILE" ]; then
        check_bib_changes "$BIB_FILE" "$BASENAME" "$DIRNAME" || exit 0
    fi
    
    # Process bibliography
    process_bibliography "$TEXFILE" "$BASENAME" "$DIRNAME" "$BIB_TYPE"
    
    if [ "$CLEAN" = true ]; then
        clean_aux_files "$BASENAME" "$DIRNAME"
    fi
    
    echo -e "${GREEN}✅ Bibliography processing completed successfully!${NC}"
}

# Run main function with all arguments
main "$@"
