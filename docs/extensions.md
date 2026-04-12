# Extensions

`speckit-core` now bundles a small set of Spec Kit extensions directly in the repo so a consuming project can opt into richer workflow behavior without pulling each one separately.

## Bundled with speckit-core

The installer exposes these under `.specify/extensions/` and seeds a starter `.specify/extensions.yml` with the default hook wiring.

| Extension | Primary commands | Default role |
|-----------|------------------|--------------|
| `git` | `speckit.git.initialize`, `speckit.git.feature`, `speckit.git.validate`, `speckit.git.remote`, `speckit.git.commit` | Git bootstrap, feature branches, optional auto-commit hooks across the lifecycle |
| `memorylint` | `speckit.memorylint.run` | Optional `before_constitution` guardrail for AGENTS vs constitution boundaries |
| `cleanup` | `speckit.cleanup.run` | Optional post-implementation cleanup and tech-debt review |
| `archive` | `speckit.archive.run` | Archive merged feature knowledge back into project memory |
| `optimize` | `speckit.optimize.run`, `speckit.optimize.tokens`, `speckit.optimize.learn` | Constitution and governance token-efficiency analysis |
| `sync` | `speckit.sync.analyze`, `speckit.sync.propose`, `speckit.sync.apply`, `speckit.sync.conflicts`, `speckit.sync.backfill` | Detect and resolve drift between specs and implementation |

## Default hook wiring

The starter `.specify/extensions.yml` created by `install.sh` enables the current opinionated defaults:

- `before_constitution`: `memorylint`, `git.initialize`
- `before_specify`: `git.feature`
- `before_*` / `after_*` phase hooks: optional `git.commit`
- `after_implement`: optional `sync.analyze`, `cleanup.run`, `git.commit`

Edit or remove those hooks per project - the file is created locally and is not overwritten if it already exists.

## Community extensions worth pairing with speckit-core

These are not bundled here, but they fit well with the repo's workflow:

| Extension | Why pair it |
|-----------|-------------|
| [spec-kit-checkpoint](https://github.com/aaronrsun/spec-kit-checkpoint) | Break large implementation sessions into safer mid-stream checkpoints |
| [spec-kit-status](https://github.com/KhawarHabibKhan/spec-kit-status) | Show where a feature currently sits in the lifecycle |
| [spec-kit-doctor](https://github.com/KhawarHabibKhan/spec-kit-doctor) | Validate that a project's Spec Kit installation is wired correctly |
| [spec-kit-iterate](https://github.com/imviancagrace/spec-kit-iterate) | Tighten fast iteration loops on an existing spec |
| [spec-kit-onboard](https://github.com/dmux/spec-kit-onboard) | Generate contributor onboarding context from your project memory |

For the full, current catalog, use the upstream [Spec Kit community extension index](https://github.com/github/spec-kit?tab=readme-ov-file#-community-extensions).
