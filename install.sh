# === Claude Code 省 token 套件：在项目根目录粘贴运行 ===
mkdir -p ~/.claude/commands ~/.claude/agents docs
cat > ~/.claude/commands/commit.md <<'CCKIT_EOF'
---
description: 生成规范的提交信息并提交（Haiku）
model: haiku
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*)
---
1. 看 `git status` 和 `git diff`。
2. 按格式写提交信息：`feat: / fix: / refactor: / docs:` + 中文说明，一行标题，必要时加 2–3 行正文。
3. 如果改动包含多件不相关的事，建议我拆成几次提交，先问我。
4. 否则 `git add -A` 并提交，回复提交信息。不要 push。
CCKIT_EOF
cat > ~/.claude/commands/fix.md <<'CCKIT_EOF'
---
description: 修 bug：定位 → 最小改动修复 → 验证（Sonnet）
argument-hint: <现象 / 报错 / 文件路径>
model: sonnet
---
问题：$ARGUMENTS

1. 先定位根因：给了路径就直接看；没给就交给 code-searcher 查。
2. 用最小改动修复，不顺手重构其他代码。
3. 补一个能复现该 bug 的测试。
4. 交给 test-runner 验证。
5. 回复：根因一句话 + 改了什么。修 2 次仍失败就停下，告诉我建议用 /model opus 接手。
CCKIT_EOF
cat > ~/.claude/commands/go.md <<'CCKIT_EOF'
---
description: 执行 PLAN.md 里下一个未完成任务（Sonnet）
argument-hint: [可选：任务编号，如 T3]
model: sonnet
---
1. 读 docs/PLAN.md，执行任务 $ARGUMENTS；没指定就执行第一个未勾选的任务。只做这一个。
2. 只读该任务涉及的文件，找不到位置时交给 code-searcher。
3. 按 CLAUDE.md 规范实现，附带测试。
4. 交给 test-runner 跑测试和 lint，失败就修，最多修 3 轮，还不行就停下告诉我。
5. 在 PLAN.md 勾选该任务，更新 docs/HANDOVER.md。
6. 回复：改了哪些文件、为什么，3–5 行。
CCKIT_EOF
cat > ~/.claude/commands/handover.md <<'CCKIT_EOF'
---
description: 结束会话前更新交接文件，然后可以放心 /clear（Haiku）
model: haiku
---
根据本次会话做的事，更新 docs/HANDOVER.md：
- 最后更新日期
- 当前状态（已完成 / 进行中 / 下一步）
- 新发现的坑和重要决定
- 本次改动的文件

保持简短，整个文件不超过 60 行，旧的已完成项可以合并成一行。
完成后回复：“已交接，可以 /clear。”
CCKIT_EOF
cat > ~/.claude/commands/i18n.md <<'CCKIT_EOF'
---
description: 补齐 zh / th / en 多语言文案（Haiku）
argument-hint: [可选：文件或模块]
model: haiku
---
范围：$ARGUMENTS（没写就是整个 i18n 目录）

交给 translator 子代理：以 zh 为源，补齐缺失的 th / en。
完成后回复：补了多少条，哪些需要我人工确认。
CCKIT_EOF
cat > ~/.claude/commands/init-project.md <<'CCKIT_EOF'
---
description: 给现有项目自动填写 CLAUDE.md（Sonnet）
model: sonnet
---
交给 code-searcher 子代理，查看 package.json / pyproject / 目录结构 / 配置文件，弄清：
技术栈、常用命令、重要目录。

然后填写 CLAUDE.md 里所有 `<...>` 占位符，删掉项目用不到的行。
项目名称和一句话描述不确定就问我。整个 CLAUDE.md 保持在 80 行以内。
CCKIT_EOF
cat > ~/.claude/commands/plan.md <<'CCKIT_EOF'
---
description: 规划新功能，拆成小任务写进 docs/PLAN.md（Opus）
argument-hint: <要做的功能>
model: opus
---
需求：$ARGUMENTS

