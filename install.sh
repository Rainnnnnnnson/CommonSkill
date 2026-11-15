#!/bin/sh
# 安装 CommonSkill 中的技能到 DSH 技能根目录。
# 用法见 README.md 或运行 ./install.sh --help
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILLS_SRC="$REPO_DIR/skills"

MODE=link
SCOPE=user
FORCE=0

usage() {
  cat <<'EOF'
用法: ./install.sh [选项]

  --user          安装到 ~/.agents/skills（默认，所有项目可用）
  --project       安装到当前目录的 .agents/skills（仅本项目）
  --link          使用软链接（默认；git pull 后自动生效）
  --copy          复制文件而非软链接
  --force         覆盖已存在的同名技能
  -h, --help      显示本帮助
EOF
}

for arg in "$@"; do
  case "$arg" in
    --user) SCOPE=user ;;
    --project) SCOPE=project ;;
    --link) MODE=link ;;
    --copy) MODE=copy ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$SCOPE" = project ]; then
  DEST=$(pwd)/.agents/skills
else
  DEST="$HOME/.agents/skills"
fi

[ -d "$SKILLS_SRC" ] || { echo "找不到技能源目录: $SKILLS_SRC" >&2; exit 1; }
mkdir -p "$DEST"

# 校验技能名：DSH 要求 kebab-case，非法名会被静默丢弃。
# 变量名加 _vn_ 前缀，避免覆盖调用方的循环变量（POSIX sh 无局部变量）。
validate_name() {
  _vn_dir=$1
  _vn_file="$SKILLS_SRC/$_vn_dir/SKILL.md"
  if [ ! -f "$_vn_file" ]; then
    echo "跳过 ${_vn_dir}：缺少 SKILL.md" >&2
    return 1
  fi
  _vn_name=$(awk 'NR==1 && $0!="---"{exit} NR>1 && /^---[[:space:]]*$/{exit} NR>1 && /^name:[[:space:]]*/{sub(/^name:[[:space:]]*/,""); gsub(/[[:space:]"'"'"']/,""); print; exit}' "$_vn_file")
  if [ -z "$_vn_name" ]; then
    echo "跳过 ${_vn_dir}：SKILL.md 缺少 name 字段" >&2
    return 1
  fi
  if ! printf '%s' "$_vn_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    echo "跳过 ${_vn_dir}：name \"${_vn_name}\" 不是 kebab-case，DSH 会静默丢弃" >&2
    return 1
  fi
  if [ "$_vn_name" != "$_vn_dir" ]; then
    echo "警告: ${_vn_dir} 的 name 是 \"$_vn_name\"，与目录名不一致" >&2
  fi
  return 0
}

installed=0
skipped=0

for dir in "$SKILLS_SRC"/*; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  validate_name "$name" || { skipped=$((skipped + 1)); continue; }

  target="$DEST/$name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$FORCE" -eq 1 ]; then
      rm -rf "$target"
    else
      echo "跳过 ${name}：$target 已存在（用 --force 覆盖）"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  if [ "$MODE" = link ]; then
    ln -s "$dir" "$target"
    echo "已链接 $name -> $dir"
  else
    cp -R "$dir" "$target"
    echo "已复制 $name -> $target"
  fi
  installed=$((installed + 1))
done

echo
echo "目标目录: $DEST"
echo "已安装 $installed 个，跳过 $skipped 个"
if [ "$MODE" = link ]; then
  echo "软链接方式：以后 cd 到仓库执行 git pull 即自动更新。"
else
  echo "复制方式：更新需重新运行 ./install.sh --copy --force"
fi
