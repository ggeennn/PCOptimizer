# PCOptimizer

一个用于 Windows PC 系统优化、安全维护和软件包管理的工具集。

## 项目目标

- 保护个人数据安全和隐私
- 优化系统性能和维护
- 自动化系统维护任务
- 提供编程学习路径

## 主要功能

1. **数据安全与隐私保护**
   - 密码管理（Bitwarden）
   - 文件加密（VeraCrypt）
   - 隐私数据清理（BleachBit）

2. **系统优化与维护**
   - 系统清理（CCleaner, DISM++）
   - 性能优化（CPU, GPU）
   - 系统监控（Sysinternals Suite）

3. **自动化工具**
   - 软件包管理（winget）
   - 自动清理计划任务
   - 数据自动备份

## 项目结构

- `GetPackages.ps1`: PowerShell 脚本，用于软件包管理
- `optimization_suggestions.md`: 系统优化和安全维护指南
- `installed_list.csv`: 已安装软件清单
- `work_log.txt`: 项目进度日志

## 使用方法

1. **基础安全设置**：
   ```powershell
   # 安装必要的安全工具
   winget install Bitwarden.Bitwarden
   winget install IDRIX.VeraCrypt
   ```

2. **系统维护**：
   ```powershell
   # 运行软件包扫描
   .\GetPackages.ps1
   
   # 设置自动清理任务
   schtasks /create /tn "CCleaner_AutoClean" /tr "C:\Program Files\CCleaner\CCleaner.exe /AUTO" /sc daily /mo 3
   ```

3. **查看建议**：
   阅读 `optimization_suggestions.md` 获取详细的优化和安全建议

## 维护计划

- **每3天**：系统基础清理
- **每周**：安全扫描和数据备份
- **每月**：系统深度优化

## 开发计划

- [ ] 实现自动化维护脚本
- [ ] 开发系统监控工具
- [ ] 创建文件加密程序
- [ ] 实现自动化维护面板

## 学习路径

1. **基础项目**：
   - PowerShell 自动化脚本
   - 文件备份工具

2. **进阶项目**：
   - 系统监控工具
   - 文件加密程序
   - 维护自动化面板

## 许可证

[待定] 