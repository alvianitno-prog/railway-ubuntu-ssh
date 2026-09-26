#!/bin/bash

# 1. Set Password root
if [ -n "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
else
    echo "root:root" | chpasswd
fi

# 2. Buat Script MOTD Dinamis agar Tampilan Welcome Banner Persis Foto
cat << 'EOF' > /etc/profile.d/samudev_banner.sh
#!/bin/bash

# Mencegah eksekusi ganda jika bukan interactive shell
if [[ $- != *i* ]]; then return; fi

# Deteksi IP Public
PUBLIC_IP=$(curl -s --max-time 3 https://api.ipify.org || curl -s --max-time 3 https://ifconfig.me || echo "208.77.244.28")

# Deteksi Stats System
HOSTNAME_SYS=$(hostname)
USER_SYS=$(whoami)
OS_SYS="Ubuntu $(lsb_release -rs 2>/dev/null || echo "24.04") LTS"
KERNEL_SYS=$(uname -r)

# Uptime
UPTIME_SYS=$(uptime -p 2>/dev/null | sed 's/up //' || echo "1 minute")

# CPU & RAM Info
CPU_SYS=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //' || echo "Intel Xeon Processor (Icelake)")
if [ -z "$CPU_SYS" ]; then CPU_SYS="Intel Xeon Processor (Icelake)"; fi

RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/Mem:/ {print $3}')

# Storage Info
STORAGE_USED=$(df -h / | awk 'NR==2 {print $3}')
STORAGE_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
STORAGE_PERC=$(df -h / | awk 'NR==2 {print $5}')

# Load Avg
LOAD_AVG=$(awk '{print $1", "$2", "$3}' /proc/loadavg)

# ANSI Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${YELLOW}SamuDev VPS  •  ONLINE${RESET}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${CYAN}│${RESET}"
echo -e "${CYAN}├─ Hostname   :${RESET} ${GREEN}${HOSTNAME_SYS}${RESET}"
echo -e "${CYAN}├─ Username   :${RESET} ${GREEN}${USER_SYS}${RESET}"
echo -e "${CYAN}├─ IP PubLiK  :${RESET} ${GREEN}${PUBLIC_IP}${RESET}"
echo -e "${CYAN}├─ OS         :${RESET} ${GREEN}${OS_SYS}${RESET}"
echo -e "${CYAN}├─ KerneL     :${RESET} ${GREEN}${KERNEL_SYS}${RESET}"
echo -e "${CYAN}├─ Uptime     :${RESET} ${GREEN}${UPTIME_SYS}${RESET}"
echo -e "${CYAN}│${RESET}"
echo -e "${CYAN}├─ CPU        :${RESET} ${GREEN}${CPU_SYS}${RESET}"
echo -e "${CYAN}├─ RAM        :${RESET} ${GREEN}${RAM_USED} / ${RAM_TOTAL}${RESET}"
echo -e "${CYAN}├─ Storage    :${RESET} ${GREEN}${STORAGE_USED} / ${STORAGE_TOTAL} (${STORAGE_PERC})${RESET}"
echo -e "${CYAN}├─ Load Avg   :${RESET} ${GREEN}${LOAD_AVG}${RESET}"
echo -e "${CYAN}├─ TunneL     :${RESET} ${GREEN}Tidak ada${RESET}"
echo -e "${CYAN}└─ Port Aktif :${RESET} ${GREEN},22,${RESET}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e ""
echo -e " ✦ ${YELLOW}Selamat datang, ${USER_SYS}!${RESET} ✦"
echo -e ""
EOF

chmod +x /etc/profile.d/samudev_banner.sh

# Kosongkan MOTD Bawaan Ubuntu Biar Gak Dobel
> /etc/motd
> /etc/issue

# 3. Jalankan OpenSSH Daemon (Tetap di foreground -D agar koneksi tidak terputus)
echo "🚀 Menjalankan OpenSSH Server Daemon..."
exec /usr/sbin/sshd -D
