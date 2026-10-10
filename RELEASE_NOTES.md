# FITA Mahjong — release notes

## Candidate release: 0.2.0+2

### Gameplay
- Classic 144-tile, four-layer turtle-inspired board.
- New layout uses a verified legal removal order; matching pairs are dealt along that order so a fresh board has a guaranteed solution.
- Hint highlights a currently available matching pair.
- Undo restores the board and move counter to before the last attempted pair.
- Responsive board sizing and layered tile rendering.

### Automated verification
- **GitHub Actions #64: passed** on commit `459212b3fbd50f4bf1ebfd5bfd55d6fe1adf6b43`.
- `flutter analyze`: passed, no issues reported.
- `flutter test`: passed, 9 tests.
- Android release APK: built successfully (49.8 MB).
- Artifact: `fita-mahjong-android-apk`; uploaded ZIP SHA-256: `9bb171c6f8509ff01461559a32d97455111eb8ed00f9c79e43c2bec37d5acd61`.
- Extracted APK SHA-256: `7751c7ae0b97e791a504c536d258c24d8f6bd1b05e4f08b9077584a7bf66e1ef`.

### Remaining release checklist
- [ ] Install the APK on a physical Android device or emulator.
- [ ] Smoke-test new board, hint, matching, mismatch, undo, and level completion.
- [ ] Confirm Firebase-backed sign-in/sync behavior in the intended release configuration.
- [ ] Publish a GitHub Release and attach the APK after device smoke tests.

**Scope note:** CI verifies analysis, unit tests, APK packaging, and artifact upload. It does not verify real-device installation or Firebase production behavior. This file does not itself publish a GitHub Release.
