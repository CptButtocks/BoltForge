# Ratchet & Clank PS2-to-PC Native Port Project Plan

**Working title:** RatchetPC / RAC Native Runtime  
**Scope:** Native PC runtime and tooling for the PlayStation 2 *Ratchet & Clank* games, using legally obtained user-provided disc images and without distributing copyrighted game assets.  
**Date:** 2026-05-21  
**Status:** Planning document, not legal advice.

---

## 1. Executive summary

The realistic path to a playable PC version of the PS2 *Ratchet & Clank* games is **not** to “run the ISO” the way an emulator does. The project should instead become a native game-runtime plus asset-import pipeline:

1. The user supplies a legally obtained ISO/disc image.
2. A launcher/importer verifies the image, reads the ISO filesystem and hidden sector-based data, unpacks WADs, decompresses assets, and builds a local asset database.
3. A native PC engine loads the extracted data and reproduces the original engine behavior through clean-room reimplementation, selective decompilation research, and carefully verified subsystem ports.
4. The project ships only open-source code, schemas, tools, tests, and documentation. It does **not** ship original assets, original executable binaries, copyrighted source code, leaked SDK material, or patches that require illegal circumvention.

The most important strategic conclusion is that **ISO unpacking is only the first 10–20% of the problem**. Community tooling already exists for several R&C PS2 formats, notably Wrench, which supports the PS2 R&C titles and can pack/unpack full ISO files, meshes, collision meshes, gameplay instances, and other assets. The much harder work is reproducing the original engine: level streaming, object logic, combat, movement, camera, collision, animation, rendering, audio, saves, UI, and per-game differences.

This plan recommends a **hybrid clean-room native port**:

- Use existing public documentation and tools as references.
- Build an importer that can stand alone and eventually replace borrowed tooling where license compatibility or long-term control requires it.
- Reimplement runtime systems in native C++/Rust rather than shipping decompiled proprietary code.
- Use disassembly/decompilation internally to understand behavior, but record behavior as specifications, tests, and data schemas.
- Establish milestone-driven validation against original hardware or PCSX2 traces, while avoiding embedding any emulator.

---

## 2. Legal, ethical, and project-boundary principles

This project lives in a legally sensitive area. The technical plan should be designed from day one to reduce risk.

### 2.1 Distribution policy

The public project should distribute only:

- Native runtime source code.
- Importer/extractor source code.
- File-format documentation written by the project or incorporated under compatible licenses.
- Tests using synthetic, homebrew, or minimal fixture data.
- Scripts that operate on user-owned ISOs.
- Optional patches to project-owned code, not to copyrighted game binaries.

The project should not distribute:

- Game ISOs, asset packs, textures, models, music, sound effects, cutscenes, fonts, voice lines, or proprietary binaries.
- Decompiled proprietary game source code unless the team has received legal review and has chosen to accept that risk.
- Sony SDK files, leaked documentation, proprietary headers, or symbols from confidential sources.
- Tools whose purpose is to bypass access controls, region locks, or copy-protection systems.

### 2.2 User-facing launcher policy

The launcher should require a user-supplied disc image and should display clear language:

> This project does not include game data. You must provide a legally obtained copy of the game. The importer extracts assets locally on your machine. Do not upload, share, or redistribute extracted assets.

### 2.3 Clean-room workflow

A conservative workflow is recommended:

- **Research group:** examines binaries, PCSX2 traces, Wrench docs, public modding notes, and original game behavior. Produces behavior descriptions, type sketches, state-machine diagrams, and tests.
- **Implementation group:** implements the native runtime from those descriptions and tests. They should avoid copying disassembled code verbatim.
- **Shared artifacts:** schemas, behavior specs, test cases, fixture metadata, screenshots, frame captures, and issue tickets.

For a small volunteer team, a strict two-team clean room may be impractical, but the project should still prefer **specification-driven implementation** over copied decompilation.

### 2.4 Licensing implications

Wrench is GPL-3.0 licensed. That is useful but consequential. If this project copies or links GPL code, the combined work may also need to be GPL-compatible. Options:

- Make RatchetPC GPL-compatible and incorporate Wrench code where useful.
- Invoke Wrench as a separate external tool in the launcher rather than copying/linking it.
- Reimplement formats from public docs and behavioral observations to keep a different license.
- Keep a clear third-party-license inventory.

Before choosing the project license, decide whether GPL compatibility is acceptable. For a preservation/modding tool, GPL-3.0 is likely viable. For a future commercial-adjacent engine, it may not be.

---

## 3. Scope and target games

### 3.1 Primary targets

The obvious target family is:

1. *Ratchet & Clank* / R&C1.
2. *Ratchet & Clank: Going Commando* / *Locked and Loaded* / R&C2.
3. *Ratchet & Clank: Up Your Arsenal* / R&C3.
4. *Ratchet: Deadlocked* / *Gladiator* / DL.

The plan should treat R&C1 as the first playable target unless early research proves that R&C2 or R&C3 has a substantially easier runtime path. R&C1 is simpler in feature set but may have unique file-layout behavior. R&C2/R&C3/DL share more systems, but R&C3 and DL introduce online/multiplayer complexity.

### 3.2 Recommended first milestone game

**Recommended first playable game:** R&C1.

Why:

- No online mode to block “complete game” status.
- Smaller weapon, vendor, progression, and UI system than later games.
- Strong preservation value.
- Lower systemic complexity than R&C3/DL.

Why it is still hard:

- R&C1 retail builds use raw sector-based assets that are not fully represented in the normal ISO filesystem.
- The original engine depends heavily on PS2-specific rendering, DMA/VIF/VU behavior, and level overlays.
- Gameplay is object-heavy and full of bespoke interactions.

### 3.3 Supported disc variants

The project should maintain a `disc_database.yml` with:

- Game title.
- Region.
- Serial.
- Disc label.
- Executable path from `SYSTEM.CNF`.
- ISO size.
- CRC32, SHA-1, and SHA-256 of known-good images.
- Asset table sector constants.
- Whether main executable is packed.
- Localization set.
- Known differences and unsupported builds.

Start with one well-known NTSC-U R&C1 build, then add PAL and NTSC-J variants only after the pipeline is stable.

---

## 4. Definition of “native PC port without emulation”

This project should explicitly define what it means by “without emulation,” because several implementation strategies sit on a spectrum.

### 4.1 Not allowed as the primary approach

The project should not become:

- A PS2 CPU emulator.
- A GS/VU/SPU emulator wrapped in a game-specific shell.
- A modified PCSX2 build that auto-boots R&C.
- A compatibility layer that runs the original ELF dynamically instruction by instruction.

Those are emulation, even if branded differently.

### 4.2 Allowed and recommended

The project should be:

- A native PC executable.
- A native resource manager reading extracted original assets.
- Native rendering using Vulkan/D3D12/OpenGL/Metal abstractions.
- Native audio mixing.
- Native input, save, UI, networking, and settings systems.
- Reimplemented gameplay code that produces equivalent behavior.
- Optional static analysis of original binaries to document behavior.

### 4.3 Gray-zone options

The following are technically possible but should be treated with caution:

- **Static binary translation:** translate MIPS EE code into native x86-64/ARM64 code ahead of time. This may avoid dynamic emulation but still requires emulating large parts of the PS2 ABI, memory map, GS/VU/SPU interactions, and timing-sensitive behavior. It also creates legal and maintainability concerns.
- **Function lifting:** lift selected routines into C++/IR for research and test generation. This is useful, but shipping lifted code may be risky.
- **Microprogram translation:** translate VU1 microprogram behavior into shaders or CPU-side preprocessors. This is likely necessary, but it should be done as renderer reimplementation, not as a general-purpose VU emulator.

Recommended stance: **use static analysis to understand, but ship clean native systems.**

---

## 5. Current technical baseline from public sources

Public R&C PS2 tooling and documentation already gives the project a head start.

### 5.1 Wrench

