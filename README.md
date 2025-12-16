# StarFab Easy Installer

A community-provided workaround to run [StarFab](https://gitlab.com/scmodding/tools/starfab) with the latest Star Citizen game files.

> [!IMPORTANT]
> **This is NOT a fork.** All credit goes to the original [StarFab](https://gitlab.com/scmodding/tools/starfab) and [scdatatools](https://gitlab.com/scmodding/frameworks/scdatatools) developers.
> This project simply bundles the fix from the `devel` branch as outlined in [Issue #119](https://gitlab.com/scmodding/tools/starfab/-/issues/119).

## The Problem

As of late 2024, Star Citizen changed how `Data.p4k` stores datacore files ("multiple datacores"). This broke StarFab.

The fix exists in the `scdatatools` development branch, but installing it requires technical knowledge (Git, Python virtual environments, pip).

**This installer automates that process.**

## Requirements

- **Windows 10/11**
- **Git for Windows**: [Download Here](https://git-scm.com/download/win)
- **Python 3.10**: Will be installed automatically via `winget` if missing.

## What This Fixes

1. **"Multiple Datacores" Crash** - StarFab crashed when loading recent Star Citizen patches. Fixed by using the development branch of `scdatatools`.

2. **Blender Export (Empty Models)** - Exports resulted in only bounding boxes/lights in Blender. Fixed by auto-downloading the required converter tools:
   - `cgf-converter.exe` from [Markemp/Cryengine-Converter](https://github.com/Markemp/Cryengine-Converter)
   - `texconv.exe` from [Microsoft/DirectXTex](https://github.com/microsoft/DirectXTex)

## Installation

1. Download this repository (click the green "Code" button → "Download ZIP").
2. Extract the ZIP to a folder of your choice (e.g., `C:\StarFab`).
3. **Double-click** `Run-StarFab.bat` to start the installer.

> **Note**: If you prefer PowerShell, you can right-click `Run-StarFab.ps1` and select "Run with PowerShell" instead.

The script will:
- Create a local `.venv` folder (keeps your system clean).
- Install StarFab and scdatatools from the official GitLab repositories.
- Apply the "multiple datacores" fix automatically.
- Launch StarFab.

## Updating

To update to the latest version of StarFab/scdatatools:
1. Delete the `.venv` folder.
2. Run `Run-StarFab.ps1` again.

## Credits

- **StarFab**: [ventorvar](https://gitlab.com/ventorvar), [th3st0rmtr00p3r](https://gitlab.com/th3st0rmtr00p3r), [VMXEO](https://gitlab.com/vmxeo)
- **scdatatools**: Same awesome team.
- **This Installer**: [Deltawerks](https://github.com/Deltawerks) with assistance from Gemini.

## License

This installer script is provided under the [MIT License](LICENSE).
StarFab and scdatatools are subject to their own respective licenses.

## Disclaimer

This project is not endorsed by or affiliated with Cloud Imperium Games or Roberts Space Industries.
All game content and materials are copyright Cloud Imperium Rights LLC and Cloud Imperium Rights Ltd.
Star Citizen®, Squadron 42®, Roberts Space Industries®, and Cloud Imperium® are registered trademarks of Cloud Imperium Rights LLC.
