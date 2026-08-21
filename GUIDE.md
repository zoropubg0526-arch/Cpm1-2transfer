# How to Deploy Your Telegram Bot sa Render

Gawa ni **Manus AI** · August 20, 2026

Ang bot mo ay isang **Telegram polling bot** (`python-telegram-bot` na tumatakbo sa `app.run_polling()`), kaya ang tamang service type sa Render ay **Background Worker**, hindi Web Service. Ang Web Service ay para sa apps na may HTTP endpoint; ang worker naman ay para sa mga script na tumatakbo nang tuloy-tuloy sa background — exactly ang kailangan ng isang bot.

## Ano ang Binago Ko sa Files Mo

| File | Binago / Nilagyan | Dahilan |
|------|-------------------|---------|
| `bot1.py` | Ang `BOT_TOKEN = ""` ay pinalitan ng `os.environ.get("BOT_TOKEN", "")` | Sa Render, ang secrets ay hindi nakasulat sa code kundi nasa **Environment Variables**. May guard din: magfo-fail nang malinaw kung wala ang token. |
| `requirements.txt` | Pinalitan ng slim na list: `python-telegram-bot`, `requests`, `beautifulsoup4`, `pycryptodome`, `deep-translator` | Ang lumang list ay full pip freeze na may mga dependencies na hindi kailangan. **Tinanggal ko ang `stem` at `aiohttp-socks`** dahil walang Tor/proxy code sa `bot1.py` — kung gagamitin mo pa talaga ang Tor, i-add mo ulit ang `stem` at mag-install ng Tor system package sa Dockerfile. |
| `Dockerfile` | **Bago** | Ginagamit ko ang Docker-based setup dahil mas madali at mas maaasahan sa Render, at dahil ang lumang config mo (`APT=tor`) ay hindi supported ng Render. |
| `render.yaml` | **Bago** (optional) | Blueprint file para sa one-click setup sa Render. |
| `discloud.config` | Hindi na kailangan | Para lang ito sa Discloud hosting; wala itong ginagawa sa Render. |

**Paalala:** Tinanggal ko ang Tor requirement dahil walang anumang Tor/proxy code sa bot mo (nag-search ako ng `tor`, `socks`, `proxy`, `stem` — walang matches). Kung may bahagi ka ng bot na gumagamit ng Tor na hindi kasama sa file na pinadala mo, sabihin mo lang at ia-add ko ulit ang `RUN apt-get update && apt-get install -y tor` sa Dockerfile.

## Step-by-Step: Pag-deploy sa Render (GitHub Method)

### Step 1 — I-push ang files sa GitHub

Lumikha ng bagong repository sa [github.com](https://github.com) at i-upload ang apat na files: `bot1.py`, `requirements.txt`, `Dockerfile`, at `render.yaml`.

```bash
git init
git add bot1.py requirements.txt Dockerfile render.yaml
git commit -m "Bot ready for Render"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

### Step 2 — Gumawa ng Background Worker sa Render

1. Pumunta sa [dashboard.render.com](https://dashboard.render.com) at mag-login.
2. Pindutin ang **New +** at pumili ng **Background Worker**.
3. Pumili ng **Build and deploy from a Git repository** at i-connect ang GitHub account mo.
4. Piliin ang repository at ang branch (karaniwang `main`).

### Step 3 — I-configure ang service

| Setting | Value |
|---------|-------|
| Name | Kahit ano, e.g. `es3-session-bot` |
| Runtime | **Docker** |
| Plan | **Free** |
| Docker Command | `python3 bot1.py` (o iwanang default kung Dockerfile ang base) |

Kung gusto mo ng mas mabilis na setup, gamitin mo ang **Deploy Blueprint**: pumunta sa [render.com/blueprints](https://dashboard.render.com/blueprints), i-link ang GitHub repo na may `render.yaml`, at auto-configure na ang lahat.

### Step 4 — I-set ang BOT_TOKEN environment variable

Ito ang pinaka-importante. **Huwag isulat ang token sa code.**

1. Sa Render dashboard, buksan ang service mo at pumunta sa **Environment**.
2. Pindutin ang **Add Environment Variable**.
3. Key: `BOT_TOKEN`
4. Value: ang bot token mo mula kay [@BotFather](https://t.me/BotFather) (hal. `123456789:AAH...`)
5. I-save.

### Step 5 — I-deploy at i-verify

Pindutin ang **Create Worker** (o **Deploy**). Ang Render ay magbu-build ng Docker image, i-install ang requirements, at sisimulan ang bot. I-check ang **Logs** tab: dapat makita mo ang mensaheng:

> 🤖 ES3 Session Bot running with CPM1, CPM2, CPM1→CPM2, and CPM2→CPM2 support...

At dapat tumutugon na ang bot mo sa Telegram.

## Tungkol sa Libreng Plan ng Render

Ang free plan ng Render ay para sa workers ay may limit sa **monthly build and runtime hours**. Hindi siya "sleeping" tulad ng free web services, pero kung maubos ang monthly allowance mo, hihinto ang worker hanggang sa susunod na buwan. Kung kailangan mo ng 24/7 na bot na hindi napuputol, mag-upgrade sa **Starter plan ($7/buwan)**. Para sa testing at light usage, sapat ang free plan.

## Local Testing

Bago i-deploy, pwede mo itong i-test sa sarili mong PC:

```bash
pip install -r requirements.txt
BOT_TOKEN="123456789:AAH..." python3 bot1.py
```

**Pinagpatunayan ko na ito na gumagana sa sandbox:** tumakbo ang bot nang tama kapag naka-set ang token, at nagbigay ng malinaw na error message (`RuntimeError: BOT_TOKEN environment variable is not set`) kapag walang token — kaya siguradong magfo-fail nang ligtas ang Render build kung nakalimutan mong i-set ang environment variable.

## Troubleshooting

| Problema | Solusyon |
|----------|----------|
| Build failed — "Invalid API key" o login error sa bot code | Hindi ito Render issue — i-check ang Google API keys sa loob ng `bot1.py` |
| Bot hindi tumutugon kahit deployed | Tingnan ang **Logs** sa Render dashboard; malimit na sanhi ay kulang o mali ang `BOT_TOKEN` env var |
| Kumakapit sa "Installing Tor" o build na mabagal | Tinanggal ko na ang Tor — siguruhin na ang `Dockerfile` ko ang ginagamit mo, hindi yung lumang config |
| Worker tumigil matapos ang ilang oras | Naubos ang monthly hours ng free plan — mag-upgrade o hintayin ang susunod na billing cycle |
| File storage nawawala pag-restart | Ang `coins.json`, `ashlog/`, at iba pang local files ay **ephemeral** sa Render — mawawala sa bawat redeploy. Kung kailangan mong permanenteng storage, idagdag ang Redis/Postgres o S3 storage |
