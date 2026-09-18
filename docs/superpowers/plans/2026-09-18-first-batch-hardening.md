# First-Batch Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the current Flutter demonstration app safe for release-network testing and robust against stale asynchronous results, malformed local state, and failed WeChat/API operations.

**Architecture:** Keep home and per-category catalog state independently addressable, move share-result policy into a testable service, and use request generations wherever a newer asynchronous operation must supersede an older one. Preserve the existing Repository/Gateway/Provider boundaries and add typed network business failures without introducing new packages.

**Tech Stack:** Flutter 3.22, Dart 3.4, Provider, Dio, Retrofit, SharedPreferences, flutter_test, package:test, Android Gradle Plugin.

**Spec:** `docs/superpowers/specs/2026-09-18-first-batch-hardening-design.md`

## Global Constraints

- Keep package ID `com.clg.blessing_share` unchanged.
- Preserve the local JSON/demo gateway default behavior.
- Do not add image compression, lazy masonry, reminder scheduling, calendar generation, or nine-grid UX changes.
- Do not store keystores, passwords, aliases, or production secrets in Git.
- Preserve the user's existing README and documentation worktree changes.
- Every behavior change follows a failing-test, minimal-fix, passing-test cycle.

---

### Task 1: Android network and signing configuration

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/build.gradle`
- Create: `android/key.properties.example`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: optional local `android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`.
- Produces: release networking permission and conditional production signing; local demo release builds fall back to the debug key with an explicit Gradle warning.

- [ ] **Step 1: Add the main-manifest permission**

Insert directly under the `<manifest>` element:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

- [ ] **Step 2: Add the documented local signing template**

Create `android/key.properties.example`:

```properties
storeFile=/absolute/path/to/blessing-share-upload.jks
storePassword=replace-with-local-secret
keyAlias=blessing-share-upload
keyPassword=replace-with-local-secret
```

- [ ] **Step 3: Configure optional release signing**

Load `key.properties` before `android {}` and define a release signing config only from those values:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
def hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.withInputStream { keystoreProperties.load(it) }
} else {
    logger.warn("Release keystore not configured; using debug signing for local demo builds.")
}
```

Inside `android {}` add:

```groovy
signingConfigs {
    release {
        if (hasReleaseSigning) {
            storeFile = file(keystoreProperties["storeFile"])
            storePassword = keystoreProperties["storePassword"]
            keyAlias = keystoreProperties["keyAlias"]
            keyPassword = keystoreProperties["keyPassword"]
        }
    }
}
```

Set the release build signing config with:

```groovy
signingConfig = hasReleaseSigning ? signingConfigs.release : signingConfigs.debug
```

- [ ] **Step 4: Ignore nested generated output**

Replace the root-only `/build/` rule with:

```gitignore
**/build/
```

Remove the currently tracked generated output from the index while preserving local files:

```bash
git rm -r --cached android/build packages/ui_common/build
```

- [ ] **Step 5: Verify the Android configuration**

Run:

```bash
flutter build apk --debug
```

Expected: exit code 0 and `build/app/outputs/flutter-apk/app-debug.apk` exists.

- [ ] **Step 6: Commit the configuration**

```bash
git add .gitignore android/app/src/main/AndroidManifest.xml android/app/build.gradle android/key.properties.example
git add -u android/build packages/ui_common/build
git commit -m "build: harden Android release configuration"
```

---

### Task 2: Isolate catalog request state

**Files:**
- Create: `test/features/catalog/catalog_provider_test.dart`
- Modify: `lib/features/catalog/presentation/catalog_provider.dart`
- Modify: `lib/features/catalog/presentation/home_page.dart`
- Modify: `lib/features/catalog/presentation/category_page.dart`
- Modify: `lib/features/catalog/presentation/occasion_page.dart`

**Interfaces:**
- Consumes: existing `BlessingRepository` methods.
- Produces: `homeLoading`, `homeError`, and `CategoryCatalogState categoryState(String categoryId)`; `CategoryCatalogState` exposes `items`, `isLoading`, and `error`.

- [ ] **Step 1: Write stale-response and category-isolation tests**

Create a controllable repository with queued `Completer` objects and write tests equivalent to:

