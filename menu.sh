#!/bin/bash
C='\033[0;36m'; V='\033[1;32m'; A='\033[1;33m'; R='\033[1;31m'; N='\033[0m'; M='\033[1;35m'
IP_VPS=$(hostname -I | awk '{print $1}'); [ -z "$IP_VPS" ] && IP_VPS="Desconocida"
es() { systemctl is-active --quiet $1 && echo -e "${V}[ON] ${N}" || echo -e "${R}[OFF]${N}"; }
ep() { ss -tlnp | grep -q ":$1 " > /dev/null 2>&1 || ss -ulnp | grep -q ":$1 " > /dev/null 2>&1 && echo -e "${V}[ON] ${N}" || echo -e "${R}[OFF]${N}"; }
info_sistema() {
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USADA=$(free -m | awk '/Mem:/ {print $3}')
LIBRE_RAM=$(free -m | awk '/Mem:/ {print $4}')
PORCENT_RAM=$(( (MEM_USADA * 100) / MEM_TOTAL ))
S_OS=$(grep -oP '(?<=PRETTY_NAME=")[^"]+' /etc/os-release 2>/dev/null || echo "Ubuntu Linux")
S_ARCH=$(uname -m)
S_CPU=$(nproc)
FECHA_ACT=$(date +'%d/%m/%Y-%H:%M')
STR_PORTS=""
C_PORT=0
agregar_puerto() {
STR_PORTS+="$1       "
C_PORT=$((C_PORT+1))
if [ $C_PORT -eq 2 ]; then
STR_PORTS+="\n "
C_PORT=0
fi
}
ss -tlnp | grep -q ":22 " && agregar_puerto "🔹 SSH: ${V}22${N}"

if ss -tlnp | grep -q ":80 "; then
    systemctl is-active --quiet xray && grep -q '"port": 80' /usr/local/etc/xray/config.json 2>/dev/null && agregar_puerto "🔹 V2RAY: ${V}80${N}" || agregar_puerto "🔹 PROXY: ${V}80${N}"
fi

if ss -tlnp | grep -q ":443 "; then
    systemctl is-active --quiet xray && grep -q '"port": 443' /usr/local/etc/xray/config.json 2>/dev/null && agregar_puerto "🔹 V2RAY: ${V}443${N}" || agregar_puerto "🔹 SSL: ${V}443${N}"
fi

ss -tlnp | grep -q ":444 " && agregar_puerto "🔹 SSL: ${V}444${N}"
ss -ulnp | grep -q ":36712" && agregar_puerto "🔹 UDP: ${V}36712${N}"
ss -tlnp | grep -q ":53 " && agregar_puerto "🔹 DNS: ${V}53${N}"
ss -tlnp | grep -q ":7300" && agregar_puerto "🔹 BadVPN: ${V}7300${N}"
ss -tlnp | grep -q ":7200" && agregar_puerto "🔹 BadVPN: ${V}7200${N}"
if [ -f /etc/hcr/config ]; then
    source /etc/hcr/config
    ss -tlnp | grep -q ":$P_INJ " && agregar_puerto "🔹 HCR: ${V}$P_INJ${N}"
fi
[ -z "$STR_PORTS" ] && STR_PORTS="🔹 ${R}Sin puertos abiertos actualmente${N}"
echo -e "${C}=========>>>>> 🌿 Script Osmaca 🌿 <<<<<=========${N}"
echo -e "${V}$IP_VPS${N}"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " 🔹 S.O: ${C}$S_OS${N}  🔹 Base:${C}$S_ARCH${N}  🔹 CPU's:${C}$S_CPU${N}"
echo -e " 🔹 IP:  ${V}$IP_VPS${N}  🔹 FECHA: ${A}$FECHA_ACT${N}"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " Key: ${V}Verified [ Sabana de Torres © ] (V5.7)${N}"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " ${M}🟢 PUERTOS ACTIVOS:${N}"
echo -e " $STR_PORTS"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " 🔹 TOTAL: ${C}${MEM_TOTAL}M${N} 🔹 M|LIBRE: ${C}${LIBRE_RAM}M${N} 🔹 EN USO: ${C}${MEM_USADA}M${N}"
echo -e " 🔹 U/RAM: ${A}${PORCENT_RAM}%${N}"
echo -e "${A}────────────────────────────────────────────────────────${N}"
}
menu_usuarios() {
while true; do
clear
echo -e "${C}================================================${N}"
echo -e "       ${A}⚜️  CREADOR DE CUENTAS TIPO ⚜️${N}"
echo -e "       ${C}MENU DE CREACION DE USUARIOS${N}"
echo -e "${C}================================================${N}"
echo -e " [1] ➕ CREAR USUARIO SSH"
echo -e " [2] 🗑️  ELIMINAR USUARIO"
echo -e " [3] 👥 VER LISTADO DE USUARIOS"
echo -e " [0] ↩️  VOLVER"
read -p " ► Opcion: " op_user
case $op_user in
1)
clear
echo -e "${C}================================================${N}"
echo -e "       ${A}⚜️  CREADOR DE CUENTAS TIPO ⚜️${N}"
echo -e "${C}================================================${N}"
read -p " 👤 Nombre de usuario: " u
read -p " 🔑 Contraseña: " p
read -p " ⏳ Dias de duración: " d
read -p " 📈 Límite de conexiones: " l
useradd -m -s /bin/bash "$u" 2>/dev/null
echo "$u:$p" | chpasswd 2>/dev/null
chage -E $(date -d "+$d days" +%Y-%m-%d) "$u" 2>/dev/null || true
mkdir -p /etc/vps_limites
echo "$l" > "/etc/vps_limites/$u"
if [ ! -f /usr/local/bin/monitor_limites.sh ]; then
cat << 'EOF_MONITOR' > /usr/local/bin/monitor_limites.sh
#!/bin/bash
for user in \$(ls /etc/vps_limites/ 2>/dev/null); do
limite=\$(cat /etc/vps_limites/\$user)
conex=\$(ps -u \$user 2>/dev/null | grep -c sshd)
if [ "\$conex" -gt "\$limite" ]; then
pkill -u \$user sshd
fi
done
EOF_MONITOR
chmod +x /usr/local/bin/monitor_limites.sh
(crontab -l 2>/dev/null | grep -v "monitor_limites.sh"; echo "* * * * * /usr/local/bin/monitor_limites.sh") | crontab -
fi
apt-get install figlet -y >/dev/null 2>&1
clear
echo -e "${C}================================================${N}"
if command -v figlet > /dev/null 2>&1; then
echo -e "${V}$(figlet -c -f slant "$u")${N}"
else
echo -e "${V}     >>> $u <<<     ${N}"
fi
echo -e "${C}* Puertas Activas en su Servidor *${N}"
echo -e "${A}────────────────────────────────────────────────────────${N}"
STR_P=""
ss -tlnp | grep -q ":22 " && STR_P+="🔹 SSH: ${V}22${N}   "
if ss -tlnp | grep -q ":80 "; then
    systemctl is-active --quiet xray && grep -q '"port": 80' /usr/local/etc/xray/config.json 2>/dev/null && STR_P+="🔹 V2RAY: ${V}80${N}   " || STR_P+="🔹 PROXY: ${V}80${N}   "
