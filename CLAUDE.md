# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

Tradeoff: These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what is confusing. Ask.

## 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

Define success criteria. Loop until verified.

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

These guidelines are working if: fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## 5. File Search & Investigation

- Cite files as `<relative-path>:<line>` (forward slashes, from workspace root) so it opens in VSCode/IntelliJ; add a column only when pinpointing an exact term.
- Use text search (e.g. ripgrep) to verify existing content instead of guessing from memory.
- Read the actual file you're about to edit — never trust memory or autocomplete about what's there.
- If a search returns nothing, broaden it before concluding something doesn't exist.

## 6. Java

- JPA/DB: mitigate N+1 (e.g. `@EntityGraph`, `JOIN FETCH`, batch size); prefer JPQL for `@Query`; flag genuine `nativeQuery`; for NoSQL (e.g. MongoDB) prefer explicit `@Query` plus derived methods.
- Lombok: use it wherever possible; default to `@RequiredArgsConstructor` for injection; watch `.equals`/`.hashCode` pitfalls and N+1 from lazy fields in `@Data`.

## 7. Utility Scripts

Scope: standalone/one-off utility, helper, maintenance, or automation scripts. Does not override application-level project rules unless explicitly requested.

### 7.1 General Script Rules
- Start with a short README header: what it does, how to run, expected inputs/outputs, side effects (especially file modification/deletion), and required external tools.
- Keep scripts short and maintainable. Put tunable settings in a `CONFIG` block near the top (`.py`/`.ts`: a `CONFIG` dict; shell: `CONFIG_*` variables).
- No hard-coded absolute paths unless asked.
- Destructive safety: scripts that overwrite/update/delete files must list the affected paths, require explicit confirmation, and prefer a `--dry-run` mode. Never silently auto-confirm.
- Fuzzy input: when accepting file/folder names, support fuzzy/substring matching — auto-proceed on a single match, prompt a numbered picker on several, error clearly if ambiguous and non-interactive.
- Third-party dependencies: prefer the standard library. If a third-party package is needed, name each package and why, then give the exact run command, and wait for my explicit approval before running the script. Writing the file is fine; running it is what needs approval.

### 7.2 Python: use `uv` + PEP 723
- Default to `uv` for running and dependencies. Avoid `pip install`, manual venvs, `source .venv/bin/activate`, and global package installs for one-off scripts.
- Declare dependencies via PEP 723 inline metadata rather than `requirements.txt`:
```python
#!/usr/bin/env -S uv run --script --no-python-downloads
# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "openpyxl",
# ]
# ///
```
- Run with `uv run --no-python-downloads script.py`; prefer stdlib, and latest (bare package names) when deps are needed. If the `uv` or Python version or a dependency is missing, state the exact install command and wait for my explicit approval — never install automatically.

### 7.3 Logging
- Log to `<script_dir>/tool_logs/<script-name>.log`, resolved from the script file (not CWD); create the dir if missing. Append across runs, starting each run with one header line (start time).
- Logs go to the file only. Keep stdout for the script's real output and print concise errors to stderr.
- Default level `INFO`; `--verbose` enables `DEBUG`.
- Never log secrets, tokens, or credentials.
- Use the stdlib logger (Python) or plain file appends (TS). No custom handlers or logging frameworks.
- Applies to Python and TS scripts. Shell and Rust: optional.

### 7.4 Shell Scripts
- Use `#!/usr/bin/env bash` and `set -euo pipefail`. Use `CONFIG_*` variables, quote all paths and variable expansions, print explicit error messages, and require confirmation for destructive actions.

### 7.5 TypeScript Scripts
- Run with `node`; prefer built-ins and avoid trivial package deps. Third-party deps follow the approval rule in 7.1; state the exact install and run commands.

### 7.6 Rust Scripts
- Single `.rs` file; no `cargo new` for one-offs. A `fn main()` is optional.
- Use `rust-script` with or without crates (install `cargo install rust-script` only after approval); run `rust-script script.rs`.
- Need crates: add inline dependencies, then use the same command:
````rust
//! ```cargo
//! [dependencies]
//! serde_json = "1"
//! ```
````
- Third-party deps follow the approval rule in 7.1. First run compiles and caches; shebangs are Unix-only, so invoke it explicitly on Windows.

## 8. Git

- Commits and PR titles: conventional `type(scope): summary`; types `feat`, `fix`, `docs`, `chore`, `refactor`, `test`; scope optional. E.g. `docs: update contributing guide`.
- Never add `Co-Authored-By` or any coauthor/attribution trailer to commits.
- Never run these without my explicit approval:
  - `git add`, `git commit`, `git push` — I stage, commit, and push myself.
  - `git reset`, `git rebase`, `git commit --amend`, `git restore`, `git checkout -- .`, `git clean`, `git stash drop`/`clear`, `git branch -D`, `git push --delete` — these can discard or rewrite work.
  - Any force push (`-f`, `--force`, `--force-with-lease`), especially on shared branches.
- Never rewrite history on shared branches. When in doubt, stop and ask.
- Read-only git (`status`, `diff`, `log`, `show`, `blame`, `fetch`) is always fine.

After any coding task that modifies files, end your response with:

```text
COMMIT MSG: <msg>
```

so I can copy-paste it. Skip for general queries.