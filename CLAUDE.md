# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes; merge with project-specific rules. Bias toward caution over speed — use judgment on trivial tasks.

## 1. Core Principles

- Think before coding. State assumptions, surface tradeoffs, push back when warranted.
- Simplicity first. Minimum code that solves the problem. Nothing speculative.
- Surgical changes. Touch only what you must. Clean up only your own mess.
- Goal-driven execution. Define success criteria. Loop until verified.

## 2. File Search & Investigation

- Cite files as `<relative-path>:<line>` (forward slashes, from workspace root); add a column only to pinpoint an exact term.
- Use text search (e.g. ripgrep) to verify existing content instead of guessing from memory.
- Read the actual file before editing — never trust memory or autocomplete.
- If a search returns nothing, broaden it before concluding something doesn't exist.

## 3. Java

- JPA/DB: mitigate N+1 (e.g. `@EntityGraph`, `JOIN FETCH`, batch size); prefer JPQL for `@Query`; flag genuine `nativeQuery`; for NoSQL (e.g. MongoDB) prefer explicit `@Query` plus derived methods.
- Lombok: use it wherever possible; default to `@RequiredArgsConstructor` for injection; watch `.equals`/`.hashCode` pitfalls and N+1 from lazy fields in `@Data`.

## 4. Utility Scripts

Scope: standalone/one-off utility, helper, maintenance, or automation scripts; does not override application-level project rules unless explicitly requested.

### General

- Start with a short README header: what it does, how to run it, expected inputs/outputs, side effects (especially file modification/deletion), and required external tools.
- Config-driven: tunable settings in one `CONFIG` block near the top — an object/dict named exactly `CONFIG` where the language supports object literals (e.g. Python, TS), otherwise `CONFIG_`-prefixed variables (e.g. shell). No hard-coded absolute paths unless asked.
- Approval gate: writing a script is fine; running it, installing a dependency, or overwriting/deleting files needs my explicit approval. Prefer the standard library; for any third-party package, name it, say why, and give the exact install and run commands. Destructive scripts list the affected paths, support `--dry-run`, and never auto-confirm.
- Fuzzy input: accept file/folder names by fuzzy/substring match — auto-proceed on one match, numbered picker on several, clear error if ambiguous and non-interactive.

### Language Notes
 
- Python: use `uv` + PEP 723 inline dependencies (no `pip install`, manual venvs, or global installs). Shebang `#!/usr/bin/env -S uv run --script --no-python-downloads`; run `uv run --no-python-downloads script.py`. Use latest bare package names when deps are needed.
- Shell: `#!/usr/bin/env bash` with `set -euo pipefail`; quote all paths and expansions and print explicit error messages.
- TypeScript: run with `node`; prefer built-ins and avoid trivial package deps.
- Rust: single `.rs` file, no `cargo new`; run with `rust-script`; if `rust-script` is missing, ask me before installing it (`cargo install rust-script`). Add inline dependencies in a leading `//!` cargo block when needed. First run compiles and caches; shebangs are Unix-only, so invoke it explicitly on Windows.

### Logging

- Log to `<script_dir>/tool_logs/<script-name>.log`, resolved from the script file (not CWD); create the dir if missing, append across runs, one header line (start time) per run.
- Logs go to the file only; keep stdout for the script's real output and print concise errors to stderr.
- Default level `INFO`; `--verbose` enables `DEBUG`. Never log secrets, tokens, or credentials.
- Use the standard library logger (Python) or plain file appends (TS); no custom handlers or logging frameworks. Shell and Rust: optional.

## 5. Git

- Commits and PR titles: conventional `type(scope): summary` — `feat`, `fix`, `docs`, `chore`, `refactor`, `test`; scope optional. E.g. `docs: update contributing guide`.
- Never add `Co-Authored-By` or any coauthor/attribution trailer to commits.
- Never run without my explicit approval: `git add`, `git commit`, `git push` (I stage, commit, and push myself); `git reset`, `git rebase`, `git commit --amend`, `git restore`, `git checkout -- .`, `git clean`, `git stash drop`/`clear`, `git branch -D`, `git push --delete`; any force push (`-f`, `--force`, `--force-with-lease`), especially on shared branches. Never rewrite shared history — when in doubt, stop and ask.
- Read-only git (`status`, `diff`, `log`, `show`, `blame`, `fetch`) is always fine.
- After modifying files, end with a fenced code block containing only the commit message (no prefix). Skip for general queries.