fi
if ss -tlnp | grep -q ":443 "; then
    systemctl is-active --quiet xray && grep -q '"port": 443' /usr/local/etc/xray/config.json 2>/dev/null && STR_P+="🔹 V2RAY: ${V}443${N}   " || STR_P+="🔹 SSL: ${V}443${N}   "
fi
ss -ulnp | grep -q ":36712" && STR_P+="🔹 UDP: ${V}36712${N}   "
[ -z "$STR_P" ] && STR_P="🔹 ${R}Sin puertos configurados${N}"
echo -e " $STR_P"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " Host/IP-Address : ${V}$IP_VPS${N}"
echo -e " USUARIO : ${V}$u${N}"
echo -e " PASSWD  : ${V}$p${N}"
echo -e " LIMITE  : ${V}$l${N}"
echo -e " VALIDEZ : ${V}$(date -d "+$d days" +%d/%m/%Y)${N}"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " ${R}✓ El servidor desconectará automáticamente al${N}"
echo -e " ${R}  usuario si supera el límite de $l conexiones.${N}"
echo -e "${C}================================================${N}"
read -p " ► Enter para continuar..." ;;
2) read -p " Usuario a eliminar: " u; userdel -r "$u" 2>/dev/null && rm -f /etc/vps_limites/$u && echo -e "${V}Eliminado.${N}" || echo -e "${R}Error.${N}"; read -p "Enter..." ;;
3) awk -F: '$3 >= 1000 && $1 != "nobody" {print " -> " $1}' /etc/passwd; read -p "Enter..." ;;
0) break ;;
esac
done
}
menu_ssl() {
while true; do
clear
echo -e "${A}--- GESTOR DE PROTOCOLO SSL/TLS ---${N}"
echo -e " Estado: $(es stunnel4)"
echo -e "----------------------------------------"
echo -e " ${V}[1]${N} 🟢 Instalar Certificado SSL (Interno 22 -> Externo a elegir)"
echo -e " ${A}[2]${N} ⏸️  Detener SSL"
echo -e " ${R}[3]${N} 🗑️  Desinstalar"
echo -e " ${C}[0]${N} ↩️  Volver"
echo -e "----------------------------------------"
read -p " ► Opcion : " op_ssl
case $op_ssl in
1)
p1=22
read -p " ► Puerto externo SSL a elegir (Ej: 443, 444): " p2; p2=${p2:-443}
apt-get install stunnel4 openssl -y >/dev/null 2>&1
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem -subj "/CN=Sabana/O=VPN/C=CO" >/dev/null 2>&1
echo -e "pid = /var/run/stunnel4.pid\ncert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n[stunnel-custom]\naccept = $p2\nconnect = 127.0.0.1:$p1" > /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null || echo "ENABLED=1" > /etc/default/stunnel4
ufw allow $p2/tcp >/dev/null 2>&1
systemctl restart stunnel4
echo -e "${V}¡SSL instalado y activo en puerto externo $p2!${N}"
read -p "Enter..." ;;
2) systemctl stop stunnel4; echo -e "${A}Detenido.${N}"; read -p "Enter..." ;;
3) systemctl stop stunnel4; apt-get purge stunnel4 -y >/dev/null 2>&1; rm -rf /etc/stunnel/; echo -e "${R}Desinstalado.${N}"; read -p "Enter..." ;;
0) break ;;
esac
done
}
menu_py() {
while true; do
clear
echo -e "${A}--- GESTOR DE PROXY PYTHON ---${N}"
echo -e " Estado: $(es proxypy)"
echo -e "----------------------------------------"
echo -e " ${V}[3]${N} 🟢 WebSocket PRO (Elegir Puerto)"
echo -e " ${A}[4]${N} ⏸️  Detener Proxy"
echo -e " ${R}[5]${N} 🗑️  Desinstalar"
echo -e " ${C}[0]${N} ↩️  Volver"
echo -e "----------------------------------------"
read -p " ► Opcion : " op_py
case $op_py in
3)
read -p " ► Puerto para el WebSocket (Ej: 80): " pt; pt=${pt:-80}
echo -e "${A}Liberando el puerto $pt y preparando Python...${N}"
systemctl stop apache2 nginx dropbear 2>/dev/null
fuser -k $pt/tcp 2>/dev/null
apt-get install python3 -y >/dev/null 2>&1
cat << 'EOF_PY' > /etc/proxy.py
import socket, threading
def c(s):
    try:
        s.recv(1024)
        s.sendall(b"HTTP/1.1 200 Connection Established\r\n\r\n")
        d = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        d.connect(('127.0.0.1', 22))
        def f(x, y):
            try:
                while True:
                    a = x.recv(4096)
                    if not a: break
                    y.sendall(a)
            except: pass
        threading.Thread(target=f, args=(s, d)).start()
        threading.Thread(target=f, args=(d, s)).start()
    except: pass
