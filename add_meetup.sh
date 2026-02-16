#!/bin/bash
# filepath: /home/manczak/meetup/add_meetup.sh
# Script to create scaffolding for a new Rust Meetup

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <next_meetup_number>"
  exit 1
fi

NEXT_NUM="$1"
SRC_DIR="src"
MEETUP_FILE="${SRC_DIR}/Meetup_${NEXT_NUM}.md"
FOTOS_FILE="${SRC_DIR}/MeetupFotos_${NEXT_NUM}.md"
IMG_DIR="${SRC_DIR}/img/meetup${NEXT_NUM}"
TEMP_IMG_DIR="/tmp/meetup${NEXT_NUM}_photos"
INTRO_FILE="${SRC_DIR}/introduction.md"
SUMMARY_FILE="${SRC_DIR}/SUMMARY.md"

PREV_NUM=$((NEXT_NUM - 1))
ATTENDEES_FILE="${SRC_DIR}/attendees.md"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Creating scaffolding for Meetup #${NEXT_NUM} ==="
echo ""

# 1. Create new meetup file if it doesn't exist
if [ ! -f "$MEETUP_FILE" ]; then
  echo "# Augsburg Rust Meetup #${NEXT_NUM}" > "$MEETUP_FILE"
  echo "" >> "$MEETUP_FILE"
  echo "## Datum und Uhrzeit" >> "$MEETUP_FILE"
  echo "_TBD_" >> "$MEETUP_FILE"
  echo "" >> "$MEETUP_FILE"
  echo "Willkommen in unserer Rust-Gruppe! Entdecke mit uns die faszinierende Welt der Programmiersprache Rust. Ob Anfänger oder Experte - hier tauschen wir Know-how aus, lösen Herausforderungen und erschaffen gemeinsam innovative Projekte. Sei dabei und werde Teil unserer leidenschaftlichen Community! #RustEnthusiasten" >> "$MEETUP_FILE"
  echo "" >> "$MEETUP_FILE"
  echo "## Agenda" >> "$MEETUP_FILE"
  echo "- 17:00pm - Willkommen und vorstellung" >> "$MEETUP_FILE"
  echo "- 17:30pm - TBD" >> "$MEETUP_FILE"
  echo "- 18:30pm - Allgemeine Themen" >> "$MEETUP_FILE"
  echo "" >> "$MEETUP_FILE"
  echo "## [Teilnehmerliste](./attendees.md)" >> "$MEETUP_FILE"
  echo "" >> "$MEETUP_FILE"
  echo -e "${GREEN}✓ Created $MEETUP_FILE${NC}"
else
  echo -e "${YELLOW}! $MEETUP_FILE already exists${NC}"
fi

# 2. Create photos directory if it doesn't exist
if [ ! -d "$IMG_DIR" ]; then
  mkdir -p "$IMG_DIR"
  echo -e "${GREEN}✓ Created directory $IMG_DIR${NC}"
else
  echo -e "${YELLOW}! Directory $IMG_DIR already exists${NC}"
fi

