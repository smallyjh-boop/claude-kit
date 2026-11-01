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
