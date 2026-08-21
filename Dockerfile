FROM python:3.11-slim

# Tor is no longer required by the bot code (no proxy/Tor usage found)
# so we keep the image slim. If you ever add Tor/proxy usage back,
# add: RUN apt-get update && apt-get install -y tor

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Render Web Service: expose health-check port 10000
EXPOSE 10000
ENV PORT=10000

CMD ["python3", "bot1.py"]
