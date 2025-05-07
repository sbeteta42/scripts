
# 1. Désactiver le service SysMain (Superfetch)
Write-Host "🛑 Désactivation du service SysMain..."
Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
Set-Service -Name "SysMain" -StartupType Disabled

# 2. Désactiver la recherche Web dans Windows Search
Write-Host "🔍 Désactivation de la recherche Web dans le menu Démarrer..."
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1

# 3. Désactiver UsePlatformClock dans le Boot Configuration Data
Write-Host "⏱️ Désactivation de UsePlatformClock dans BCD..."
bcdedit /deletevalue useplatformclock | Out-Null

# 4. Désactivation des tâches planifiées inutiles
Write-Host "🗓️ Désactivation de tâches planifiées inutiles..."

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
        Write-Host "✅ $task désactivée."
    } catch {
        Write-Host "⚠️ $task non trouvée ou déjà désactivée."
    }
}

Write-Host "`n✔️ Optimisations terminées. Redémarrage recommandé."