Wrench is a set of modding tools for the PS2 R&C games and is compatible with R&C1, R&C2, R&C3, and Deadlocked. Its listed features include ISO pack/unpack, gameplay instance pack/unpack, tfrag/moby/tie mesh extraction, collision mesh pack/unpack, and other asset tools. This strongly suggests that the asset-import phase is feasible and should not be reinvented blindly.

Wrench documentation also describes important details:

- R&C discs use a standard ISO filesystem to access `SYSTEM.CNF`, the main executable, and some files, but most assets are accessed later by sector number via raw disk I/O.
- Retail builds differ: R&C2 retail includes assets on the filesystem, while R&C1/R&C3/DL retail builds do not expose all assets through the normal filesystem.
- The sector size is `0x800` bytes.
- R&C1 and later games use different table-of-contents layouts.
- The game code is split between the main ELF and level overlays.
- UYA and DL pack the main ELF.
- WAD compression uses a custom LZ-style stream.

### 5.2 RatchetModding resource list

The RatchetModding resource list identifies Wrench as an asset packer/unpacker for the PS2 R&C titles and links other utilities such as WAD tools, hidden-file parsers, save editors, and Ghidra Emotion Engine support. This should become the project’s first discovery map.

### 5.3 OpenGOAL as a comparable project, not a direct solution

OpenGOAL is an unofficial native PC port effort for the *Jak & Daxter* games. Its public materials describe a native x86-64 port, decompilation tooling, asset unpacking, a launcher, mod support, and a methodology that manually recovers types/casts until code can be recompiled and tested. This is the closest public proof that a PS2-era platformer can be ported natively by a community project.

However, R&C is not Jak. The R&C engine, data formats, object systems, renderer, and code organization differ. OpenGOAL should guide process and quality bars, not be treated as reusable engine code.

### 5.4 PS2 architecture constraints

The PS2’s architecture is unusual by modern PC standards:

- The Emotion Engine is the main CPU and is also known as the R5900, a custom MIPS core.
- The EE has custom SIMD/MMI behavior, 128-bit general-purpose registers, VU0 integration, scratchpad memory, DMA, IPU, and tight coupling to VIF/VU/GIF/GS graphics paths.
- PS2SDK documentation highlights the split between the Emotion Engine and the I/O Processor.
- R&C rendering relies on PS2-style VIF DMA packets, VU1 microprograms, GIF packets, GS state, swizzled textures, and fixed-function rendering conventions.

These facts explain why a native port is much harder than simply decoding models and textures.

---

## 6. Recommended architecture

## 6.1 High-level system diagram

```text
              User-owned ISO / Disc Image
                         |
                         v
+----------------------------------------------------+
| Importer / Launcher                                |
| - Verify known build                               |
| - Parse ISO9660 + SYSTEM.CNF                       |
| - Locate ELF + hidden sector tables                |
| - Extract/decompress WADs                          |
| - Convert/index assets                             |
| - Build local manifest + cache                     |
+------------------------+---------------------------+
                         |
                         v
+----------------------------------------------------+
| Local User Asset Store                             |
| - No redistribution                                |
| - Game/region/build manifest                       |
| - Raw extracted files                              |
| - Converted runtime assets                         |
| - Hashes/provenance                                |
+------------------------+---------------------------+
                         |
                         v
+----------------------------------------------------+
| Native Runtime                                     |
| - Core engine                                      |
| - Renderer                                         |
| - Audio                                            |
| - Physics/collision                                |
| - Gameplay/object system                           |
| - UI/localization                                  |
| - Save/profile system                              |
| - Optional multiplayer/network layer               |
+------------------------+---------------------------+
                         |
                         v
                  Playable PC Game
```

## 6.2 Repository layout

```text
ratchetpc/
  CMakeLists.txt or meson.build
  README.md
  LICENSE
  THIRD_PARTY.md
  docs/
    legal-boundaries.md
    disc-database.md
    reverse-engineering-workflow.md
    asset-formats/
    engine/
    testing/
  data/
    disc_database.yml
    schemas/
      asset_manifest.schema.json
      level.schema.json
      texture.schema.json
      moby.schema.json
      pvar.schema.json
      sound_bank.schema.json
    synthetic_fixtures/
  tools/
    iso_importer/
    wad_tool/
    asset_inspector/
    level_viewer/
    trace_tools/
    decomp_support/
    save_tool/
  engine/
    core/
    platform/
    render/
    audio/
    input/
    physics/
    gameplay/
    ui/
    net/
  launcher/
  tests/
    unit/
    integration/
    golden_assets/
    replay/
  external/
    README.md
```

## 6.3 Language and framework recommendation

A practical stack:

- **C++20 or C++23** for the native runtime.
- **Rust or C++** for import tools. Rust is excellent for safe binary parsing; C++ may simplify code sharing with the engine.
- **SDL3** for windowing, input, controller mapping, and platform abstraction.
- **wgpu**, **bgfx**, or a custom Vulkan/D3D12 abstraction for rendering.
- **miniaudio**, **OpenAL Soft**, or a custom mixer for audio.
- **Dear ImGui** for internal tools: asset browser, level viewer, debug UI.
- **CMake** or **Meson** for builds.
- **GitHub Actions** or equivalent CI for Windows/Linux/macOS builds.
- **RenderDoc** for graphics debugging.
- **Tracy** for profiling.
- **Ghidra** plus PS2/Emotion Engine support for analysis.

Recommended first choice: C++20 + SDL3 + bgfx/wgpu + miniaudio + Dear ImGui. The exact graphics abstraction can be revisited after renderer prototyping.

## 6.4 Runtime data philosophy

The importer should preserve three layers of data:

1. **Raw provenance layer:** exact extracted bytes, sectors, offsets, and source hash. This is essential for debugging and verification.
2. **Decoded asset layer:** parsed but still close to original structures, such as PIF textures, WAD members, tfrag packets, moby models, animation chunks, and gameplay instance arrays.
3. **Runtime-native layer:** GPU-ready meshes, texture arrays, skeletons, animation clips, collision acceleration structures, sound clips, string tables, and material definitions.

Do not skip directly from raw ISO to runtime-native assets. The decoded layer is what makes reverse engineering, tools, mods, and tests sustainable.

---

## 7. Phase-by-phase implementation plan

## Phase 0 — Governance, scope, and build skeleton

### Goals

- Create the public repository.
- Define legal boundaries.
- Set the first target disc build.
- Establish a repeatable build and test workflow.
- Avoid architectural decisions that will need to be undone later.

### Work items

1. Create repo with license, contribution guide, code-of-conduct, and legal boundary document.
2. Decide license after reviewing Wrench and other dependencies.
3. Create `disc_database.yml` with one target build.
4. Add CI for at least Windows and Linux.
5. Add a minimal launcher shell and CLI skeleton:

```bash
ratchetpc import --iso /path/to/game.iso --library ~/.local/share/ratchetpc
ratchetpc verify --game rac1 --region ntsc-u
ratchetpc launch --game rac1
ratchetpc inspect --asset <asset-id>
```

6. Add a synthetic binary fixture set for parser tests.
7. Add a project rule: no original game data in Git.

### Deliverables

- Buildable empty runtime window.
- Buildable CLI.
- Legal/distribution policy.
- Disc database schema.
- CI pipeline.

### Exit criteria

- New contributor can build the project in under one hour.
- CI rejects accidental binary asset commits by size/type/pattern.
- CLI can read an ISO path and produce a structured error if unsupported.

---

## Phase 1 — ISO verification and disc indexing

### Goals

- Parse the user-supplied ISO.
- Identify the game, region, and build.
- Read `SYSTEM.CNF` and the main ELF path.
- Record all filesystem files and known hidden sector ranges.

### Work items

1. Implement ISO9660 reader or integrate a permissively licensed one.
2. Parse `SYSTEM.CNF`:
   - boot executable path,
   - version,
   - any boot flags.
