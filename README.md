# ES3 Session Bot — Render Deployment

Telegram bot na nagco-convert ng CPM1/CPM2 ES3 files at may VIP Stars subscription system. Deployed sa Render bilang **Web Service** (may built-in health-check server sa port 10000, patuloy na tumatakbo ang polling sa background).

## Files

| File | Purpose |
|------|---------|
| `bot1.py` | Main bot code (token is read from `BOT_TOKEN` env var; includes health-check server + VIP subscription system) |
| `requirements.txt` | Python dependencies |
| `Dockerfile` | Render Docker build definition (exposes port 10000) |
| `render.yaml` | Render Blueprint (optional one-click setup) |

## Local Test

```bash
pip install -r requirements.txt
BOT_TOKEN="your-token-here" python3 bot1.py
# Health check: curl http://localhost:10000/  -> should return "OK"
```

## Render Deploy (GitHub method)

1. Push files to GitHub
2. New **Web Service** sa render.com
3. Connect GitHub repo, branch: `main`
4. Language: **Docker**
5. Environment Variables: `BOT_TOKEN` = token mula sa BotFather
6. Health Check Path (Advanced): `/` (optional — may built-in health server na)
7. Plan: Free
8. Deploy Web Service

## Important

- Use **Web Service** — ang bot ay may built-in na health-check server (port 10000) na nagsisigurong hindi siya pumapatay ng Render.
- Ang Telegram polling ay patuloy na tumatakbo sa background habang online ang health server.
- Ang `BOT_TOKEN` ay HUWAG isulat sa code — i-set lang sa Render Environment Variables.