1. 读 CLAUDE.md、docs/HANDOVER.md。需要了解代码时交给 code-searcher 子代理。
2. 把需求拆成 3–8 个小任务，每个任务能在一个会话内完成。
3. 每个任务写清：涉及文件、做法要点、验收标准。
4. 写明“不做的事”。
5. 覆盖写入 docs/PLAN.md（格式见文件现有模板），不要写代码。
6. 最后用 5 行以内总结方案，有需要我决定的地方列出来问我。
CCKIT_EOF
cat > ~/.claude/commands/review.md <<'CCKIT_EOF'
---
description: 审查当前未提交的改动（交给 reviewer 子代理 / Opus）
---
把当前 `git diff`（含未暂存改动）交给 reviewer 子代理审查。
只把它的结论原样转给我，不要自己再重复审查一遍。
CCKIT_EOF
cat > ~/.claude/commands/test.md <<'CCKIT_EOF'
---
description: 跑测试 + lint + 构建，只看结论（Haiku）
model: haiku
---
交给 test-runner 子代理依次运行 CLAUDE.md 里的测试、lint、构建命令。
只回复它的结论，不贴日志。
CCKIT_EOF
cat > ~/.claude/agents/code-searcher.md <<'CCKIT_EOF'
---
name: code-searcher
description: 在代码库里查找文件、函数、调用关系、某段逻辑在哪。需要大范围搜索时使用，只返回结论。
tools: Glob, Grep, Read
model: haiku
---
你是代码搜索助手。只读不改。

- 用 Glob / Grep 定位，只读必要的片段，不整文件阅读大文件。
- 跳过 node_modules、dist、build、.next、日志、lock 文件。
- 返回格式：
  - 结论：一两句话
  - 位置：`路径:行号` — 一句说明（最多 10 条）
- 不要贴大段代码，不要给修改建议，除非被要求。
CCKIT_EOF
cat > ~/.claude/agents/reviewer.md <<'CCKIT_EOF'
---
name: reviewer
description: 审查最近的改动，找 bug、安全问题、性能问题、违反 CLAUDE.md 规范的地方。
tools: Bash, Read, Grep, Glob
model: opus
---
你是严格的代码审查员。只读不改。

- 用 `git diff` 看改动范围，只审查改动及其直接相关代码。
- 按严重程度列出问题：🔴 必须修 / 🟡 建议修 / 🟢 可选
- 每条：`文件:行号` + 问题 + 修复建议（一两句）
- 没问题就直接说没问题，不要凑数。
CCKIT_EOF
cat > ~/.claude/agents/test-runner.md <<'CCKIT_EOF'
---
name: test-runner
description: 运行测试、lint、构建命令并分析报错。只汇报结论和失败原因，不贴完整日志。
tools: Bash, Read, Grep
model: haiku
---
你负责跑命令和读报错。

- 命令以 CLAUDE.md 里的“常用命令”为准。
- 不修改任何文件。
- 返回格式：
  - 结果：通过 / 失败（X 个）
  - 每个失败：`文件:行号`，一句原因，最可能的修复方向
- 日志只摘最关键的几行，总长度不超过 30 行。
CCKIT_EOF
cat > ~/.claude/agents/translator.md <<'CCKIT_EOF'
---
name: translator
description: 翻译和补齐多语言文案（中文 zh / 泰文 th / 英文 en），保持 i18n 文件结构不变。
tools: Read, Edit, Glob, Grep
model: haiku
---
你负责 i18n 文案。

- 以中文为源，补齐缺失的 th / en key；已有翻译不改，除非明显错误。
- 保持 JSON / 文件结构、key 顺序、占位符（如 {name}、{{count}}）完全不变。
- 泰文用自然、口语友好的表达，面向普通用户。
- 完成后只汇报：补了多少条、哪些 key 需要人工确认。
CCKIT_EOF
[ -f CLAUDE.md ] || cat > CLAUDE.md <<'CCKIT_EOF'
# 项目说明（Claude 每次会话自动读取，保持简短）

## 项目
- 名称：<项目名>
- 一句话：<这个项目做什么、给谁用>
- 当前阶段：<MVP / 上线中 / 维护>