# 3. Create fotos file with placeholder images
if [ ! -f "$FOTOS_FILE" ]; then
  echo "# Fotos" > "$FOTOS_FILE"
  echo "" >> "$FOTOS_FILE"
  # Check if photos directory has images
  if [ -d "$IMG_DIR" ] && [ "$(ls -A "$IMG_DIR")" ]; then
    # Add existing photos
    for photo_file in "$IMG_DIR"/*; do
      if [ -f "$photo_file" ]; then
        basename=$(basename "$photo_file")
        echo "![The Rust Meetup Foto](./img/meetup${NEXT_NUM}/${basename})" >> "$FOTOS_FILE"
      fi
    done
  else
    # Add placeholder photos (3 photos with standard naming)
    for i in 1 2 3; do
      echo "![The Rust Meetup${i} Foto](./img/meetup${NEXT_NUM}/meetup${NEXT_NUM}_${i}.jpg)" >> "$FOTOS_FILE"
    done
  fi
  echo -e "${GREEN}✓ Created $FOTOS_FILE${NC}"
else
  echo -e "${YELLOW}! $FOTOS_FILE already exists${NC}"
fi

# 4. Create temporary directory for photo uploads
if [ ! -d "$TEMP_IMG_DIR" ]; then
  mkdir -p "$TEMP_IMG_DIR"
  echo -e "${YELLOW}→ Photo directory created: $TEMP_IMG_DIR${NC}"
  echo -e "${YELLOW}  Please add photos here and run: $0 $NEXT_NUM process-photos${NC}"
else
  echo -e "${YELLOW}! Temporary photo directory already exists: $TEMP_IMG_DIR${NC}"
fi

# 5. Process photos if specified
if [ "$2" == "process-photos" ]; then
  if [ -d "$TEMP_IMG_DIR" ] && [ "$(ls -A "$TEMP_IMG_DIR")" ]; then
    echo ""
    echo "Processing photos..."
    photo_count=1
    for photo_file in "$TEMP_IMG_DIR"/*; do
      if [ -f "$photo_file" ]; then
        extension="${photo_file##*.}"
        extension="${extension,,}" # convert to lowercase
        new_name="meetup${NEXT_NUM}_${photo_count}.${extension}"
        cp "$photo_file" "${IMG_DIR}/${new_name}"
        echo "  ![The Rust Meetup Foto](./img/meetup${NEXT_NUM}/${new_name})" >> "$FOTOS_FILE"
        echo -e "${GREEN}✓ Processed: $new_name${NC}"
        photo_count=$((photo_count + 1))
      fi
    done

    # Clean up temp directory
    rm -rf "$TEMP_IMG_DIR"
    echo -e "${GREEN}✓ Cleaned up temporary directory${NC}"
  else
    echo -e "${YELLOW}! No photos found in $TEMP_IMG_DIR${NC}"
  fi
fi

# 6. Update introduction.md with next meetup link (if it has a date link)
# Replace existing meetup link with the new one
if grep -q "\[Augsburg Rust Meetup #[0-9]*\](./Meetup_[0-9]*.md)" "$INTRO_FILE"; then
  sed -i -E "s#\[Augsburg Rust Meetup #[0-9]+\]\(\./Meetup_[0-9]+\.md\)#[Augsburg Rust Meetup #${NEXT_NUM}](./Meetup_${NEXT_NUM}.md)#" "$INTRO_FILE"
  echo -e "${GREEN}✓ Updated $INTRO_FILE${NC}"
else
  echo -e "${YELLOW}! No meetup link found to update in $INTRO_FILE${NC}"
fi

# 7. Update SUMMARY.md: move N-1 to Vergangene and add N as Nächste
if grep -q "# Vorstellung" "$SUMMARY_FILE"; then
  # Update "Nächste" link to point to new meetup
  sed -i -E "s#- \[Nächste\]\(\./Meetup_[0-9]+\.md\)#- [Nächste](./Meetup_${NEXT_NUM}.md)#" "$SUMMARY_FILE"

  # Add previous meetup to Vergangene section (if it's not already there)
  if ! grep -q "Meetup#${PREV_NUM}" "$SUMMARY_FILE"; then
    # Find the "# Vergangene" line and add PREV_NUM entry after it
    sed -i "/# Vergangene/a\\ - [Meetup#${PREV_NUM}](./Meetup_${PREV_NUM}.md)\n    - [Fotos](./MeetupFotos_${PREV_NUM}.md)" "$SUMMARY_FILE"
  fi

  echo -e "${GREEN}✓ Updated $SUMMARY_FILE${NC}"
else
  echo -e "${YELLOW}! Could not find '# Vorstellung' in $SUMMARY_FILE${NC}"
fi

# 8. Update attendees.md: update meetup reference and reset table
if [ -f "$ATTENDEES_FILE" ]; then
  # Update the meetup reference link
  sed -i -E "s### \[Augsburg Rust Meetup #[0-9]+\]\(\./Meetup_[0-9]+\.md\)### [Augsburg Rust Meetup #${NEXT_NUM}](./Meetup_${NEXT_NUM}.md)#" "$ATTENDEES_FILE"

  # Clear attendees table: keep header and separator line, delete all data rows after that
  # First, find the line number of the table separator (|---|) and delete everything after
  separator_line=$(grep -n "^|.*-.*|.*-.*|$" "$ATTENDEES_FILE" | head -1 | cut -d: -f1)
  if [ -n "$separator_line" ]; then
    sed -i "$((separator_line + 1)),\$d" "$ATTENDEES_FILE"
    # Ensure file ends with newline
    sed -i -e '$a\' "$ATTENDEES_FILE"
  fi

  echo -e "${GREEN}✓ Updated $ATTENDEES_FILE${NC}"
else
  echo -e "${YELLOW}! $ATTENDEES_FILE not found${NC}"
fi

# 8b. Remove attendees.md link from previous meetup and add fotos link instead
PREV_MEETUP_FILE="${SRC_DIR}/Meetup_${PREV_NUM}.md"
NEXT_MEETUP_FILE="${SRC_DIR}/Meetup_${NEXT_NUM}.md"
PREV_FOTOS_FILE="${SRC_DIR}/MeetupFotos_${PREV_NUM}.md"

# Create MeetupFotos file for previous meetup if it doesn't exist
if [ ! -f "$PREV_FOTOS_FILE" ]; then
  echo "# Fotos" > "$PREV_FOTOS_FILE"
  echo "" >> "$PREV_FOTOS_FILE"
  # Add placeholder photos (3 photos with standard naming)
  for i in 1 2 3; do
    echo "![The Rust Meetup${i} Foto](./img/meetup${PREV_NUM}/meetup${PREV_NUM}_${i}.jpg)" >> "$PREV_FOTOS_FILE"
  done
  echo -e "${GREEN}✓ Created $PREV_FOTOS_FILE${NC}"
fi

# Replace attendees link with fotos link in previous meetup
if [ -f "$PREV_MEETUP_FILE" ]; then
  sed -i "s/## \[Teilnehmerliste\](\.\/attendees\.md)/## [Fotos](.\/MeetupFotos_${PREV_NUM}.md)/" "$PREV_MEETUP_FILE"
  echo -e "${GREEN}✓ Replaced attendees link with fotos link in Meetup #${PREV_NUM}${NC}"
fi

# Ensure attendees link exists in new meetup
if [ -f "$NEXT_MEETUP_FILE" ]; then
  if ! grep -q "\[Teilnehmerliste\]" "$NEXT_MEETUP_FILE"; then
    echo "" >> "$NEXT_MEETUP_FILE"
    echo "## [Teilnehmerliste](./attendees.md)" >> "$NEXT_MEETUP_FILE"
    echo "" >> "$NEXT_MEETUP_FILE"
  fi
  echo -e "${GREEN}✓ Ensured attendees link in Meetup #${NEXT_NUM}${NC}"
fi

# 9. Validation
echo ""
echo "=== Validation ==="
checklist_complete=true

# Check Meetup file
if [ -f "$MEETUP_FILE" ]; then
  echo -e "${GREEN}✓ Meetup file exists${NC}"
else
  echo -e "\033[0;31m✗ Meetup file missing${NC}"
  checklist_complete=false
fi

# Check Fotos file
if [ -f "$FOTOS_FILE" ]; then
  echo -e "${GREEN}✓ Fotos file exists${NC}"
else
  echo -e "\033[0;31m✗ Fotos file missing${NC}"
  checklist_complete=false
fi

# Check IMG directory
if [ -d "$IMG_DIR" ]; then
  echo -e "${GREEN}✓ Photos directory exists${NC}"
else
  echo -e "\033[0;31m✗ Photos directory missing${NC}"
  checklist_complete=false
fi

# Check if introduction.md contains the next meetup
if grep -q "Meetup #${NEXT_NUM}" "$INTRO_FILE"; then
  echo -e "${GREEN}✓ introduction.md updated${NC}"
else
  echo -e "\033[0;31m✗ introduction.md not properly updated${NC}"
  checklist_complete=false
fi

# Check if SUMMARY.md contains the meetup entry
if grep -q "Meetup#${NEXT_NUM}" "$SUMMARY_FILE"; then
  echo -e "${GREEN}✓ SUMMARY.md updated with Meetup #${NEXT_NUM}${NC}"
else
  echo -e "\033[0;31m✗ SUMMARY.md not properly updated${NC}"
  checklist_complete=false
fi

# Check if SUMMARY.md contains the previous meetup in Vergangene section
if grep -q "Meetup#${PREV_NUM}" "$SUMMARY_FILE"; then
  echo -e "${GREEN}✓ SUMMARY.md updated with Meetup #${PREV_NUM} in Vergangene${NC}"
else
  echo -e "\033[0;31m✗ SUMMARY.md missing Meetup #${PREV_NUM} in Vergangene${NC}"
  checklist_complete=false
fi

# Check if attendees.md updated with correct meetup number
if grep -q "Meetup #${NEXT_NUM}" "$ATTENDEES_FILE"; then
  echo -e "${GREEN}✓ attendees.md updated with correct meetup number${NC}"
else
  echo -e "\033[0;31m✗ attendees.md not properly updated${NC}"
  checklist_complete=false
fi

# Check if attendees table was properly cleared
table_data_count=$(grep -c "^|.*|.*|$" "$ATTENDEES_FILE" | grep -v "^| Name" | grep -v "^|.*-.*|" || true)
if [ "$table_data_count" -eq 0 ] 2>/dev/null || [ -z "$(grep "^| [^|-]" "$ATTENDEES_FILE" 2>/dev/null)" ]; then
  echo -e "${GREEN}✓ attendees table cleared${NC}"
else
  echo -e "\033[0;31m✗ attendees table not properly cleared${NC}"
  checklist_complete=false
fi

# Check if attendees link was replaced with fotos link in previous meetup
if [ -f "$PREV_MEETUP_FILE" ]; then
  if grep -q "## \[Fotos\](./MeetupFotos_${PREV_NUM}.md)" "$PREV_MEETUP_FILE"; then
    echo -e "${GREEN}✓ attendees link replaced with fotos link in Meetup #${PREV_NUM}${NC}"
  elif ! grep -q "\[Teilnehmerliste\]" "$PREV_MEETUP_FILE"; then
    echo -e "${GREEN}✓ attendees link removed from Meetup #${PREV_NUM}${NC}"
  else
    echo -e "\033[0;31m✗ attendees link still in Meetup #${PREV_NUM}${NC}"
    checklist_complete=false
  fi
fi

# Check if MeetupFotos file was created for previous meetup
if [ -f "$PREV_FOTOS_FILE" ]; then
  echo -e "${GREEN}✓ MeetupFotos_${PREV_NUM}.md created${NC}"
else
  echo -e "\033[0;31m✗ MeetupFotos_${PREV_NUM}.md not found${NC}"
  checklist_complete=false
fi

# Check if attendees link exists in new meetup
if [ -f "$NEXT_MEETUP_FILE" ]; then
  if grep -q "\[Teilnehmerliste\]" "$NEXT_MEETUP_FILE"; then
    echo -e "${GREEN}✓ attendees link added to Meetup #${NEXT_NUM}${NC}"
  else
    echo -e "\033[0;31m✗ attendees link missing from Meetup #${NEXT_NUM}${NC}"
    checklist_complete=false
  fi
fi

# Check if MeetupFotos file has photo entries
if grep -q "img/meetup${NEXT_NUM}" "$FOTOS_FILE"; then
  echo -e "${GREEN}✓ MeetupFotos_${NEXT_NUM}.md has photo entries${NC}"
else
  echo -e "\033[0;31m✗ MeetupFotos_${NEXT_NUM}.md missing photo entries${NC}"
  checklist_complete=false
fi

echo ""
if [ "$checklist_complete" = true ]; then
  echo -e "${GREEN}Everything done!${NC}"
  echo ""
  echo "Next steps:"
  echo "1. Edit $MEETUP_FILE to add date, time, and agenda"
  echo "2. (Optional) Add actual photos to: $TEMP_IMG_DIR"
  echo "3. (Optional) Run: $0 $NEXT_NUM process-photos to replace placeholder images"
else
  echo -e "\033[0;31m⚠ Some tasks are incomplete. Please review above.${NC}"
  exit 1
fi