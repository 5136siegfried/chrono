# CHRONO — Focus Timer

> PWA cyberpunk de gestion de sessions focus. Hébergée sur `timer.5136.fr`.

---

## Stack

- **Frontend** : HTML/CSS/JS vanilla — zéro dépendance, zéro build step
- **Conteneur** : `nginx:alpine`
- **Reverse proxy** : Nginx host → port `3002`
- **CI/CD** : GitHub Actions → SSH → `docker compose up --build`
- **PWA** : Service Worker + Web App Manifest (offline ready)

---

## Fonctionnalités

- Anneau SVG animé avec changement de couleur progressif (cyan → jaune → magenta)
- Durée configurable (1–180 min, paliers de 5)
- Son à la fin via Web Audio API + vibration (`navigator.vibrate`)
- Stats du jour persistées en `localStorage` (sessions, complétées, temps total)
- Notifications push locales (iOS 16.4+ requis, ajout écran d'accueil obligatoire)
- Mode offline complet via Service Worker

---

## Structure

```
chrono/
├── index.html              # App complète (single file)
├── manifest.json           # PWA manifest
├── sw.js                   # Service Worker (cache + push)
├── Dockerfile              # nginx:alpine + static files
├── nginx.container.conf    # Config Nginx dans le container
├── docker-compose.yml      # Port 3002, restart unless-stopped
└── .github/
    └── workflows/
        └── deploy.yml      # CI/CD : push main → deploy VPS
```

---

## Déploiement

### Prérequis VPS (one-time)

```bash
# Clone
git clone https://github.com/<user>/chrono /opt/chrono
cd /opt/chrono

# Premier lancement
docker compose up --build -d

# Nginx host
sudo cp nginx.host.conf /etc/nginx/sites-available/chrono
sudo ln -s /etc/nginx/sites-available/chrono /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# SSL
sudo certbot --nginx -d timer.5136.fr

# Docker sans sudo pour le user CI
sudo usermod -aG docker $USER
```

### Secrets GitHub Actions

| Secret | Description |
|---|---|
| `VPS_HOST` | IP ou hostname du VPS |
| `VPS_USER` | User SSH |
| `VPS_SSH_KEY` | Clé privée SSH (`~/.ssh/id_ed25519`) |

### Pipeline

```
push main
  └─► GitHub Actions
        └─► SSH VPS
              ├─ git pull origin main
              ├─ docker compose up --build -d
              └─ docker image prune -f
```

Rebuild en ~5s. Downtime négligeable.

---

## PWA — Installation iPhone

1. Ouvrir `https://timer.5136.fr` dans **Safari**
2. Partager → **"Sur l'écran d'accueil"**
3. L'app tourne en standalone (plein écran, pas de barre Safari)

> Les notifications push web nécessitent iOS 16.4+ **et** l'app ajoutée à l'écran d'accueil.

---

## Développement local

```bash
# Avec Docker
docker compose up --build

# Sans Docker (Python)
python3 -m http.server 8080
# → http://localhost:8080
# ⚠ Le Service Worker ne s'active qu'en HTTPS ou localhost
```

---

## V2 — Idées

- [ ] Push notifications réelles (backend VAPID + `web-push`)
- [ ] Multi-phases configurable (focus / pause courte / pause longue)
- [ ] timer Sport
- [ ] post it et reminder des subtask
- [ ] checklist
- [ ] animations
- [ ] Historique des sessions sur 7/30 jours
- [ ] Thème clair