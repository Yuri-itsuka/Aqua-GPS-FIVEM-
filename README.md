# 🚓 PK Job GPS System

Ein modernes ESX Legacy GPS-System für FiveM.

Spieler mit demselben Job können sich gegenseitig live auf der Karte sehen. Das System unterstützt Fahrzeug-Blips, Helikopter, Flugzeuge, Boote und Motorräder. Zusätzlich wird ein GPS-Item benötigt, damit Spieler im System sichtbar sind.

---

## ✨ Features

* ESX Legacy Support
* GPS Item erforderlich
* Nur gleiche Jobs sehen sich gegenseitig
* Eigener GPS-Blip sichtbar
* Live Fahrzeug-Erkennung
* Auto Blips
* Motorrad Blips
* Helikopter Blips
* Flugzeug Blips
* Boot Blips
* Spielername direkt auf dem Blip
* Smooth Blip Movement
* Automatisches Entfernen von Offline-Spielern
* Optimiert für RP Server

---

## 📦 Installation

### 1. Resource installieren

Ordner in:

```text
resources/[esx]/
```

einfügen.

---

### 2. server.cfg

```cfg
ensure pk_jobgps
```

hinzufügen.

---

### 3. GPS Item importieren

SQL ausführen:

```sql
INSERT INTO items (name, label, weight) VALUES
('gps', 'GPS Tracker', 1);
```

---

### 4. Server neu starten

```cfg
refresh
ensure pk_jobgps
```

oder kompletten Server restart.

---

## ⚙️ Config

### GPS Item

```lua
Config.RequiredItem = 'gps'
```

---

### Jobs

```lua
Config.AllowedJobs = {
    police = true,
    ambulance = true,
    mechanic = true
}
```

---

### Eigenen Blip anzeigen

```lua
Config.ShowSelf = true
```

---

### Debug Modus

```lua
Config.Debug = true
```

Für Live Server empfohlen:

```lua
Config.Debug = false
```

---

## 🚗 Fahrzeug Blips

| Fahrzeug   | Blip     |
| ---------- | -------- |
| Zu Fuß     | Standard |
| Auto       | Fahrzeug |
| Motorrad   | Motorrad |
| Helikopter | Heli     |
| Flugzeug   | Flugzeug |
| Boot       | Boot     |

---

## 🔒 Sichtbarkeit

Ein Spieler wird nur angezeigt wenn:

* gleicher Job
* GPS Item vorhanden
* Spieler online
* GPS aktiv

---

## 🛠️ ESX Version

Empfohlen:

```lua
shared_script '@es_extended/imports.lua'
```

ESX Legacy verwendet Imports für die automatische ESX-Initialisierung.

---

## ❤️ Credits

Developed by AQUA-SCRIPTS
https://discord.gg/PFYAGd7uPz

FiveM • ESX Legacy • Roleplay Servers
