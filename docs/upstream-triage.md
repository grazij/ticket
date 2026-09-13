# Upstream triage ledger

Every open item in [wedow/ticket](https://github.com/wedow/ticket) as of the
snapshot below, and what this fork decided to do about it. The point of this
file is that nothing gets reviewed twice: if an upstream number appears here, it
has been dispositioned.

- **Snapshot:** 2026-09-13 — upstream had 42 open items (14 issues, 28 PRs).
- **Upstream master at snapshot:** `194b71a`.
- **This fork at snapshot:** `9cbdd2d`, 12 commits ahead. Upstream has merged
  none of our fixes, so every item marked *fixed* or *reimplemented* below is
  still open upstream.
- **Tracker:** Gitea `grazij/ticket`. A `#NN` in the Tracker column is an issue
  there, not an upstream number.

`dirty` and `clean` describe mergeability against **our** master, not upstream's.

## Dispositions

| Disposition | Meaning |
| --- | --- |
| **fixed** | Defect fixed here; no upstream PR existed, or we wrote our own |
| **merged** | Upstream PR cherry-picked essentially as written |
| **reimplemented** | Upstream PR's problem fixed, but the patch was rewritten — usually because it targets code that moved into `plugins/`, or because its approach was wrong |
| **deferred** | Real work, tracked, not started |
| **rejected** | Not work: already delivered, a question, or noise |

## Issues

| Upstream | Kind | Disposition | Where |
| --- | --- | --- | --- |
| [#2](https://github.com/wedow/ticket/issues/2) extensibility / custom commands | stale | **rejected** | The plugin system (`tk-<cmd>` on PATH) already delivers this |
| [#3](https://github.com/wedow/ticket/issues/3) ship as an Agent Skill | feature | deferred | tracker #17 (blocked by #12) |
| [#19](https://github.com/wedow/ticket/issues/19) hierarchical IDs | feature | deferred | tracker #15 — breaking ID-format change, needs a decision first |
| [#23](https://github.com/wedow/ticket/issues/23) create straight into `$EDITOR` | feature | deferred | tracker #11, with PR #55 |
| [#24](https://github.com/wedow/ticket/issues/24) "I ported it to Go" | noise | **rejected** | Not an issue; author says so |
| [#33](https://github.com/wedow/ticket/issues/33) branching strategy | question | **rejected** | Open-ended discussion, no deliverable |
| [#36](https://github.com/wedow/ticket/issues/36) `$EDITOR` with whitespace | defect | **reimplemented** | `2c5301d` — see PR #53 below |
| [#39](https://github.com/wedow/ticket/issues/39) draft/pending status | feature | deferred | tracker #10, with PR #50 |
| [#46](https://github.com/wedow/ticket/issues/46) parent vs deps confusion | docs | deferred | tracker #13, with PR #48 |
| [#56](https://github.com/wedow/ticket/issues/56) list parent/epic tickets | feature | deferred | tracker #16 — may be answered by PRs #29 + #40 |
| [#57](https://github.com/wedow/ticket/issues/57) create with a dependency | feature | deferred | tracker #14 — closes a real `ready`-status race |
| [#58](https://github.com/wedow/ticket/issues/58) path traversal via ticket ID | defect | **fixed** | `f55ca35` — `validate_id()` rejects `/` and `..`; also patched `plugins/ticket-edit` |
| [#63](https://github.com/wedow/ticket/issues/63) help ignores `TICKETS_DIR` | defect | **fixed** | `9cbdd2d` — help now reports the resolved store |
| [#64](https://github.com/wedow/ticket/issues/64) mise support | feature | deferred | tracker #12, with PR #65 |

## Pull requests

| Upstream | Merge state | Disposition | Where |
| --- | --- | --- | --- |
| [#1](https://github.com/wedow/ticket/pull/1) shell completion (bash/zsh) | clean, +482 | deferred | tracker #18 |
| [#12](https://github.com/wedow/ticket/pull/12) `--id` / `--dir` / `--summary` | dirty | deferred | tracker #19 — conflicts with `validate_id` and partial matching |
| [#25](https://github.com/wedow/ticket/pull/25) beads labels → tags | dirty, +1 | deferred | tracker #20 |
| [#26](https://github.com/wedow/ticket/pull/26) demote `--design` headings | dirty | deferred | tracker #21 |
| [#27](https://github.com/wedow/ticket/pull/27) `TICKET_PAGER=""` fell back to `PAGER` | clean | **merged** | `ed1fab0`; its shipped test was ineffective, replaced in `75ef1e0` |
| [#28](https://github.com/wedow/ticket/pull/28) quoted YAML tags → invalid JSON | dirty | **reimplemented** | `7d9e3d4`. Incomplete: single-quoted items still wrong → tracker #6 |
| [#29](https://github.com/wedow/ticket/pull/29) `tk tree` (children) | dirty, +445 | deferred | tracker #22 |
| [#30](https://github.com/wedow/ticket/pull/30) `---` rule leaks into `query` JSON | dirty | **reimplemented** | `7d9e3d4` |
| [#31](https://github.com/wedow/ticket/pull/31) `tk edit --children` | dirty | deferred | tracker #23 |
| [#34](https://github.com/wedow/ticket/pull/34) partial IDs vs symlinked `.tickets` | clean | **merged** | `4c087ba`. Missed `plugins/ticket-edit` → tracker #8 |
| [#35](https://github.com/wedow/ticket/pull/35) parameterise program name | clean, 9+/9− | deferred | tracker #24 |
| [#38](https://github.com/wedow/ticket/pull/38) `query --include-full-path` | dirty | deferred | tracker #25 |
| [#40](https://github.com/wedow/ticket/pull/40) type filter for `ls` | dirty | deferred | tracker #26 — overlaps PR #60 |
| [#41](https://github.com/wedow/ticket/pull/41) hidden parent dir broke ID prefix | clean | **merged** | `934032e` |
| [#42](https://github.com/wedow/ticket/pull/42) multi-word `create` titles | clean | **merged** | `8746849`; subject reworded `feat:` → `fix:` |
| [#44](https://github.com/wedow/ticket/pull/44) POSIX awk bracket expressions | dirty | **reimplemented** | `f29fa0b`. Wider than the PR: 12 sites incl. `plugins/ticket-ls` and `cmd_link`, which the PR misses. Verified on busybox awk 1.37.0 |
| [#47](https://github.com/wedow/ticket/pull/47) CONTRIBUTING.md | clean | deferred | tracker #27 — adapt, don't merge; `CLAUDE.md` holds the real conventions |
| [#48](https://github.com/wedow/ticket/pull/48) parent-vs-deps docs | clean | deferred | tracker #13, with issue #46 |
| [#50](https://github.com/wedow/ticket/pull/50) `pending` status | clean, 4+/4− | deferred | tracker #10, with issue #39 |
| [#52](https://github.com/wedow/ticket/pull/52) workflow plugin | clean, +1154 | deferred | tracker #28 — largest item in the queue |
| [#53](https://github.com/wedow/ticket/pull/53) `$EDITOR` whitespace | clean | **reimplemented** | `2c5301d`. The PR unquotes `$EDITOR`, which fixes flags but breaks a path containing spaces; we used `eval` instead, which handles both |
| [#54](https://github.com/wedow/ticket/pull/54) Nix flake | clean | deferred | tracker #29 |
| [#55](https://github.com/wedow/ticket/pull/55) `-d -` stdin + `--edit` | clean | deferred | tracker #11, with issue #23 |
| [#59](https://github.com/wedow/ticket/pull/59) `tk update` | clean, +373 | deferred | tracker #30 — land with PR #62 |
| [#60](https://github.com/wedow/ticket/pull/60) `ls --type/--priority` + fail-fast | clean | deferred | tracker #31 — the fail-fast half is worth more than the filters |
| [#62](https://github.com/wedow/ticket/pull/62) valid YAML flow arrays for `update` | clean | deferred | tracker #32 (blocked by #30) |
| [#65](https://github.com/wedow/ticket/pull/65) libexec plugin discovery | clean | deferred | tracker #12, with issue #64 |
| [#67](https://github.com/wedow/ticket/pull/67) `tk archive` | clean, +346 | deferred | tracker #33 — also claims a `tk closed` SIGPIPE fix, **unverified**, worth splitting out |

## Tracker items not from upstream

Gitea `grazij/ticket` #1–#9 came from reviewing this fork, not from upstream:
#1–#5 from a review of `194b71a`, and #6–#9 as incidental findings while fixing
the defects above. They are listed here only so a reader does not mistake the
numbering for upstream issues.

## Refreshing this ledger

```sh
curl -sS -H 'Accept: application/vnd.github+json' \
  'https://api.github.com/repos/wedow/ticket/issues?state=open&per_page=100'
```

Anything in that list whose number is absent from the two tables above is new
since the snapshot and needs a disposition. `pull_request` in an entry marks it
as a PR. Add a row before triaging, so a half-finished pass leaves a record.
