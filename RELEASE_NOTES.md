# FITA Mahjong — release notes

## Candidate release: 0.2.0+2

### Gameplay
- Classic 144-tile, four-layer turtle-inspired board.
- New layout uses a verified legal removal order; matching pairs are dealt along that order so a fresh board has a guaranteed solution.
- Hint highlights a currently available matching pair.
- Undo restores the board and move counter to before the last attempted pair.
- Responsive board sizing and layered tile rendering.

### Verification
- GitHub Actions runs `flutter analyze`, `flutter test`, and builds a release Android APK.
- The APK is uploaded as the `fita-mahjong-android-apk` workflow artifact.

### Release checklist
- [ ] Confirm the latest workflow run succeeds.
- [ ] Download and install the APK on a physical Android device or emulator.
- [ ] Smoke-test new board, hint, matching, mismatch, undo, and level completion.
- [ ] Confirm Firebase-backed sign-in/sync behavior in the intended release configuration.
- [ ] Publish a GitHub Release and attach the tested APK.

This file prepares release notes and a checklist; it does not itself publish a GitHub Release.
