# speckit-core

The spec-kit workflow layer — tool-agnostic templates, scripts, and memory stubs for spec-driven AI development.

Used as a git submodule (at `.speckit/`) to provide:

- `.specify/templates/` — spec, plan, tasks, constitution, stack, agent, checklist templates
- `.specify/scripts/` — helper bash scripts for the spec-kit workflow
- `.specify/memory/` — per-project constitution and stack stubs

## Composable Kit Architecture

`speckit-core` is the foundation layer. Pair it with a tool-specific kit:

| Kit | Submodule path | Provides |
|-----|---------------|---------|
| [copilot-kit](https://github.com/jwill824/copilot-kit) | `.copilot/` | GitHub Copilot agents, prompts, skills, hooks |
| `claude-kit` *(coming soon)* | `.claude/` | Claude-specific tooling |

## Spec-Kit Workflow

```
/speckit.constitution  →  Initialize your project constitution
/speckit.specify       →  Write a feature spec
/speckit.clarify       →  Clarify ambiguous requirements
/speckit.plan          →  Generate an implementation plan
/speckit.tasks         →  Break the plan into tasks
/speckit.implement     →  Implement the tasks
/speckit.analyze       →  Analyze code quality and spec compliance
```

## Usage

### Via github-repo-factory (Recommended)

Set `speckit_enabled: true` in your `repos.json` entry — the bootstrap workflow handles everything automatically.

### Manual Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jwill824/speckit-core/main/install.sh)
```

## What's Included

### Templates (`.specify/templates/`)

| Template | Purpose |
|----------|---------|
| `constitution-template.md` | Project constitution — governing principles & decisions |
| `stack-template.md` | Tech stack reference |
| `spec-template.md` | Feature specification |
| `plan-template.md` | Implementation plan |
| `tasks-template.md` | Task breakdown |
| `agent-file-template.md` | Custom agent scaffolding |
| `checklist-template.md` | Pre-merge checklist |

### Scripts (`.specify/scripts/bash/`)

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Initial project setup |
| `check-prerequisites.sh` | Verify required tools are installed |
| `common.sh` | Shared utilities |
| `create-new-feature.sh` | Scaffold a new feature spec |
| `setup-plan.sh` | Initialize a plan file |
| `update-agent-context.sh` | Refresh agent context files |

## Links

- [copilot-kit](https://github.com/jwill824/copilot-kit) — Copilot-specific tooling layer
- [github-repo-factory](https://github.com/jwill824/github-repo-factory) — Terraform-managed repo factory
- [spec-kit (GitHub)](https://github.com/github/spec-kit) — The spec-kit specification
