# speckit-core

The tool-agnostic Spec Kit foundation layer for composable, spec-driven development.

`speckit-core` is designed to live in a project as the `.speckit/` submodule. It owns the shared Spec Kit workflow assets - templates, helper scripts, bundled extensions, and integration manifests - while agent-specific repos such as [`copilot-kit`](https://github.com/jwill824/copilot-kit) stay separate.

## Overview

Use this repo when you want Spec Kit workflow building blocks without forcing a specific AI client. `speckit-core` is the shared layer your repo factory or templates can depend on whether the consuming project later chooses Copilot, Claude Code, Codex CLI, or another agent-specific toolkit.

## Getting started

```bash
git clone https://github.com/jwill824/speckit-core.git
cd speckit-core
```

## Composable kit architecture

| Kit | Submodule path | Provides |
|-----|---------------|----------|
| `speckit-core` | `.speckit/` | Templates, scripts, bundled extensions, shared memory stubs |
| [copilot-kit](https://github.com/jwill824/copilot-kit) | `.copilot/` | GitHub Copilot agents, prompts, skills, hooks |
| `claude-kit` *(coming soon)* | `.claude/` | Claude-specific tooling |

This separation matters for upgrades: update Spec Kit workflow assets from `.speckit`, and update Copilot command assets from `.copilot`.

## Install Specify CLI

Install the upstream `specify` CLI first. `speckit-core` complements it; it does not replace it.

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
```

To upgrade later:

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git@vX.Y.Z
```

See the upstream [Spec Kit README](https://github.com/github/spec-kit?tab=readme-ov-file) and [Upgrade Guide](https://github.com/github/spec-kit/blob/main/docs/upgrade.md) for CLI-level details.

## Install speckit-core

### Via github-repo-factory

Set `speckit_enabled: true` in your `repos.json` entry and let the factory bootstrap the submodule for you.

### Manual bootstrap

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jwill824/speckit-core/main/install.sh)
```

The installer:

1. Adds or updates the `.speckit/` submodule.
2. Links `.specify/templates/` and `.specify/scripts/` back to the submodule.
3. Exposes bundled extensions and integration manifests inside the project's local `.specify/` tree.
4. Seeds a local `.specify/extensions.yml` starter config if one does not already exist.
5. Creates local constitution and stack stubs in `.specify/memory/`.

## AI-specific integrations

The intended ownership boundary is:

| Layer | Owns |
|------|------|
| `speckit-core` | `.specify/templates`, `.specify/scripts`, `.specify/extensions`, `.specify/integrations` |
| AI-specific kit | `.github/agents`, `.github/prompts`, `.github/skills`, `.github/hooks`, `.claude/*`, or other tool-specific assets |

That means `speckit-core` should not vendor Copilot-, Claude-, or Codex-specific agent files directly. Instead, it should expose shared integration metadata plus a generic linker that lets a tool-specific kit wire its own files into the active project.

Today that boundary exists through:

- `.specify/integrations/*.manifest.json` describes a selected integration
- `.specify/integration.json` records the active integration in a consuming project
- `.specify/scripts/bash/update-agent-context.sh <agent>` is the shared update entry point
- `.specify/scripts/bash/link-ai-integration.sh <integration> <kit-path>` links a tool-specific kit using its manifest
- tool-specific kits provide the actual command/agent payloads and a small manifest declaring what they own

So the clean update model is:

1. Install or update `.speckit` for workflow assets.
2. Install or update the matching AI-specific kit for the chosen tool.
3. Run the generic linker so the AI kit links only the paths it owns.

Example:

```bash
bash .speckit/.specify/scripts/bash/link-ai-integration.sh copilot .copilot
```

Expected AI kit manifest path:

```text
<kit>/.specify/ai-kit.manifest.json
```

For a future `claude-kit`, the same pattern would apply: ship `.claude/...` assets plus an `ai-kit.manifest.json`, then call the same linker with `claude` and `.claude`.

## What's included

### Core assets

| Path | Purpose |
|------|---------|
| `.specify/templates/` | Spec, plan, tasks, constitution, stack, agent, and checklist templates |
| `.specify/scripts/` | Shared bash workflow helpers |
| `.specify/integrations/` | Integration manifests and helper scripts |
| `.specify/memory/` | Per-project constitution and stack stubs |

### Bundled extensions

| Extension | Purpose |
|-----------|---------|
| `git` | Feature branch creation, validation, remote detection, and optional auto-commit hooks |
| `memorylint` | Cleans AGENTS/constitution boundaries before constitution work |
| `cleanup` | Post-implementation review and tech-debt follow-up |
| `archive` | Roll merged feature knowledge back into long-lived memory |
| `optimize` | Governance/token-budget analysis for constitution health |
| `sync` | Spec drift detection and backfill workflow |

See [extensions.md](extensions.md) for the bundled extension details plus a short community extension list.

## Spec Kit workflow

```text
/speckit.constitution  ->  initialize project principles
/speckit.specify       ->  write the feature spec
/speckit.clarify       ->  resolve ambiguity
/speckit.plan          ->  create the implementation plan
/speckit.tasks         ->  break the plan into tasks
/speckit.implement     ->  execute the tasks
/speckit.analyze       ->  review implementation/spec alignment
```

## Updating a project

There are three separate upgrade surfaces:

1. **Specify CLI**: upgrade with `uv tool install ... --force`.
2. **speckit-core**: update the `.speckit/` submodule, then rerun `install.sh` if you need to recreate missing links or stubs.
3. **copilot-kit**: update the `.copilot/` submodule separately if you use Copilot-specific prompts and agents.

For a composable `.speckit` + `.copilot` setup, prefer submodule updates over `specify init --here --force --ai copilot`. The upstream `specify init` path is useful when you intentionally want CLI-managed project files, but it will rewrite local agent/prompt assets and can blur the repo boundary you are keeping between `speckit-core` and `copilot-kit`.

## Links

- [spec-kit](https://github.com/github/spec-kit) - upstream Spec Kit project
- [copilot-kit](https://github.com/jwill824/copilot-kit) - GitHub Copilot tooling layer
- [github-repo-factory](https://github.com/jwill824/github-repo-factory) - template/bootstrap automation