3. Locate and hash the main ELF.
4. Create `DiscImage` abstraction:

```text
DiscImage
  sector_size = 0x800
  read_sector(n)
  read_bytes(offset, length)
  filesystem_entries[]
  boot_executable
  disc_hashes
```

5. Add known-build matching:
   - full ISO hash,
   - ELF hash,
   - file table fingerprints,
   - table-of-contents sector heuristics.
6. Dump a report:

```text
Game: Ratchet & Clank
Region: NTSC-U
Build: unknown or matched
Boot ELF: SCUS_971.99
ISO SHA-256: ...
Main ELF SHA-256: ...
Known TOC sector: 1500
Filesystem file count: ...
Hidden sector ranges: suspected ...
```

### Technical notes

R&C file loading is not just normal ISO file extraction. The importer must support raw sector access and game-specific tables. Wrench documentation notes that assets may be accessed by sector number after the executable is loaded, and that R&C1/R&C3/DL retail builds do not expose all assets through the normal ISO filesystem.

### Deliverables

- `ratchetpc disc-info` command.
- ISO report JSON.
- Build matching database.

### Exit criteria

- Tool correctly identifies the first supported R&C1 build.
- Tool refuses unknown images unless `--allow-unknown` is passed.
- Tool can read arbitrary sectors and print hex dumps for debugging.

---

## Phase 2 — Table-of-contents and WAD extraction

### Goals

- Locate the game-specific table of contents.
- Extract global and level WADs.
- Decompress WAD-compressed files.
- Preserve sector provenance.

### Work items

1. Implement R&C1 table parser.
2. Implement R&C2/R&C3/DL table parser.
3. Represent disc entries:

```yaml
asset_source:
  game: rac1
  region: ntsc-u
  source_iso_sha256: ...
  sector: 1500
  size_sectors: 42
  byte_offset: 0x...
  byte_size: 0x...
  name_hint: LEVEL03.WAD
  type_hint: level_wad
```

4. Implement WAD decompression.
5. Add round-trip tests against synthetic compressed streams.
6. Compare output with Wrench on user-local data where allowed.
7. Add error recovery for unknown builds:
   - scan for WAD magic,
   - scan for plausible level header tables,
   - compare sector ranges with filesystem gaps.

### Deliverables

- Extracted WAD list.
- Decompressed WAD file cache.
- Provenance manifest.

### Exit criteria

- Importer extracts all known global and level WADs for one target build.
- Every extracted byte range is traceable to an ISO sector.
- Decompression tests cover boundary conditions, including 0x2000-byte alignment behavior where applicable.

---

## Phase 3 — Asset manifest and asset database

### Goals

- Establish one canonical internal representation for every extracted asset.
- Make asset discovery searchable.
- Create a foundation for tools and runtime loading.

### Work items

1. Create `asset_index.sqlite` or equivalent.
2. Create asset ID scheme:

```text
asset_id = rac:<game>:<region>:<build>:<type>:<sector>:<size>:<sha1-short>
```

3. Store:
   - asset type,
   - source sector/offset,
   - source hash,
   - decoded fields,
   - references to other assets,
   - conversion status,
   - parser version.
4. Add import cache invalidation:
   - if importer version changes, re-decode affected assets;
   - if runtime converter changes, regenerate runtime blobs.
5. Add CLI:

```bash
ratchetpc assets list --type texture
ratchetpc assets inspect <asset-id>
ratchetpc assets export <asset-id> --format gltf
ratchetpc assets validate
```

### Deliverables

- Persistent local asset database.
- JSON asset manifest.
- Asset inspector CLI.

### Exit criteria

- All extracted files are represented as assets, even if type is `unknown`.
- Assets can be queried by type, level, sector, and source WAD.
- Import is deterministic: same ISO + same importer version produces same manifest.

---

## Phase 4 — Texture pipeline

### Goals

- Decode texture formats used by the games.
- Support UI textures, skins, environment textures, and special alpha semantics.
- Upload textures to the native renderer.

### Work items

1. Implement PIF parser:
   - magic,
   - file size,
   - width/height,
   - pixel format,
   - CLUT format,
   - CLUT order,
   - mip levels.
2. Implement palette unswizzling.
3. Implement pixel unswizzling for GS-native layouts.
4. Convert to intermediate image formats:
   - RGBA8 for general debugging,
   - BCn/ASTC optional compressed runtime targets,
   - original-indexed/CLUT-preserving representation for exactness.
5. Handle special alpha behavior:
   - alpha above threshold used for bloom in UYA/DL,
   - alpha/reflectivity conventions for specific materials.
6. Create texture viewer.
7. Add golden tests:
   - known texture hash after decode,
   - mip-level count,
   - palette mapping.

### Deliverables

- `TextureAsset` schema.
- PIF decoder.
- Texture viewer.
- Runtime texture upload.

### Exit criteria

- UI and world textures display correctly in the asset viewer.
- Swizzle/unswizzle logic is covered by tests.
- Texture provenance remains intact.

---

## Phase 5 — Static geometry, collision, and level viewer

### Goals

- Render a level in a PC window with a free camera.
- Decode enough level geometry and collision to inspect worlds.
- Build confidence in importer correctness before gameplay implementation.

### Work items

1. Decode terrain/tfrag geometry.
2. Decode tie meshes and instances.
3. Decode shrub meshes and instances.
4. Decode sky geometry or skybox/skydome assets.
5. Decode collision meshes:
   - triangle soups,
   - spatial partitions,
   - collision material IDs,
   - climbable/slippery/damage/water flags if present.
6. Decode occlusion and visibility data where practical.
7. Convert geometry to runtime mesh format:

```text
RuntimeMesh
  vertex_buffer
  index_buffer
  material_id
  bounds
  source_asset_id
  original_vif_packet_ref optional
```

8. Implement free-camera level viewer.
9. Add basic rendering passes:
   - opaque terrain,
   - alpha-tested surfaces,
   - sky,
   - debug collision overlay,
   - instance bounds,
   - portal/occlusion debug.

### Deliverables

- Native level viewer.
- Geometry conversion pipeline.
- Collision viewer.
- Material assignment enough for recognizable scenes.

### Exit criteria

- First target level loads and is visually recognizable.
- Collision mesh aligns with visible geometry.
- Tool can switch between levels without restarting.

### Why this milestone matters

A level viewer gives immediate feedback and attracts contributors. It also validates the hardest asset-import assumptions before the project invests years in gameplay.

---

## Phase 6 — Moby/object model, animation, and gameplay-instance parsing

### Goals

- Decode interactive object definitions and placements.
- Render player/enemy/weapon/gadget models.
- Load level object instances with pvars, links, paths, and groups.

### Work items

1. Implement gameplay file header parsers per game.
2. Decode object categories:
   - moby classes,
   - moby instances,
   - moby groups,
   - pvars,
   - moby links,
   - shared data,
   - path data,
   - cuboids/spheres/cylinders/pills,
   - cameras,
   - lights,
   - environment transitions,
   - sound instances.
3. Implement moby mesh parser.
4. Implement skeleton/animation parser.
5. Create animation viewer:
   - browse clips,
   - scrub frames,
   - show bones,
   - show attachment points.
6. Create instance viewer:
   - click object in level,
   - inspect class ID,
   - inspect pvars,
   - inspect links.
7. Create preliminary object registry:

```yaml
moby_class:
  id: 0x1234
  name: vendor_placeholder
  confidence: low
  mesh_asset: ...
  update_function_addr: 0x...
  pvar_schema: unknown
```

### Deliverables

- Moby renderer in level viewer.
- Animation viewer.
- Instance/pvar inspector.
- First object registry.

### Exit criteria

- Player model, common enemies, crates, bolts, and vendors appear in correct level positions.
- At least one idle/walk animation plays correctly.
- pvars are inspectable even if not fully understood.

---

## Phase 7 — Reverse-engineering workflow for code and behavior

### Goals

