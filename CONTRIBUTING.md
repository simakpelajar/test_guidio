## Contributing

Follow these guidelines to keep platform changes safe and easy for other developers.

- **Branching:** Create a feature branch: `git checkout -b feature/your-feature`.
- **Don't commit build artifacts:** Ensure `git status` doesn't show `build/`, `local.properties`, or `ephemeral/` files. Use `.gitignore` entries already present.
- **Platform native work:** Put Android Kotlin changes under `android/app/src/main/kotlin/...` and iOS Swift under `ios/Runner/`.
- **Hardware layer:** Keep hardware-specific code isolated in a single package/module (e.g., `com.example.test_guidio.hardware`) and expose APIs via Flutter platform channels or a dedicated plugin.
- **Testing:** Test changes on a device or emulator before pushing. Run `flutter run` and any native unit tests.
- **Commit messages:** Use clear messages like `feat(android): add camera2 hardware adapter` or `fix(ios): correct permission handling`.
- **Code review:** Open a PR and describe any required native setup steps and test devices.

If unsure about native changes, ask maintainers before force-pushing history.