sv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sv.bind(('0.0.0.0', PUERTO_AQUI))
sv.listen(100)
while True:
    cl, a = sv.accept()
    threading.Thread(target=c, args=(cl,)).start()
EOF_PY
sed -i "s/PUERTO_AQUI/$pt/g" /etc/proxy.py
echo -e "[Unit]\nDescription=Proxy Python WS\n[Service]\nExecStart=/usr/bin/python3 /etc/proxy.py\nRestart=always\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/proxypy.service
systemctl daemon-reload; systemctl enable proxypy >/dev/null 2>&1; systemctl restart proxypy
ufw allow $pt/tcp >/dev/null 2>&1
echo -e "${V}¡WebSocket PRO Activo en el puerto $pt!${N}"
read -p "Enter..." ;;
4) systemctl stop proxypy; echo -e "${A}Detenido.${N}"; read -p "Enter..." ;;
5) systemctl stop proxypy; rm -f /etc/proxy.py /etc/systemd/system/proxypy.service; systemctl daemon-reload; echo -e "${R}Desinstalado.${N}"; read -p "Enter..." ;;
0) break ;;
esac
done
}
menu_udp() {
while true; do
clear
echo -e "${A}--- UDP CUSTOM ---${N}"
echo -e " Estado: $(es udp-custom)"
echo -e "----------------------------------------"
echo -e " ${V}[1]${N} 🟢 Instalar UDP Custom"
echo -e " ${A}[2]${N} ⏸️  Detener UDP"
echo -e " ${R}[3]${N} 🗑️  Desinstalar UDP"
echo -e " ${C}[0]${N} ↩️  Volver"
echo -e "----------------------------------------"
read -p " ► Opcion : " op_udp
case $op_udp in
1)
echo "Instalando servidor UDP Custom..."
apt-get install -y iptables wget >/dev/null 2>&1
wget -q "https://raw.githubusercontent.com/Haris131/UDP-Custom/main/udp-custom-linux-amd64" -O /usr/bin/udp-custom
chmod +x /usr/bin/udp-custom; mkdir -p /root/udp
echo -e "{\n  \"listen\": \":36712\",\n  \"stream_buffer\": 33554432,\n  \"receive_buffer\": 8388608,\n  \"auth\": {\n    \"mode\": \"passwords\"\n  }\n}" > /root/udp/config.json
echo -e "[Unit]\nDescription=UDP Custom\n[Service]\nUser=root\nType=simple\nWorkingDirectory=/root/udp\nExecStart=/usr/bin/udp-custom server -exclude 53,5300,443\nRestart=always\nRestartSec=2\n[Install]\nWantedBy=default.target" > /etc/systemd/system/udp-custom.service
systemctl daemon-reload; systemctl enable udp-custom >/dev/null 2>&1; systemctl restart udp-custom
iptables -t nat -D PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null
iptables -t nat -A PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712
echo -e "${V}¡UDP Custom Instalado y Activo (Puerto 36712)!${N}"
read -p "Enter..." ;;
2) systemctl stop udp-custom; echo -e "${A}Detenido.${N}"; read -p "Enter..." ;;
3) systemctl stop udp-custom; rm -rf /usr/bin/udp-custom /root/udp /etc/systemd/system/udp-custom.service; systemctl daemon-reload; iptables -t nat -D PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null; echo -e "${R}Desinstalado.${N}"; read -p "Enter..." ;;
0) break ;;
esac
done
}
menu_badvpn() {
while true; do
clear
P_BAD72=$(ss -tlnp | grep -q ":7200" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
P_BAD73=$(ss -tlnp | grep -q ":7300" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
echo -e "${A}--- BADVPN UDP (VIDEOLLAMADAS) ---${N}"
echo -e " Estado: 7200 $P_BAD72 | 7300 $P_BAD73"
echo -e "----------------------------------------"
echo -e " ${V}[1]${N} 🟢 Instalar / Iniciar BadVPN"
echo -e " ${A}[2]${N} ⏸️  Detener BadVPN"
echo -e " ${R}[3]${N} 🗑️  Desinstalar BadVPN"
echo -e " ${C}[0]${N} ↩️  Volver"
echo -e "----------------------------------------"
read -p " ► Opcion : " op_badvpn
case $op_badvpn in
1)
clear
echo -e "${C}=== SISTEMA INTELIGENTE BADVPN ===${N}"
echo -e "Buscando binario compatible con tu sistema...\n"
systemctl stop badvpn7200 2>/dev/null
systemctl stop badvpn7300 2>/dev/null
killall badvpn-udpgw 2>/dev/null

func_test_binario() {
    if [ ! -f /usr/bin/badvpn-udpgw ]; then return 1; fi
    chmod +x /usr/bin/badvpn-udpgw 2>/dev/null
    /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 >/dev/null 2>&1 &
    TEST_PID=$!
    sleep 2
    if ss -tlnp | grep -q ":7300"; then
        kill -9 $TEST_PID 2>/dev/null
        return 0
    else
        kill -9 $TEST_PID 2>/dev/null
        return 1
    fi
}

BIN_OK=0
echo -e "1) Probando desde Repositorio Oficial..."
apt-get update -y >/dev/null 2>&1
apt-get install -y badvpn >/dev/null 2>&1
if func_test_binario; then
    echo -e "${V}[✓] Binario Oficial Compatible.${N}"
    BIN_OK=1
else
    echo -e "2) Oficial falló. Probando Binario Estático #1..."
    rm -f /usr/bin/badvpn-udpgw
    wget -q -O /usr/bin/badvpn-udpgw --no-check-certificate "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64"
    if func_test_binario; then
        echo -e "${V}[✓] Binario #1 Compatible.${N}"
        BIN_OK=1
    else
        echo -e "3) Binario #1 falló. Probando Binario Estático #2..."
        rm -f /usr/bin/badvpn-udpgw
        wget -q -O /usr/bin/badvpn-udpgw --no-check-certificate "https://raw.githubusercontent.com/rudi9999/ADMRufu/main/Plugins/badvpn-udpgw64"
        if func_test_binario; then
            echo -e "${V}[✓] Binario #2 Compatible.${N}"
            BIN_OK=1
        fi
    fi
fi

if [ $BIN_OK -eq 1 ]; then
    echo -e "\n${V}Configurando el arranque automatico...${N}"
    echo -e "[Unit]\nDescription=BadVPN UDPGW 7300\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10\nRestart=always\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/badvpn7300.service
    echo -e "[Unit]\nDescription=BadVPN UDPGW 7200\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 10\nRestart=always\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/badvpn7200.service
    systemctl daemon-reload
    systemctl enable badvpn7300 >/dev/null 2>&1
    systemctl enable badvpn7200 >/dev/null 2>&1
    systemctl start badvpn7300 >/dev/null 2>&1
    systemctl start badvpn7200 >/dev/null 2>&1
    sleep 2
    if ss -tlnp | grep -q ":7300"; then
        echo -e "${V}¡BadVPN activado exitosamente en los puertos 7200 y 7300!${N}"
    else
        echo -e "${R}Fallo al encender el servicio. Reinicie su VPS.${N}"
    fi
else
    echo -e "\n${R}ERROR FATAL: Ningún binario funcionó en tu Sistema.${N}"
fi
read -p " ► Enter para continuar..." ;;
2)
systemctl stop badvpn7300 2>/dev/null
systemctl stop badvpn7200 2>/dev/null
killall badvpn-udpgw 2>/dev/null
echo -e "${A}BadVPN Detenido.${N}"; read -p "Enter..." ;;
3)
systemctl stop badvpn7300 2>/dev/null
systemctl stop badvpn7200 2>/dev/null
systemctl disable badvpn7300 2>/dev/null
systemctl disable badvpn7200 2>/dev/null
rm -f /etc/systemd/system/badvpn*.service
rm -f /usr/bin/badvpn-udpgw
systemctl daemon-reload
killall badvpn-udpgw 2>/dev/null
echo -e "${R}BadVPN Desinstalado.${N}"; read -p "Enter..." ;;
0) break ;;
esac
done
}
menu_v2ray() {
while true; do
clear
P_V2=$(systemctl is-active --quiet xray && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
echo -e "${C}================================================${N}"
echo -e "     ${A}⚜️  V2RAY / XRAY MANAGER (WebSocket) ⚜️${N}"
echo -e "${C}================================================${N}"
echo -e " Estado actual: $P_V2"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " ${V}[1]${N} 🟢 Instalar V2Ray/Xray (Modo WebSocket)"
echo -e " ${A}[2]${N} ➕ Generar Nuevo Usuario (UUID)"
echo -e " ${C}[3]${N} ⚙️  Modificar Puerto de Conexión"
echo -e " ${V}[4]${N} 👁️  Ver mis Datos y Link de Conexión"
echo -e " ${R}[5]${N} 🗑️  Desinstalar Todo"
echo -e " ${C}[0]${N} ↩️  Volver al Menú Principal"
echo -e "${A}────────────────────────────────────────────────────────${N}"
read -p " ► Opcion : " op_v2
case $op_v2 in
1)
    clear
    echo -e "${C}=== INSTALANDO NUCLEO XRAY (V2RAY) ===${N}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y jq uuid-runtime curl psmisc lsof openssl >/dev/null 2>&1
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    
    echo -e "\n${C}=== CONFIGURANDO CONEXIÓN WEBSOCKET ===${N}"
    read -p " ► Puerto a usar (Recomendado: 443): " pt_v2; pt_v2=${pt_v2:-443}
    read -p " ► Tu Dominio del Servidor (Ej: movistar.zex.digital): " dom_v2; dom_v2=${dom_v2:-$IP_VPS}
    UUID=$(uuidgen)
    
    echo -e "\n${A}Realizando escaneo a fondo y liberando el puerto $pt_v2...${N}"
    systemctl stop proxypy stunnel4 apache2 nginx dropbear hcr-server 2>/dev/null
    fuser -k -9 $pt_v2/tcp >/dev/null 2>&1
    lsof -ti tcp:$pt_v2 | xargs kill -9 2>/dev/null
    sleep 2
    
    echo -e "${A}Generando Certificado de Seguridad (TLS) interno...${N}"
    mkdir -p /usr/local/etc/xray
    openssl req -newkey rsa:2048 -nodes -keyout /usr/local/etc/xray/private.key -x509 -days 3650 -out /usr/local/etc/xray/cert.crt -subj "/C=CO/ST=Santander/L=Sabana/O=Osmaca/CN=$dom_v2" >/dev/null 2>&1
    chmod 644 /usr/local/etc/xray/private.key /usr/local/etc/xray/cert.crt
    
    cat <<EOF > /usr/local/etc/xray/config.json
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": $pt_v2,
    "listen": "0.0.0.0",
    "protocol": "vmess",
    "settings": {
      "clients": [ { "id": "$UUID", "alterId": 0 } ]
    },
    "streamSettings": {
      "network": "ws",
      "security": "tls",
      "tlsSettings": {
        "certificates": [
          {
            "certificateFile": "/usr/local/etc/xray/cert.crt",
            "keyFile": "/usr/local/etc/xray/private.key"
          }
        ]
      },
      "wsSettings": { "path": "/osmaca" }
    }
  }],
  "outbounds": [{ "protocol": "freedom", "settings": {} }]
}
EOF
    echo "$dom_v2" > /usr/local/etc/xray/dominio.txt
    echo "$pt_v2" > /usr/local/etc/xray/puerto.txt
    echo "$UUID" > /usr/local/etc/xray/uuid.txt
    
    systemctl restart xray
    systemctl enable xray >/dev/null 2>&1
    ufw allow $pt_v2/tcp >/dev/null 2>&1
    
    sleep 2
    if systemctl is-active --quiet xray; then
        echo -e "\n${V}¡V2Ray Instalado y Activo con TLS!${N}"
    else
        echo -e "\n${R}ERROR: V2Ray no pudo iniciar.${N}"
    fi
    read -p " ► Enter para continuar..." ;;
