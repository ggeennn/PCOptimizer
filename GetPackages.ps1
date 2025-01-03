# 设置控制台编码为 UTF-8，确保中文显示正常
# 这三行代码都是为了处理中文编码问题，防止出现乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)

# 函数：获取系统中已安装的软件包列表并导出到CSV文件
function Get-InstalledPackages {
    Write-Output "[INFO] Getting installed packages..."
    
    # 使用 winget list 命令获取已安装的包
    $wingetPackages = winget list | Select-Object -Skip 3 | ForEach-Object {
        # 用正则表达式分割每行，匹配2个或更多空格
        $line = $_ -split "  +"
        # 确保分割后至少有3个元素，且第一个元素不是空或进度条字符
        if (($line.Count -ge 3) -and 
            (-not [string]::IsNullOrWhiteSpace($line[0])) -and 
            (-not $line[0].Contains("█")) -and 
            (-not $line[0].Contains("▒"))) {
            # 创建自定义对象
            [PSCustomObject]@{
                Name = $line[0].Trim()      # 软件名称，移除前后空格
                Version = $line[1].Trim()    # 软件版本，移除前后空格
                Source = "winget"           # 来源
            }
        }
    }

    # 导出到CSV文件
    if ($wingetPackages) {
        $wingetPackages | Export-Csv -Path ".\installed_list.csv" -NoTypeInformation -Encoding UTF8
        Write-Output "[SUCCESS] Exported package list to installed_list.csv"
    } else {
        Write-Output "[WARNING] No valid packages found to export"
    }
}

# 函数：从CSV文件中读取软件列表并安装
function Install-PackagesFromList {
    param (
        [string]$CsvPath = ".\optimization_packages.csv"
    )
    
    # 检查CSV文件是否存在
    if (Test-Path $CsvPath) {
        # 读取CSV文件内容
        $packages = Import-Csv $CsvPath
        
        # 获取当前已安装的软件列表
        Write-Output "[INFO] Checking installed packages..."
        $installedPackages = winget list | Select-Object -Skip 3 | ForEach-Object {
            $line = $_ -split '\s{2,}'
            if ($line.Count -ge 3) {
                [PSCustomObject]@{
                    Name = $line[0]
                    Version = $line[1]
                }
            }
        }

        # 遍历每个软件包并检查
        foreach ($package in $packages) {
            $installed = $installedPackages | Where-Object { $_.Name -eq $package.Name }
            
            if ($installed) {
                # 检查是否有可用更新
                Write-Output "[CHECK] $($package.Name) is already installed (Version: $($installed.Version))"
                $updateCheck = winget upgrade $package.Name
                
                if ($updateCheck -match "No applicable upgrade") {
                    Write-Output "[INFO] Already up to date"
                } else {
                    $choice = Read-Host "New version available. Update? (Y/N)"
                    if ($choice -eq 'Y' -or $choice -eq 'y') {
                        Write-Output "[UPDATE] Updating $($package.Name)..."
                        winget upgrade $package.Name --accept-source-agreements --accept-package-agreements
                    }
                }
            } else {
                Write-Output "[INSTALL] Installing $($package.Name)..."
                winget install $package.Name --accept-source-agreements --accept-package-agreements
            }
        }
    } else {
        Write-Output "[ERROR] Package list file not found: $CsvPath"
    }
}

# 函数：创建推荐的优化软件包列表
function New-OptimizationPackagesList {
    # 创建推荐软件包数组
    $packages = @(
        # 每个软件包包含名称、类别和优先级信息
        [PSCustomObject]@{
            Name = "Piriform.CCleaner"    # CCleaner清理工具
            Category = "System Cleanup"    # 系统清理类
            Priority = "Essential"         # 必备软件
        },
        [PSCustomObject]@{
            Name = "Chuyu-Team.DISM++"    # DISM++系统优化工具
            Category = "System Optimization"
            Priority = "Essential"
        },
        [PSCustomObject]@{
            Name = "BleachBit"            # BleachBit隐私清理工具
            Category = "Privacy Cleanup"
            Priority = "Optional"          # 可选软件
        },
        [PSCustomObject]@{
            Name = "Sysinternals.SysinternalsSuite"  # 系统诊断工具集
            Category = "System Monitor"
            Priority = "Optional"
        },
        [PSCustomObject]@{
            Name = "KeePass.KeePass"    # KeePass 密码管理器
            Category = "Security"        # 安全类
            Priority = "Essential"       # 必备软件
        }
    )

    # 将推荐软件列表导出到CSV文件
    $packages | Export-Csv -Path ".\optimization_packages.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "[SUCCESS] Created optimization packages list"
}

# 函数：显示主菜单界面
function Show-Menu {
    Clear-Host
    Write-Output "=== PC Optimizer Tool Manager ==="
    Write-Output "1. Export current installed packages list"
    Write-Output "2. Create recommended optimization packages list"
    Write-Output "3. Install packages from list"
    Write-Output "4. Backup important data"
    Write-Output "5. Monitor system performance"
    Write-Output "6. Run system cleanup"
    Write-Output "7. Set cleanup schedule"
    Write-Output "8. Exit"
    Write-Output "================================="
}

# 函数：自动备份重要数据
function Backup-ImportantData {
    param (
        [string]$SourcePath,
        [string]$BackupPath,
        [switch]$Encrypt
    )
    
    Write-Output "[INFO] Starting backup process..."
    
    try {
        # 创建备份目录（如果不存在）
        if (-not (Test-Path $BackupPath)) {
            New-Item -ItemType Directory -Path $BackupPath
        }
        
        # 复制文件
        Copy-Item -Path $SourcePath -Destination $BackupPath -Recurse -Force
        
        # 如果需要加密
        if ($Encrypt) {
            # TODO: 调用 VeraCrypt 进行加密
            Write-Output "[INFO] Encryption feature coming soon..."
        }
        
        Write-Output "[SUCCESS] Backup completed"
    }
    catch {
        Write-Output "[ERROR] Backup failed: $_"
    }
}