- Understand the original engine enough to reimplement gameplay.
- Build tooling that makes binary analysis repeatable and collaborative.
- Avoid a pile of unreviewable notes.

### Work items

1. Create Ghidra/analysis loader for:
   - main ELF,
   - level overlay sections,
   - packed UYA/DL ELF sections,
   - function pointer tables,
   - vtables for moby/camera/sound classes.
2. Create symbol database:

```yaml
function:
  address: 0x00123456
  name: rac1_update_ratchet_movement_candidate
  game: rac1
  build: ntsc-u
  confidence: medium
  source: string-xref / trace / vtable / manual
  notes: ...
```

3. Create type database:

```yaml
struct:
  name: Moby
  size: 0x??
  fields:
    - offset: 0x00
      name: class_id
      type: u16
      confidence: high
```

4. Use runtime tracing on original game via PCSX2 or hardware capture for research:
   - memory writes to object structs,
   - function call traces,
   - player position/velocity/camera state,
   - collision queries,
   - draw-call-like packet output.
5. Write behavior specs from observations:
   - movement acceleration,
   - jump arcs,
   - wrench attack state machine,
   - bolt pickup rules,
   - enemy AI loops,
   - vendor purchase flow,
   - planet transition flow.
6. Implement trace diff tooling:

```bash
ratchetpc trace compare original_trace.json native_trace.json --fields player.pos,player.vel,camera
```

7. Define confidence levels:
   - **observed:** behavior witnessed but not fully understood;
   - **specified:** behavior described in tests;
   - **implemented:** native behavior exists;
   - **verified:** matches trace/playtest threshold.

### Deliverables

- Analysis database.
- Overlay loader.
- Function/type annotation workflow.
- Behavior spec template.
- Trace comparison tools.

### Exit criteria

- Team can identify which function updates a chosen moby class.
- Team can trace player movement variables in the original game.
- Native implementation tasks are driven by behavior specs, not vague guesses.

---

## Phase 8 — Native engine core

### Goals

- Build the runtime architecture that will support actual gameplay.
- Keep systems simple enough for reverse-engineered content.
- Avoid generic-engine overengineering.

### Core systems

1. **Game loop**
   - Fixed simulation tick matching original game assumptions.
   - Variable rendering interpolation optional.
   - Deterministic replay mode for testing.

2. **Memory/resource model**
   - Level-local asset heaps.
   - Global assets.
   - Streaming boundaries.
   - Object pools.
   - Handles instead of raw pointers.

3. **Scene system**
   - Active level.
   - Active chunks/rooms.
   - Object registry.
   - Visibility system.

4. **Object system**
   - Moby instances.
   - Class behavior functions.
   - Per-instance pvars.
   - Links and triggers.
   - Lifecycle: spawn, update, damage, destroy, serialize.

5. **Physics/collision**
   - Character movement controller.
   - Ground detection.
   - Collision material rules.
   - Sweeps and raycasts.
   - Projectiles.
   - Bolts/items.

6. **Camera**
   - Follow camera.
   - Combat camera.
   - scripted cameras.
   - grind rail camera.
   - cutscene camera.

7. **UI/frontend**
   - Main menu.
   - HUD.
   - weapon wheel/quick select.
   - vendor UI.
   - subtitles/localization.

8. **Save/profile**
   - PC-native save files.
   - Optional import/export from PS2 save structures later.
   - Versioned serialization.

### Deliverables

- Native engine loop.
- Loadable level state.
- Debug console.
- Deterministic replay recorder.

### Exit criteria

- Can load a level, spawn a placeholder Ratchet object, move in free-camera or no-clip mode, and render stable frames.
- Engine can reset/reload level cleanly.

---

## Phase 9 — Renderer reimplementation

### Goals

- Reproduce the look of the original games while taking advantage of PC hardware.
- Translate PS2 rendering concepts into modern GPU passes.
- Support both accuracy and enhancement modes.

### Rendering challenges

The PS2 path differs deeply from PC rendering. R&C uses multiple renderers for different object types, and public Wrench documentation describes the high-level PS2 flow: RAM → VIF1 → VU1 → GIF → GS, plus alternative paths that bypass parts of that flow. A native PC renderer must reconstruct final intent, not mechanically emulate every register.

### Recommended pass structure

1. **Frame setup**
   - camera matrices,
   - fog parameters,
   - global lighting,
   - level visibility.

2. **Sky pass**
   - sky geometry/background,
   - depth behavior matching original.

3. **Terrain/tfrag pass**
   - static world geometry,
   - baked lighting/vertex colors,
   - texture pages/materials.

4. **Tie/shrub pass**
   - instanced scenery,
   - distance fade/culling.

5. **Moby pass**
   - animated characters,
   - weapons,
   - enemies,
   - pickups.

6. **Particle/effects pass**
   - weapon effects,
   - explosions,
   - smoke,
   - sparks,
   - bolt effects.

7. **Transparent pass**
   - alpha blending,
   - water/glass/energy effects,
   - ordering heuristics.

8. **Post-processing**
   - bloom recreation,
   - color correction,
   - optional CRT/PS2-like output,
   - widescreen-safe output.

9. **UI pass**
   - HUD,
   - menus,
   - subtitles.

### Accuracy modes

Provide renderer profiles:

- **Original-like:** native resolution scaling but original aspect, original fog distances, original texture filtering as closely as practical.
- **Enhanced:** widescreen, higher internal resolution, improved anisotropic filtering, optional MSAA/TAA, increased draw distance only when safe.
- **Debug:** wireframe, collision overlay, object IDs, material IDs, overdraw, draw-call grouping.

### VU/GIF/GS translation strategy

Avoid building a general PS2 renderer. Instead:

- Decode model packet formats into semantic geometry where possible.
- Identify microprogram outputs and reproduce equivalent vertex transforms in shaders.
- Convert material state to modern pipeline state.
- Preserve PS2 quirks that affect gameplay or recognizable visuals:
  - alpha test thresholds,
  - texture wrapping,
  - CLUT behavior,
  - fog,
  - depth precision artifacts if visually important,
  - additive effects,
  - bloom markers.

### Deliverables

- Modern renderer with tfrag/tie/shrub/moby/material support.
- Debug render tools.
- RenderDoc capture workflow.
- Screenshot diff pipeline.

### Exit criteria

- First level visually matches original at a recognizable level.
- Common visual artifacts have issues filed with screenshots and source asset IDs.
- Renderer can run at stable 60 FPS on a midrange PC for test scenes.

---

## Phase 10 — Audio system

### Goals

- Decode music, voice, and sound effects.
- Recreate 3D positional audio, streaming, mixing, reverb, and event triggers.
- Handle Sony 989snd bank behavior or reimplement enough of it.

### Known baseline

Wrench documentation says VAG files store music and voice lines as raw ADPCM samples in the PS2 SPU format. It also notes that the games use Sony’s 989snd audio library for sound effects, and that Wrench does not currently support 989snd sound banks. This makes audio one of the highest-risk subsystems.

### Work items

1. Implement VAG/PS2 ADPCM decoder.
2. Build music/voice playback in native mixer.
3. Reverse engineer sound bank structure:
   - sample tables,
   - pitch/volume/envelopes,
   - program/instrument mapping,
   - event IDs,
   - sequence data if present,
   - reverb/send parameters.
4. Map sound instances from gameplay files to runtime emitters.
5. Recreate event API:

```cpp
AudioEventHandle play_sound(SoundEventId id, const Vec3* position, AudioParams params);
void stop_sound(AudioEventHandle handle);
void set_listener(const Vec3& pos, const Quat& orientation);
```

6. Implement streaming policy:
   - music streaming,
   - voice streaming,
   - preloaded SFX banks per level.
7. Add debug audio UI:
   - currently playing voices,
   - bank inspector,
   - event trigger console,
   - 3D emitter view.
8. Validate by comparing captured original audio events and native events.

### Deliverables

- VAG decoder.
- Audio bank inspector.
- Native mixer integration.
- First working in-level sounds.

