# Contributing

## Local setup

1. Clone the repository.
2. Install the upstream `specify` CLI with `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z`.
3. Keep AI-specific assets in their own toolkit repos; use this repo to work on shared `.specify` assets and integration metadata.

## Local-only generated files

This repository intentionally keeps Copilot command assets and local Spec Kit state out of version control. The following paths are expected to be local-only while developing:

- `.github/agents/`
- `.github/prompts/`
- `.specify/integration.json`
- `.specify/init-options.json`
- `.specify/memory/`
- `.vscode/`

## Pull requests

1. Create a feature branch.
2. Keep changes scoped to the workflow/docs/install surface you are touching.
3. Use Conventional Commits for commit messages and PR titles.
4. Open the PR against `main`.

## Implementation notes

- Keep bootstrap scripts portable across the default macOS Bash runtime.
- Prefer documenting upstream `specify` behavior rather than re-explaining it differently here.
- Preserve the ownership split: `speckit-core` owns shared workflow assets, while tool-specific kits own their own command, prompt, and hook files.
