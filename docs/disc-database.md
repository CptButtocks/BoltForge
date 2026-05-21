# Disc Database

`data/disc_database.yml` records known user-owned disc builds. It should be
safe to commit because it stores metadata and hashes, not game data.

## Entry Requirements

Only add a build after verifying it from a local disc image. Each entry should
include:

- stable build id,
- game and region,
- serial and disc label when known,
- boot executable path from `SYSTEM.CNF`,
- ISO size and hashes,
- sector size,
- table-of-contents sector information when known,
- support status and notes.

Do not add paths to local ISOs or extracted files.

## Unknown Builds

Importer tools should reject unknown builds by default. Research-only commands
may offer explicit override flags, but their output must remain local-only until
metadata is cleaned and reviewed.