```dart
test('newest home request wins when responses complete out of order', () async {
  final repository = ControlledBlessingRepository();
  final provider = CatalogProvider(repository: repository);

  final first = provider.loadHome();
  final second = provider.loadHome();
  repository.completeSecondHome(categories: [newCategory], featured: [newItem]);
  await second;
  repository.completeFirstHome(categories: [oldCategory], featured: [oldItem]);
  await first;

  expect(provider.categories, [newCategory]);
  expect(provider.featured, [newItem]);
});

test('different categories keep independent items and errors', () async {
  final repository = ControlledBlessingRepository();
  final provider = CatalogProvider(repository: repository);

  final daily = provider.loadCategory('daily');
  final festival = provider.loadCategory('festival');
  repository.completeCategory('festival', [festivalItem]);
  repository.completeCategory('daily', [dailyItem]);
  await Future.wait([daily, festival]);

  expect(provider.categoryState('daily').items, [dailyItem]);
  expect(provider.categoryState('festival').items, [festivalItem]);
});
```

- [ ] **Step 2: Run the new tests and verify RED**

Run:

```bash
flutter test test/features/catalog/catalog_provider_test.dart
```

Expected: compilation fails because the new state API and controlled behavior do not exist.

- [ ] **Step 3: Implement independent state and request generations**

Add this immutable state shape:

```dart
@immutable
class CategoryCatalogState {
  const CategoryCatalogState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<BlessingItem> items;
  final bool isLoading;
  final AppException? error;
}
```

Use separate counters for home and each category:

```dart
int _homeGeneration = 0;
final Map<String, int> _categoryGenerations = {};
final Map<String, CategoryCatalogState> _categoryStates = {};

CategoryCatalogState categoryState(String id) =>
    _categoryStates[id] ?? const CategoryCatalogState();
```

Every load captures the incremented generation and checks it before publishing results or clearing loading state.

- [ ] **Step 4: Migrate screens to scoped getters**

- `HomePage` reads `homeLoading` and `homeError`.
- `CategoryPage` reads `categoryState(widget.category.id)`.
- `OccasionPage` reads `categoryState(widget.occasion.categoryId)`.

- [ ] **Step 5: Run focused catalog tests and verify GREEN**

```bash
flutter test test/features/catalog/catalog_provider_test.dart test/features/catalog/catalog_flow_test.dart test/features/catalog/home_calendar_test.dart
```

Expected: all focused tests pass.

- [ ] **Step 6: Commit catalog isolation**

```bash
git add lib/features/catalog/presentation test/features/catalog/catalog_provider_test.dart
git commit -m "fix: isolate catalog request state"
```

---

### Task 3: Record only successful WeChat shares

**Files:**
- Create: `lib/features/wechat/wechat_share_service.dart`
- Create: `test/features/wechat/wechat_share_service_test.dart`
- Modify: `lib/features/catalog/presentation/detail_page.dart`

**Interfaces:**
- Consumes: `WechatGateway`, `ActivityProvider`, `BlessingItem`, and `ShareTarget`.
- Produces: `WechatShareService.share(BlessingItem item, ShareTarget target) -> Future<WechatResult>`.

- [ ] **Step 1: Write share-policy tests**

Cover both recordable and non-recordable statuses:

```dart
test('demo and success shares create activity records', () async {
  final activity = ActivityProvider(storage: MemoryAppStorage());
  await activity.load();
  final service = WechatShareService(
    gateway: SequenceWechatGateway([WechatStatus.demo, WechatStatus.success]),
    activity: activity,
  );

  await service.share(dailyItem, ShareTarget.friend);
  await service.share(dailyItem, ShareTarget.timeline);

  expect(activity.records, hasLength(2));
});

test('cancelled unavailable and failed shares do not create records', () async {
  final activity = ActivityProvider(storage: MemoryAppStorage());
  await activity.load();
  final service = WechatShareService(
    gateway: SequenceWechatGateway([
      WechatStatus.cancelled,
      WechatStatus.unavailable,
      WechatStatus.failed,
    ]),
    activity: activity,
  );

  await service.share(dailyItem, ShareTarget.friend);
  await service.share(dailyItem, ShareTarget.friend);
  await service.share(dailyItem, ShareTarget.friend);

  expect(activity.records, isEmpty);
});
```

