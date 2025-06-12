# KMU-Netzwerk-Setup mit PowerShell

Dieses Projekt automatisiert die vollständige Einrichtung eines Windows-Servers für ein kleines oder mittleres Unternehmen (KMU) mithilfe eines PowerShell-Skripts. Das Skript richtet alle wesentlichen Dienste wie Active Directory, DHCP, DNS, File Services und Gruppenrichtlinien ein, damit der Server schnell und zuverlässig im Netzwerk arbeiten kann.

## Projektziele

- **Automatisierung der Servereinrichtung**: Alle grundlegenden Dienste (AD, DNS, DHCP, Dateifreigaben) werden automatisch konfiguriert.
- **Einfache Netzwerkverbindung**: Statische IP-Adresse und korrekt konfiguriertes DNS und Gateway.
- **Benutzerverwaltung**: Automatische Erstellung von Benutzern und Gruppen im Active Directory.
- **Sicherheit**: Zugriffskontrolle über NTFS-Berechtigungen für Ordner.
- **Zukunftssicher**: Einfacher Ausbau durch ein einziges PowerShell-Skript, das nach Bedarf angepasst werden kann.

## Funktionen

- **Hostname und IP-Adresse setzen**: Der Server wird mit einem eindeutigen Namen und einer statischen IP-Adresse eingerichtet.
- **Active Directory (AD) einrichten**: Der Server wird zum Domänencontroller für die Domäne `kmu.intern`.
- **Rollen installieren**: Die Serverrollen für **Active Directory**, **DNS**, **DHCP** und **Dateidienste** werden automatisch installiert.
- **Ordnerstruktur und Berechtigungen**: Erstellen von Freigabeordnern und Festlegen von NTFS-Berechtigungen.
- **Gruppenrichtlinien (GPO)**: Automatisches Setzen von Gruppenrichtlinien für Benutzer und Computer.
- **Netzwerkkonfiguration prüfen**: Testen der Netzwerkverbindung (Gateway, DNS, Internet).

## Installation

1. **PowerShell-Skript ausführen:**
   - Stelle sicher, dass die PowerShell-Ausführungsrichtlinie gesetzt ist, damit das Skript ausgeführt werden kann:
     ```powershell
     Set-ExecutionPolicy RemoteSigned -Scope Process -Force
     ```
     
2. **Skript starten:**
   - Lade das Skript herunter und führe es in PowerShell aus:
     ```powershell
     .\setup.ps1
     ```

3. **Automatische Ausführung:**
   - Das Skript wird den Server einrichten, Neustarts durchführen und Dienste wie Active Directory und DNS konfigurieren.

## Struktur

```text
setup.ps1               # Hauptskript für die Servereinrichtung
docs/                   # Dokumentation und Screenshots
└── Präsentation.pptx   # Präsentation für das Projekt
