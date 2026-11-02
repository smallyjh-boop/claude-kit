#!/usr/bin/env bash
# 根据仓库里的模板重新生成 install.sh
set -e
cd "$(dirname "$0")"
OUT=install.sh
{
echo '# === Claude Code 省 token 套件：在项目根目录粘贴运行 ==='
echo 'mkdir -p ~/.claude/commands ~/.claude/agents docs'
for f in .claude/commands/*.md .claude/agents/*.md; do
  echo "cat > ~/$f <<'CCKIT_EOF'"; cat "$f"; echo 'CCKIT_EOF'
done
for f in CLAUDE.md docs/PLAN.md docs/HANDOVER.md; do
  echo "[ -f $f ] || cat > $f <<'CCKIT_EOF'"; cat "$f"; echo 'CCKIT_EOF'
done
cat snippets/auto-compact.sh
# 已有的 CLAUDE.md 不覆盖，只在缺少时追加压缩说明（内容取自 CLAUDE.md 模板）
echo '# 已有的 CLAUDE.md 不覆盖，只在缺少时追加压缩说明'
echo 'if [ -f CLAUDE.md ] && ! grep -q "Compact instructions" CLAUDE.md; then'
echo "  cat >> CLAUDE.md <<'CCKIT_EOF'"
echo
awk '/^## Compact instructions/{p=1} p&&/^## /&&!/^## Compact instructions/{p=0} p' CLAUDE.md
echo 'CCKIT_EOF'
echo 'fi'
echo 'echo "✅ 安装完成：命令和子代理已装到 ~/.claude，本项目已有的 CLAUDE.md / docs 不会被覆盖（缺压缩说明时只追加一段）；已开启自动压缩（70%）。现在运行 claude，然后输入 /init-project"'
} > "$OUT"
echo "已生成 $OUT"