- [ ] **Step 2: Run the service tests and verify RED**

```bash
flutter test test/features/wechat/wechat_share_service_test.dart
```

Expected: compilation fails because `WechatShareService` does not exist.

- [ ] **Step 3: Implement the share service**

```dart
class WechatShareService {
  const WechatShareService({required this.gateway, required this.activity});

  final WechatGateway gateway;
  final ActivityProvider activity;

  Future<WechatResult> share(BlessingItem item, ShareTarget target) async {
    final result = target == ShareTarget.friend
        ? await gateway.shareToFriend(item)
        : await gateway.shareToTimeline(item);
    if (result.status == WechatStatus.success ||
        result.status == WechatStatus.demo) {
      await activity.recordShare(item.id, target);
    }
    return result;
  }
}
```

- [ ] **Step 4: Use the service and handle gateway exceptions**

In `DetailPage._share`, create the service from the injected gateway/activity. Catch exceptions, check `context.mounted`, and show `AppToastType.error` with `分享失败，请稍后重试`; normal results continue to display `result.message`.

- [ ] **Step 5: Run share and integration tests**

```bash
flutter test test/features/wechat/wechat_share_service_test.dart test/core/integration_boundaries_test.dart test/app/full_demo_flow_test.dart
```

Expected: all tests pass, and demo sharing still creates history.

- [ ] **Step 6: Commit share correctness**

```bash
git add lib/features/wechat lib/features/catalog/presentation/detail_page.dart test/features/wechat
git commit -m "fix: respect WeChat share outcomes"
```

---

### Task 4: Tolerate malformed persisted state

**Files:**
- Modify: `lib/features/profile/domain/activity_record.dart`
- Modify: `lib/features/profile/activity_provider.dart`
- Modify: `lib/features/profile/session_provider.dart`
- Modify: `lib/app/theme_provider.dart`
- Modify: `lib/app/blessing_app.dart`
- Modify: `test/features/state/providers_test.dart`

**Interfaces:**
- Consumes: arbitrary `Map<String, Object?>` values returned by `AppStorage`.
- Produces: `ActivityRecord.tryFromJson(Map<String, Object?>) -> ActivityRecord?`; providers retain defaults and skip malformed records.

- [ ] **Step 1: Add malformed-state regression tests**

Append tests equivalent to:

```dart
test('session and theme retain defaults for wrong stored types', () async {
  final storage = MemoryAppStorage()
    ..values['session.v1'] = {'version': 1, 'isLoggedIn': 'yes'}
    ..values['theme.v1'] = {'version': 1, 'themeId': 123};

  final session = SessionProvider(storage: storage);
  final theme = ThemeProvider(storage: storage);
  await Future.wait([session.load(), theme.load()]);

  expect(session.isLoggedIn, isFalse);
  expect(theme.themeId, AppThemeId.festiveRed);
});

test('activity load keeps valid rows and skips malformed rows', () async {
  final storage = MemoryAppStorage()
    ..values['activity.v1'] = {
      'version': 1,
      'records': [validActivityJson, {'id': 7, 'createdAt': 'bad'}],
    };
  final provider = ActivityProvider(storage: storage);

  await provider.load();

  expect(provider.records, hasLength(1));
  expect(provider.records.single.id, validActivityJson['id']);
});
```

- [ ] **Step 2: Run state tests and verify RED**

```bash
flutter test test/features/state/providers_test.dart
```

Expected: wrong stored types throw and malformed activity rows abort the load.

- [ ] **Step 3: Implement tolerant parsing**

Implement `ActivityRecord.tryFromJson` using explicit `is String` checks, `Enum.values` matching, and `DateTime.tryParse`. Return `null` for any invalid required field or invalid enum.

Replace direct casts in theme/session providers with type guards:

```dart
final raw = value['themeId'];
if (raw is String) { /* match known values */ }

final raw = value['isLoggedIn'];
if (raw is bool) _isLoggedIn = raw;
```

Map activity records through `tryFromJson` and keep only non-null results.

