# YT-DLP

Video downloader container embedding **yt-dlp** and **NordVPN** ready to connect.

## Prerequisites

- Docker and Docker Compose installed
- NordVPN subscription with token

## Setup

### 1. Configure Environment Variables

Create a `.env` file in the project root:

```env
NORDVPN_TOKEN=<your-token>
NORDVPN_COUNTRY=<country-name>
```

### 2. Build and Run the Container

```bash
docker compose build
docker compose up -d
```

## Usage

### Change VPN Country

To connect to a different country:

```bash
# Access the container
docker exec -ti nordvpn_app /bin/bash

# Check current status
nordvpn status

# Connect to a specific country
nordvpn connect <country>
```

## Features

- **yt-dlp**: Download videos from thousands of platforms ([GitHub repository](https://github.com/yt-dlp/yt-dlp))
- **NordVPN**: Built-in VPN support for privacy and geo-restriction bypass
- **Docker**: Easy deployment and isolation