2)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e "${R}V2Ray no está instalado. Instálalo primero (Opción 1).${N}"; read -p "Enter..."; continue
    fi
    UUID=$(uuidgen)
    sed -i -E "s/\"id\": \".*\"/\"id\": \"$UUID\"/" /usr/local/etc/xray/config.json
    echo "$UUID" > /usr/local/etc/xray/uuid.txt
    systemctl restart xray
    echo -e "${V}¡Nuevo UUID generado y configurado exitosamente!${N}"
    echo -e "Nuevo UUID: $UUID"
    read -p " ► Enter para continuar..." ;;
3)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e "${R}V2Ray no está instalado. Instálalo primero (Opción 1).${N}"; read -p "Enter..."; continue
    fi
    pt_actual=$(cat /usr/local/etc/xray/puerto.txt)
    echo -e "\n${C}=== MODIFICAR PUERTO V2RAY ===${N}"
    echo -e " 🔹 Puerto actual: ${V}$pt_actual${N}"
    read -p " ► Ingresa el NUEVO puerto a usar (Ej: 80, 443): " pt_nuevo
    if [ -z "$pt_nuevo" ]; then
        echo -e "${R}Cancelado.${N}"; read -p "Enter..."; continue
    fi
    
    echo -e "\n${A}Liberando el nuevo puerto $pt_nuevo para evitar conflictos...${N}"
    systemctl stop proxypy stunnel4 apache2 nginx dropbear hcr-server 2>/dev/null
    fuser -k -9 $pt_nuevo/tcp >/dev/null 2>&1
    lsof -ti tcp:$pt_nuevo | xargs kill -9 2>/dev/null
    
    sed -i -E "s/\"port\": [0-9]+/\"port\": $pt_nuevo/" /usr/local/etc/xray/config.json
    echo "$pt_nuevo" > /usr/local/etc/xray/puerto.txt
    ufw allow $pt_nuevo/tcp >/dev/null 2>&1
    systemctl restart xray
    
    sleep 2
    if systemctl is-active --quiet xray; then
        echo -e "\n${V}¡Puerto modificado exitosamente al $pt_nuevo!${N}"
    else
        echo -e "\n${R}ERROR: El puerto $pt_nuevo está bloqueado por el sistema. Intenta con otro.${N}"
    fi
    read -p " ► Enter para continuar..." ;;