- [ ] **Step 4: Contain deferred load failures**

Change `_defer` to invoke an async callback with `try/catch` and `debugPrint`, preventing plugin/storage failures from escaping as unhandled futures:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  try {
    await task();
  } catch (error, stackTrace) {
    debugPrint('Deferred provider load failed: $error\n$stackTrace');
  }
});
```

- [ ] **Step 5: Run all provider tests and verify GREEN**

```bash
flutter test test/features/state/providers_test.dart test/features/profile/profile_and_favorites_flow_test.dart
```

Expected: all focused tests pass.

- [ ] **Step 6: Commit persisted-state tolerance**

```bash
git add lib/app lib/features/profile test/features/state/providers_test.dart
git commit -m "fix: tolerate malformed persisted state"
```

---

### Task 5: Prevent stale favorites and likes hydration

**Files:**
- Create: `lib/features/catalog/presentation/item_collection_loader.dart`
- Create: `test/features/catalog/item_collection_loader_test.dart`
- Modify: `lib/features/favorites/favorites_page.dart`
- Modify: `lib/features/likes/likes_page.dart`

**Interfaces:**
- Consumes: `BlessingRepository` and ordered item-ID snapshots.
- Produces: `ItemCollectionLoader.load(List<String> ids) -> Future<List<BlessingItem>?>`; returns `null` when superseded by a newer load.

- [ ] **Step 1: Write the stale-hydration test**

```dart
test('newer id snapshot supersedes an older pending load', () async {
  final repository = ControlledItemRepository();
  final loader = ItemCollectionLoader(repository: repository);

  final oldLoad = loader.load(['old']);
  final newLoad = loader.load(['new']);
  repository.complete('new', newItem);
  expect(await newLoad, [newItem]);
  repository.complete('old', oldItem);
  expect(await oldLoad, isNull);
});
```

- [ ] **Step 2: Run the loader test and verify RED**

```bash
flutter test test/features/catalog/item_collection_loader_test.dart
```

Expected: compilation fails because `ItemCollectionLoader` does not exist.

- [ ] **Step 3: Implement the generation-aware loader**

```dart
class ItemCollectionLoader {
  ItemCollectionLoader({required BlessingRepository repository})
      : _repository = repository;

  final BlessingRepository _repository;
  final Map<String, BlessingItem> _cache = {};
  int _generation = 0;

  Future<List<BlessingItem>?> load(List<String> ids) async {
    final generation = ++_generation;
    for (final id in ids) {
      if (_cache.containsKey(id)) continue;
      try {
        _cache[id] = await _repository.getById(id);
      } catch (_) {}
    }
    if (generation != _generation) return null;
    return [for (final id in ids) if (_cache[id] case final item?) item];
  }

  void clearCache() => _cache.clear();
}
```

- [ ] **Step 4: Migrate both collection pages**

Initialize the loader from `context.read<BlessingRepository>()` in `didChangeDependencies`. Start a new load whenever the ID signature changes, even if another load is pending. Only apply a non-null result; the newest call owns `_loading = false`. Refresh clears the cache before loading the current snapshot.

- [ ] **Step 5: Run collection flow tests**

```bash
flutter test test/features/catalog/item_collection_loader_test.dart test/features/profile/profile_and_favorites_flow_test.dart test/app/full_demo_flow_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit hydration protection**

```bash
git add lib/features/catalog/presentation/item_collection_loader.dart lib/features/favorites/favorites_page.dart lib/features/likes/likes_page.dart test/features/catalog/item_collection_loader_test.dart
git commit -m "fix: discard stale collection loads"
```

---

### Task 6: Reject API business errors

**Files:**
- Modify: `packages/blessing_network/lib/src/error/network_exceptions.dart`
- Modify: `packages/blessing_network/lib/src/response/api_envelope.dart`
- Modify: `packages/blessing_network/test/network_client_test.dart`
- Modify: `lib/features/catalog/data/remote_blessing_repository.dart`
- Modify: `test/core/integration_boundaries_test.dart`

**Interfaces:**
- Consumes: bare responses and envelopes containing optional `code`, `success`, `message`, and `data`.
- Produces: `ApiBusinessException`, `NetworkBusinessFailure`, and app-level `NetworkException` preserving the server message.

