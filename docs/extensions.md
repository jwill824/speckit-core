# Community Extensions

These community-built spec-kit extensions pair well with `speckit-personal`.

---

## spec-kit-checkpoint

**Repository**: [aaronrsun/spec-kit-checkpoint](https://github.com/aaronrsun/spec-kit-checkpoint)

Save and restore spec-kit workflow state. Useful when you need to switch contexts mid-feature and resume later without losing your place in the spec-kit lifecycle. Creates checkpoint snapshots of your current spec, plan, and task state.

---

## spec-kit-cleanup

**Repository**: [dsrednicki/spec-kit-cleanup](https://github.com/dsrednicki/spec-kit-cleanup)

Cleans up stale spec-kit artifacts: old specs that were never implemented, completed tasks that are still marked in-progress, and orphaned plan files. Keeps your `.specify/` directory tidy over time.

---

## spec-kit-status

**Repository**: [KhawarHabibKhan/spec-kit-status](https://github.com/KhawarHabibKhan/spec-kit-status)

Shows a visual dashboard of your current spec-kit workflow progress. Displays which stage of the lifecycle you're in, what's complete, and what's next. Great for onboarding collaborators onto an in-progress feature.

---

## spec-kit-doctor

**Repository**: [KhawarHabibKhan/spec-kit-doctor](https://github.com/KhawarHabibKhan/spec-kit-doctor)

Diagnoses health issues in your spec-kit setup. Checks that all required agent files are present, that the constitution is initialized, that hooks are properly configured, and that templates are up to date. Run it after installing speckit-personal to verify everything is wired up correctly.

---

## spec-kit-iterate

A workflow extension that adds a `/speckit.iterate` command for rapid iteration on an existing spec. Useful when you need to make small, fast changes without going through the full lifecycle.

---

## spec-kit-onboard

Generates an onboarding guide for new contributors based on the project constitution and stack. Reads `.specify/memory/constitution.md` and `.specify/memory/stack.md` and produces a `docs/onboarding.md` tailored to the project.

---

## Installing Extensions

Extensions can be installed by copying their `.github/` and `.specify/` files into your project, similar to how `speckit-personal` is installed via `install.sh`.

Check the [spec-kit repository](https://github.com/github/spec-kit) for an up-to-date list of community extensions.