4)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e "${R}V2Ray no está instalado.${N}"; read -p "Enter..."; continue
    fi
    dom_v2=$(cat /usr/local/etc/xray/dominio.txt)
    pt_v2=$(cat /usr/local/etc/xray/puerto.txt)
    UUID=$(cat /usr/local/etc/xray/uuid.txt)
    
    cat <<EOF > /tmp/vmess.json
{
  "v": "2",
  "ps": "Osmaca-V2Ray",
  "add": "$dom_v2",
  "port": "$pt_v2",
  "id": "$UUID",
  "aid": "0",
  "scy": "auto",
  "net": "ws",
  "type": "none",
  "host": "$dom_v2",
  "path": "/osmaca",
  "tls": "tls",
  "sni": "$dom_v2",
  "alpn": ""
}
EOF
    VMESS_BASE64=$(cat /tmp/vmess.json | base64 -w 0)
    VMESS_LINK="vmess://$VMESS_BASE64"
    
    clear
    echo -e "${C}=== TUS DATOS DE V2RAY ===${N}"
    echo -e " 🔹 Dominio Server : ${V}$dom_v2${N}"
    echo -e " 🔹 Puerto         : ${V}$pt_v2${N}"
    echo -e " 🔹 UUID           : ${A}$UUID${N}"
    echo -e " 🔹 Protocolo      : WebSocket (WS)"
    echo -e " 🔹 Path           : /osmaca"
    echo -e " 🔹 Seguridad      : TLS (Activada)"
    echo -e "${C}================================================${N}"
    echo -e " 🔗 ${V}LINK VMESS PARA IMPORTAR (Cópialo todo):${N}\n"
    echo -e "${A}$VMESS_LINK${N}\n"
    read -p " ► Enter para continuar..." ;;