### Exit criteria

- Music and voice clips play correctly.
- At least one level’s ambient and common SFX are mapped.
- Audio does not block level load or frame loop.

---

## Phase 11 — Player controller and core gameplay vertical slice

### Goals

- Make Ratchet move correctly in one level.
- Implement the smallest satisfying playable loop.

### Vertical slice target

A recommended first playable slice:

- R&C1, first planet/level.
- Spawn Ratchet at correct start position.
- Walk/run/jump/double jump/ledge interaction if applicable.
- Camera follow.
- Collision with terrain.
- Wrench attack.
- Crate destruction.
- Bolt pickup.
- Health/damage from one enemy or hazard.
- Basic HUD.
- Level exit trigger or transition stub.

### Work items

1. Reconstruct player physics constants through trace/playtest.
2. Implement movement states:
   - idle,
   - walk/run,
   - jump/fall,
   - landing,
   - wrench attack,
   - damage reaction,
   - death/respawn.
3. Implement camera states.
4. Implement collision sweeps and material responses.
5. Implement input mapping:
   - DualShock-compatible gamepad mapping,
   - keyboard/mouse optional,
   - rebindable controls.
6. Implement core object classes:
   - crates,
   - bolts,
   - health pickups,
   - simplest enemy,
   - level trigger.
7. Implement HUD basics:
   - health,
   - bolts,
   - selected weapon placeholder.
8. Add replay tests:
   - fixed input script,
   - final player position tolerance,
   - object state checks.

### Deliverables

- First playable vertical slice.
- Player movement spec.
- Debug replay comparison.

### Exit criteria

- A user can run around a real extracted level, break crates, collect bolts, and recognize the gameplay feel.
- A scripted replay is deterministic on at least two machines.

---

## Phase 12 — Weapons, gadgets, enemies, and mission logic

### Goals

- Move from a tech demo to an actual game.
- Implement the gameplay systems that make R&C recognizable.

### Work items

1. Weapon system:
   - inventory,
   - ammo,
   - purchase/unlock,
   - quick select,
   - projectile/hitscan behavior,
   - weapon-specific effects,
   - upgrades if applicable to target game.
2. Gadget system:
   - context-sensitive use,
   - level interactions,
   - progression gating.
3. Enemy system:
   - class registry,
   - AI update loops,
   - pathing/spline use,
   - attack states,
   - damage/death/drop logic.
4. Mission scripting:
   - triggers,
   - dialogues,
   - cutscenes,
   - planet objectives,
   - vendor and infobot progression.
5. Economy/progression:
   - bolts,
   - purchases,
   - unlock flags,
   - level completion states.
6. Cutscenes:
   - determine format,
   - decode/play videos if present,
   - scripted in-engine scenes if applicable,
   - subtitle and audio synchronization.

### Deliverables

- Weapon framework.
- Gadget framework.
- Enemy AI framework.
- Mission trigger system.
- Planet progression system.

### Exit criteria

- One planet can be completed from start to finish.
- Vendor interaction works.
- At least three weapons/gadgets work.
- Enemy encounters are playable without debug intervention.

---

## Phase 13 — Full R&C1 campaign implementation

### Goals

- Complete all planets for R&C1.
- Reach “playable start-to-finish” status.

### Work items

1. Build a planet checklist:

```text
Planet
  Loads
  Terrain visible
  Objects visible
  Collision complete
  Music/SFX
  Mission triggers
  Required enemies
  Required gadgets
  Cutscenes
  Vendor/progression
  Save/load
  Completion verified
```

2. Prioritize planets by dependency:
   - early planets first,
   - gadget-unlock planets next,
   - boss planets after core combat,
   - optional/edge-case content last.
3. Implement object classes by frequency:
   - crates/bolts/vendors first,
   - common enemies next,
   - unique mission objects later.
4. Implement save/load.
5. Implement menus and planet selection/travel.
6. Implement pause/options.
7. Add QA playthrough process.

### Deliverables

- R&C1 playable campaign.
- Save/load support.
- End-to-end playtest report.

### Exit criteria

- Game can be completed without emulator or debug tools.
- Known-blocker list is empty.
- Remaining issues are classified as visual/audio/minor gameplay bugs.

---

## Phase 14 — R&C2/R&C3/DL expansion

### Goals

- Reuse the engine foundation across later PS2 R&C titles.
- Add game-specific systems without corrupting R&C1 support.

### Work items

1. Expand disc database for R&C2, R&C3, and DL.
2. Add per-game feature flags:

```yaml
features:
  weapon_xp: true
  armor_vendor: true
  arena: true
  multiplayer: false
  online: false
  packed_main_elf: true
```

3. Import and load levels for each title.
4. Add changed file-format parsers.
5. Add weapon upgrade systems for R&C2/R&C3 where needed.
6. Add arena/minigame systems.
7. Add R&C3/DL multiplayer split-screen support if feasible.
8. Treat online multiplayer as a separate large project.

### Deliverables

- R&C2 level viewer, then playable slice.
- R&C3 level viewer, then playable slice.
- DL level viewer, then playable slice.

### Exit criteria

- Shared engine does not regress R&C1.
- Each new game reaches a vertical slice before full-campaign work starts.

---

## Phase 15 — Online and multiplayer, if pursued

### Goals

- Preserve multiplayer behavior for R&C3/DL where possible.
- Avoid letting multiplayer block single-player completion.

### Baseline

The Clank project is an open-source implementation of the SCE-RT/Medius server stack originally intended for *Ratchet & Clank: Up Your Arsenal* online community work. This suggests that existing community knowledge can support server-side research.

### Work items

1. Split multiplayer into layers:
   - local split-screen rendering/input,
   - game-mode rules,
   - network protocol,
   - matchmaking/lobby/server services.
2. Implement local multiplayer first if target game requires it.
3. For online, decide whether to integrate with, interoperate with, or learn from Clank.
4. Reimplement networking in native terms:
   - deterministic/state-sync model,
   - packet formats,
   - latency handling,
   - NAT/session behavior,
   - authentication/account replacement for private servers.
5. Keep online optional and disabled by default until stable.

### Deliverables

- Local multiplayer prototype.
- Online architecture doc.
- Optional integration plan with community server stack.

### Exit criteria

- Multiplayer is not a blocker for single-player games.
- Any online feature has clear user safety and server rules.

---

## 8. Deep dive: asset importer design

## 8.1 Importer pipeline

```text
ISO path
  -> validate file exists and readable
  -> hash ISO
  -> read ISO9660 filesystem
  -> parse SYSTEM.CNF
  -> locate boot ELF
  -> match known build
  -> locate game-specific TOC
  -> extract global WADs
  -> extract level WADs
  -> decompress WAD-compressed files
  -> parse asset types
  -> write raw cache
  -> write decoded cache
  -> write runtime cache
  -> produce import report
```

## 8.2 Failure handling

The importer should be defensive. It should never silently guess in a way that corrupts the local library.

Error classes:

- `UnsupportedDiscBuild`
- `HashMismatch`
- `MalformedSystemCnf`
- `UnsupportedTableLayout`
- `WadDecompressionFailed`
- `AssetParserFailed`
- `RuntimeConversionFailed`
- `LicensePolicyBlocked`

Each error should include:

- source game/build if known,
- sector and byte offset,
- parser name/version,
- expected vs actual bytes/fields,
- next suggested action.

## 8.3 Import report

Generate a Markdown and JSON report after import:

```text
Import successful
Game: R&C1
Region: NTSC-U
Known build: SCUS-...
ISO SHA-256: ...
Global assets: ...
Levels: ...
Textures: ...
Models: ...
Collision meshes: ...
Audio clips: ...
Unknown assets: ...
Warnings: ...
```

## 8.4 Local asset storage

Recommended layout:

