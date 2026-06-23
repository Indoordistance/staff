# Indoor Distance Staff App

Internt arbetsverktyg för Indoor Distance-teamet.

🌐 **Live:** `https://indoordistance.github.io/staff/` (efter deploy)

## ⚡ Snabbstart

### Lokalt
```bash
cd StaffApp
python -m http.server 8770
# Öppna http://localhost:8770
```

### Login som VD (första gången)
- **Email:** `indoor.distance.vd@gmail.com`
- **Lösenord:** valfritt (sparas automatiskt)

## 🚀 Deploy till GitHub Pages (5 min)

### Steg 1 — Skapa GitHub-repot
```bash
cd "C:/Users/simon/OneDrive/Skrivbord/IndoorDistance/StaffApp"
git init
git add .
git commit -m "Initial Staff App"
```

### Steg 2 — Pusha till GitHub
1. Skapa **privat** repo på https://github.com/new — namn: `staff`
2. Kopiera commands de visar:
```bash
git remote add origin https://github.com/indoordistance/staff.git
git branch -M main
git push -u origin main
```

### Steg 3 — Slå på GitHub Pages
1. Repot → **Settings → Pages**
2. **Source:** `Deploy from a branch`
3. **Branch:** `main` / `/ (root)`
4. **Save** → vänta ~2 min
5. Klart på `https://indoordistance.github.io/staff/`

### Steg 4 — Konfigurera Supabase
1. Logga in i Staff-appen
2. **Inställningar → Supabase-anslutning**
3. Klistra in **URL** + **anon key** (från supabase.com → API)
4. Klicka **🧪 Testa anslutning** → ska bli grönt
5. Kör `supabase-schema.sql` i Supabase SQL Editor

### Steg 5 — Slå på Google OAuth (valfritt)
Se `DEPLOY.md` för full guide.

## 📂 Filstruktur

```
StaffApp/
├── index.html              # Allt-i-en app (HTML/CSS/JS)
├── manifest.json           # PWA-manifest
├── sw.js                   # Service Worker (offline)
├── supabase-schema.sql     # Databastabeller + RLS
├── DEPLOY.md               # Detaljerad deploy-guide
├── README.md               # Denna fil
└── .gitignore
```

## ✨ Vad ingår (65+ features)

### Huvudtabbar
- 📊 **Dashboard** — KPIs, snabbåtgärder, dagens fokus
- 🛍️ **Shop** — produkter, lager, shop-toggle
- 📦 **Order** — beställningar + CSV-export
- 🤝 **CRM** — klubbkontakter (5 statusar)
- 📅 **Kalender** — team-events
- 💬 **Chatt** — internt team
- 🧠 **AI-hjälp** — coach-prompts
- 🎟️ **Rabatter** — koder
- 📨 **Nyhetsbrev** — prenumeranter + utskick
- 🎧 **Support** — biljetter
- 📷 **Media** — bildbank
- 🛠️ **Verktyg** — todo, mallar, audit, onboarding
- 🔗 **Länkar** — Supabase, Stripe, etc.
- 📚 **Handbok** — intern FAQ
- 🔐 **Säkerhet** — 2FA, magic links, IP-whitelist (7 sub-tabs)
- 📡 **Kommunikation** — Gmail, SMS, Slack, DeepL (7 sub-tabs)
- 📈 **Analys** — kunder, segments, funnel, heatmap (7 sub-tabs)
- 🔌 **Integrationer** — Stripe, frakt, webhooks, A/B-test (14 sub-tabs)
- ⚙️ **Inställningar** — Supabase, PIN, profil, backup

### Kortkommandon
- `Ctrl+K` eller `/` — Kommandopalett
- `g+d` — Dashboard, `g+s` — Shop, `g+c` — CRM, osv.

## 🔐 Säkerhet

- ✅ Email/password + Google OAuth via Supabase
- ✅ VD-godkännande för nya konton (mejl-flöde)
- ✅ Lösenord hashade (SHA-256 med salt)
- ✅ 2FA / TOTP-stöd
- ✅ Backup-koder
- ✅ Row Level Security i Supabase
- ✅ Audit-log för alla åtgärder
- ✅ 8-timmars session-timeout

## 🌗 Tema

Klicka månikonen i headern för att växla mellan mörkt/ljust läge.

## 📞 Support

Kontakta `info.indoordistance@gmail.com` vid problem.

---

Made with 🤖 + ❤️ för Indoor Distance · 2026
