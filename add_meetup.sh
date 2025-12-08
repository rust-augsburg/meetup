#!/bin/bash
# filepath: /home/manczak/meetup/add_meetup.sh

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <next_meetup_number>"
  exit 1
fi

NEXT_NUM="$1"
SRC_DIR="src"
MEETUP_FILE="${SRC_DIR}/Meetup_${NEXT_NUM}.md"
INTRO_FILE="${SRC_DIR}/introduction.md"
SUMMARY_FILE="${SRC_DIR}/SUMMARY.md"

# 1. Create new meetup file if it doesn't exist
if [ ! -f "$MEETUP_FILE" ]; then
  echo "# Augsburg Rust Meetup #${NEXT_NUM}" > "$MEETUP_FILE"
  echo "" >> "$MEETUP_FILE"
  echo "_Hier folgt die Agenda und Notizen für Meetup #${NEXT_NUM}_." >> "$MEETUP_FILE"
  echo "Created $MEETUP_FILE"
else
  echo "$MEETUP_FILE already exists."
fi

# 2. Update introduction.md
sed -i -E "s#Nächste Termin: \[Augsburg Rust Meetup #[0-9]+\]\(\./Meetup_[0-9]+\.md\)#Nächste Termin: [Augsburg Rust Meetup #${NEXT_NUM}](./Meetup_${NEXT_NUM}.md)#" "$INTRO_FILE"
echo "Updated $INTRO_FILE"

# 3. Update SUMMARY.md (add at the end of the list)
if ! grep -q "\[Meetup ${NEXT_NUM}\](Meetup_${NEXT_NUM}.md)" "$SUMMARY_FILE"; then
  echo "* [Meetup ${NEXT_NUM}](Meetup_${NEXT_NUM}.md)" >> "$SUMMARY_FILE"
  echo "Updated $SUMMARY_FILE"
else
  echo "$SUMMARY_FILE already contains Meetup ${NEXT_NUM}."
fi

echo "Done. Please review the changes."