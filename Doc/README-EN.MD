# AutoDownloader Script Documentation

This document provides an overview and usage guide for the `AutoDownloader` PowerShell script.

## Languages

- [English](/Doc/README-EN.MD)
- [简体中文](/README.MD)

## Parameters

- **owner**: The owner of the GitHub repository
- **repo**: The name of the GitHub repository
- **pat**: GitHub Personal Access Token (optional)
- **proxy**: Proxy URL (optional)
- **ignoreFolders**: Array of folder patterns to ignore during the move operation (supports regex)

## Usage

cmd:

```cmd
.\AutoDownloader.ps1 -owner <owner> -repo <repo> [-pat <pat>] [-proxy <proxy>] [-ignoreFolders <ignoreFolders>]
```

powershell:

```powershell
.\AutoDownloader.ps1 -owner "owner" -repo "repo" -pat "pat" -proxy "proxy" -ignoreFolders @("folder1", "folder2")
```

## Examples

cmd:

```cmd
.\AutoDownloader.ps1 -owner MicrosoftDocs -repo PowerShell-Docs -pat yourPersonalAccessToken -proxy http://proxy -ignoreFolders images scripts
```

powershell:

```powershell
.\AutoDownloader.ps1 -owner "MicrosoftDocs" -repo "PowerShell-Docs" -pat "yourPersonalAccessToken" -proxy "http://proxy" -ignoreFolders @("images", "scripts")
```

## Notes

- The script will download the repository to the current directory.
- The script will ignore folders specified in the `ignoreFolders` parameter.
- The script will not automatically overwrite existing files or folders.
