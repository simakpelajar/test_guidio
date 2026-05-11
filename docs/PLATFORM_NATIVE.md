**Platform Native Guidelines**

Purpose: make Kotlin/Swift hardware-layer development repeatable and low-friction for contributors.

Quick checklist for native changes:

- Keep hardware logic in a dedicated package/module (Android: `com.example.test_guidio.hardware`).
- Prefer MethodChannel/API wrappers instead of scattering native calls across the app.
- Document method names and payload shapes in this file when adding or changing channels.
- Avoid committing generated/plugin ephemeral files (`ephemeral/`, `.gradle/`, `local.properties`, `Pods/`).

Android specific:

- Use `android/app/src/main/kotlin/.../MainActivity.kt` for host activity only; put hardware classes under `android/app/src/main/kotlin/.../hardware/`.
- Provide a Kotlin interface and an implementation that accesses sensors/USB/Bluetooth. Keep Android permissions request logic centralized.
- Example minimal MethodChannel usage (Kotlin):

```kotlin
class HardwarePlugin(private val binding: Activity) {
  private val channel = MethodChannel(binding.flutterEngine.dartExecutor.binaryMessenger, "app/hardware")
  init {
    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "getSensorData" -> result.success(readSensor())
        else -> result.notImplemented()
      }
    }
  }
}
```

iOS specific:

- Place Swift hardware adapters under `ios/Runner/Hardware/` and expose via `MethodChannel` in `AppDelegate.swift`.

Developer workflow (recommended):

1. Create feature branch.
2. Implement native code under `android/.../hardware` or `ios/Runner/Hardware`.
3. Update `CONTRIBUTING.md` and this doc with method names and required permissions.
4. Run app and test on device: `flutter run -d <device>`.
5. Push branch and open PR with clear native setup instructions.

Tooling & CI:

- CI should run `flutter analyze`, `flutter test`, and optionally build Android/iOS artifacts to validate native compilation.
