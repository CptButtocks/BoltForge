# Testing Strategy

Committed tests must run without copyrighted data.

## Test Inputs

- Use synthetic WADs, textures, meshes, manifests, and byte streams.
- Keep real ISO and extracted-asset tests opt-in and local-only.
- Store tiny generated fixtures under `data/synthetic_fixtures/`.

## Test Types

- Unit tests for parsers, math, serialization, and runtime primitives.
- Integration tests using synthetic manifests and fake asset stores.
- Golden tests using generated scenes or images only.
- Replay tests using deterministic input/state fixtures.
- Fuzz targets for binary parsers once parser code exists.
