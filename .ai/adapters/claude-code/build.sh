#!/usr/bin/env bash
# Adapter: Claude Code
# Reads  : .ai/skills/<name>/{SKILL.md,meta.yml}
# Writes : .claude/skills/<name>/SKILL.md (with frontmatter: name, description)
# Idempotent: re-running produces identical output.
# Pure bash, no external dependencies beyond coreutils.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SRC_DIR="$REPO_ROOT/.ai/skills"
DST_DIR="$REPO_ROOT/.claude/skills"

if [ ! -d "$SRC_DIR" ]; then
  echo "ERROR: source dir not found: $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$DST_DIR"

# Minimal YAML scalar extractor: reads "key: value" at column 0.
# Quoted or plain scalars. Does not handle multiline, lists, or nesting.
yaml_get() {
  local file="$1" key="$2"
  awk -v k="$key" '
    $0 ~ "^"k":[[:space:]]" {
      sub("^"k":[[:space:]]+", "", $0)
      # strip surrounding quotes if present
      sub(/^"/, "", $0); sub(/"$/, "", $0)
      sub(/^'\''/, "", $0); sub(/'\''$/, "", $0)
      print
      exit
    }
  ' "$file"
}

count=0
for skill_dir in "$SRC_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  meta="$skill_dir/meta.yml"
  src="$skill_dir/SKILL.md"

  # Skip non-skill entries (README.md, CONTEXT.md live as files, not dirs).
  [ -f "$meta" ] || continue
  [ -f "$src" ] || continue

  name="$(yaml_get "$meta" name)"
  description="$(yaml_get "$meta" description)"

  if [ -z "$name" ] || [ -z "$description" ]; then
    echo "ERROR: missing name or description in $meta" >&2
    exit 1
  fi

  # Defensive check: yaml_get does not handle multi-line scalars (>, |).
  if grep -qE "^(name|description):[[:space:]]*[>|]" "$meta"; then
    echo "ERROR: multi-line YAML scalar in $meta — parser only supports single-line." >&2
    exit 1
  fi

  out_dir="$DST_DIR/$skill_name"
  out_file="$out_dir/SKILL.md"
  mkdir -p "$out_dir"

  {
    echo "<!-- GENERATED FROM .ai/skills/$skill_name — DO NOT EDIT MANUALLY -->"
    echo "---"
    echo "name: $name"
    echo "description: $description"
    echo "---"
    echo
    cat "$src"
  } > "$out_file"

  count=$((count + 1))
  echo "  built: .claude/skills/$skill_name/SKILL.md"
done

echo "Done. $count skill(s) built into .claude/skills/"
