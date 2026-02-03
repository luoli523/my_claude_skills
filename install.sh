#!/usr/bin/env bash
set -euo pipefail

# Skills Manager for my_claude_skills
# Clones repos defined in skills.yaml and creates symlinks to ~/.claude/skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/skills.yaml"

# --- Defaults ---
DRY_RUN=false
CLEANUP=false
LIST=false

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Usage ---
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Skills Manager - clone repos and symlink skills to ~/.claude/skills/

Options:
  --dry-run   Show what would be done without making changes
  --cleanup   Remove stale managed symlinks
  --list      List all managed skills and their status
  -h, --help  Show this help message

Configuration: skills.yaml
EOF
    exit 0
}

# --- Parse CLI args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  DRY_RUN=true; shift ;;
        --cleanup)  CLEANUP=true; shift ;;
        --list)     LIST=true; shift ;;
        -h|--help)  usage ;;
        *)          echo "Unknown option: $1"; usage ;;
    esac
done

# --- Check config exists ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}Error: $CONFIG_FILE not found${NC}"
    exit 1
fi

# --- Ensure PyYAML ---
ensure_pyyaml() {
    python3 -c "import yaml" 2>/dev/null && return 0
    echo -e "${YELLOW}Installing PyYAML...${NC}"
    pip3 install --user pyyaml >/dev/null 2>&1 || {
        echo -e "${RED}Error: Failed to install PyYAML. Install it manually: pip3 install pyyaml${NC}"
        exit 1
    }
}

ensure_pyyaml

# --- Parse config for bash (repos + local lists only) ---
eval "$(python3 -c "
import yaml, os

with open('$CONFIG_FILE') as f:
    cfg = yaml.safe_load(f)

clone_dir = cfg.get('clone_dir', '.repos')
skills_dir = os.path.expanduser(cfg.get('skills_dir', '~/.claude/skills'))

print(f'CLONE_DIR=\"{clone_dir}\"')
print(f'SKILLS_DIR=\"{skills_dir}\"')

repos = cfg.get('repos', {})
repo_lines = []
for name, rcfg in repos.items():
    url = rcfg.get('url', '')
    branch = rcfg.get('branch', 'main')
    repo_lines.append(f'{name}|{url}|{branch}')
print(f'REPO_ENTRIES=\"{chr(10).join(repo_lines)}\"')
")"

CLONE_DIR_ABS="$SCRIPT_DIR/$CLONE_DIR"

# --- Phase: --list ---
if $LIST; then
    python3 - "$CONFIG_FILE" "$SCRIPT_DIR" "$CLONE_DIR_ABS" "$SKILLS_DIR" <<'PYEOF'
import yaml, os, sys

config_file, script_dir, clone_dir, skills_dir = sys.argv[1:5]

with open(config_file) as f:
    cfg = yaml.safe_load(f)

BLUE, GREEN, NC = '\033[0;34m', '\033[0;32m', '\033[0m'
print(f"{BLUE}=== Managed Skills ==={NC}\n")

# Local skills
local_skills = cfg.get('local', [])
if local_skills:
    print(f"{GREEN}Local skills:{NC}")
    for skill in local_skills:
        link = os.path.join(skills_dir, skill)
        if os.path.islink(link):
            print(f"  {skill} -> {os.readlink(link)}")
        elif os.path.isdir(os.path.join(script_dir, skill)):
            print(f"  {skill} (not linked)")
        else:
            print(f"  {skill} (missing)")
    print()

