# 设置控制台编码为 UTF-8，确保中文显示正常
# 这三行代码都是为了处理中文编码问题，防止出现乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)

# 函数：获取系统中已安装的软件包列表并导出到CSV文件
function Get-InstalledPackages {
    Write-Output "[INFO] Getting installed packages..."
    
    # 使用 winget list 命令获取已安装的包
    # Select-Object -Skip 3 是跳过winget输出的前3行（标题和分隔线）
    # ForEach-Object 循环处理每一行数据
    $wingetPackages = winget list | Select-Object -Skip 3 | ForEach-Object {
        # 用2个或更多空格分割每行，得到软件名、版本等信息
        $line = $_ -split '\s{2,}'
        # 确保分割后至少有3个元素（软件名、版本号等）
        if ($line.Count -ge 3) {
            # 创建自定义对象，存储软件信息
            [PSCustomObject]@{
                Name = $line[0]      # 软件名称
                Version = $line[1]    # 软件版本
                Source = "winget"     # 来源标记为winget
            }
        }
    }

    # 将收集到的软件包信息导出到CSV文件
    # NoTypeInformation 参数避免在CSV中包含类型信息行
    $wingetPackages | Export-Csv -Path ".\installed_list.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "[SUCCESS] Exported package list to installed_list.csv"
}

# 函数：从CSV文件中读取软件列表并安装
function Install-PackagesFromList {
    # 参数：CSV文件路径，默认为当前目录下的 optimization_packages.csv
    param (
        [string]$CsvPath = ".\optimization_packages.csv"
    )
    
    # 检查CSV文件是否存在
    if (Test-Path $CsvPath) {
        # 读取CSV文件内容
        $packages = Import-Csv $CsvPath
        # 遍历每个软件包并安装
        foreach ($package in $packages) {
            Write-Output "[INSTALL] Installing $($package.Name)..."
            # 使用winget安装软件，自动接受协议
            winget install $package.Name --accept-source-agreements --accept-package-agreements
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
        }
    )

    # 将推荐软件列表导出到CSV文件
    $packages | Export-Csv -Path ".\optimization_packages.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "[SUCCESS] Created optimization packages list"
}

# 函数：显示主菜单界面
function Show-Menu {
    Clear-Host    # 清屏
    Write-Output "=== PC Optimizer Tool Manager ==="
    Write-Output "1. Export current installed packages list"    # 导出当前已安装的软件列表
    Write-Output "2. Create recommended optimization packages list"    # 创建推荐的优化软件列表
    Write-Output "3. Install packages from list"    # 从列表安装软件
    Write-Output "4. Exit"    # 退出程序
    Write-Output "================================="
}

# 主程序循环
do {
    Show-Menu    # 显示菜单
    $choice = Read-Host "Select an option (1-4)"    # 读取用户输入
    
    # 根据用户选择执行相应功能
    switch ($choice) {
        "1" { Get-InstalledPackages }    # 导出已安装软件列表
        "2" { New-OptimizationPackagesList }    # 创建推荐软件列表
        "3" { Install-PackagesFromList }    # 安装软件
        "4" { return }    # 退出程序
        default { Write-Output "[ERROR] Invalid choice, please try again" }    # 无效输入提示
    }
    
    # 如果不是选择退出，则等待用户按键继续
    if ($choice -ne "4") {
        Write-Output "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne "4")    # 循环直到用户选择退出