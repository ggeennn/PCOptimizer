# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)

# 获取已安装的软件包列表并导出到CSV
function Get-InstalledPackages {
    Write-Output "[INFO] Getting installed packages..."
    
    # 获取 winget 已安装的包
    $wingetPackages = winget list | Select-Object -Skip 3 | ForEach-Object {
        $line = $_ -split '\s{2,}'
        if ($line.Count -ge 3) {
            [PSCustomObject]@{
                Name = $line[0]
                Version = $line[1]
                Source = "winget"
            }
        }
    }

    # 导出到CSV
    $wingetPackages | Export-Csv -Path ".\installed_list.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "[SUCCESS] Exported package list to installed_list.csv"
}

# 从CSV安装软件包
function Install-PackagesFromList {
    param (
        [string]$CsvPath = ".\optimization_packages.csv"
    )
    
    if (Test-Path $CsvPath) {
        $packages = Import-Csv $CsvPath
        foreach ($package in $packages) {
            Write-Output "[INSTALL] Installing $($package.Name)..."
            winget install $package.Name --accept-source-agreements --accept-package-agreements
        }
    } else {
        Write-Output "[ERROR] Package list file not found: $CsvPath"
    }
}

# 创建推荐的优化软件包列表
function New-OptimizationPackagesList {
    $packages = @(
        [PSCustomObject]@{
            Name = "Piriform.CCleaner"
            Category = "System Cleanup"
            Priority = "Essential"
        },
        [PSCustomObject]@{
            Name = "Chuyu-Team.DISM++"
            Category = "System Optimization"
            Priority = "Essential"
        },
        [PSCustomObject]@{
            Name = "BleachBit"
            Category = "Privacy Cleanup"
            Priority = "Optional"
        },
        [PSCustomObject]@{
            Name = "Sysinternals.SysinternalsSuite"
            Category = "System Monitor"
            Priority = "Optional"
        }
    )

    $packages | Export-Csv -Path ".\optimization_packages.csv" -NoTypeInformation -Encoding UTF8
    Write-Output "[SUCCESS] Created optimization packages list"
}

# 主菜单
function Show-Menu {
    Clear-Host
    Write-Output "=== PC Optimizer Tool Manager ==="
    Write-Output "1. Export current installed packages list"
    Write-Output "2. Create recommended optimization packages list"
    Write-Output "3. Install packages from list"
    Write-Output "4. Exit"
    Write-Output "================================="
}

# 主程序循环
do {
    Show-Menu
    $choice = Read-Host "Select an option (1-4)"
    
    switch ($choice) {
        "1" { Get-InstalledPackages }
        "2" { New-OptimizationPackagesList }
        "3" { Install-PackagesFromList }
        "4" { return }
        default { Write-Output "[ERROR] Invalid choice, please try again" }
    }
    
    if ($choice -ne "4") {
        Write-Output "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne "4")