```text
~/.local/share/ratchetpc/
  library.json
  games/
    rac1-ntscu-<hash>/
      import_report.md
      manifest.json
      asset_index.sqlite
      raw/
      decoded/
      runtime/
      screenshots/
      logs/
```

Never write extracted assets into the repo by default. Keep all user-owned data in a local library path.

---

## 9. Deep dive: runtime object system

The R&C games are object-heavy. Many objects are not generic entities; they are class-specific “moby” instances with per-class update functions and pvars.

## 9.1 Native representation

```cpp
struct MobyInstance {
    MobyId id;
    MobyClassId class_id;
    Transform transform;
    uint32_t flags;
    BoundingVolume bounds;
    AssetHandle model;
    AnimationState animation;
    ByteSpan pvars;
    std::vector<MobyLink> links;
    MobyState state;
};
```

## 9.2 Behavior registration

```cpp
using MobyUpdateFn = void(*)(GameContext&, MobyInstance&, float dt);

struct MobyClassRuntime {
    MobyClassId id;
    std::string_view debug_name;
    PvarSchema pvar_schema;
    MobyUpdateFn update;
    MobyDamageFn damage;
    MobySerializeFn serialize;
};
```

## 9.3 Implementation strategy

1. Start with generic placeholder behavior for unknown classes.
2. Implement common class families:
   - crates,
   - pickups,
   - vendors,
   - doors,
   - triggers,
   - simple enemies,
   - projectiles,
   - hazards.
3. Add game-specific classes as needed for planet completion.
4. Keep a registry of unimplemented classes per planet.
5. Use debug overlays to highlight unimplemented active objects.

## 9.4 Pvar schema recovery

Pvars are likely the heart of many object behaviors. Recovery strategy:

- Identify pvar byte size per class.
- Watch reads/writes in original traces.
- Correlate fields with level editor values.
- Compare multiple instances of same class.
- Use deltas between levels to infer semantics.
- Name fields gradually with confidence markers.

Example:

```yaml
pvar_schema:
  class_id: 0x0421
  debug_name: bolt_crate
  size: 0x30
  fields:
    - offset: 0x00
      type: u16
      name: bolt_count
      confidence: high
    - offset: 0x04
      type: f32
      name: explosion_radius_candidate
      confidence: low
```

---

## 10. Deep dive: renderer challenges

## 10.1 Why PS2 rendering is hard

A modern PC renderer wants meshes, materials, textures, shaders, and draw calls. A PS2 game often stores data closer to DMA command streams and VU/GIF packet formats. The original data may be optimized for the PS2’s memory layout rather than for semantic readability.

The challenge is to recover meaning:

- Which bytes are vertices?
- Which bytes are VU commands?
- Which bytes are material state?
- Which transforms are applied by VU1 microcode?
- Which effects depend on GS blending or alpha test quirks?
- Which artifacts are accidental and which are part of the visual identity?

## 10.2 Practical renderer recovery order

1. Draw static terrain with approximate materials.
2. Add texture coordinate correctness.
3. Add vertex colors/lighting.
4. Add fog.
5. Add moby models.
6. Add animation skinning.
7. Add transparent materials.
8. Add particles/effects.
9. Add bloom and post effects.
10. Add accuracy fixes level by level.

## 10.3 Testing renderer accuracy

Use several methods:

- Screenshot comparison from known camera positions.
- Material/texture hash validation.
- Geometry bounds comparison.
- Object count comparison.
- Frame capture analysis.
- Visual QA checklist for each planet.

Do not over-optimize for pixel-perfect output at first. The first goal is recognizable and playable. Pixel accuracy can come later.

---

## 11. Deep dive: code recovery and gameplay reimplementation

## 11.1 The code layout problem

Wrench documentation indicates that the games store code in both the main ELF and level overlays. The non-core sections can be overwritten when a level is loaded, and `lvl.*vtbl` sections contain function pointer tables for moby, camera, and sound classes.

This means the project cannot understand gameplay by analyzing only the boot ELF. It must understand:

- always-resident core engine functions,
- level-loaded code,
- class-specific update functions,
- function pointer tables,
- per-level dependencies,
- packed executable sections in later games.

## 11.2 Function classification

Classify functions into categories:

- core memory/resource management,
- math/vector/matrix,
- collision,
- animation,
- rendering packet generation,
- audio event dispatch,
- object lifecycle,
- player controller,
- weapon logic,
- enemy AI,
- camera,
- UI/menu,
- save/load,
- debug/development leftovers.

## 11.3 Reimplementation order

Do not reimplement randomly. Use gameplay dependencies:

1. Math and transforms.
2. Resource handles and object pools.
3. Collision primitives.
4. Player movement.
5. Camera.
6. Pickups/crates.
7. Damage/health.
8. Weapons/projectiles.
9. Vendors/inventory.
10. Mission triggers.
11. Planet transitions.
12. Cutscenes.
13. Edge cases.

## 11.4 Equivalence tests

For each behavior, write tests such as:

```yaml
test: rac1_player_jump_flat_ground
initial:
  position: [0, 0, 0]
  velocity: [0, 0, 0]
  grounded: true
inputs:
  - frame: 0
    jump: true
  - frame: 1..60
    jump: false
expected:
  frame_10:
    y_velocity_range: [a, b]
  frame_60:
    grounded: true
    position_tolerance: 0.05
```

These tests can start loose and become stricter as confidence improves.

---

## 12. Deep dive: physics and collision

Physics feel is one of the most important parts of the port. Players will notice even small differences.

## 12.1 Required systems

- Ground movement.
- Air movement.
- Jumping and falling.
- Slope handling.
- Step-up/ledge behavior.
- Collision response against level mesh.
- Moving platforms.
- Hazards and death volumes.
- Projectile collision.
- Melee hit detection.
- Enemy navigation.
- Grind rails and special movement paths.
- Water/swimming if applicable.

## 12.2 Data recovery

Use level data to identify:

- collision mesh triangles,
- material flags,
- trigger volumes,
- path splines,
- grind paths,
- camera collision grids,
- environment transitions.

Use traces to recover:

- gravity,
- acceleration,
- friction,
- terminal velocity,
- jump impulse,
- slope thresholds,
- capsule dimensions,
- hitbox sizes.

## 12.3 Testing

Create deterministic movement tests:

- flat run distance after N frames,
- jump height,
- landing frame,
- slope climb behavior,
- wall collision response,
- crate hit range,
- projectile impact position.

---

## 13. Deep dive: UI, localization, and saves

## 13.1 UI

UI work includes:

- boot flow,
- title screen,
- save selection,
- pause menu,
- options,
- HUD,
- weapon selection,
- vendor menu,
- subtitles,
- planet transition screens,
- end screens.

Implementation approach:

- Decode original UI textures and fonts.
- Recreate layout natively.
- Support original aspect ratio and widescreen-safe variants.
- Keep text in localization tables.
- Add debug overlay separate from game UI.

## 13.2 Localization

The importer should extract all available language data. Runtime should support:

- language selection,
- fallback language,
- text rendering,
- subtitle timing,
- controller glyph replacement.

## 13.3 Saves

Recommended order:

1. PC-native save format first.
2. Version every save schema.
3. Store game, region, build, and runtime version.
4. Add PS2 save import later.
5. Add PS2 save export only if safe and well understood.

Example save header:

```yaml
save_version: 1
game: rac1
source_build: ntsc-u-scus-...
runtime_version: 0.2.0
profile:
  bolts: 1234
  current_planet: veldin
  inventory: [...]
  flags: {...}
```

---

## 14. Tooling roadmap

## 14.1 Essential internal tools

1. **Disc inspector**
   - reads ISO,
   - prints filesystem,
   - prints sector map,
   - validates known builds.

2. **WAD inspector**
   - shows compressed/decompressed structure,
   - validates headers,
   - exports selected data.

3. **Asset browser**
   - searchable asset list,
   - texture preview,
   - mesh preview,
   - sound preview,
   - source provenance.

4. **Level viewer**
   - free camera,
   - mesh/material/collision/object overlays,
   - click-to-inspect.

