---
name: guige-x-to-blog
description: "将 X 推文下载、整理并改写为中文博客文章，复用原图并按既有博客发布流程交付。触发词：/x-to-blog、x 推文转博客、tweet to blog。"
version: 0.1.0
---

# X 推文转博客文章

一键将 X 推文转为中文博客文章并发布到 luoli523.github.io。

## 语言

**固定中文**：文章内容、标题、描述、标签全部使用中文。与用户的交流语言跟随用户。

## 输入

```
/x-to-blog <tweet_url>
```

- `<tweet_url>`：X 推文链接，如 `https://x.com/user/status/123456`

## 工作流总览

```
X-to-Blog Progress:
- [ ] Phase 1: 下载推文（/baoyu-danger-x-to-markdown）
- [ ] Phase 2: 创建博客文章（/guige-blog-post）
- [ ] Phase 3: 复用原文图片
- [ ] Phase 4: 等待用户提供 cover 图
- [ ] Phase 5: 验证、提交、推送
- [ ] Phase 6: 发布微信公众号（可选）
```

---

## Phase 1: 下载推文

调用 `/baoyu-danger-x-to-markdown` skill 下载推文内容。

1. 按照该 skill 的流程完成 consent 检查、EXTEND.md 加载
2. 运行脚本下载推文，使用 `--download-media` 下载全部图片
3. 记录下载产物路径：
   - Markdown 文件路径（如 `~/Download/x-markdown/{username}/{tweet-id}/xxx.md`）
   - 图片目录路径（如 `~/Download/x-markdown/{username}/{tweet-id}/imgs/`）

**失败处理**：如果下载失败（如需要登录），引导用户设置 `X_AUTH_TOKEN` 和 `X_CT0` 环境变量后重试。

---

## Phase 2: 创建博客文章

读取下载好的推文 Markdown，然后按照 `/guige-blog-post` skill 的规范写文章。

### 2.1 读取原文

1. 读取 Phase 1 下载的 Markdown 文件，提取全部内容
2. 统计原文中的图片数量和位置

### 2.2 生成 slug

从推文主题生成 kebab-case slug（2-4 个英文单词），如：
- Claude Code 相关 → `claude-code-session-management`
- AI Agent 相关 → `ai-agent-workflow`

### 2.3 创建目录和写文章

按照 `/guige-blog-post` 的 Step 2-3 规范：

1. 创建 `content/post/<slug>/` 目录
2. 写 `index.md`，遵守以下规则：

**Frontmatter**：

```yaml
---
title: "中文标题"
description: "中文摘要，120 字以内"
date: YYYY-MM-DD
slug: <slug>
image: cover.webp
categories:
    - <类别>
tags:
    - tag1
    - tag2
    - tag3
---
```

**文章要求**：

- **语言**：全文中文
- **结构**：必须遵守「钩子 → 认知增量 → Takeaway」三层结构
- **章节顺序**：紧跟原文结构，不要自行调整章节顺序
- **图片**：按原文中图片出现的顺序，在文章对应位置引用全部图片（不要遗漏任何一张）
- **个人视角**：在翻译/整理原文的基础上，适当加入作者自己的使用体感和观点
- **排版**：口语化但有技术深度，大量使用加粗，用表格对比概念
- **参考资料**：文末附原推文链接

**反模式**：
- ❌ 纯翻译/摘要，没有自己的观点
- ❌ 自行调整原文章节顺序
- ❌ 遗漏原文中的图片
- ❌ 开头"本文将介绍..."
- ❌ 结尾"以上就是全部内容"

---

## Phase 3: 复用原文图片

将原文下载的全部图片复制到博客文章目录，并转换为 WebP 格式。

1. **复制并重命名**：从 Phase 1 的 `imgs/` 目录复制图片到 `content/post/<slug>/`，使用语义化文件名（如 `context-rot.webp`、`rewind-flow.webp`）
2. **转换格式**：使用 `cwebp -q 80` 转为 WebP（如果 cwebp 不可用，用 `sips -s format webp`）
3. **删除原始文件**：转换成功后删除 JPG/PNG 原文件
4. **验证数量**：确保文章中引用的图片数量 = 原文图片数量（不含 cover）

---

## Phase 4: 等待用户提供 cover 图

1. 在文章目录下创建 `image-prompts.md`，只包含 cover 图的生成 prompt
2. Prompt 风格：深色背景 `#07090f`，主色调 teal `#2dd4bf`，辅色 amber `#f59e0b`，16:9，无文字
3. 告知用户：

```
文章和配图已就绪：
- 文章：content/post/<slug>/index.md
- 原文图片：已全部转换为 WebP（共 N 张）
- 只需生成 1 张封面图，prompt 在 image-prompts.md 中

请生成 cover 图，保存到同目录（PNG 或 WebP 均可）。完成后告诉我。
```

4. **等待用户确认**，不要自行继续

---

## Phase 5: 验证、提交、推送

用户确认 cover 图就绪后：

1. **转换 cover**：如果是 PNG/JPG，转为 `cover.webp`
2. **验证**：
   - Frontmatter 完整（title, description, date, slug, image, categories, tags）
   - 所有图片引用都有对应 .webp 文件
   - cover.webp 存在
3. **提交**：

```bash
git add content/post/<slug>/
git commit -m "feat: 新增 <文章标题简述> 文章，含 N 张配图"
git push origin master
```

如果 push 被拒绝（远程有新提交），先 `git pull --rebase` 再 push。

---

## Phase 6: 发布微信公众号（可选）

提交推送后，询问用户：「需要同步发布到微信公众号吗？」

如果用户确认：

1. 转换封面：`sips -s format jpeg cover.webp --out cover-wechat.jpg`
2. 调用 `/baoyu-post-to-wechat` skill：

```bash
# 传入绝对路径
${BUN_X} {wechat_skill_dir}/scripts/wechat-api.ts <absolute_path>/index.md \
  --theme simple --author 鬼哥 \
  --cover <absolute_path>/cover-wechat.jpg
```

3. 注意：必须使用**绝对路径**，脚本不会解析相对路径
4. 注意：`cover-wechat.jpg` 不要 commit 到 git

---

## 错误恢复

| 场景 | 处理 |
|------|------|
| 推文下载失败（认证） | 引导用户设置 X_AUTH_TOKEN 和 X_CT0 |
| 推文下载超时 | 重试一次，仍失败则让用户手动提供内容 |
| 图片转换失败（cwebp） | fallback 到 `sips -s format webp` |
| git push 被拒绝 | `git pull --rebase` 后重试 |
| 微信 API 依赖报错 | 在 skill scripts 目录下 `bun install` 后重试 |
