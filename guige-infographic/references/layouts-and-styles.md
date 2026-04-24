# Layouts And Styles

This file is the standalone design vocabulary for `guige-infographic`.

## Layouts

### dense-modules

High-density portrait layout for data-rich Chinese long images.

- 6-7 compact modules
- strong top title zone
- metric cards, quote strips, process boxes, warning/takeaway blocks
- small but readable text
- best for launches, product analysis, technical summaries, trend explainers

### bento-dashboard

Modular bento layout for cleaner overviews.

- 5-6 uneven cards
- one hero card plus supporting cards
- larger whitespace and fewer details
- best for executive summaries and general audience explainers

### technical-map

System map layout for technical relationships.

- nodes, arrows, swimlanes, labels
- benchmark numbers in technical badges
- good for architecture, agent workflows, model capability maps

### timeline-road

Sequential layout for historical or process content.

- vertical or winding path
- milestones, numbered steps, before/after states
- best for tutorials, releases, migration stories

### comparison-board

Side-by-side comparison layout.

- 2-4 columns
- scoring rows, pros/cons, metric highlights
- best for A/B comparisons, model comparisons, tool choices

## Styles

### guige-journal

Default Gui Ge style.

- warm cream paper background
- muted teal, sage, terracotta, pale yellow, charcoal brown
- hand-drawn module frames, dotted lines, tabs, tape labels
- technical but human, like a premium bullet journal
- includes Gui Ge narrator stickers/callouts

### lab-notes

Technical benchmark style.

- light gray paper with faint grid
- teal blocks, yellow highlights, red warning accents
- coordinate labels, tiny annotations, benchmark bars, terminal doodles
- best for coding, model benchmarks, infrastructure topics

### social-pop

Bold shareable social style.

- stronger contrast
- large numbers
- sticker-like callouts
- simplified modules
- best for mobile social posts

### clean-explainer

Readable education style.

- calm color blocks
- larger labels
- fewer decorative elements
- best when source content is complex and readability is more important than density

### dark-terminal

Developer-focused dark style.

- dark charcoal background
- green/teal terminal accents
- code windows, logs, CLI panels
- use only when the user explicitly wants dark technical visuals

## Recommendation Rules

- Use `dense-modules + guige-journal` for most high-density Chinese information graphics.
- Use `technical-map + lab-notes` when relationships, infrastructure, or benchmark systems matter most.
- Use `bento-dashboard + clean-explainer` when the user asks for a clean, readable overview.
- Use `comparison-board + lab-notes` for model/tool comparisons.
- Use `timeline-road + guige-journal` for process, launch history, or migration stories.

