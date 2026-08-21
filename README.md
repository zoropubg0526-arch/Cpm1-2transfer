# ES3 Session Bot — Render Deployment

Telegram bot na nagco-convert ng CPM1/CPM2 ES3 files. Deployed sa Render bilang **Background Worker**.

## Files

| File | Purpose |
|------|---------|
| `bot1.py` | Main bot code (token is read from `BOT_TOKEN` env var) |
| `requirements.txt` | Python dependencies |
| `Dockerfile` | Render Docker build definition |
| `render.yaml` | Render Blueprint (optional one-click setup) |

## Local Test

```bash
pip install -r requirements.txt
BOT_TOKEN="your-token-here" python3 bot1.py
```

## Render Deploy (GitHub method)

1. Push files to GitHub
2. New Web Service o **Background Worker** sa render.com
3. Connect GitHub repo
4. Environment: Docker o Python
5. Add env var `BOT_TOKEN`
6. Deploy

## Important

- Use **Background Worker** (not Web Service) — polling bots walang HTTP endpoint na kailangan i-keep-alive.
- Libreng plan: sasapin ang bot pag nag-idle siya? Hindi — workers walang spin-down sa free plan, pero limited ang monthly hours. Pwedeng mag-upgrade kung 24/7 reliable kailangan.
