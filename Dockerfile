FROM ubuntu:22.04
LABEL maintainer="fle108"
LABEL description="Container Ubuntu avec Python, yt-dlp et NordVPN"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Installation des paquets de base et NordVPN
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        curl \
        wget \
        apt-transport-https \
        ca-certificates \
        gnupg \
        iputils-ping \
        net-tools \
        iproute2 && \
    # Installation du dépôt NordVPN
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc https://repo.nordvpn.com/gpg/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    # Nettoyage
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# Téléchargement et installation de yt-dlp
RUN curl -fsSL -o /usr/local/bin/yt-dlp \
    https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
    chmod a+x /usr/local/bin/yt-dlp

# Création d'un script d'initialisation pour NordVPN
RUN echo '#!/bin/bash\n\
# Démarrage du service NordVPN\n\
service nordvpn start\n\
sleep 2\n\
\n\
# Fonction pour vérifier si le service est prêt\n\
wait_for_nordvpn() {\n\
    for i in {1..30}; do\n\
        if nordvpn status &>/dev/null; then\n\
            echo "NordVPN service is ready"\n\
            return 0\n\
        fi\n\
        echo "Waiting for NordVPN service... ($i/30)"\n\
        sleep 1\n\
    done\n\
    echo "NordVPN service failed to start"\n\
    return 1\n\
}\n\
\n\
wait_for_nordvpn\n\
\n\
# Connexion automatique si le token est fourni\n\
if [ -n "$NORDVPN_TOKEN" ]; then\n\
    echo "Connexion automatique à NordVPN avec le token..."\n\
    echo "n" | nordvpn login --token "$NORDVPN_TOKEN"\n\
    nordvpn connect ${NORDVPN_COUNTRY:-France}\n\
    sleep 3\n\
    echo "=== VPN Status ==="\n\
    nordvpn status\n\
else\n\
    echo "Aucun token fourni. Utilisez '\''nordvpn login'\'' manuellement"\n\
fi\n\
\n\
# Exécution de la commande passée en argument\n\
exec "$@"\n\
' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
