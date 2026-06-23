# Deploy Guide — Indoor Distance Staff App

Komplett guide för att lansera Staff-appen från lokalt → produktion.

---

## 🎯 Översikt

Staff-appen är en standalone PWA med:
- **Frontend**: HTML/CSS/JS i en fil (`index.html`)
- **Backend**: Supabase (databas + auth)
- **Email-notiser**: Formspree
- **Hosting**: GitHub Pages (gratis) eller Cloudflare Pages

---

## 🚀 STEG 1 — Supabase Setup (en gång)

### 1a. Skapa Supabase-projekt
1. Gå till https://supabase.com → **New Project**
2. Namn: `indoor-distance-staff` (eller använd ditt befintliga projekt)
3. Lösenord: spara säkert
4. Region: **eu-north-1 (Stockholm)** för bästa latens i Sverige
5. Vänta ~2 min på att projektet skapas

### 1b. Kör SQL-schemat
1. I Supabase Dashboard → **SQL Editor** → **New query**
2. Kopiera hela `supabase-schema.sql` (i denna mapp)
3. Klicka **Run** (eller Ctrl+Enter)
4. Verifiera att 6 tabeller skapades: `staff_accounts`, `products`, `orders`, `newsletter_subscribers`, `discount_codes`, `staff_activity`

### 1c. Slå på Google OAuth
1. Authentication → **Providers** → Hitta **Google**
2. Toggle **Enabled**
3. Du behöver Google OAuth-credentials — se nedan
4. Lägg till **Redirect URLs**:
   - `https://indoordistance.github.io/staff/` (din deploy)
   - `http://localhost:8770/index.html` (lokal dev)
   - Den callback-URL som Supabase visar (`https://xxxx.supabase.co/auth/v1/callback`)

### 1d. Google Cloud Console (för Google OAuth)
1. https://console.cloud.google.com → Skapa nytt projekt **"Indoor Distance"**
2. **APIs & Services → Credentials → Create Credentials → OAuth Client ID**
3. **Application type**: Web application
4. **Authorized redirect URIs**: Klistra in Supabase callback-URL (från 1c)
5. Kopiera **Client ID** + **Client Secret** → klistra in i Supabase Google-provider
6. Spara

### 1e. Hämta dina nycklar
1. Project Settings → **API**
2. Kopiera:
   - **Project URL** (`https://xxxx.supabase.co`)
   - **anon public key** (lång JWT-sträng)

---

## 🌐 STEG 2 — Deploy till GitHub Pages

### 2a. Förbered Git
```bash
cd "C:/Users/simon/OneDrive/Skrivbord/IndoorDistance/StaffApp"
git init
git add .
git commit -m "Initial Staff App"
```

### 2b. Skapa GitHub-repo
1. https://github.com/new → namn: `staff` (du blir `indoordistance/staff`)
2. **Private** (viktigt — innehåller intern info)
3. Skapa
4. Pusha:
```bash
git remote add origin https://github.com/indoordistance/staff.git
git branch -M main
git push -u origin main
```

### 2c. Slå på GitHub Pages
1. På GitHub-repot → **Settings → Pages**
2. **Source**: `Deploy from a branch`
3. **Branch**: `main` / `/ (root)`
4. **Save**
5. Vänta ~2 min → din app finns på `https://indoordistance.github.io/staff/`

### 2d. Alternativ: Cloudflare Pages (rekommenderas för custom domain)
1. https://dash.cloudflare.com → Pages → **Create project**
2. Anslut GitHub-repo
3. Build settings: lämna tomt (statisk site)
4. Custom domain: `staff.indoordistance.se`
5. Deploy

---

## 🔐 STEG 3 — Första inloggningen (VD)

1. Öppna `https://indoordistance.github.io/staff/`
2. Du ser Login-skärmen
3. Klicka **"Logga in med Google"**
4. Eller skriv:
   - E-post: `indoor.distance.vd@gmail.com`
   - Lösenord: valfritt (det blir ditt VD-lösenord)
5. → Du loggas in som **admin**
6. Gå till **Inställningar** → **Supabase-anslutning**
7. Klistra in **Project URL** + **anon key** → Spara
8. Klicka **🧪 Testa anslutning** → ska visa "✓ Anslutning OK"
9. Statusbadgen i header ska bli grön **LIVE**

---

## 👥 STEG 4 — Bjud in teamet

### Som teammedlem
1. Gå till `https://indoordistance.github.io/staff/`
2. Klicka **"Begär konto →"**
3. Fyll i namn, mejl, roll, anledning + lösenord
4. (Eller klicka **"Begär konto med Google"** för snabbare flöde)
5. → Begäran skickas till VD-mejl + sparas i Supabase

### Som VD (godkänna)
1. Logga in
2. Du ser en notis om väntande begäran på Dashboard
3. Gå till **Inställningar** → **Pending Approvals**
4. Klicka **✓ Godkänn** eller **Avvisa**
5. → Teammedlemmen får ett mejl med approval-status

---

## 🔧 Felsökning

### Google-login funkar inte
- Kontrollera att redirect-URL i Supabase **exakt** matchar din deploy-URL
- Slutet på URL:en spelar roll — `/staff/` vs `/staff` är olika
- Kolla browser-konsolen för fel

### "Supabase ej konfigurerad"
- Logga in som VD med email/password
- Gå till Inställningar → klistra in URL + anon key
- Spara

### "Ditt konto väntar på VD-godkännande"
- Be VD logga in och godkänna i Inställningar

### Lokal dev
```bash
cd "C:/Users/simon/OneDrive/Skrivbord/IndoorDistance/StaffApp"
python -m http.server 8770
# Öppna http://localhost:8770/
```

---

## 🔒 Säkerhetstips

1. **Använd alltid `anon key`** — aldrig `service_role` i klienten
2. **RLS är på** — SQL-schemat sätter upp Row Level Security
3. **Privat repo** — innehåller känslig intern info
4. **Stark VD-PIN** — minst 8 siffror, byt med jämna mellanrum
5. **Backup** — exportera lokal data från Inställningar regelbundet

---

## 📊 Verifiera att allt funkar

| Test | Förväntat resultat |
|---|---|
| Öppna deploy-URL | Login-skärm syns |
| Klicka Google | Redirect till Google → tillbaka |
| Logga in som VD | Dashboard visas, namn = "VD" |
| Anslut Supabase | Status badge = grön **LIVE** |
| Begär konto (incognito) | Email skickas till VD-mejl |
| Godkänn som VD | Teammedlem kan logga in |
| Slå av/på shop | Hemsidan reflekterar ändringen |

---

## 🌍 Domäner (rekommenderad setup)

- **Hemsida** → `indoordistance.se` (eller `indoordistance.github.io/hemsida/`)
- **Staff** → `staff.indoordistance.se` (eller `indoordistance.github.io/staff/`)
- **App** → `app.indoordistance.se` (Q3 2026)

---

Klart! 🎯
