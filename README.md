# claude-kit

Claude Code 省 token 开发套件：斜杠命令 + 子代理 + CLAUDE.md 模板。
贵模型负责想，便宜模型负责做，上下文越短越省。

## 一行安装

在**项目根目录**的终端里运行：

```bash
curl -fsSL https://raw.githubusercontent.com/smallyjh-boop/claude-kit/main/install.sh | bash
```

- 命令和子代理装到 `~/.claude/`，所有项目通用。
- 当前项目里生成 `CLAUDE.md`、`docs/PLAN.md`、`docs/HANDOVER.md`；已存在的不会覆盖。
- 再次运行即可更新命令和子代理。

装好后运行 `claude`，先输入 `/init-project` 自动填写 CLAUDE.md。

## 日常流程

```
/plan 做会员订阅功能    ← Opus 拆任务写进 PLAN.md
/go                      ← Sonnet 做下一个任务（自动测试）
/go                      ← 继续下一个
/review                  ← Opus 审查改动
/commit                  ← Haiku 写提交信息并提交
/handover                ← 更新交接文件
/clear                   ← 清空上下文，下次从 HANDOVER.md 接着做
```

## 命令

| 命令 | 模型 | 用途 |
|---|---|---|
| /init-project | Sonnet | 给项目自动填 CLAUDE.md |
| /plan <需求> | Opus | 规划、拆任务 |
| /go [T3] | Sonnet | 执行下一个（或指定）任务 |
| /fix <问题> | Sonnet | 修 bug，修不好会提示换 Opus |
| /review | Opus | 审查未提交改动 |
| /test | Haiku | 跑测试 / lint / 构建 |
| /i18n [范围] | Haiku | 补齐中 / 泰 / 英文案 |
| /commit | Haiku | 规范提交 |
| /handover | Haiku | 更新交接文件 |

## 子代理

| 名称 | 模型 | 用途 |
|---|---|---|
| code-searcher | Haiku | 搜代码，只返回位置 |
| test-runner | Haiku | 跑命令、读报错 |
| translator | Haiku | 多语言文案 |
| reviewer | Opus | 代码审查 |

## 修改命令

改 `.claude/commands/` 或 `.claude/agents/` 里的文件后，运行 `bash build.sh` 重新生成 `install.sh` 再提交。
