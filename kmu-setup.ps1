
# ================================
# KMU Setup-Skript für Windows Server
# Erstellt von: my big sexy latino andrija ayri
# Funktion: Vollautomatischer Aufbau einer AD-Domäne mit Benutzer, Gruppen, Laufwerken, GPOs und NTFS-Rechten
# ================================

# ------- KONFIGURATION -------
$domainName = "kmu.intern"
$netbiosName = "KMU"
$ouMitarbeiter = "OU=Mitarbeiter,DC=kmu,DC=intern"
$homeRoot = "C:\HomeVerzeichnisse"
$freigabeName = "Home_Mitarbeiter"
$csvPfad = "C:\Skripte\benutzer.csv"

# ------- 1. CSV-Datei vorbereiten -------
New-Item -Path "C:\Skripte" -ItemType Directory -Force | Out-Null
@"
Vorname,Nachname,Benutzername,Passwort
Luca,Meier,luca.meier,Start123!
Mira,Huber,mira.huber,Start123!
Tim,Fischer,tim.fischer,Start123!
Sofia,Weber,sofia.weber,Start123!
"@ | Set-Content -Path $csvPfad -Encoding UTF8

# ------- 2. OU erstellen -------
Import-Module ActiveDirectory
New-ADOrganizationalUnit -Name "Mitarbeiter" -Path "DC=kmu,DC=intern" -ErrorAction SilentlyContinue

# ------- 3. Gruppe erstellen -------
New-ADGroup -Name "GRP_Home_Mitarbeiter" -GroupScope Global -GroupCategory Security -Path $ouMitarbeiter -ErrorAction SilentlyContinue

# ------- 4. Benutzer aus CSV anlegen -------
Import-Csv $csvPfad | ForEach-Object {
    $name = "$($_.Vorname) $($_.Nachname)"
    $login = $_.Benutzername
    $pass = ConvertTo-SecureString $_.Passwort -AsPlainText -Force

    New-ADUser `
        -Name $name `
        -GivenName $_.Vorname `
        -Surname $_.Nachname `
        -SamAccountName $login `
        -UserPrincipalName "$login@$domainName" `
        -AccountPassword $pass `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -DisplayName $name `
        -Path $ouMitarbeiter

    Add-ADGroupMember -Identity "GRP_Home_Mitarbeiter" -Members $login
}

# ------- 5. Home-Ordner erstellen + NTFS-Rechte -------
New-Item -Path $homeRoot -ItemType Directory -Force | Out-Null
icacls $homeRoot /inheritance:r | Out-Null
icacls $homeRoot /grant "GRP_Home_Mitarbeiter:(OI)(CI)(RX)" | Out-Null

Import-Csv $csvPfad | ForEach-Object {
    $login = $_.Benutzername
    $userPath = Join-Path $homeRoot $login
    if (-not (Test-Path $userPath)) {
        New-Item -Path $userPath -ItemType Directory -Force | Out-Null
        icacls $userPath /inheritance:r | Out-Null
        icacls $userPath /grant "${login}:(OI)(CI)F" | Out-Null
    }
}

# ------- 6. Benutzer HomeDrive zuweisen -------
Import-Csv $csvPfad | ForEach-Object {
    $login = $_.Benutzername
    $homePath = "\\$env:COMPUTERNAME\$freigabeName\$login"
    Set-ADUser $login -HomeDirectory $homePath -HomeDrive "H:"
}

# ------- 7. SMB-Freigabe erstellen -------
if (-not (Get-SmbShare -Name $freigabeName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $freigabeName -Path $homeRoot -FullAccess "GRP_Home_Mitarbeiter"
}

# ------- 8. GPO erstellen und verknüpfen -------
$gpoName = "KMU_Laufwerkzuweisung"
New-GPO -Name $gpoName -Comment "Automatische Laufwerkszuweisung H:"
New-GPLink -Name $gpoName -Target $ouMitarbeiter -LinkEnabled Yes

# ------- 9. Laufwerkszuweisung (XML in GPO schreiben) -------
$gpo = Get-GPO -Name $gpoName
$gpoId = $gpo.Id
$domain = (Get-ADDomain).DNSRoot
$gpoPath = "\\$domain\SYSVOL\$domain\Policies\{$gpoId}\User\Preferences\Drives"
New-Item -Path $gpoPath -ItemType Directory -Force | Out-Null

$xml = @"
<Drive clsid="{C631DF4C-088F-48E3-A6F0-13A016BFC0C3}" name="H Drive" status="OK">
  <Properties action="U" thisDrive="H:" useLetter="1" userName="%USERNAME%" path="\\$env:COMPUTERNAME\$freigabeName\%USERNAME%" persistent="0" mapAs="0" />
</Drive>
"@
Set-Content -Path (Join-Path $gpoPath "Drives.xml") -Value $xml -Encoding UTF8

# ------- 10. Abschlussmeldung -------
Write-Host "✔ KMU-Setup abgeschlossen! Benutzer, Gruppen, Home-Verzeichnisse, GPO & Rechte erfolgreich eingerichtet." -ForegroundColor Green