5)
    systemctl stop xray >/dev/null 2>&1
    systemctl disable xray >/dev/null 2>&1
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove >/dev/null 2>&1
    rm -rf /usr/local/etc/xray
    echo -e "${R}V2Ray / Xray Desinstalado completamente.${N}"
    read -p " ► Enter para continuar..." ;;
0) break ;;
esac
done
}

# --------- NUEVO MODULO HCR SERVER (OPCION 37) ---------
menu_hcr() {
while true; do
    clear
    ESTADO=$(systemctl is-active --quiet hcr-server && echo -e "${V}Activo${N}" || echo -e "${R}Inactivo${N}")
    
    if [ -f /etc/hcr/config ]; then
        source /etc/hcr/config
    else
        P_INJ="8080"
        P_DEST="22"
        MODO="Plain"
        MAX_FILE="16384"
    fi

    echo -e "${C}================================================${N}"
    echo -e "       MENU HCR SERVER - Estado: $ESTADO"
    echo -e "${C}================================================${N}"
    echo -e " ${V}[1]${N} ⚙️ Puerto Inyección [$P_INJ]  ${V}[2]${N} ⚙️ Puerto Destino   [$P_DEST]"
    echo -e " ${V}[3]${N} 🛡️ Modo             [$MODO]  ${V}[4]${N} 📦 Max On File      [$MAX_FILE]"
    echo -e " ${A}[5]${N} 🟢 Iniciar/Detener           ${R}[6]${N} 🗑️ Desinstalar HCR"
    echo -e " ${C}[7]${N} 👁️ Ver Logs (Real-time)"
    echo -e " ${C}[0]${N} ↩️ REGRESAR"
    echo -e "${C}================================================${N}"
    read -p " ► Opcion : " op_hcr
    
    case $op_hcr in
        1)
            read -p " Nuevo Puerto Inyección: " nuevo_inj
            if [ -n "$nuevo_inj" ]; then
                sed -i "s/P_INJ=.*/P_INJ=\"$nuevo_inj\"/" /etc/hcr/config
                systemctl restart hcr-server
                echo -e "${V}Puerto Inyección actualizado a $nuevo_inj.${N}"; sleep 1
            fi
            ;;
        2)
            read -p " Nuevo Puerto Destino: " nuevo_dest
            if [ -n "$nuevo_dest" ]; then
                sed -i "s/P_DEST=.*/P_DEST=\"$nuevo_dest\"/" /etc/hcr/config
                systemctl restart hcr-server
                echo -e "${V}Puerto Destino actualizado a $nuevo_dest.${N}"; sleep 1
            fi
            ;;
        3)
            if [ "$MODO" == "Plain" ]; then
                sed -i "s/MODO=.*/MODO=\"TLS\"/" /etc/hcr/config
                sed -i "s/-tls=false/-tls=true/" /etc/systemd/system/hcr-server.service
                if [ ! -f /etc/hcr/cert.pem ]; then
                    echo -e "${A}Generando certificado TLS...${N}"
                    openssl req -newkey rsa:2048 -nodes -keyout /etc/hcr/key.pem -x509 -days 3650 -out /etc/hcr/cert.pem -subj "/C=CO/O=Osmaca/CN=hcr" >/dev/null 2>&1
                fi
            else
                sed -i "s/MODO=.*/MODO=\"Plain\"/" /etc/hcr/config
                sed -i "s/-tls=true/-tls=false/" /etc/systemd/system/hcr-server.service
            fi
            systemctl daemon-reload
            echo -e "${V}Modo cambiado. Reiniciando HCR...${N}"; systemctl restart hcr-server; sleep 1
            ;;
        4)
            read -p " Nuevo Max On File: " nuevo_max
            if [ -n "$nuevo_max" ]; then
                sed -i "s/MAX_FILE=.*/MAX_FILE=\"$nuevo_max\"/" /etc/hcr/config
                sed -i "s/LimitNOFILE=.*/LimitNOFILE=$nuevo_max/" /etc/systemd/system/hcr-server.service
                systemctl daemon-reload; systemctl restart hcr-server
                echo -e "${V}Límite actualizado.${N}"; sleep 1
            fi
            ;;
        5)
            if systemctl is-active --quiet hcr-server; then
                systemctl stop hcr-server
                echo -e "${A}Servidor HCR Detenido.${N}"; sleep 1
            else
                if [ ! -f /etc/hcr/hcr-server ]; then
                    instalar_hcr
                else
                    source /etc/hcr/config
                    fuser -k -9 $P_INJ/tcp >/dev/null 2>&1
                    lsof -ti tcp:$P_INJ | xargs kill -9 2>/dev/null
                    systemctl restart hcr-server
                    echo -e "${V}Servidor HCR Iniciado.${N}"; sleep 1
                fi
            fi
            ;;
        6)
            systemctl stop hcr-server 2>/dev/null
            systemctl disable hcr-server 2>/dev/null
            rm -rf /etc/hcr /etc/systemd/system/hcr-server.service
            systemctl daemon-reload
            echo -e "${R}HCR Desinstalado.${N}"; sleep 1
            ;;
        7)
            echo -e "${A}Presiona CTRL+C para salir de los logs${N}"
            journalctl -u hcr-server -f
            ;;
        0) break ;;
    esac