# Repo skills
for repo_name, rcfg in cfg.get('repos', {}).items():
    print(f"{GREEN}Repo: {repo_name}{NC}")
    single_skill = rcfg.get('single_skill', False)
    repo_dir = os.path.join(clone_dir, repo_name)

    if not os.path.isdir(repo_dir):
        print("  (not cloned yet - run install first)")
    elif single_skill:
        # Repo itself is the skill
        link = os.path.join(skills_dir, repo_name)
        if os.path.islink(link):
            print(f"  {repo_name} -> {os.readlink(link)}")
        else:
            print(f"  {repo_name} (not linked)")
    else:
        skills_path = rcfg.get('skills_path', '.')
        scan_dir = repo_dir
        if skills_path != '.':
            scan_dir = os.path.join(scan_dir, skills_path)
        found = False
        if os.path.isdir(scan_dir):
            for entry in sorted(os.listdir(scan_dir)):
                skill_dir = os.path.join(scan_dir, entry)
                if os.path.isdir(skill_dir) and os.path.isfile(os.path.join(skill_dir, 'SKILL.md')):
                    found = True
                    link = os.path.join(skills_dir, entry)
                    if os.path.islink(link):
                        print(f"  {entry} -> {os.readlink(link)}")
                    else:
                        print(f"  {entry} (not linked)")
        if not found:
            print("  (no skills found)")
    print()
PYEOF
    exit 0
fi

# --- Phase 1: Clone or update repos ---
echo -e "${BLUE}=== Phase 1: Clone/update repos ===${NC}"
mkdir -p "$CLONE_DIR_ABS"

IFS=$'\n'
for entry in $REPO_ENTRIES; do
    repo_name="$(echo "$entry" | cut -d'|' -f1)"
    url="$(echo "$entry" | cut -d'|' -f2)"
    branch="$(echo "$entry" | cut -d'|' -f3)"
    repo_dir="$CLONE_DIR_ABS/$repo_name"

    if [[ -d "$repo_dir/.git" ]]; then
        if ! $DRY_RUN; then
            local_sha="$(git -C "$repo_dir" rev-parse HEAD)"
            git -C "$repo_dir" fetch origin "$branch" --quiet
            remote_sha="$(git -C "$repo_dir" rev-parse "origin/$branch")"
            if [[ "$local_sha" != "$remote_sha" ]]; then
                echo -e "  ${GREEN}Updated${NC} $repo_name (${local_sha:0:7} -> ${remote_sha:0:7})"
                git -C "$repo_dir" reset --hard "origin/$branch" --quiet
            else
                echo -e "  ${BLUE}Up-to-date${NC} $repo_name (${local_sha:0:7})"
            fi
        else
            echo -e "  ${GREEN}Would update${NC} $repo_name"
        fi
    else
        echo -e "  ${GREEN}Cloning${NC} $repo_name..."
        if ! $DRY_RUN; then
            git clone --branch "$branch" --single-branch --quiet "$url" "$repo_dir"
        fi
    fi
done
unset IFS

# --- Phases 2-5: Discover, resolve conflicts, symlink, cleanup (all in Python) ---
python3 - "$CONFIG_FILE" "$SCRIPT_DIR" "$CLONE_DIR_ABS" "$SKILLS_DIR" "$DRY_RUN" "$CLEANUP" <<'PYEOF'
import yaml, os, sys

config_file, script_dir, clone_dir, skills_dir, dry_run_str, cleanup_str = sys.argv[1:7]
dry_run = dry_run_str == "true"
cleanup = cleanup_str == "true"

with open(config_file) as f:
    cfg = yaml.safe_load(f)

# Colors
RED, GREEN, YELLOW, BLUE, NC = (
    '\033[0;31m', '\033[0;32m', '\033[1;33m', '\033[0;34m', '\033[0m'
)

# --- Phase 2: Discover skills ---
print(f"{BLUE}=== Phase 2: Discover skills ==={NC}")

skill_sources = {}   # skill_name -> source_path
skill_repos = {}     # skill_name -> repo_name
conflicts = {}       # skill_name -> description

