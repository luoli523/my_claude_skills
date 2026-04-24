---
name: guige-infographic
description: Generate Chinese infographics in Gui Ge's personal style as a standalone skill. Always uses the bundled Gui Ge character image from assets/guige.jpeg, creates analysis/structured content/prompts independently, generates the final infographic, and can optionally upload it to Google Drive guige-images with a content-related filename. Use for 鬼哥信息图, 中文信息图, 信息图, 高密度信息大图, visual summary, or turning article/content into a Gui Ge branded infographic.
version: 0.2.2
---

# Gui Ge Infographic

Standalone workflow for Chinese infographics with the bundled Gui Ge narrator character and optional Google Drive delivery.

This skill owns its own analysis, structure, design choices, prompt generation, image generation, and upload flow.

## Defaults

| Setting | Default |
|---------|---------|
| Language | `zh` |
| Character image | `assets/guige.jpeg` |
| Output root | `infographic/{topic-slug}/` |
| Default layout | `dense-modules` |
| Default style | `guige-journal` |
| Default aspect | `portrait` (`9:16`) |
| Upload behavior | Disabled by default; opt in per request or env |
| Upload target | `gdrive:guige-images` |
| Upload filename | `{topic-slug}-infographic-{YYYYMMDD}.png` |

## Assets

Always use the bundled character asset:

```text
assets/guige.jpeg
```

At run time, copy it into the output directory:

```text
infographic/{topic-slug}/refs/01-ref-guige.jpeg
```

Use the image as a style/character reference whenever the active image backend supports reference images. If the backend does not support reference images, inject the character traits in text:

- Q-style young male narrator
- sleepy half-lidded eyes
- mildly sarcastic / 吐槽 expression
- orange headband with Chinese text `鬼哥`
- blue hoodie
- acoustic guitar as a signature prop
- cute, efficient cartoon style: simple silhouette, readable pose, expressive face, no unnecessary detail
- may use Japanese manga-style expression effects when they fit the content: sweat drop, surprise lines, angry vein mark, speech bubble, speed lines, sparkle eyes, deadpan face, tiny chibi reaction sticker
- choose expressions based on the module content: surprise for key insights, sweat drop for risks, sparkle for opportunities, deadpan for obvious product friction, speed lines for action items
- used as a narrator, sticker, pointer, or callout host
- supportive visual role, never overpowering the information architecture

## Supported Layouts And Styles

Read [layouts-and-styles.md](references/layouts-and-styles.md) when choosing or explaining design options.

Default recommendation:

```text
dense-modules + guige-journal + portrait
```

Use the default when the user asks for 高密度信息大图, wants a social/shareable long image, or does not specify visual preferences.

## Workflow

### Step 1: Setup

1. Derive a short English `topic-slug` from the source title or topic, e.g. `gpt-5-5-overview`.
2. Create:
   - `infographic/{topic-slug}/`
   - `infographic/{topic-slug}/refs/`
   - `infographic/{topic-slug}/prompts/`
3. If the output directory already exists, append `-YYYYMMDD-HHMMSS`.
4. Copy `assets/guige.jpeg` to `refs/01-ref-guige.jpeg`.
5. Save pasted content or source file content as `source-{topic-slug}.md`.

### Step 2: Analyze Content

Create `analysis.md` with:

- title
- topic
- source language and output language
- audience
- content type
- complexity
- 1-3 learning objectives
- key statistics and quotes copied exactly
- recommended layout/style/aspect combinations
- any user design instructions

Preserve factual data exactly. Strip secrets, credentials, API keys, and tokens if present.

### Step 3: Structure Content

Create `structured-content.md` with:

- title and subtitle
- overview
- 4-7 visual modules
- for each module: key concept, exact content points, visual treatment, text labels
- data points and quotes copied exactly
- Gui Ge character usage notes
- suggested Gui Ge expressions for key modules when helpful

Keep module text concise enough for image generation. Preserve source facts, but compress wording for display labels when necessary.

### Step 4: Confirm Options

Confirm before generating unless the user explicitly says `--no-confirm`, `直接生成`, `不用确认`, `跳过确认`, or equivalent.

Ask for:

- layout/style combination
- aspect ratio
- any must-include or must-remove points

Offer 3 options by default:

- `dense-modules + guige-journal` for high-density social long images
- `bento-dashboard + guige-journal` for cleaner overview images
- `technical-map + lab-notes` for more technical/benchmark-heavy content

### Step 5: Generate Prompt

Read [prompt-template.md](references/prompt-template.md), then create:

```text
prompts/infographic.md
```

The prompt must include:

- chosen layout/style/aspect
- full structured content
- all required Chinese text labels
- `Gui Ge Character Reference` section
- reference frontmatter:

```yaml
references:
  - ref_id: 01
    filename: 01-ref-guige.jpeg
    usage: style
```

Write the prompt file before invoking any image backend.

### Step 6: Generate Image

Use the best image backend available in the current runtime:

1. Native runtime image tool, if available.
2. A configured local image generation skill or script, if the current runtime provides one.
3. If no image backend exists, stop and report the prepared prompt path.

If the backend supports image references, pass `refs/01-ref-guige.jpeg`. If not, rely on the text character section in the prompt.

Normalize final output to:

```text
infographic/{topic-slug}/infographic.png
```

If the backend saves to another path, copy the generated image to `infographic.png` and leave the original in place.

If `infographic.png` exists, rename the old file to:

```text
infographic-backup-YYYYMMDD-HHMMSS.png
```

### Step 7: Optional Google Drive Upload

Google Drive upload is optional and disabled by default.

Upload only when one of these is true:

- The user explicitly asks to upload, e.g. `上传到 Google Drive`, `传到 guige-images`, `upload to Drive`, or equivalent.
- The environment variable `GUIGE_INFOGRAPHIC_UPLOAD=1` is set.

When upload is enabled and `infographic.png` exists, run:

```bash
guige-infographic/scripts/upload_to_drive.sh \
  infographic/{topic-slug}/infographic.png \
  "{topic-slug}" \
  "gdrive:guige-images"
```

The upload script requires `rclone` configured with a Google Drive remote named `gdrive`.

If upload is not enabled, skip this step and report the local image path.

If upload is enabled but fails, keep the local image and report:

- local image path
- upload target
- exact upload error
- required fix, usually installing/configuring `rclone`

### Step 8: Final Report

Report:

- topic
- layout, style, aspect, language, image backend
- local image path
- Google Drive path, upload skipped, or upload blocker
- generated files: source, analysis, structured content, prompt

Keep the report short.

## Helper Scripts

Use [upload_to_drive.sh](scripts/upload_to_drive.sh) for Drive upload.

Environment overrides:

| Env var | Meaning |
|---------|---------|
| `GUIGE_INFOGRAPHIC_UPLOAD` | Set to `1` to upload by default |
| `GUIGE_IMAGES_TARGET` | Override upload target, e.g. `gdrive:guige-images` |
| `GUIGE_IMAGES_DATE` | Override date suffix for deterministic tests |
