# 网络层独立 Package（DDD）

网络基础设施位于纯 Dart 包 `packages/blessing_network`；领域实体与 `BlessingRepository` 仍在 App 内。依赖方向：

```
Presentation → Domain
Data adapters → Domain + blessing_network
blessing_network ↛ Flutter / Domain
```

## 包内容

| 模块 | 职责 |
|------|------|
| `NetworkClient` | Dio 工厂（超时、JSON 头、可选 logging、`{data}` 解包） |
| `BlessingApi` | Retrofit REST 接口 |
| DTO | `BlessingCategoryDto` / `BlessingItemDto` / `GridThemeDto` 等 |
| `NetworkFailure` | 超时 / 取消 / 连接等基础设施异常 |

## 默认仍走本地

`BlessingApp` 默认注入 `LocalBlessingRepository()`。切换远程示例：

```dart
RemoteBlessingRepository.fromBaseUrl(
  'https://api.example.com',
  enableLogging: true,
)
```

或手动装配：

```dart
final dio = NetworkClient.create('https://api.example.com');
final api = BlessingApi(dio);
RemoteBlessingRepository(api: api);
```

DTO → 领域映射在 `lib/features/catalog/data/mappers/blessing_mapper.dart`。

## Codegen

在 package 目录执行：

```bash
cd packages/blessing_network
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

生成 `*.g.dart`（Retrofit + json_serializable）。修改 API / DTO 后需重新跑。

## 测试

- Package：`cd packages/blessing_network && dart test`
- App 边界：`test/core/integration_boundaries_test.dart`（Fixture adapter + Retrofit）
