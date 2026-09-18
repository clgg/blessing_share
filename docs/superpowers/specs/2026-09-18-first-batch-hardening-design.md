# First-Batch Hardening Design

## Goal

Harden the current Flutter demonstration app for reliable iteration and future
production integrations without changing its visible product scope. This batch
covers Android networking/signing configuration, catalog request isolation,
WeChat result handling, persisted-state tolerance, collection-page request
races, API business errors, repository hygiene, and analyzer cleanup.

## Scope

### Android release configuration

- Declare `android.permission.INTERNET` in the main manifest so debug, profile,
  and release builds share the same networking capability.
- Add an ignored `android/key.properties`-based release signing configuration.
- Keep a clearly logged debug-key fallback for local demo release builds because
  no production keystore has been supplied yet.
- Add a tracked example properties file that documents the required keys.

### Catalog state isolation

- Keep home loading/error state independent from category loading/error state.
- Store category results by category ID instead of in one global list.
- Assign a monotonically increasing request generation to every home request
  and to every category request. Only the newest request for a resource may
  publish its result.
- Category and occasion screens read state using their own category ID, so
  stacked routes cannot overwrite each other's visible content.

### WeChat share correctness

- Treat `success` and `demo` as recordable share results.
- Do not create activity records for `cancelled`, `unavailable`, or `failed`.
- Catch gateway exceptions and show a failure toast without modifying history.
- Preserve the gateway result message for normal user feedback.

### Persisted-state tolerance

- Parse stored primitive values with type checks instead of casts.
- Add a tolerant activity-record parser that skips malformed records while
  preserving valid records in the same payload.
- Catch deferred provider-load failures so a storage/plugin failure does not
  become an unhandled asynchronous exception.
- Retain current defaults when persisted data is absent, old, or malformed.

### Favorites and likes hydration

- Track a request generation for ID-to-item hydration in both pages.
- Allow a newer ID snapshot to start while an older fetch is pending.
- Only the newest generation may publish the item list or clear loading state.

### API envelope validation

- Continue accepting bare JSON and `{data: ...}` responses.
- When an envelope explicitly reports failure through `success: false` or a
  non-success `code`, reject it with a typed business failure carrying the
  server message.
- Accept missing codes and the conventional success codes `0` and `200`.
- Map the business failure through the existing network-to-app error boundary.

### Hygiene

- Ignore every nested `build/` directory and remove already tracked generated
  build artifacts from version control.
- Resolve all current analyzer warnings/info without unrelated refactoring.

## Testing

- Catalog provider tests use controllable repositories to prove stale home and
  category responses cannot overwrite newer data and different categories are
  isolated.
- Share tests prove cancelled/failed results do not create activity records and
  demo/success results do.
- State tests seed malformed values and mixed valid/invalid activity records.
- Network-package tests cover successful envelopes and HTTP-200 business errors.
- Finish with root and nested-package analyzers, all test suites, and an Android
  debug APK build.

## Out of scope

- Image recompression and asset delivery changes.
- Lazy masonry rendering.
- Calendar data generation and reminder scheduling.
- Nine-grid selection/preview improvements.
- Supplying or storing a production signing key.