done
}

instalar_hcr() {
    clear
    echo -e "${A}========= INSTALACION DE HCR SERVER =========${N}"
    echo -e "${C}Descargando binario oficial de HCR...${N}"
    mkdir -p /etc/hcr
    
    read -p " Puerto de Inyección [Default 8080]: " p_inj
    p_inj=${p_inj:-8080}
    
    read -p " Puerto de redireccionamiento [Default 22]: " p_dest
    p_dest=${p_dest:-22}
    
    echo -e "\n Modo de transporte:"
    echo -e " [1] Plain (Recomendado)"
    echo -e " [2] TLS (Generará certificado)"
    read -p " Seleccione opción [Default 1]: " op_m
    op_m=${op_m:-1}
    
    if [ "$op_m" == "2" ]; then
        MODO="TLS"
        TLS_FLAG="true"
        echo -e "\n${A}Generando certificado TLS...${N}"
        apt-get install openssl -y >/dev/null 2>&1
        openssl req -newkey rsa:2048 -nodes -keyout /etc/hcr/key.pem -x509 -days 3650 -out /etc/hcr/cert.pem -subj "/C=CO/O=Osmaca/CN=hcr" >/dev/null 2>&1
    else
        MODO="Plain"
        TLS_FLAG="false"
    fi
    
    echo -e "P_INJ=\"$p_inj\"\nP_DEST=\"$p_dest\"\nMODO=\"$MODO\"\nMAX_FILE=\"16384\"" > /etc/hcr/config

    wget -qO /etc/hcr/hcr-server "https://github.com/hiddify/hiddify-config/raw/main/hcr/hcr-server"
    if [ ! -f /etc/hcr/hcr-server ]; then
         wget -qO /etc/hcr/hcr-server "https://github.com/chukkteam/hcr-server/releases/download/v1.0/hcr-server-linux-amd64"
    fi
    
    chmod +x /etc/hcr/hcr-server
    apt-get install lsof -y >/dev/null 2>&1
    
    echo -e "[Unit]\nDescription=HCR Server Custom\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/etc/hcr/hcr-server -listen=:$p_inj -target=127.0.0.1:$p_dest -tls=$TLS_FLAG -cert=/etc/hcr/cert.pem -key=/etc/hcr/key.pem\nRestart=always\nLimitNOFILE=16384\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/hcr-server.service
    
    fuser -k -9 $p_inj/tcp >/dev/null 2>&1
    lsof -ti tcp:$p_inj | xargs kill -9 2>/dev/null
    
    systemctl daemon-reload
    systemctl enable hcr-server >/dev/null 2>&1
    systemctl start hcr-server
    ufw allow $p_inj/tcp >/dev/null 2>&1
    
    echo -e "\n${V}Instalación completada exitosamente.${N}"
    sleep 2
}
# --------- FIN MODULO HCR SERVER ---------

