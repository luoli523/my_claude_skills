# My Claude Skills

个人收藏和管理的 Claude Skills 集合。通过 `skills.yaml` 清单统一跟踪多个 GitHub 仓库和本地 Skills，使用 `install.sh` 一键克隆仓库并创建符号链接到 `~/.claude/skills/`。

## Quick Start

```bash
# 安装所有 skills（克隆仓库 + 创建符号链接）
./install.sh

# 预览模式，不做实际修改
./install.sh --dry-run

# 列出所有已管理的 skills 及其状态
./install.sh --list

# 清理失效的符号链接
./install.sh --cleanup
```

**前置依赖：** `python3` + `PyYAML`（脚本会自动安装）

## 工作原理

1. `skills.yaml` 定义 skill 来源：GitHub 仓库和本地 skills
2. `install.sh` 克隆仓库到 `.repos/`，扫描含 `SKILL.md` 的目录，在 `~/.claude/skills/` 创建符号链接
3. 重复运行时自动检查远程仓库更新——比较本地与远程 commit hash，有更新才拉取，并显示变更的 commit 摘要（如 `Updated repo (abc1234 -> def5678)`）；已是最新则显示 `Up-to-date`
4. 符号链接指向 `.repos/` 中的目录，仓库更新后 symlink 自动指向最新内容，无需重建链接
5. 本地 skills 优先级高于同名的仓库 skills

## 添加新仓库

编辑 `skills.yaml`：

```yaml
repos:
  # 仓库内含多个 skill 子目录
  my-skills-collection:
    url: https://github.com/user/repo.git
    branch: main
    skills_path: "."         # 扫描路径，"." 表示根目录
    include:                 # 可选：只安装指定 skills
      - skill-a
      - skill-b

  # 仓库本身就是一个 skill
  my-single-skill:
    url: https://github.com/user/single-skill.git
    branch: main
    single_skill: true       # 根目录有 SKILL.md
```

然后运行 `./install.sh`。

---

## 跟踪的 Skill 来源

| 仓库 | 地址 | Skills 数量 |
|------|------|-------------|
| awesome-claude-skills | https://github.com/ComposioHQ/awesome-claude-skills | ~29 |
| baoyu-skills | https://github.com/JimLiu/baoyu-skills | 15 |
| remotion-skills | https://github.com/remotion-dev/skills | 1 |
| anything-to-notebooklm | https://github.com/joeseesun/anything-to-notebooklm | 1 |
| **本仓库（local）** | — | 1 |

---

## 本仓库 Skills（local）

| Skill | 说明 |
|-------|------|
| [huiwang-writing-style](./huiwang-writing-style/) | 《回望灯火阑珊》写作风格指南，温情现实主义青春文学创作，适用于成长小说、考研/奋斗题材 |

---

## awesome-claude-skills

来源：[ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)（社区精选 Claude Skills 合集）

| Skill | 说明 |
|-------|------|
| [artifacts-builder](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/artifacts-builder) | 使用 React、Tailwind CSS、shadcn/ui 构建复杂的多组件 HTML Artifact |
| [brand-guidelines](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/brand-guidelines) | 将 Anthropic 官方品牌配色和排版风格应用到 Artifact |
| [canvas-design](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/canvas-design) | 基于设计哲学创作 PNG/PDF 视觉艺术作品（海报、设计图等） |
| [changelog-generator](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/changelog-generator) | 从 Git 提交历史自动生成面向用户的更新日志 |
| [competitive-ads-extractor](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/competitive-ads-extractor) | 从广告库（Facebook、LinkedIn 等）提取并分析竞品广告策略 |
| [connect](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/connect) | 连接 Gmail、Slack、GitHub、Notion 等 1000+ 应用，执行实际操作 |
| [connect-apps](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/connect-apps) | 连接外部应用（Gmail、Slack、GitHub），执行发邮件、建 Issue 等操作 |
| [content-research-writer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/content-research-writer) | 辅助高质量内容写作：调研、引用、优化开头、迭代大纲 |
| [developer-growth-analysis](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/developer-growth-analysis) | 分析 Claude Code 聊天历史，识别编码模式和成长空间，推送学习报告 |
| [domain-name-brainstormer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/domain-name-brainstormer) | 生成创意域名并检查 .com/.io/.dev/.ai 等可用性 |
| [file-organizer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/file-organizer) | 智能整理文件和文件夹：理解上下文、查找重复、建议更优结构 |
| [image-enhancer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/image-enhancer) | 提升图片（尤其截图）的分辨率、清晰度和锐度 |
| [internal-comms](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/internal-comms) | 撰写各类内部沟通文档（状态报告、通讯、FAQ、事故报告等） |
| [invoice-organizer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/invoice-organizer) | 自动整理发票和收据：提取信息、统一命名、分类归档 |
| [langsmith-fetch](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/langsmith-fetch) | 从 LangSmith Studio 获取执行追踪，调试 LangChain/LangGraph Agent |
| [lead-research-assistant](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/lead-research-assistant) | 搜索目标公司，提供高质量潜在客户线索和外联策略 |
| [mcp-builder](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/mcp-builder) | 创建 MCP（模型上下文协议）服务器的指南，支持 Python 和 TypeScript |
| [meeting-insights-analyzer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/meeting-insights-analyzer) | 分析会议记录，发现沟通模式和行为洞察，提供改进建议 |
| [raffle-winner-picker](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/raffle-winner-picker) | 从列表或 Google Sheets 中随机抽取获奖者，确保公平透明 |
| [skill-creator](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/skill-creator) | 创建或更新 Claude Skill 的指南 |
| [skill-share](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/skill-share) | 创建 Claude Skill 并通过 Slack 自动分享给团队 |
| [slack-gif-creator](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/slack-gif-creator) | 创建适配 Slack 尺寸约束的动画 GIF |
| [tailored-resume-generator](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/tailored-resume-generator) | 分析职位描述并生成定制简历，突出相关经验和技能 |
| [template-skill](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/template-skill) | Skill 模板/占位符，用于创建新 Skill 的起点 |
| [theme-factory](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/theme-factory) | 为 Artifact 应用主题样式的工具包，含 10 套预设主题 |
| [twitter-algorithm-optimizer](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/twitter-algorithm-optimizer) | 基于 Twitter 开源算法分析并优化推文，提升曝光和互动 |
| [video-downloader](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/video-downloader) | 下载 YouTube 视频，支持自定义画质、格式和纯音频 MP3 |
| [webapp-testing](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/webapp-testing) | 使用 Playwright 测试本地 Web 应用的 UI 功能 |