# 函数：获取系统性能
# 用途：监控系统的 CPU 和内存使用情况
# 参数：
#   - Duration: 监控持续时间（秒）
#   - Interval: 采样间隔（秒）
function Get-SystemPerformance {
    param (
        [Parameter(Mandatory=$false)]
        [int]$Duration = 60,    # 默认监控 60 秒
        
        [Parameter(Mandatory=$false)]
        [int]$Interval = 5      # 默认每 5 秒采样一次
    )
    
    Write-Output "[INFO] Starting system monitoring..."
    
    # 计算结束时间
    $endTime = (Get-Date).AddSeconds($Duration)
    
    # 循环监控直到达到指定时间
    while ((Get-Date) -lt $endTime) {
        # 获取 CPU 使用率
        $cpu = Get-Counter '\Processor(_Total)\% Processor Time'
        # 获取可用内存
        $memory = Get-Counter '\Memory\Available MBytes'
        
        # 输出监控结果
        Write-Output "CPU Usage: $($cpu.CounterSamples.CookedValue)%"
        Write-Output "Available Memory: $($memory.CounterSamples.CookedValue)MB"
        
        # 等待到下一次采样
        Start-Sleep -Seconds $Interval
    }
}

# 函数：发送系统通知
# 用途：显示系统清理相关的通知
# 参数：
#   - Message: 通知消息内容
function Show-CleanupNotification {
    param (
        [string]$Message = "系统将在 5 分钟后开始清理"    # 默认通知消息
    )
    
    # 加载 Windows Forms 程序集以使用通知功能
    Add-Type -AssemblyName System.Windows.Forms
    
    # 创建通知图标对象
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    
    # 设置通知属性
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipTitle = "PC Optimizer"
    $balloon.BalloonTipText = $Message
    $balloon.Visible = $true
    
    # 显示通知
    $balloon.ShowBalloonTip(5000)    # 显示 5 秒
    
    # 等待通知显示完成并清理资源
    Start-Sleep -Seconds 6           # 确保通知完全显示
    $balloon.Dispose()               # 释放资源
}

# 函数：执行系统清理
function Start-SystemCleanup {
    param (
        [switch]$AutoConfirm
    )
    
    Write-Output "[INFO] Preparing system cleanup..."
    
    if (-not $AutoConfirm) {
        # 发送清理通知
        Show-CleanupNotification
        $choice = Read-Host "Ready to start cleanup? (Y/N)"
        if ($choice -ne 'Y' -and $choice -ne 'y') {
            Write-Output "[INFO] Cleanup cancelled by user"
            return
        }
    }
    
    try {
        Write-Output "[CLEANUP] Starting CCleaner..."
        # 使用 CCleaner 命令行参数
        # /AUTO: 自动模式
        # /SILENT: 静默运行
        Start-Process "C:\Program Files\CCleaner\CCleaner.exe" -ArgumentList "/AUTO","/SILENT" -Wait
        Write-Output "[SUCCESS] Cleanup completed"
    }
    catch {
        Write-Output "[ERROR] Cleanup failed: $_"
    }
}

# 函数：设置自动清理计划任务
function Set-CleanupSchedule {
    param (
        [int]$IntervalDays = 3    # 默认每3天运行一次
    )
    
    Write-Output "[INFO] Setting up cleanup schedule..."
    
    $taskName = "PCOptimizer_AutoClean"
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\GetPackages.ps1`" -AutoCleanup"
    
    $trigger = New-ScheduledTaskTrigger -Daily -DaysInterval $IntervalDays -At "03:00"
    
    try {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Force
        Write-Output "[SUCCESS] Cleanup schedule set successfully"
    }
    catch {
        Write-Output "[ERROR] Failed to set cleanup schedule: $_"
    }
}

# 主程序循环
do {
    Show-Menu    # 显示菜单
    $choice = Read-Host "Select an option (1-8)"    # 读取用户输入
    
    # 根据用户选择执行相应功能
    switch ($choice) {
        "1" { Get-InstalledPackages }    # 导出已安装软件列表
        "2" { New-OptimizationPackagesList }    # 创建推荐软件列表
        "3" { Install-PackagesFromList }    # 安装软件
        "4" { 
            $source = Read-Host "Enter source path"
            $destination = Read-Host "Enter backup path"
            $encrypt = Read-Host "Encrypt backup? (Y/N)"
            Backup-ImportantData -SourcePath $source -BackupPath $destination -Encrypt:($encrypt -eq 'Y')
        }
        "5" { 
            $duration = Read-Host "Enter monitoring duration (seconds)"
            Get-SystemPerformance -Duration ([int]$duration)
        }
        "6" { Start-SystemCleanup }
        "7" { 
            $interval = Read-Host "Enter cleanup interval in days (default: 3)"
            if ([string]::IsNullOrEmpty($interval)) { $interval = 3 }
            Set-CleanupSchedule -IntervalDays ([int]$interval)
        }
        "8" { return }    # 退出程序
        default { Write-Output "[ERROR] Invalid choice, please try again" }    # 无效输入提示
    }
    
    # 如果不是选择退出，则等待用户按键继续
    if ($choice -ne "8") {
        Write-Output "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne "8")    # 循环直到用户选择退出