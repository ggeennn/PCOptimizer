
1. **优化CPU和GPU性能**

   - **CPU性能优化**：
     - 使用Windows自带的工具如`Powercfg`来调整电源设置为“高性能”模式：
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
       - 输入 `chrome://settings/system`，然后启用“使用硬件加速模式”。

2. **免费清理工具（Total PC Cleaner替代）**

   - **CCleaner（免费版）**：通过CLI命令清理临时文件和注册表项：
     ```bash
     winget install Piriform.CCleaner
     ```

     使用CLI命令进行清理：
     ```bash
     ccleaner /AUTO
     ```

   - **BleachBit**：开源清理工具，支持CLI清理：
     ```bash
     winget install BleachBit
     ```

     使用CLI清理：
     ```bash
     bleachbit --clean system.cache system.logs
     ```

   - **Disk Cleanup（Windows自带工具）**：使用CLI启动Windows的磁盘清理工具：
     ```bash
     cleanmgr /sagerun:1
     ```

3. **系统监控与调优**
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