## 技术栈
- 前端：<如 Next.js 15 + TypeScript + Tailwind>
- 后端：<如 Node.js / Python FastAPI>
- 数据库：<如 PostgreSQL / SQLite>
- 移动端：<如 React Native / Flutter，没有就删掉>
- 部署：<如 NAS Docker / Vercel>

## 常用命令
- 安装：`<npm install>`
- 开发：`<npm run dev>`
- 测试：`<npm test>`
- 构建：`<npm run build>`
- 代码检查：`<npm run lint>`

## 目录结构（只写重要的）
- `src/app/`：页面
- `src/api/`：接口
- `src/lib/`：工具函数
- `src/i18n/`：多语言文案（zh / th / en）
- `docs/`：PLAN.md、HANDOVER.md

## 规范
- 用 TypeScript，不写 any
- 函数小而单一，一个文件不超过 300 行
- 新功能必须附带最少一个测试
- 用户可见文字一律走 i18n，不在代码里写死
- 提交信息格式：`feat: / fix: / refactor: / docs:` + 中文说明

## 禁止
- 不要修改：`<.env、迁移文件、第三方 SDK 目录等>`
- 不要自行安装新依赖，需要时先问我
- 不要一次性大范围重构，除非我明确要求

## 工作方式（省 token）
- 开始新任务前先读 `docs/HANDOVER.md` 和 `docs/PLAN.md`
- 需要在代码库里大范围查找时，交给 `code-searcher` 子代理，不要自己逐个打开文件
- 跑测试、看报错交给 `test-runner` 子代理，只要结论
- 翻译多语言文案交给 `translator` 子代理
- 只读完成任务所需的文件；不读 node_modules、dist、日志、大 JSON
- 回复简洁：说改了什么、为什么，不要复述整段代码
- 任务做完后更新 `docs/HANDOVER.md`

## Compact instructions（自动压缩上下文时保留什么）
- 保留：当前任务和进度、改过的文件路径、未解决的报错、已做的决定和原因、下一步
- 丢弃：已读文件的全文、命令完整日志、已解决问题的排查过程
- 压缩前如有重要进展，先更新 `docs/HANDOVER.md`
CCKIT_EOF
[ -f docs/PLAN.md ] || cat > docs/PLAN.md <<'CCKIT_EOF'
# 开发计划（由 /plan 生成，/go 逐条执行）

## 目标
<这一阶段要做成什么>

## 任务清单
- [ ] T1：<任务>｜涉及文件：<路径>｜验收：<怎样算完成>
- [ ] T2：
- [ ] T3：

## 不做的事
- <明确排除的范围，防止 AI 越做越多>
CCKIT_EOF
[ -f docs/HANDOVER.md ] || cat > docs/HANDOVER.md <<'CCKIT_EOF'
# 交接记录（每次会话结束更新，下次新会话只读这里）

## 最后更新
<日期>

## 当前状态
- 已完成：
  - <功能 A>
- 进行中：
  - <功能 B：做到哪一步>
- 下一步：
  1. <最优先的事>
  2. <其次>

## 已知问题 / 坑
- <如：某接口在 token 过期时返回 500，待修>

## 重要决定（以及原因）
- <如：支付用 Stripe 而不是 Omise，因为……>

## 本次改动的文件
- <路径>：<改了什么>
CCKIT_EOF
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
# 已有的 CLAUDE.md 不覆盖，只在缺少时追加压缩说明
if [ -f CLAUDE.md ] && ! grep -q "Compact instructions" CLAUDE.md; then
  cat >> CLAUDE.md <<'CCKIT_EOF'

## Compact instructions（自动压缩上下文时保留什么）
- 保留：当前任务和进度、改过的文件路径、未解决的报错、已做的决定和原因、下一步
- 丢弃：已读文件的全文、命令完整日志、已解决问题的排查过程
- 压缩前如有重要进展，先更新 `docs/HANDOVER.md`
CCKIT_EOF
fi
echo "✅ 安装完成：命令和子代理已装到 ~/.claude，本项目已有的 CLAUDE.md / docs 不会被覆盖（缺压缩说明时只追加一段）；已开启自动压缩（70%）。现在运行 claude，然后输入 /init-project"
