# script d'Optimisation pour les VMs Windows 10/11
# Par sbeteta@beteta.org

# 1. Désactiver le service SysMain (anciennement Superfetch...)
Write-Host "[INFO] Désactivation du service SysMain..."
Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
Set-Service -Name "SysMain" -StartupType Disabled

# 2. Désactiver la recherche Web dans Windows Search
Write-Host "[INFO] Désactivation de la recherche Web dans le menu Démarrer..."
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1

# 3. Désactiver UsePlatformClock dans le Boot Configuration Data
Write-Host "[INFO] Désactivation de UsePlatformClock dans BCD..."
bcdedit /deletevalue useplatformclock | Out-Null

# 4. Désactivation des tâches planifiées inutiles
Write-Host "[INFO] Désactivation de tâches planifiées inutiles..."

$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Maintenance\WinSAT",
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting",
    "\Microsoft\Windows\Shell\FamilySafetyMonitor",
    "\Microsoft\Windows\Shell\FamilySafetyRefresh"
)

foreach ($task in $tasksToDisable) {
    try {
        Disable-ScheduledTask -TaskPath $task -ErrorAction Stop
        Write-Host "[OK] $task désactivée."
    } catch {
        Write-Host "[INFO] $task non trouvée ou déjà désactivée."
    }
}

Write-Host "`n[OK] Optimisations terminées. Redémarrage recommandé."
