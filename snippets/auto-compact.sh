# --- 自动压缩上下文：用到 70% 就自动压缩（默认快满才压缩），保持自动压缩开启 ---
if [ ! -f ~/.claude/settings.json ]; then
  echo '{ "env": { "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70" } }' > ~/.claude/settings.json
elif command -v node >/dev/null 2>&1; then
  node -e 'const f=process.argv[1],fs=require("fs");const j=JSON.parse(fs.readFileSync(f,"utf8"));j.env=Object.assign({},j.env);if(!j.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE)j.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE="70";fs.writeFileSync(f,JSON.stringify(j,null,2)+"\n")' ~/.claude/settings.json
elif command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys;f=sys.argv[1];j=json.load(open(f));j.setdefault("env",{}).setdefault("CLAUDE_AUTOCOMPACT_PCT_OVERRIDE","70");json.dump(j,open(f,"w"),indent=2,ensure_ascii=False)' ~/.claude/settings.json
else
  echo "⚠️ 没有 node / python3，请手动在 ~/.claude/settings.json 的 env 里加 CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70"
fi
command -v claude >/dev/null 2>&1 && claude config set -g autoCompactEnabled true >/dev/null 2>&1 || true
