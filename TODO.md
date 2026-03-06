# MicropolisJ Modernization Plan

This document defines the phased plan to modernize MicropolisJ from legacy Ant/Java to a reproducible baseline, Gradle, and incremental Kotlin adoption.

## Goals

- Make builds and verification reproducible on any machine.
- Remove reliance on manual GUI startup for regression checks.
- Migrate safely from Ant to Gradle with behavior parity.
- Introduce Kotlin incrementally without destabilizing core simulation.
- Start on JDK 17 LTS, then move to JDK 21 when migration risk is lower.

## Constraints and Context

- Current project build is Ant (`build.xml`) with custom tasks:
  - resource copy and `native2ascii` localization conversion
  - tile composition via `micropolisj.build_tool.MakeTiles`
  - jar packaging with `Main-Class: micropolisj.Main`
- There is no established automated test suite in the repository.
- Project is Swing desktop app; default entrypoint launches UI.
- Baseline verification should be local-only and Docker-based.

## Phase 0 - Baseline Safety Net (Ant + Docker, JDK 17)

### Deliverables

- [x] `docker/baseline.Dockerfile`
  - JDK 17 + Ant toolchain
  - reproducible env defaults (`LANG`, `LC_ALL`, `TZ`, headless Java)
- [x] `scripts/verify-baseline.sh`
  - single local command
  - image caching by default
  - `--rebuild` to force image rebuild
- [x] `src/micropolisj/verify/EngineSmokeCheck.java`
  - headless smoke check for engine init + animation progression
- [x] Baseline verification stages implemented:
  1. Toolchain check (Java 17)
  2. `ant clean build`
  3. Artifact checks
  4. Manifest check
  5. Resource/l10n checks
  6. Headless smoke check
- [x] `build.xml` updated to compile with Java 8 source/target for JDK 17 compatibility.

### Baseline Command

```bash
./scripts/verify-baseline.sh
```

Force rebuild:

```bash
./scripts/verify-baseline.sh --rebuild
```

### Exit Criteria for Phase 0

- One command verifies build + packaging + resources + engine smoke in Docker.
- No manual GUI launch required.
- Failures are stage-specific and actionable.

## Phase 1 - Harden the Baseline

### Tasks

- [ ] Add `README` section describing local baseline verification flow.
- [ ] Add `.dockerignore` to reduce Docker build context size.
- [ ] Add script options (`--verbose`, optional debug keep-container mode) if needed.
- [ ] Add at least one more deterministic engine assertion in smoke check (non-flaky).
- [ ] Run baseline repeatedly on multiple machines to check reproducibility.

### Exit Criteria

- Baseline is stable over repeated runs.
- Dev onboarding for verification is documented.

## Phase 2 - Gradle Parity Build (No Kotlin Yet)

### Objective

Recreate Ant behavior in Gradle without changing runtime behavior.

### Tasks

- [ ] Introduce Gradle wrapper and initial `build.gradle.kts`.
- [ ] Mirror Ant compile/resource/tile/jar behavior:
  - [ ] Java compile with compatible level
  - [ ] string conversion and resource copy
  - [ ] tile composition tasks equivalent to Ant `compose-tiles`
  - [ ] jar manifest parity (`Main-Class`, version metadata)
- [ ] Add Gradle task that runs `EngineSmokeCheck`.
- [ ] Compare outputs against Ant baseline contract.

### Parity Checks

- [ ] `micropolisj.jar` produced by Gradle.
- [ ] required tile and resource outputs present.
- [ ] manifest fields match expected values.
- [ ] smoke check passes under Gradle workflow.

### Exit Criteria

- Gradle can satisfy the same verification contract as Ant.
- Ant remains available as fallback during this phase.

## Phase 3 - Kotlin Introduction (Mixed Java/Kotlin)

### Objective

Start Kotlin migration in small, low-risk increments.

### Tasks

- [ ] Enable Kotlin JVM plugin in Gradle.
- [ ] Keep Java/Kotlin interop boundaries stable.
- [ ] Convert low-risk leaf classes first:
  - [ ] `util` helpers
  - [ ] small non-core support classes
- [ ] Keep PRs small and behavior-preserving.
- [ ] Extend smoke/regression checks as needed.

### Guardrails

- Do not redesign core simulation during initial conversion.
- Keep public API Java-friendly until majority migration is complete.
- Prefer deterministic checks over UI/manual validation.

### Exit Criteria

- Mixed-language build is stable.
- Initial Kotlin conversions are merged without regressions.

## Phase 4 - Expand Verification Coverage

### Objective

Increase confidence beyond smoke tests before larger engine/UI migrations.

### Tasks

- [ ] Add deterministic engine regression tests (fixed seeds, fixed tick counts).
- [ ] Add targeted resource/serialization checks where practical.
- [ ] Add packaging sanity checks to Gradle `check` lifecycle.

### Exit Criteria

- Core simulation behavior has automated regression protection.

## Phase 5 - Move Runtime Baseline to JDK 21

### Objective

After Gradle parity and baseline stability, bump toolchain/runtime target from JDK 17 to JDK 21.

### Tasks

- [ ] Update Docker verifier image/toolchain to JDK 21.
- [ ] Update Gradle toolchains to JDK 21.
- [ ] Run full verification and compare behavior/perf.
- [ ] Resolve any library/toolchain incompatibilities.

### Exit Criteria

- Verification passes consistently on JDK 21.
- JDK 21 becomes the default documented baseline.

## Tracking and Ownership

- Keep this TODO updated as tasks are completed.
- Prefer one focused migration step per commit.
- Do not remove Ant build until Gradle parity is proven across repeated runs.