for repo_name, rcfg in cfg.get('repos', {}).items():
    single_skill = rcfg.get('single_skill', False)
    repo_dir = os.path.join(clone_dir, repo_name)

    if not os.path.isdir(repo_dir):
        if dry_run:
            print(f"  (would scan {repo_name} after cloning)")
        continue

    if single_skill:
        # Repo itself is the skill
        if os.path.isfile(os.path.join(repo_dir, 'SKILL.md')):
            if repo_name in skill_sources:
                conflicts[repo_name] = f"{skill_repos[repo_name]} + {repo_name}"
            else:
                skill_sources[repo_name] = repo_dir
                skill_repos[repo_name] = repo_name
        continue

    skills_path = rcfg.get('skills_path', '.')
    include = rcfg.get('include', [])
    scan_dir = repo_dir
    if skills_path != '.':
        scan_dir = os.path.join(scan_dir, skills_path)

    if not os.path.isdir(scan_dir):
        continue

    for entry in sorted(os.listdir(scan_dir)):
        skill_dir = os.path.join(scan_dir, entry)
        if not os.path.isdir(skill_dir):
            continue
        if not os.path.isfile(os.path.join(skill_dir, 'SKILL.md')):
            continue
        if include and entry not in include:
            continue

        if entry in skill_sources:
            conflicts[entry] = f"{skill_repos[entry]} + {repo_name}"
        else:
            skill_sources[entry] = skill_dir
            skill_repos[entry] = repo_name

# Discover local skills (override repo skills)
for skill in cfg.get('local', []):
    local_dir = os.path.join(script_dir, skill)
    if os.path.isdir(local_dir):
        if skill in skill_sources:
            print(f"  {YELLOW}Local override:{NC} {skill} (replaces {skill_repos[skill]})")
        skill_sources[skill] = local_dir
        skill_repos[skill] = 'local'
        conflicts.pop(skill, None)
    else:
        print(f"  {YELLOW}Warning:{NC} local skill '{skill}' directory not found")

# --- Phase 3: Conflict detection ---
if conflicts:
    print(f"{BLUE}=== Phase 3: Conflict detection ==={NC}")
    for skill, desc in sorted(conflicts.items()):
        print(f"  {RED}Conflict:{NC} '{skill}' found in {desc} - skipping both")
        skill_sources.pop(skill, None)
        skill_repos.pop(skill, None)

print(f"  Found {len(skill_sources)} skills to install")

# --- Phase 4: Create symlinks ---
print(f"{BLUE}=== Phase 4: Create symlinks ==={NC}")
os.makedirs(skills_dir, exist_ok=True)

created = updated = skipped = 0

for skill in sorted(skill_sources):
    source_dir = skill_sources[skill]
    link = os.path.join(skills_dir, skill)

    if os.path.exists(link) and not os.path.islink(link):
        print(f"  {YELLOW}Skip:{NC} {skill} (target exists and is not a symlink)")
        skipped += 1
        continue

    if os.path.islink(link):
        current_target = os.readlink(link)
        if current_target == source_dir:
            skipped += 1
            continue
        print(f"  {GREEN}Update:{NC} {skill} -> {source_dir}")
        if not dry_run:
            os.remove(link)
            os.symlink(source_dir, link)
        updated += 1
    else:
        print(f"  {GREEN}Link:{NC} {skill} -> {source_dir}")
        if not dry_run:
            os.symlink(source_dir, link)
        created += 1

print(f"  Created: {created}, Updated: {updated}, Unchanged: {skipped}")

# --- Phase 5: Cleanup stale symlinks ---
if cleanup:
    print(f"{BLUE}=== Phase 5: Cleanup stale symlinks ==={NC}")
    removed = 0

    if os.path.isdir(skills_dir):
        for entry in sorted(os.listdir(skills_dir)):
            link = os.path.join(skills_dir, entry)
            if not os.path.islink(link):
                continue
            target = os.readlink(link)
            # Only remove symlinks pointing into our project
            if target.startswith(clone_dir) or target.startswith(script_dir):
                if entry not in skill_sources:
                    print(f"  {RED}Remove stale:{NC} {entry} -> {target}")
                    if not dry_run:
                        os.remove(link)
                    removed += 1

    if removed == 0:
        print("  No stale symlinks found")
    else:
        print(f"  Removed: {removed}")

if dry_run:
    print(f"\n{YELLOW}(dry-run mode - no changes were made){NC}")

print(f"{GREEN}Done!{NC}")
PYEOF