- [ ] **Step 1: Add envelope business-error tests**

Use the existing fixture adapter to cover:

```dart
test('HTTP 200 business failure keeps the server message', () async {
  final dio = NetworkClient.create('https://example.test')
    ..httpClientAdapter = FixtureAdapter({
      'code': 40301,
      'message': '登录状态已失效',
      'data': <Object>[],
    });

  expect(
    dio.get<Object>('/categories'),
    throwsA(
      isA<DioException>().having(
        (error) => error.error,
        'error',
        isA<ApiBusinessException>().having(
          (failure) => failure.message,
          'message',
          '登录状态已失效',
        ),
      ),
    ),
  );
});
```

Also test `{'success': false, 'message': '服务繁忙', 'data': null}` and confirm envelopes with code `0`, code `200`, or no code still unwrap normally.

- [ ] **Step 2: Run network tests and verify RED**

```bash
cd packages/blessing_network && dart test test/network_client_test.dart
```

Expected: compilation fails because `ApiBusinessException` does not exist, or the response is incorrectly accepted.

- [ ] **Step 3: Implement typed business failures**

Add:

```dart
class ApiBusinessException implements Exception {
  const ApiBusinessException({required this.message, this.code});
  final String message;
  final Object? code;
}

class NetworkBusinessFailure extends NetworkFailure {
  const NetworkBusinessFailure(super.message, {super.cause, this.code});
  final Object? code;
}
```

Before unwrapping, treat `success == false` or a present code outside `{0, 200, '0', '200'}` as failure. Reject through `handler.reject` using a `DioException` whose `error` is `ApiBusinessException`.

Make `NetworkFailureMapper.fromDio` detect `ApiBusinessException` before switching on `DioExceptionType`, returning `NetworkBusinessFailure` with the original message. Map that failure to app `NetworkException` in `RemoteBlessingRepository`.

- [ ] **Step 4: Run package and integration tests**

```bash
cd packages/blessing_network && dart test
cd ../.. && flutter test test/core/integration_boundaries_test.dart
```

Expected: package and app integration tests pass.

- [ ] **Step 5: Commit business-error handling**

```bash
git add packages/blessing_network lib/features/catalog/data/remote_blessing_repository.dart test/core/integration_boundaries_test.dart
git commit -m "fix: surface API business failures"
```

---

### Task 7: Analyzer cleanup and full verification

**Files:**
- Modify: Dart files reported by `flutter analyze` for unnecessary imports.
- Modify: `packages/ui_common/test/app_dimens_test.dart`
- Modify: `test/features/update/app_update_flow_test.dart`

**Interfaces:**
- Consumes: completed Tasks 1–6.
- Produces: analyzer-clean project, passing root/package tests, and a buildable debug APK.

- [ ] **Step 1: Remove only analyzer-reported imports and add const**

Remove duplicate direct `app_theme.dart` imports where `ui_common.dart` already exports the symbols. Remove the unused Material import from `packages/ui_common/test/app_dimens_test.dart`. Add `const` to the two constructions identified in `test/features/update/app_update_flow_test.dart`.

- [ ] **Step 2: Format changed Dart files**

```bash
dart format lib test packages/blessing_network/lib packages/blessing_network/test packages/ui_common/test
```

- [ ] **Step 3: Run all analyzers**

```bash
flutter analyze
cd packages/blessing_network && dart analyze
cd ../ui_common && flutter analyze
```

Expected: every analyzer exits 0 with no issues.

- [ ] **Step 4: Run all tests**

```bash
cd ../.. && flutter test
cd packages/blessing_network && dart test
cd ../ui_common && flutter test
```

Expected: every suite exits 0 with no failed tests.

- [ ] **Step 5: Build the Android debug APK**

```bash
cd ../.. && flutter build apk --debug
```

Expected: exit code 0 and a generated debug APK.

- [ ] **Step 6: Inspect the final diff and commit cleanup**

```bash
git diff --check
git status --short
git add lib test packages/ui_common/test
git commit -m "chore: clean analyzer findings"
```

Confirm that README and the user's pre-existing documentation changes remain uncommitted.