5. **Animation viewer**
   - skeleton view,
   - clip playback,
   - event markers.

6. **Audio bank viewer**
   - sample list,
   - event list,
   - playback,
   - 3D emitter debug.

7. **Trace tools**
   - import original trace,
   - import native replay,
   - compare states.

8. **Object class tracker**
   - list unimplemented classes by level,
   - confidence levels,
   - owners,
   - related functions/assets.

## 14.2 User-facing tools

1. **Launcher**
   - import ISO,
   - configure game path,
   - launch game,
   - manage settings,
   - show compatibility status.

2. **Mod manager**
   - load mods from user directory,
   - enforce no original asset redistribution in published mods if desired,
   - conflict detection.

3. **Settings UI**
   - resolution,
   - aspect ratio,
   - renderer profile,
   - input mapping,
   - audio volume,
   - accessibility options.

---

## 15. Testing and validation strategy

## 15.1 Test categories

1. **Parser unit tests**
   - synthetic fixtures,
   - malformed input,
   - boundary conditions.

2. **Importer integration tests**
   - user-provided local ISO only,
   - no CI copyrighted data,
   - compare generated manifest hashes.

3. **Runtime unit tests**
   - math,
   - collision,
   - object lifecycle,
   - save serialization.

4. **Golden visual tests**
   - synthetic scenes in CI,
   - optional local tests against user-owned data.

5. **Replay tests**
   - deterministic input scripts,
   - state snapshots,
   - tolerance checks.

6. **Manual QA**
   - planet checklists,
   - playthrough reports,
   - bug reproduction saves.

## 15.2 CI without copyrighted assets

CI should use:

- synthetic WADs,
- synthetic PIF textures,
- synthetic meshes,
- small homebrew-like binary fixtures,
- parser fuzz tests,
- mocked asset manifests.

Optional local developer tests can use real ISOs but must be opt-in and excluded from Git.

## 15.3 Fuzzing

Binary parsers should be fuzzed. The importer will process large untrusted files. Even if users are expected to provide legitimate ISOs, robust parsing matters.

Fuzz targets:

- ISO parser,
- SYSTEM.CNF parser,
- TOC parser,
- WAD decompressor,
- PIF parser,
- mesh parser,
- sound bank parser,
- save parser.

## 15.4 Performance tests

Track:

- import time,
- level load time,
- asset conversion time,
- runtime memory use,
- draw calls,
- frame time,
- audio latency,
- stutter during streaming.

---

## 16. Milestone schedule and rough effort estimates

These are rough engineering estimates for planning, not promises. A small expert volunteer team could move faster on some tasks and much slower on others depending on reverse-engineering breakthroughs.

| Milestone | Result | Small team estimate | Main risk |
|---|---:|---:|---|
| M0 | Repo, policy, build skeleton | 2–4 weeks | License/governance churn |
| M1 | ISO verification and disc indexing | 2–6 weeks | Unknown build variants |
| M2 | WAD extraction and decompression | 1–3 months | Edge cases in compression/layout |
| M3 | Asset DB and texture viewer | 1–2 months | Swizzle/format gaps |
| M4 | Level viewer with static geometry | 2–6 months | VIF/geometry interpretation |
| M5 | Moby/object/animation viewer | 3–9 months | Animation and pvar complexity |
| M6 | Native engine core | 2–5 months | Architecture rework |
| M7 | First playable movement slice | 3–9 months | Physics/camera feel |
| M8 | One complete planet | 6–18 months | Mission/object behavior |
| M9 | R&C1 start-to-finish | 2–5+ years | Long tail of bespoke logic |
| M10 | R&C2/R&C3/DL expansion | additional years | Per-game systems and multiplayer |

The biggest uncertainty is not tooling; it is the volume of bespoke gameplay behavior.

---

## 17. Staffing and roles

A strong team would include:

1. **Project lead / maintainer**
   - scope control,
   - review process,
   - milestone ownership.

2. **Legal/licensing maintainer**
   - third-party inventory,
   - contribution policy,
   - asset redistribution rules.

3. **Binary/file-format reverse engineers**
   - ISO/WAD/assets,
   - Ghidra work,
   - format docs.

4. **Engine programmers**
   - core loop,
   - object system,
   - resource management.

5. **Rendering programmers**
   - PS2 packet interpretation,
   - modern GPU pipeline,
   - visual debugging.

6. **Gameplay programmers**
   - player controller,
   - weapons,
   - AI,
   - mission logic.

7. **Audio programmer**
   - VAG decoding,
   - 989snd bank reverse engineering,
   - native mixer.

8. **Tools programmers**
   - launcher,
   - asset browser,
   - level viewer,
   - trace tooling.

9. **QA/playtesters**
   - planet checklists,
   - regression testing,
   - controller feel feedback.

10. **Documentation/modding maintainers**
   - schemas,
   - guides,
   - contributor onboarding.

A two-person team can begin, but reaching full campaign parity likely requires sustained community involvement.

---

## 18. Risk register

| Risk | Severity | Probability | Mitigation |
|---|---:|---:|---|
| Copyright/licensing conflict | High | Medium | No assets distributed; legal boundary docs; avoid leaked SDK; review GPL dependencies |
| Project becomes accidental emulator | Medium | Medium | Define native-port boundary; avoid dynamic CPU/GS emulation architecture |
| File formats differ by game/region | High | High | Disc database; per-build manifests; parser versioning; Wrench comparison |
| WAD compression edge cases | Medium | Medium | Tests, fuzzing, compare with known tools |
| Renderer cannot match PS2 visuals | High | High | Start approximate; build debug tools; frame captures; focus on gameplay first |
| VU microprogram behavior unclear | High | High | Recover semantic geometry; shader reimplementation; targeted traces |
| Audio 989snd banks difficult | High | High | Start with music/voice; isolate SFX bank work; reuse public research where license allows |
| Gameplay logic volume too large | Very high | High | Planet-by-planet vertical slices; class frequency prioritization; object tracker |
| Physics/camera feel wrong | High | High | Trace original behavior; deterministic replay tests; early player-controller focus |
| Multiplayer scope explosion | High | Medium | Defer online; single-player first; separate milestone |
| Volunteer burnout | High | High | Milestones with visible wins; tools first; documentation; manageable tasks |
| Unknown hidden assets/builds | Medium | High | Sector map tooling; scan heuristics; community build reports |
| Save corruption | Medium | Medium | PC-native saves first; versioned schema; PS2 save import later |
| Mod ecosystem redistributes assets | Medium | Medium | Mod policy; package scanner; educate users |

---

## 19. The hardest aspects, ranked

### 1. Full gameplay reimplementation

Every object class, enemy, gadget, weapon, mission trigger, camera behavior, and cutscene interaction may need bespoke work. This is the long tail that turns a promising viewer into a full game.

### 2. Player physics and camera feel

A game can be visually imperfect and still enjoyable, but movement and camera mistakes are immediately obvious. The team should invest in traces, replay tests, and side-by-side playtesting early.

### 3. PS2 renderer translation

The renderer must map VIF/VU/GIF/GS-era assumptions to PC GPU pipelines. Terrain, moby animation, transparency, particles, bloom, fog, texture swizzling, and fixed-function quirks will each have edge cases.

### 4. Level overlay code and vtables

Gameplay code is not all in the main ELF. Level overlays and function pointer tables mean the analysis database must understand per-level code, not just global engine code.

### 5. Audio banks

Music/voice via VAG is approachable. Sound effects through 989snd banks are likely much harder and may require a dedicated subproject.

### 6. Region/build differences

The importer and runtime must not assume one disc layout forever. Build fingerprints, schemas, and compatibility status need to be first-class.

### 7. Legal and licensing discipline

The project can be technically excellent and still fail if it distributes copyrighted assets, copies confidential SDK material, or creates license conflicts.

---

## 20. Recommended first 90 days

### Weeks 1–2

