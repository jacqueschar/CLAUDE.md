# Personal CLAUDE.md

```
.
├── CLAUDE.md          # Coding guidelines — the default profile, synced to ~/.claude/CLAUDE.md
├── academic.md        # Optional chat-only profile — paste into a chat for academic/conversation mode
├── sync-claude.sh     # Copies a profile to ~/.claude/CLAUDE.md
├── README.md
└── LICENSE
```

## Sync to ~/.claude/CLAUDE.md

```bash
./sync-claude.sh            # defaults to CLAUDE.md, prompts on override
./sync-claude.sh acad       # fuzzy/substring profile matching
./sync-claude.sh --dry-run  # show what would be copied, without writing
```
