# AutoDownloader 脚本文档

本文档提供了 `AutoDownloader` PowerShell 脚本的概述和使用指南。

## 参数

- **owner**: GitHub 仓库的所有者
- **repo**: GitHub 仓库的名称
- **pat**: GitHub 的个人访问令牌(可选)
- **proxy**: 代理 URL(可选)
- **ignoreFolders**: 在移动操作期间要忽略的文件夹模式数组(支持正则)

## 用法

cmd:

```cmd
.\AutoDownloader.ps1 -owner <owner> -repo <repo> [-pat <pat>] [-proxy <proxy>] [-ignoreFolders <ignoreFolders>]
```

powershell:

```powershell
.\AutoDownloader.ps1 -owner "owner" -repo "repo" -pat "pat" -proxy "proxy" -ignoreFolders @("folder1", "folder2")
```

## 示例

cmd:

```cmd
.\AutoDownloader.ps1 -owner MicrosoftDocs -repo PowerShell-Docs -pat yourPersonalAccessToken -proxy http://proxy -ignoreFolders images scripts
```

powershell:

```powershell
.\AutoDownloader.ps1 -owner "MicrosoftDocs" -repo "PowerShell-Docs" -pat "yourPersonalAccessToken" -proxy "http://proxy" -ignoreFolders @("images", "scripts")
```

## 注意事项

- 脚本会将仓库下载到当前目录。
- 脚本会忽略 `ignoreFolders` 参数中指定的文件夹。
- 脚本不会自动覆盖现有的文件或文件夹。
