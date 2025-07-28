# Local Development Pre-Setup Script

Welcome to the Pave Engineering pre-setup repository. This script will install the necessary tools before you can run the local development setup process, including:
- Brew
- Podman
- Visual Studio Code
- Google Cloud CLI
- Git
- Github
- SSH keys

## Prerequisites

Before running the setup script, ensure you have the following:

- A GitHub account
- A Mac laptop
- Ensure you have Chrome set as your default broswer 

## Setup Instructions

Follow these steps to run the setup script:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/trove-equity/engineering
   cd engineering
   ```
2. **Run the Setup Script**:
   ```bash
   ./setup.sh
   ```

3. **Follow the On-Screen Instructions**:
   
   Press Enter to continue when prompted.
   The script will prompt you for your laptop password at the beginning.
   Pay attention, because you will be prompted for input. There will also
   be a step that opens your Github settings for you. You can return to the
   prompt after that step to continue the setup.

## Troubleshooting
Common problems:
- Permission Issues: Make sure you have the necessary permissions to run the script and install software on your laptop.

Otherwise, please reach out to the Developer Platform team if you get stuck! 

# Updating the contents of `extensions.7z`

You may find that an extension needs to be updated to a more recent version.

## Prerequisites

```sh
# 7-zip archival tool
brew install 7-zip
```

## Steps

7-zip is very opinionated and will not overwrite an existing archive wholesale. Instead,
re-running the archive creation command will add new files into the existing archive and
7-zip has merge resolution workflows for overwriting existing files. Therefore, the
high-level process to update the version in the archive is to:

1. Delete the old extension version while preserving `extension.json.template`, a metadata
   file that doesn't need to be replaced/updated because it leverages templating to keep
   up-to-date with new extension versions.
1. Add the new extension version into the existing archive.

### Delete the existing extension-related files in the archive

```sh
7zz d -ba -x\!"extension.json.template" extensions.7z "*"
# Open archive: extensions.7z
# --
# Path = extensions.7z
# Type = 7z
# Physical Size = 1128801
# Headers Size = 2689
# Method = LZMA2:23 7zAES
# Solid = +
# Blocks = 1
# 
# Updating archive: extensions.7z
# 
# 
# Delete data from archive: 34 folders, 127 files, 7772485 bytes (7591 KiB)
# Keep old data in archive: 1 file, 881 bytes (1 KiB)
# Add new data to archive: 0 files, 0 bytes
# 
#     
# Files read from disk: 0
# Archive size: 641 bytes (1 KiB)
# Everything is Ok
```

### Add the new extension version into the archive

The environment variable `extension_folder_name` should be set (reach out to the Developer
Platform team for details):
```sh
# extension_folder_name=...
cd ~/.cursor/extensions
7zz a -mhe=on -ba -p "${OLDPWD}/extensions.7z" "${extension_folder_name:?}/"
# Open archive: /Volumes/git/work/trove-equity/engineering/extensions.7z
# --
# Path = /Volumes/git/work/trove-equity/engineering/extensions.7z
# Type = 7z
# Physical Size = 641
# Headers Size = 225
# Method = LZMA2:12 7zAES
# Solid = -
# Blocks = 1
# 
# Scanning the drive:
# 34 folders, 127 files, 7772485 bytes (7591 KiB)
# 
# Updating archive: /Volumes/git/work/trove-equity/engineering/extensions.7z
# 
# Keep old data in archive: 1 file, 881 bytes (1 KiB)
# Add new data to archive: 34 folders, 127 files, 7772485 bytes (7591 KiB)
# 
#                                                                                 
# Files read from disk: 127
# Archive size: 1129073 bytes (1103 KiB)
# Everything is Ok
cd -
# /Volumes/git/work/trove-equity/engineering
```

### Verify the contents of the archive:
```sh
7zz l extensions.7z
```