- Create repository.
- Set license strategy.
- Write legal boundary docs.
- Add build skeleton.
- Add CLI skeleton.
- Create `disc_database.yml` schema.

### Weeks 3–4

- Implement ISO reader and `SYSTEM.CNF` parser.
- Add disc hash reporting.
- Add first known-build entry.
- Produce import report skeleton.

### Weeks 5–8

- Implement R&C1 TOC parser.
- Extract WADs.
- Implement or integrate WAD decompression.
- Compare with Wrench output locally.
- Add asset manifest and raw cache.

### Weeks 9–12

- Implement PIF texture decoder.
- Build asset browser with texture preview.
- Start level geometry parser.
- Create level viewer window with free camera.
- Publish first progress report with screenshots from user-local data only, avoiding redistributed assets if public sharing is risky.

By the end of 90 days, the project should aim to have **a working importer and early asset viewer**, not a playable game.

---

## 21. Concrete first implementation tasks

Below is a task backlog suitable for GitHub issues.

### Infrastructure

- [ ] Create repo skeleton.
- [ ] Add CI for Windows/Linux.
- [ ] Add third-party license tracking.
- [ ] Add pre-commit rule blocking large binary game data.
- [ ] Add `ratchetpc` CLI.
- [ ] Add logging and structured error types.

### Disc/import

- [ ] Implement ISO sector reader.
- [ ] Implement ISO9660 file listing.
- [ ] Implement `SYSTEM.CNF` parser.
- [ ] Implement known-build matcher.
- [ ] Implement disc report output.
- [ ] Implement R&C1 TOC parser.
- [ ] Implement R&C2/R&C3/DL TOC parser stub.
- [ ] Implement WAD extraction.
- [ ] Implement WAD decompression.
- [ ] Add decompression tests.

### Asset database

- [ ] Define asset ID format.
- [ ] Define manifest schema.
- [ ] Implement SQLite asset index.
- [ ] Implement raw cache.
- [ ] Implement decoded cache.
- [ ] Implement runtime cache.
- [ ] Add import cache invalidation.

### Textures

- [ ] Implement PIF header parser.
- [ ] Implement palette unswizzle.
- [ ] Implement pixel unswizzle.
- [ ] Export PNG for debugging.
- [ ] Upload texture to runtime.
- [ ] Add texture viewer.

### Geometry

- [ ] Parse first tfrag mesh.
- [ ] Convert to runtime mesh.
- [ ] Parse material/texture references.
- [ ] Parse collision mesh.
- [ ] Add free-camera level viewer.
- [ ] Add collision overlay.

### Objects

- [ ] Parse gameplay header.
- [ ] Parse moby class table.
- [ ] Parse moby instances.
- [ ] Parse pvar blobs.
- [ ] Show object bounds in viewer.
- [ ] Add click-to-inspect object panel.

### Runtime

- [ ] Add fixed-tick game loop.
- [ ] Add resource manager.
- [ ] Add scene/level state.
- [ ] Add placeholder player object.
- [ ] Add collision queries.
- [ ] Add controller input.

### Reverse engineering

- [ ] Create Ghidra project template.
- [ ] Create overlay loading notes.
- [ ] Create symbol database schema.
- [ ] Create pvar schema tracker.
- [ ] Create trace/spec template.

---

## 22. Success criteria by maturity level

### Level 0 — Importer prototype

- Recognizes a known ISO.
- Extracts files/WADs.
- Generates manifest.

### Level 1 — Asset viewer

- Displays textures and meshes.
- Previews sounds where decoded.
- Shows source provenance.

### Level 2 — Level viewer

- Loads real levels.
- Shows terrain, objects, collision.
- Supports free camera.

### Level 3 — Gameplay sandbox

- Ratchet can move in a real level.
- Collision and camera work.
- Crates/bolts work.

### Level 4 — Planet vertical slice

- One planet can be completed.
- Core UI, audio, enemies, and progression work.

### Level 5 — Campaign playable

- One full game can be completed.
- Saves work.
- Known blockers resolved.

### Level 6 — Quality port

- Strong visual/audio fidelity.
- Configurable controls and graphics.
- Stable performance.
- Modding support.

### Level 7 — Multi-game support

- Later PS2 R&C titles work.
- Shared engine abstractions are proven.
- Multiplayer/online addressed separately if desired.

---

## 23. Recommended guiding principles

1. **Tools first, gameplay second.** Good importers and viewers reduce every later cost.
2. **One game, one build, one planet first.** Avoid early multi-game scope explosion.
3. **Keep provenance.** Every decoded asset should trace back to sector/offset/hash.
4. **Make unknowns visible.** Unknown object classes and fields should appear in tools, not vanish.
5. **Prefer behavior specs over copied code.** The long-term project is safer and cleaner.
6. **Validate constantly.** Use screenshots, traces, replays, and playtest checklists.
7. **Do not ship assets.** The project’s legitimacy depends on this boundary.
8. **Design for modding after correctness.** Modding becomes much easier once asset schemas and runtime systems are stable.
9. **Resist emulation creep.** A native port should not slowly become a PS2 emulator.
10. **Celebrate viewer milestones.** Visible progress keeps contributors engaged during long reverse-engineering phases.

---

## 24. References checked for this plan

These public resources were used to ground the plan:

1. Wrench Editor repository — PS2 R&C modding tools, compatibility, ISO pack/unpack, asset features.  
   https://github.com/chaoticgd/wrench

2. Wrench file-loading documentation — R&C disc layout, raw sector asset loading, table-of-contents details, ELF/overlay sections, WAD compression notes.  
   https://github.com/chaoticgd/wrench/blob/master/docs/file_loading.md

3. Wrench gameplay documentation — gameplay file headers and instance categories.  
   https://github.com/chaoticgd/wrench/blob/master/docs/gameplay.md

4. Wrench renderer documentation — R&C renderer categories and PS2 VIF/VU/GIF/GS graphics flow.  
   https://github.com/chaoticgd/wrench/blob/master/docs/renderers.md

5. Wrench sound documentation — VAG, 989snd, and current Wrench audio-support limits.  
   https://github.com/chaoticgd/wrench/blob/master/docs/sound.md

6. Wrench texture documentation — PIF layout, swizzling, alpha/bloom notes.  
   https://github.com/chaoticgd/wrench/blob/master/docs/textures.md

7. RatchetModding R&C resources — community list of R&C tools, reverse-engineering resources, save tools, WAD tools, and Ghidra EE support.  
   https://github.com/RatchetModding/rac-modding-resources

8. CreepNT RacREpo — example R&C reverse-engineering repository.  
   https://github.com/CreepNT/RacREpo

9. OpenGOAL website — native PC port framing, launcher/modding goals, native-not-emulation positioning.  
   https://opengoal.dev/

10. OpenGOAL Jak Project repository — decompiler/asset-unpacking methodology and type/cast recovery approach.  
    https://github.com/open-goal/jak-project

11. ps2tek — PS2 internals, EE/R5900 architecture notes.  
    https://psi-rockin.github.io/ps2tek/

12. ps2dev/ps2sdk — PS2SDK split between Emotion Engine and I/O Processor components.  
    https://github.com/ps2dev/ps2sdk

13. Clank — open-source Medius server implementation originally intended for UYA online community work.  
    https://github.com/hashsploit/clank

---

## 25. Final recommendation

Start by building an importer and level viewer, not a gameplay runtime. Use Wrench and RatchetModding documentation to accelerate asset understanding, but make conscious licensing decisions before copying code. Treat R&C1 as the first full-game target. Build clean-room behavior specifications and native systems planet by planet. Defer online/multiplayer and later games until one single-player vertical slice is truly playable.

The project is feasible as a long-running preservation/reimplementation effort, but the central challenge is not unpacking the ISO. The central challenge is rebuilding years of Insomniac engine behavior in a native runtime while maintaining legal discipline, contributor momentum, and high fidelity to the original games.
