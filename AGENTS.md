# kora_newsjob agent guide

`kora_newsjob` is the Weazel News job resource: a garage (van and helicopter) built as a `kora_lib` NUI app, an equipment counter, usable camera/microphone items, a teleporting building entrance and a job blip. Layout: `fxmanifest.lua`, `config.lua` (shared config), `client/main.lua` (blip, garage/counter/door zones), `client/spawner.lua` (garage app and vehicle spawn), `client/camera.lua` (usable equipment props, animations and camera overlay), `server/main.lua` (spawn callback, trunk and equipment grants, usable items), `locales/`, `test/` (offline Lua scripts) and `tests/` (kora_qa feature files).

## Documentation

User-facing documentation lives in `docs/` (Markdown, published via the Kora Docusaurus site, kora_docs_next). Read `docs/index.md` first (overview and documentation map). Layout: `index.md` (hub), `installation.md` (dependencies, items, start order, tests), `how-to-use.md` (job gating, spawn/trunk/equipment flows), topic pages `configuration.md`, `garage.md`, `equipment.md`, `events.md`, `troubleshooting.md`. There is no `commands.md` or `api/` because the resource registers no commands and exposes no exports.

When you add, change, or remove a feature, config option, command, export, event, item, permission, or database table/column, update the matching page in `docs/` in the same change. Keep docs accurate to the code; do not document behaviour that does not exist.

Docs rules: plain Markdown with `title`/`sidebar_position` front matter (no `id`/`slug`), relative links only between docs pages, assets inside `docs/`, fenced code blocks with a language, and no raw `<`, `>`, `{`, `}` outside code (pages are parsed as MDX). The release version comes from `fxmanifest.lua`'s `version` field.

## Shared contribution standards

Read [CONTRIBUTING.md](CONTRIBUTING.md) before editing. Humans and agents follow
the same Kora standards and self-contained local Lua checks. Preserve the domain
constraints above and in module guides; record policy conflicts explicitly.