---

## baoyu-skills

来源：[JimLiu/baoyu-skills](https://github.com/JimLiu/baoyu-skills)（暴雨系列 Skills 合集）

| Skill | 说明 |
|-------|------|
| [baoyu-article-illustrator](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-article-illustrator) | 分析文章结构，定位需要配图的位置，以「类型 x 风格」二维方式生成插图 |
| [baoyu-comic](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-comic) | 知识漫画创作器，支持多种画风和语调，生成原创教育漫画 |
| [baoyu-compress-image](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-compress-image) | 将图片压缩为 WebP（默认）或 PNG 格式，自动选择最佳压缩工具 |
| [baoyu-cover-image](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-cover-image) | 以五维参数（类型、色板、渲染、文字、氛围）生成文章封面图 |
| [baoyu-danger-gemini-web](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-danger-gemini-web) | 通过逆向工程的 Gemini Web API 生成图片和文本，支持多轮对话 |
| [baoyu-danger-x-to-markdown](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-danger-x-to-markdown) | 将 X（Twitter）推文和文章转换为带 YAML 前言的 Markdown |
| [baoyu-format-markdown](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-format-markdown) | 格式化纯文本或 Markdown：添加前言、标题、摘要、加粗、列表等 |
| [baoyu-image-gen](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-image-gen) | 基于 OpenAI/Google/DashScope API 的 AI 图片生成，支持文生图和参考图 |
| [baoyu-infographic](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-infographic) | 生成专业信息图，20 种布局和 17 种视觉风格自由组合 |
| [baoyu-markdown-to-html](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-markdown-to-html) | Markdown 转带样式 HTML，兼容微信公众号，支持代码高亮和数学公式 |
| [baoyu-post-to-wechat](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-post-to-wechat) | 通过 API 或 Chrome CDP 发布内容到微信公众号，支持文章和图文消息 |
| [baoyu-post-to-x](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-post-to-x) | 通过真实 Chrome 浏览器发布推文、图片、视频和长文到 X（Twitter） |
| [baoyu-slide-deck](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-slide-deck) | 从内容生成专业演示文稿幻灯片图片 |
| [baoyu-url-to-markdown](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-url-to-markdown) | 通过 Chrome CDP 抓取任意网页并转换为 Markdown |
| [baoyu-xhs-images](https://github.com/JimLiu/baoyu-skills/tree/main/skills/baoyu-xhs-images) | 生成小红书风格信息图系列，10 种视觉风格和 8 种布局 |

---

## remotion-skills

来源：[remotion-dev/skills](https://github.com/remotion-dev/skills)（Remotion 官方 Skills）

| Skill | 说明 |
|-------|------|
| [remotion](https://github.com/remotion-dev/skills/tree/main/skills/remotion) | Remotion 视频创作框架最佳实践，使用 React 编程式生成视频，含 30+ 规则指南 |

---

## anything-to-notebooklm

来源：[joeseesun/anything-to-notebooklm](https://github.com/joeseesun/anything-to-notebooklm)

| Skill | 说明 |
|-------|------|
| [anything-to-notebooklm](https://github.com/joeseesun/anything-to-notebooklm) | 多源内容智能处理器：支持微信公众号、网页、YouTube、PDF、Markdown 等，自动上传到 NotebookLM 并生成播客/PPT/思维导图等多种格式 |
