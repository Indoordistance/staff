# 🚀 Snabb-start för publicering

## Kopiera och kör

```bash
# 1) Gå till mappen
cd "C:/Users/simon/OneDrive/Skrivbord/IndoorDistance/StaffApp"

# 2) Init git
git init
git add .
git commit -m "Initial Staff App — 65 features"

# 3) Skapa repo på github.com/new → namn: "staff" → PRIVAT → Create

# 4) Pusha (byt USERNAME mot ditt GitHub-användarnamn)
git remote add origin https://github.com/USERNAME/staff.git
git branch -M main
git push -u origin main

# 5) Gå till repot på GitHub → Settings → Pages
#    Source: Deploy from a branch
#    Branch: main / (root)
#    Save

# 6) Klar! Vänta 2 min, sedan:
#    https://USERNAME.github.io/staff/
```

## Alternativ: dra och släpp till Vercel

1. Gå till https://vercel.com/new
2. Drag-and-drop **hela StaffApp-mappen**
3. Klar på `https://staff-xxx.vercel.app/`

## Alternativ: Cloudflare Pages (rekommenderas)

1. https://dash.cloudflare.com → Pages → **Create**
2. Connect GitHub-repot
3. Build settings: lämna allt tomt (statisk site)
4. Custom domain: `staff.indoordistance.se` (om du har domänen)
5. Deploy

---

**Default admin-konto:**
- Email: `indoor.distance.vd@gmail.com`
- Lösenord: valfritt (skapas vid första login)

**Glöm inte:**
- 🔐 Kör `supabase-schema.sql` i Supabase
- 🔑 Klistra in Supabase URL + key i Inställningar
- 🟢 Verifiera grönt LIVE-status i header