menu_protocolos() {
while true; do
clear
P22=$(ep 22); P80=$(es proxypy); PSSL=$(es stunnel4); PPY=$(es proxypy); PUDP=$(es udp-custom); PFB=$(es fail2ban)
PBAD=$(ss -tlnp | grep -q ":7300" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PV2=$(systemctl is-active --quiet xray && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PHCR=$(es hcr-server)
echo -e "${A}🍄 INSTALACION DE PROTOCOLOS ( Script Osmaca ) 🍄${N}"
echo -e "--------------------------------------------------------"
echo -e " ${C}[1]${N} OpenSSH       $P22    ${C}[11]${N} PSIPHON SERVER ${R}[OFF]${N}"
echo -e " ${C}[2]${N} DROPBEAR      ${R}[OFF]${N}    ${C}[12]${N} TCP DNS        ${A}(#BETA)${N}"
echo -e " ${C}[3]${N} OPENVPN       ${R}[OFF]${N}    ${C}[13]${N} WEBMIN         ${R}[OFF]${N}"
echo -e " ${C}[4]${N} SSL/TLS       $PSSL    ${C}[14]${N} SLOWDNS        ${R}[OFF]${N}"
echo -e " ${C}[5]${N} SHADOWSOCKS-R ${R}[OFF]${N}    ${C}[15]${N} SSL->PYTHON    ${R}[OFF]${N}"
echo -e " ${C}[6]${N} SQUID         ${R}[OFF]${N}    ${C}[16]${N} SSLH MULTIPLEX ${R}[OFF]${N}"
echo -e " ${C}[7]${N} PROXY PYTHON  $PPY    ${C}[17]${N} OVER WEBSOCKET ${A}(#BETA)${N}"
echo -e " ${C}[8]${N} V2RAY MANAGER $PV2    ${C}[18]${N} SOCKS5         ${A}(#BETA)${N}"
echo -e " ${C}[9]${N} CFA ( CLASH ) ${R}[OFF]${N}    ${C}[19]${N} Protocolos UDP $PUDP"
echo -e " ${C}[10]${N} TROJAN-GO     ${R}[OFF]${N}    ${C}[20]${N} ${C}FUNCIONES EN DISEÑO!${N}"
echo -e " "
echo -e "${A}🍄 INSTALACION DE HERRAMIENTAS Y SERVICIOS 🍄${N}"
echo -e "--------------------------------------------------------"
echo -e " ${C}[21]${N} BLOCK TORRENT        ${C}[22]${N} BadVPN         $PBAD"
echo -e " ${C}[23]${N} TCP (BBR|Plus) ${R}[OFF]${N} ${C}[24]${N} FAILBAN        $PFB"
echo -e " ${C}[25]${N} ARCHIVO ONLINE ${V}[81]${N}  ${C}[26]${N} UP|DOWN SpeedTest"
echo -e " ${C}[27]${N} DETALLES DEL VPS     ${C}[28]${N} BLOCK ADS      ${R}[OFF]${N}"
echo -e " ${C}[29]${N} DNS CUSTOM (NETFLIX) ${C}[30]${N} HERRAMIENTAS EXTRAS"
echo -e " ${C}[31]${N} REINICIAR SERVICIOS  ${C}[32]${N} Brook Server   ${R}[OFF]${N}"
echo -e " ${C}[33]${N} FIREWALL (IPTABLES)  ${C}[34]${N} Enable/Change PASSWD ROOT"
echo -e " ${C}[35]${N} AToken [APP's] ${R}[OFF]${N} ${C}[36]${N} BHTTP [APP's]  ${R}[OFF]${N}"
echo -e " ${C}[37]${N} HCR [HTTP C.]  $PHCR ${C}[0]${N}  ${R}[ REGRESAR ]${N}"
echo -e "--------------------------------------------------------"
read -p " ► Opcion : " op_inst
case $op_inst in
4) menu_ssl ;;
7) menu_py ;;
8) menu_v2ray ;;
19) menu_udp ;;
21) iptables -A FORWARD -m string --string "BitTorrent" --algo bm -j DROP; echo "Bloqueado"; read -p "Enter..." ;;
22) menu_badvpn ;;
24) apt install fail2ban -y >/dev/null 2>&1; systemctl enable fail2ban >/dev/null 2>&1; systemctl start fail2ban; echo "Listo"; read -p "Enter..." ;;
26) curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -; read -p "Enter..." ;;
27) info_sistema; read -p "Enter..." ;;
31) systemctl restart ssh stunnel4 proxypy udp-custom fail2ban xray hcr-server >/dev/null 2>&1; echo "Reiniciado"; read -p "Enter..." ;;
33) ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 8080/tcp; ufw allow 36712/udp; ufw allow 7200/udp; ufw allow 7300/udp; ufw --force enable; echo "Puertos Abiertos"; read -p "Enter..." ;;
34) passwd root; read -p "Enter..." ;;
37) menu_hcr ;;
0) break ;;
*) echo -e "${R}Inválido${N}"; sleep 1 ;;
esac
done
}
while true; do
clear
info_sistema
echo -e " ${V}[01]${N} ⇨ CONTROL USUARIOS (SSH/SSL/VMESS)"
echo -e " ${V}[02]${N} ⇨ [!] OPTIMIZAR VPS      [${R}OFF${N}]"
echo -e " ${V}[03]${N} ⇨ CONTADOR ONLINE USERS  [${R}OFF${N}]"
echo -e " ${V}[04]${N} ⇨ AUTOINICIAR SCRIPT     [${R}OFF${N}]"
echo -e " ${V}[05]${N} ⇨ INSTALADOR DE PROTOCOLOS"
echo -e "${A}────────────────────────────────────────────────────────${N}"
echo -e " ${V}[06]${N} ⇨ [!] UPDATE / REMOVE  |  ${V}[0]${N} ⇨ [ SALIR ]"
echo -e "${A}────────────────────────────────────────────────────────${N}"
read -p " ► Opcion : " opcion
case $opcion in
1) menu_usuarios ;;
2) clear; ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 8080/tcp; ufw allow 36712/udp; ufw allow 7200/udp; ufw allow 7300/udp; ufw --force enable; echo -e "${V}Firewall Activo.${N}"; read -p "Enter..." ;;
3|4|5|6) menu_protocolos ;;
0) exit 0 ;;
esac
done
