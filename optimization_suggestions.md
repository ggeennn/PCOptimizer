# PC优化与安全维护指南

1. **数据安全与隐私保护**

   ## 基础安全组合（优先安装）
   1. **密码与数据管理**
      - **Bitwarden**：管理所有账户密码
        - 特别用于：网银、保险、报税等账户
        - 开启双因素认证
        - 定期更改主密码
   
   2. **敏感数据保护**
      - **VeraCrypt**：创建加密卷
        - 用途：存储财务文档、报税材料
        - 建议：创建多个加密卷分类存储
      - **BleachBit**：深度清理浏览器数据
        - 每次网银操作后清理浏览记录
   
   ## 系统维护组合
   1. **日常维护（每3-4天）**
      - **CCleaner**：
        ```powershell
        # 创建自动清理任务
        schtasks /create /tn "CCleaner_AutoClean" /tr "C:\Program Files\CCleaner\CCleaner.exe /AUTO" /sc daily /mo 3
        ```
   
   2. **周度维护**
      - 运行 ClamAV 病毒扫描
      - 检查 CCleaner 启动项
      - 备份重要数据到加密卷
   
   ## 编程学习扩展
   1. **基础项目**：
      - 编写 PowerShell 脚本自动化维护任务
      - 示例：自动备份脚本
        ```powershell
        # 创建简单的文件备份脚本
        $source = "C:\ImportantFiles"
        $destination = "D:\Backups"
        Copy-Item -Path $source -Destination $destination -Recurse
        ```
   
   2. **进阶项目**：
      - 开发系统监控工具
      - 创建文件加密程序
      - 实现自动化维护面板

   ## 维护日程表
   | 频率 | 任务 | 工具 |
   |------|------|------|
   | 每3天 | 系统清理 | CCleaner |
   | 每周 | 安全扫描 | ClamAV |
   | 每周 | 数据备份 | VeraCrypt |
   | 每月 | 系统优化 | DISM++ |

   > 注意：
   > 1. 财务操作建议使用专门的加密卷
   > 2. 定期检查安全软件更新
   > 3. 保持良好的安全习惯

2. **系统性能优化**

   - **CPU性能优化**：
     - 使用Windows自带的工具如`Powercfg`来调整电源设置为"高性能"模式：
       ```bash
       powercfg /change standby-timeout-ac 0
       powercfg /change monitor-timeout-ac 0
       powercfg /setactive SCHEME_MIN
       ```

     - **ThrottleStop**：尽管是GUI工具，ThrottleStop也可以在命令行中配置来优化CPU性能。

   - **GPU性能优化**：
     - 使用命令行工具更新显卡驱动：
       ```bash
       winget install NVIDIA.GeForceExperience  # 更新NVIDIA驱动
       winget install AMD.RadeonSoftware       # 更新AMD驱动
       ```

     - **启用硬件加速**：在浏览器设置中启用硬件加速：
       - 输入 `chrome://settings/system`，然后启用"使用硬件加速模式"。

3. **系统维护工具**

   ## 核心工具（必备）

   - **CCleaner（免费版）**：最全面的基础清理工具
     - 用途：日常临时文件清理、注册表清理、启动项管理
     - 安装命令：
     ```bash
     winget install Piriform.CCleaner
     ```
     - 使用建议：
       - 每周运行一次基础清理
       - 谨慎使用注册表清理功能
       - 定期检查启动项

   - **DISM++**：系统级深度清理和优化
     - 用途：系统垃圾清理、系统优化、驱动管理、Windows功能管理
     - 安装命令：
     ```bash
     winget install Chuyu-Team.DISM++
     ```
     - 使用建议：
       - 每月运行一次系统清理
       - 系统更新后检查系统组件健康状况
       - 需要时优化系统服务

   ## 补充工具（按需使用）

   - **BleachBit**：当需要深度清理隐私数据时
     - 用途：深度清理浏览器数据、应用程序缓存
     - 适用场景：需要彻底清理个人数据时
     ```bash
     winget install BleachBit
     ```

   - **Windows10Debloater**：新系统优化
     - 用途：移除Windows预装应用、优化系统设置
     - 适用场景：新装系统后的一次性优化
     ```powershell
     iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/debloat'))
     ```

   ## 使用建议

   1. **日常维护**：
      - 使用CCleaner进行每周基础清理
      - 通过任务计划程序自动运行：
      ```batch
      schtasks /create /tn "WeeklyClean" /tr "C:\Program Files\CCleaner\CCleaner.exe /AUTO" /sc weekly
      ```

   2. **月度维护**：
      - 使用DISM++进行系统深度清理
      - 检查并优化系统服务
      - 更新系统驱动

   3. **特殊情况**：
      - 系统运行变慢时：使用CCleaner检查启动项
      - 隐私清理需求：使用BleachBit进行深度清理
      - 新装系统：使用Windows10Debloater优化系统

   > 注意：不建议同时安装多个清理工具，容易造成冲突。推荐使用CCleaner + DISM++的组合足以满足日常需求。

4. **系统监控与调优**
   - **Sysinternals Suite**：监控系统性能的CLI工具集合：
     ```bash
     winget install Sysinternals.SysinternalsSuite
     ```

     使用`Procmon`查看CPU和GPU的使用情况：
     ```bash
     procmon /Backingfile C:\path	o\logfile
     ```

   - **PowerShell性能监控脚本**：
     使用PowerShell脚本查看CPU和内存使用情况：
     ```powershell
     Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
     ```

5. **个性化推荐组合**

   ## 基础安全组合（优先安装）
   1. **密码与数据管理**
      - **Bitwarden**：管理所有账户密码
        - 特别用于：网银、保险、报税等账户
        - 开启双因素认证
        - 定期更改主密码
   
   2. **敏感数据保护**
      - **VeraCrypt**：创建加密卷
        - 用途：存储财务文档、报税材料
        - 建议：创建多个加密卷分类存储
      - **BleachBit**：深度清理浏览器数据
        - 每次网银操作后清理浏览记录
   
   ## 系统维护组合
   1. **日常维护（每3-4天）**
      - **CCleaner**：
        ```powershell
        # 创建自动清理任务
        schtasks /create /tn "CCleaner_AutoClean" /tr "C:\Program Files\CCleaner\CCleaner.exe /AUTO" /sc daily /mo 3
        ```
   
   2. **周度维护**
      - 运行 ClamAV 病毒扫描
      - 检查 CCleaner 启动项
      - 备份重要数据到加密卷
   
   ## 编程学习扩展
   1. **基础项目**：
      - 编写 PowerShell 脚本自动化维护任务
      - 示例：自动备份脚本
        ```powershell
        # 创建简单的文件备份脚本
        $source = "C:\ImportantFiles"
        $destination = "D:\Backups"
        Copy-Item -Path $source -Destination $destination -Recurse
        ```
   
   2. **进阶项目**：
      - 开发系统监控工具
      - 创建文件加密程序
      - 实现自动化维护面板

   ## 维护日程表
   | 频率 | 任务 | 工具 |
   |------|------|------|
   | 每3天 | 系统清理 | CCleaner |
   | 每周 | 安全扫描 | ClamAV |
   | 每周 | 数据备份 | VeraCrypt |
   | 每月 | 系统优化 | DISM++ |

   > 注意：
   > 1. 财务操作建议使用专门的加密卷
   > 2. 定期检查安全软件更新
   > 3. 保持良好的安全习惯

