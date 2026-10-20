#!/bin/bash

# ==========================================
# CEREBRO DE COLORES EXTENDIDOS 256 (NEÓN PURO MÁXIMO)
# ==========================================
# Colores por defecto (Paleta 256: Cyan 51, Verde 46, Amarillo 226, Rojo 196)
C='\033[38;5;51m'; V='\033[38;5;46m'; A='\033[38;5;226m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;201m'; W='\033[38;5;231m'

# Si el usuario ya eligió un tema antes, el script lo lee y aplica los colores
if [ -f /etc/zeroday_tema.conf ]; then
    source /etc/zeroday_tema.conf
fi

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
    local texto_plano=$(echo -e "$1" | sed -r 's/\x1B\[[0-9;]*[mK]//g' | sed 's/🔹//g')
    local largo=${#texto_plano}
    local espacios=$(( 18 - largo ))
    [ $espacios -lt 2 ] && espacios=2
    local pad=$(printf '%*s' "$espacios" "")

    if [ $C_PORT -eq 0 ]; then
        [ -n "$STR_PORTS" ] && STR_PORTS+="\n "
        STR_PORTS+="${W}$1${N}${pad}"
        C_PORT=1
    else
        STR_PORTS+="${W}$1${N}"
        C_PORT=0
    fi
}

ss -tlnp | grep -q ":22 " && agregar_puerto "🔹 SSH: ${V}22${N}"

# V2RAY Dinámico
if [ -f /usr/local/etc/xray/puerto.txt ]; then
    PT_V2=$(cat /usr/local/etc/xray/puerto.txt)
    if ss -tlnp | grep -q ":$PT_V2 "; then
        agregar_puerto "🔹 V2RAY: ${V}$PT_V2${N}"
    fi
fi

# SHADOWSOCKS-R Dinámico
if [ -f /etc/ssr/puerto.txt ]; then
    PT_SSR=$(cat /etc/ssr/puerto.txt)
    if ss -tlnp | grep -q ":$PT_SSR "; then
        agregar_puerto "🔹 SSR: ${V}$PT_SSR${N}"
    fi
fi

# PROXY PYTHON Dinámico
if [ -f /etc/proxy.py ]; then
    PT_PY=$(grep "bind" /etc/proxy.py | awk -F',' '{print $2}' | tr -d ' )')
    if [ -n "$PT_PY" ] && ss -tlnp | grep -q ":$PT_PY "; then
         agregar_puerto "🔹 PROXY: ${V}$PT_PY${N}"
    fi
fi

# SSL STUNNEL Dinámico
if [ -f /etc/stunnel/stunnel.conf ]; then
    for p_ssl in $(grep '^accept' /etc/stunnel/stunnel.conf | awk -F'=' '{print $2}' | tr -d ' '); do
        if ss -tlnp | grep -q ":$p_ssl "; then
            agregar_puerto "🔹 SSL: ${V}$p_ssl${N}"
        fi
    done
fi

ss -ulnp | grep -q ":36712 " && agregar_puerto "🔹 UDP: ${V}36712${N}"
ss -ulnp | grep -q ":5300 " && agregar_puerto "🔹 SlowDNS: ${V}5300${N}"
ss -tlnp | grep -q ":7300" && agregar_puerto "🔹 BadVPN: ${V}7300${N}"
ss -tlnp | grep -q ":7200" && agregar_puerto "🔹 BadVPN: ${V}7200${N}"

if [ -f /etc/hcr/config ]; then
    source /etc/hcr/config
    if ss -tlnp | grep -qw "$P_INJ"; then
        agregar_puerto "🔹 HCR: ${V}$P_INJ${N}"
    else
        agregar_puerto "🔹 HCR: ${R}CERRADO ($P_INJ)${N}"
    fi
fi

[ -z "$STR_PORTS" ] && STR_PORTS="🔹  ${R}Sin puertos abiertos actualmente   ${N}"
echo -e "${C}=========>>>>> 🌿 Script ZeroDay 🌿 <<<<<=========   ${N}"
echo -e " ${V}$IP_VPS  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}🔹 S.O:  ${N}${V}$S_OS${N}  ${W}🔹 Base:  ${N}${V}$S_ARCH${N}  ${W}🔹 CPU's:  ${N}${V}$S_CPU  ${N}"
echo -e " ${W}🔹 IP:  ${N}${V}$IP_VPS${N}  ${W}🔹 FECHA:  ${N}${A}$FECHA_ACT  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}Key: ${V}Verified [ ZeroDay © ] (V5.9)  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${M}🟢 PUERTOS ACTIVOS:   ${N}"
echo -e " $STR_PORTS"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}🔹 TOTAL:  ${N}${A}${MEM_TOTAL}M${N} ${W}🔹 M|LIBRE:  ${N}${V}${LIBRE_RAM}M${N} ${W}🔹 EN USO:  ${N}${R}${MEM_USADA}M  ${N}"
echo -e " ${W}🔹 U/RAM:  ${N}${M}${PORCENT_RAM}%  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
}

# ==========================================
# MOTOR DE VERIFICACIÓN ONLINE CON CONTADOR
# ==========================================
ver_usuarios_online() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "       ${A}📡 MONITOREO DE USUARIOS ONLINE 📡   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}Escaneando conexiones y límites en tiempo real...  ${N}"
    echo -e "${C}────────────────────────────────────────────────────────${N}"
    
    USERS=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
    
    if [ -z "$USERS" ]; then
        echo -e " ${R}No hay usuarios creados en el sistema.  ${N}"
    else
        for user in $USERS; do
            if [ -f "/etc/vps_limites/$user" ]; then
                limite=$(cat /etc/vps_limites/$user)
            else
                limite="?"
            fi
            
            conex=$(ps -u "$user" 2>/dev/null | grep -c sshd)
            
            if [ "$conex" -gt 0 ]; then
                INFO_CON=$(who | grep "^$user " | head -n 1)
                if [ -n "$INFO_CON" ]; then
                    HORA=$(echo "$INFO_CON" | awk '{print $4}')
                    IP_CLI=$(echo "$INFO_CON" | awk '{print $5}' | tr -d '()')
                else
                    HORA="Activo"
                    IP_CLI="Oculta"
                fi
                echo -e " 👤  ${W}$user  ${N}-> ${V}[ ONLINE ]  ${N}${W}(Conex: $conex/$limite | Desde: $HORA | IP: $IP_CLI)   ${N}"
            else
                ULTIMA=$(last -n 1 "$user" | head -n 1)
                if [[ "$ULTIMA" == *"wtmp begins"* ]] || [[ -z "$ULTIMA" ]]; then
                    echo -e " 👤  ${W}$user  ${N}-> ${R}[ OFFLINE ]  ${N}${W}(Límite: $limite | Nunca se ha conectado)   ${N}"
                else
                    FECHA_OFF=$(echo "$ULTIMA" | awk '{print $4, $5, $6}')
                    echo -e " 👤  ${W}$user  ${N}-> ${R}[ OFFLINE ]  ${N}${W}(Límite: $limite | Última vez: $FECHA_OFF)   ${N}"
                fi
            fi
        done
    fi
    echo -e "${C}────────────────────────────────────────────────────────${N}"
    echo -ne " ${W}► Enter para continuar...   ${N}"; read
}

menu_usuarios() {
while true; do
clear
echo -e "${C}================================================${N}"
echo -e "       ${A}⚜️  CREADOR DE CUENTAS TIPO ⚜️   ${N}"
echo -e "       ${W}MENU DE CREACION DE USUARIOS   ${N}"
echo -e "${C}================================================${N}"
echo -e " ${C}[1]${N} ${W}➕ CREAR USUARIO SSH   ${N}"
echo -e " ${C}[2]${N} ${W}🗑️  ELIMINAR USUARIO   ${N}"
echo -e " ${C}[3]${N} ${W}👥 VER LISTADO DE USUARIOS   ${N}"
echo -e " ${V}[4]${N} ${W}📡 MONITOREO DE USUARIOS ONLINE   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  VOLVER   ${N}"
echo -ne " ${W}► Opcion:   ${N}"; read op_user
case $op_user in
1)
clear
echo -e "${C}================================================${N}"
echo -e "       ${A}⚜️  CREADOR DE CUENTAS TIPO ⚜️   ${N}"
echo -e "${C}================================================${N}"
echo -ne " ${W}► Nombre de usuario:   ${N}"; read u
if [ -z "$u" ]; then
    echo -e "\n ${R}[!] El nombre de usuario no puede estar vacío.   ${N}"
    sleep 1
    continue
fi
echo -ne " ${W}► Contraseña:   ${N}"; read p
p=${p:-12345}
echo -ne " ${W}► Dias de duración [Default: 30]:   ${N}"; read d
d=${d:-30}
echo -ne " ${W}► Límite de conexiones [Default: 1]:   ${N}"; read l
l=${l:-1}

id "$u" >/dev/null 2>&1 || useradd -m -s /bin/bash "$u" 2>/dev/null
echo "$u:$p" | chpasswd 2>/dev/null
chage -E $(date -d "+$d days" +%Y-%m-%d) "$u" 2>/dev/null || true
mkdir -p /etc/vps_limites
echo "$l" > "/etc/vps_limites/$u"
if [ ! -f /usr/local/bin/monitor_limites.sh ]; then
cat << 'EOF_MONITOR' > /usr/local/bin/monitor_limites.sh
#!/bin/bash
for user in $(ls /etc/vps_limites/ 2>/dev/null); do
limite=$(cat /etc/vps_limites/$user)
conex=$(ps -u $user 2>/dev/null | grep -c sshd)
if [ "$conex" -gt "$limite" ]; then
pkill -u $user sshd
fi
done
EOF_MONITOR
chmod +x /usr/local/bin/monitor_limites.sh
(crontab -l 2>/dev/null | grep -v "monitor_limites.sh"; echo "* * * * * /usr/local/bin/monitor_limites.sh") | crontab -
fi
if ! command -v figlet > /dev/null 2>&1; then
    apt-get install figlet -y >/dev/null 2>&1
fi
clear
echo -e "${C}================================================${N}"
if command -v figlet > /dev/null 2>&1; then
echo -e "${V}$(figlet -c -f slant "$u")${N}"
else
echo -e "${V}     >>> $u <<<     ${N}"
fi
echo -e " ${W}* Puertas Activas en su Servidor *   ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
STR_P=""
ss -tlnp | grep -q ":22 " && STR_P+="${W}🔹 SSH:  ${V}22${N}   "
if ss -tlnp | grep -q ":80 "; then
    systemctl is-active --quiet xray && grep -q '"port": 80' /usr/local/etc/xray/config.json 2>/dev/null && STR_P+="${W}🔹 V2RAY:  ${V}80${N}   " || STR_P+="${W}🔹 PROXY:  ${V}80${N}   "
fi
if ss -tlnp | grep -q ":443 "; then
    systemctl is-active --quiet xray && grep -q '"port": 443' /usr/local/etc/xray/config.json 2>/dev/null && STR_P+="${W}🔹 V2RAY:  ${V}443${N}   " || STR_P+="${W}🔹 SSL:  ${V}443${N}   "
fi
ss -ulnp | grep -q ":36712" && STR_P+="${W}🔹 UDP:  ${V}36712${N}   "
ss -ulnp | grep -q ":5300" && STR_P+="${W}🔹 SlowDNS:  ${V}5300${N}   "
[ -z "$STR_P" ] && STR_P="${W}🔹  ${R}Sin puertos configurados   ${N}"
echo -e " $STR_P"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}Host/IP-Address :${N} ${V}$IP_VPS   ${N}"
echo -e " ${W}USUARIO :${N} ${V}$u   ${N}"
echo -e " ${W}PASSWD  :${N} ${V}$p   ${N}"
echo -e " ${W}LIMITE  :${N} ${V}$l   ${N}"
echo -e " ${W}VALIDEZ :${N} ${V}$(date -d "+$d days" +%d/%m/%Y)   ${N}"
if [ -s /etc/slowdns/pub_key.txt ] && [ -s /etc/slowdns/ns_domain.txt ]; then
    echo -e "${C}────────────────────────────────────────────────────────${N}"
    echo -e " ${A}SLOWDNS CONFIG (HTTP CUSTOM / INJECTOR)   ${N}"
    echo -e " ${W}NameServer (NS) :${N} ${V}$(cat /etc/slowdns/ns_domain.txt)   ${N}"
    echo -e " ${W}PUB KEY         :${N} ${A}$(cat /etc/slowdns/pub_key.txt)   ${N}"
fi
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${R}✓ El servidor desconectará automáticamente al   ${N}"
echo -e " ${R}  usuario si supera el límite de $l conexiones.   ${N}"
echo -e "${C}================================================${N}"
echo -ne " ${W}► Enter para continuar...   ${N}"; read
;;
2) echo -ne " ${W}► Usuario a eliminar:   ${N}"; read u; userdel -r "$u" 2>/dev/null && rm -f /etc/vps_limites/$u && echo -e " ${V}Eliminado.   ${N}" || echo -e " ${R}Error.   ${N}"; read -p " Enter..." ;;
3) awk -F: '$3 >= 1000 && $1 != "nobody" {print " -> " $1}' /etc/passwd; read -p " Enter..." ;;
4) ver_usuarios_online ;;
0) break ;;
esac
done
}

menu_ssl() {
while true; do
clear
echo -e "${A}--- GESTOR DE PROTOCOLO SSL/TLS ---   ${N}"
echo -e " ${W}Estado:${N} $(es stunnel4)"
echo -e "${C}----------------------------------------${N}"
echo -e " ${V}[1]${N} ${W}🟢 Instalar Certificado SSL (Base)   ${N}"
echo -e " ${V}[2]${N} ${W}➕ Adicionar Puerto Extra al SSL   ${N}"
echo -e " ${R}[3]${N} ${W}➖ Eliminar un Puerto SSL   ${N}"
echo -e " ${A}[4]${N} ${W}⏸️  Detener SSL   ${N}"
echo -e " ${R}[5]${N} ${W}🗑️  Desinstalar Todo   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion :   ${N}"; read op_ssl
case $op_ssl in
1)
p1=22
echo -ne " ${W}► Puerto externo SSL a elegir (Ej: 443, 444):   ${N}"; read p2; p2=${p2:-443}
apt-get install stunnel4 openssl -y >/dev/null 2>&1
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem -subj "/CN=ZeroDay/O=VPN/C=CO" >/dev/null 2>&1
echo -e "pid = /var/run/stunnel4.pid\ncert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n[stunnel-custom]\naccept = $p2\nconnect = 127.0.0.1:$p1" > /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null || echo "ENABLED=1" > /etc/default/stunnel4
ufw allow $p2/tcp >/dev/null 2>&1
systemctl restart stunnel4
echo -e " ${V}¡SSL instalado y activo en puerto externo $p2!   ${N}"
read -p " Enter..." ;;
2)
if [ ! -f /etc/stunnel/stunnel.conf ]; then
    echo -e "\n ${R}ERROR: Debes Instalar el SSL primero (Opción 1).   ${N}"
    echo -ne " ${W}► Enter para continuar...   ${N}"; read
    continue
fi
echo -e "\n${C}=== ADICIONAR PUERTO SSL ===   ${N}"
echo -ne " ${W}► Puerto Local Interno (Default: 22):   ${N}"; read p_int; p_int=${p_int:-22}
echo -ne " ${W}► NUEVO Puerto SSL a escuchar (Ej: 444, 445):   ${N}"; read p_ext
if [ -z "$p_ext" ]; then
    echo -e " ${R}Cancelado.  ${N}"; read -p " Enter..."; continue
fi
echo -e "\n[stunnel-extra-$p_ext]\naccept = $p_ext\nconnect = 127.0.0.1:$p_int" >> /etc/stunnel/stunnel.conf
ufw allow $p_ext/tcp >/dev/null 2>&1
systemctl restart stunnel4
echo -e "\n ${V}¡Puerto SSL $p_ext adicionado exitosamente y redirigiendo al $p_int!   ${N}"
echo -ne " ${W}► Enter para continuar...   ${N}"; read
;;
3)
if [ ! -f /etc/stunnel/stunnel.conf ]; then
    echo -e "\n ${R}ERROR: No hay SSL instalado.   ${N}"
    echo -ne " ${W}► Enter para continuar...   ${N}"; read
    continue
fi
clear
echo -e "${C}=== ELIMINAR PUERTO SSL ===   ${N}"
echo -e " ${W}Puertos SSL actualmente activos:   ${N}"
PUERTOS_ACTUALES=$(grep '^accept' /etc/stunnel/stunnel.conf | awk -F'=' '{print $2}' | tr -d ' ')
if [ -z "$PUERTOS_ACTUALES" ]; then
    echo -e " ${R}No se encontraron puertos configurados.   ${N}"
else
    for pt in $PUERTOS_ACTUALES; do
        echo -e " 🔹 Puerto:  ${V}$pt   ${N}"
    done
fi
echo -e "${C}────────────────────────────────────────${N}"
echo -ne " ${W}► Ingresa el puerto a eliminar:   ${N}"; read p_del
if [ -z "$p_del" ]; then
    echo -e " ${R}Cancelado.  ${N}"; read -p " Enter..."; continue
fi

if grep -q "accept = $p_del" /etc/stunnel/stunnel.conf; then
    BLOQUE=$(grep -B 1 "accept = $p_del" /etc/stunnel/stunnel.conf | grep '\[' | head -n 1)
    BLOQUE_ESC=$(echo "$BLOQUE" | sed 's/\[/\\[/g; s/\]/\\]/g')
    sed -i "/^$BLOQUE_ESC$/,/^connect =/d" /etc/stunnel/stunnel.conf
    
    ufw delete allow $p_del/tcp >/dev/null 2>&1
    systemctl restart stunnel4
    echo -e "\n ${V}¡Puerto SSL $p_del eliminado exitosamente!   ${N}"
else
    echo -e "\n ${R}El puerto $p_del no existe en la configuración.   ${N}"
fi
echo -ne " ${W}► Enter para continuar...   ${N}"; read
;;
4) systemctl stop stunnel4; echo -e " ${A}Detenido.   ${N}"; read -p " Enter..." ;;
5) systemctl stop stunnel4; apt-get purge stunnel4 -y >/dev/null 2>&1; rm -rf /etc/stunnel/; echo -e " ${R}Desinstalado.   ${N}"; read -p " Enter..." ;;
0) break ;;
*) echo -e " ${R}Opción inválida.  ${N}"; sleep 1 ;;
esac
done
}

# ==========================================
# MÓDULO SHADOWSOCKS-R NATIVO (OPCIÓN 5)
# ==========================================
b64_url() {
    echo -n "$1" | base64 -w 0 | tr '+/' '-_' | tr -d '='
}

generar_enlaces_ssr() {
    if [ ! -f /etc/ssr/datos.conf ]; then return; fi
    source /etc/ssr/datos.conf

    PASS_B64=$(b64_url "$SSR_PASS")
    REMARKS_B64=$(b64_url "$SSR_USER")
    OBFSPARAM_B64=$(b64_url "$SSR_OBFS_PARAM")
    PROTPARAM_B64=$(b64_url "")

    RAW_SSR="${SSR_IP}:${SSR_PORT}:${SSR_PROTO}:${SSR_METHOD}:${SSR_OBFS}:${PASS_B64}/?obfsparam=${OBFSPARAM_B64}&protoparam=${PROTPARAM_B64}&remarks=${REMARKS_B64}&group=$(b64_url "ZeroDay")"
    SSR_LINK="ssr://$(b64_url "$RAW_SSR")"

    RAW_SS="${SSR_METHOD}:${SSR_PASS}@${SSR_IP}:${SSR_PORT}"
    SS_LINK="ss://$(echo -n "$RAW_SS" | base64 -w 0)#${SSR_USER}"
}

mostrar_info_ssr() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "     ${A}ℹ️ CONFIGURACIÓN SHADOWSOCKS-R ℹ️   ${N}"
    echo -e "${C}================================================${N}"
    if [ ! -f /etc/ssr/datos.conf ]; then
        echo -e " ${R}[!] ShadowsocksR no está instalado.   ${N}"
        echo -e "${C}================================================${N}"
        echo -ne " ${W}► Presiona Enter para volver...   ${N}"; read
        return
    fi
    generar_enlaces_ssr
    echo -e " ${W}🔹 Servidor (IP/Host) :${N} ${V}$SSR_IP   ${N}"
    echo -e " ${W}🔹 Usuario / Perfil   :${N} ${V}$SSR_USER   ${N}"
    echo -e " ${W}🔹 Puerto             :${N} ${V}$SSR_PORT   ${N}"
    echo -e " ${W}🔹 Contraseña         :${N} ${V}$SSR_PASS   ${N}"
    echo -e " ${W}🔹 Encriptación       :${N} ${A}$SSR_METHOD   ${N}"
    echo -e " ${W}🔹 Protocolo          :${N} ${A}$SSR_PROTO   ${N}"
    echo -e " ${W}🔹 Ofuscación (OBFS)  :${N} ${A}$SSR_OBFS   ${N}"
    [ -n "$SSR_OBFS_PARAM" ] && echo -e " ${W}🔹 Obfs Param (SNI)   :${N} ${V}$SSR_OBFS_PARAM   ${N}"
    echo -e "${C}────────────────────────────────────────────────${N}"
    echo -e " ${V}🔗 LINK SSR (Cópialo en tu app ShadowsocksR):   ${N}"
    echo -e " ${A}$SSR_LINK   ${N}\n"
    echo -e " ${V}🔗 LINK SS CLÁSICO:   ${N}"
    echo -e " ${W}$SS_LINK   ${N}"
    echo -e "${C}================================================${N}"
    echo -ne " ${W}► Presiona Enter para continuar...   ${N}"; read
}

configurar_cuenta_ssr() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "     ${A}⚙️ PARÁMETROS DE CUENTA SHADOWSOCKS-R ⚙️   ${N}"
    echo -e "${C}================================================${N}"

    echo -ne " ${W}► IP o Dominio [Enter = $IP_VPS]:   ${N}"; read ssr_ip
    ssr_ip=${ssr_ip:-$IP_VPS}

    echo -ne " ${W}► Nombre de Usuario [Default: ZeroDay]:   ${N}"; read ssr_user
    ssr_user=${ssr_user:-ZeroDay}

    echo -ne " ${W}► Puerto SSR (Ej: 110, 443, 8388) [Default: 110]:   ${N}"; read ssr_port
    ssr_port=${ssr_port:-110}

    echo -ne " ${W}► Contraseña [Default: zeroday123]:   ${N}"; read ssr_pass
    ssr_pass=${ssr_pass:-zeroday123}

    echo -e "\n ${A}Seleccione Tipo de Encriptación:   ${N}"
    echo -e " ${V}[1]${N} ${W}aes-256-cfb (Recomendado / Clásico)   ${N}"
    echo -e " ${V}[2]${N} ${W}aes-128-cfb   ${N}"
    echo -e " ${V}[3]${N} ${W}aes-256-ctr   ${N}"
    echo -e " ${V}[4]${N} ${W}aes-128-ctr   ${N}"
    echo -e " ${V}[5]${N} ${W}chacha20-ietf   ${N}"
    echo -e " ${V}[6]${N} ${W}chacha20   ${N}"
    echo -e " ${V}[7]${N} ${W}rc4-md5   ${N}"
    echo -e " ${V}[8]${N} ${W}none (Sin cifrado)   ${N}"
    echo -ne " ${W}► Opción [Default 1]:   ${N}"; read op_enc
    case $op_enc in
        2) ssr_method="aes-128-cfb" ;;
        3) ssr_method="aes-256-ctr" ;;
        4) ssr_method="aes-128-ctr" ;;
        5) ssr_method="chacha20-ietf" ;;
        6) ssr_method="chacha20" ;;
        7) ssr_method="rc4-md5" ;;
        8) ssr_method="none" ;;
        *) ssr_method="aes-256-cfb" ;;
    esac

    echo -e "\n ${A}Seleccione Protocolo SSR:   ${N}"
    echo -e " ${V}[1]${N} ${W}origin (Recomendado / Compatible SS)   ${N}"
    echo -e " ${V}[2]${N} ${W}auth_sha1_v4   ${N}"
    echo -e " ${V}[3]${N} ${W}auth_aes128_md5   ${N}"
    echo -e " ${V}[4]${N} ${W}auth_aes128_sha1   ${N}"
    echo -e " ${V}[5]${N} ${W}auth_chain_a   ${N}"
    echo -e " ${V}[6]${N} ${W}auth_chain_b   ${N}"
    echo -ne " ${W}► Opción [Default 1]:   ${N}"; read op_proto
    case $op_proto in
        2) ssr_proto="auth_sha1_v4" ;;
        3) ssr_proto="auth_aes128_md5" ;;
        4) ssr_proto="auth_aes128_sha1" ;;
        5) ssr_proto="auth_chain_a" ;;
        6) ssr_proto="auth_chain_b" ;;
        *) ssr_proto="origin" ;;
    esac

    if [ "$ssr_proto" != "origin" ]; then
        echo -ne " ${W}► ¿Activar modo compatible con SS clásico? (s/n) [Default: s]:   ${N}"; read comp_p
        comp_p=${comp_p:-s}
        [[ "$comp_p" == "s" || "$comp_p" == "S" ]] && ssr_proto_cfg="${ssr_proto}_compatible" || ssr_proto_cfg="$ssr_proto"
    else
        ssr_proto_cfg="origin"
    fi

    echo -e "\n ${A}Seleccione Método de Ofuscación (OBFS):   ${N}"
    echo -e " ${V}[1]${N} ${W}tls1.2_ticket_auth (Ideal para Host/SNI)   ${N}"
    echo -e " ${V}[2]${N} ${W}http_simple (Payload HTTP Host)   ${N}"
    echo -e " ${V}[3]${N} ${W}http_post   ${N}"
    echo -e " ${V}[4]${N} ${W}random_head   ${N}"
    echo -e " ${V}[5]${N} ${W}plain (Sin ofuscación)   ${N}"
    echo -ne " ${W}► Opción [Default 1]:   ${N}"; read op_obfs
    case $op_obfs in
        2) ssr_obfs="http_simple" ;;
        3) ssr_obfs="http_post" ;;
        4) ssr_obfs="random_head" ;;
        5) ssr_obfs="plain" ;;
        *) ssr_obfs="tls1.2_ticket_auth" ;;
    esac

    if [ "$ssr_obfs" != "plain" ]; then
        echo -ne " ${W}► ¿Activar OBFS compatible con SS clásico? (s/n) [Default: s]:   ${N}"; read comp_o
        comp_o=${comp_o:-s}
        [[ "$comp_o" == "s" || "$comp_o" == "S" ]] && ssr_obfs_cfg="${ssr_obfs}_compatible" || ssr_obfs_cfg="$ssr_obfs"
        echo -ne " ${W}► Obfs Param / Host Bug (Ej: c.whatsapp.net) [Opcional]:   ${N}"; read ssr_obfs_param
    else
        ssr_obfs_cfg="plain"
        ssr_obfs_param=""
    fi

    mkdir -p /etc/ssr
    cat <<EOF > /etc/ssr/config.json
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "server_port": $ssr_port,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "$ssr_pass",
    "timeout": 120,
    "udp_timeout": 60,
    "method": "$ssr_method",
    "protocol": "$ssr_proto_cfg",
    "protocol_param": "",
    "obfs": "$ssr_obfs_cfg",
    "obfs_param": "$ssr_obfs_param",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open": false,
    "workers": 1
}
EOF

    cat <<EOF > /etc/ssr/datos.conf
SSR_IP="$ssr_ip"
SSR_USER="$ssr_user"
SSR_PORT="$ssr_port"
SSR_PASS="$ssr_pass"
SSR_METHOD="$ssr_method"
SSR_PROTO="$ssr_proto"
SSR_OBFS="$ssr_obfs"
SSR_OBFS_PARAM="$ssr_obfs_param"
EOF
    echo "$ssr_port" > /etc/ssr/puerto.txt

    iptables -I INPUT -p tcp --dport "$ssr_port" -j ACCEPT 2>/dev/null
    iptables -I INPUT -p udp --dport "$ssr_port" -j ACCEPT 2>/dev/null
    ufw allow "$ssr_port"/tcp >/dev/null 2>&1
    ufw allow "$ssr_port"/udp >/dev/null 2>&1
}

instalar_ssr() {
    configurar_cuenta_ssr
    echo -e "\n ${V}⏳ Instalando dependencias y librerías C/C++ (libsodium)...   ${N}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y python3 git curl wget libsodium-dev openssl lsof psmisc >/dev/null 2>&1

    rm -rf /usr/local/shadowsocksr
    echo -e " ${V}⏳ Descargando motor oficial ShadowsocksR...   ${N}"
    git clone -q -b akkariiin/master https://github.com/shadowsocksrr/shadowsocksr.git /usr/local/shadowsocksr 2>/dev/null || \
    git clone -q https://github.com/shadowsocksr-backup/shadowsocksr.git /usr/local/shadowsocksr 2>/dev/null

    if [ ! -d "/usr/local/shadowsocksr/shadowsocks" ]; then
        echo -e "\n ${R}[!] Error al clonar el repositorio base de ShadowsocksR.   ${N}"
        echo -ne " ${W}► Presiona Enter para continuar...   ${N}"; read
        return
    fi

    echo -e " ${V}🔧 Aplicando parches de ingeniería para Ubuntu 24.04/26.04 (OpenSSL 3 & Python 3)...   ${N}"
    find /usr/local/shadowsocksr -name "*.py" -exec sed -i 's/collections\.MutableMapping/collections.abc.MutableMapping/g' {} + 2>/dev/null
    find /usr/local/shadowsocksr -name "*.py" -exec sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/g' {} + 2>/dev/null

    cat <<EOF > /etc/systemd/system/ssr-server.service
[Unit]
Description=ShadowsocksR Native Server (ZeroDay)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/shadowsocksr/shadowsocks
ExecStart=/usr/bin/python3 /usr/local/shadowsocksr/shadowsocks/server.py -c /etc/ssr/config.json
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    PT_NOW=$(cat /etc/ssr/puerto.txt)
    fuser -k -9 "$PT_NOW"/tcp >/dev/null 2>&1
    lsof -ti tcp:"$PT_NOW" | xargs kill -9 2>/dev/null

    systemctl daemon-reload
    systemctl enable ssr-server >/dev/null 2>&1
    systemctl restart ssr-server
    sleep 2

    if systemctl is-active --quiet ssr-server; then
        echo -e "\n ${V}¡SHADOWSOCKS-R INSTALADO Y ACTIVO CON ÉXITO!   ${N}"
        sleep 1
        mostrar_info_ssr
    else
        echo -e "\n ${R}[!] El servicio SSR no pudo arrancar. Verifica que el puerto esté libre.   ${N}"
        echo -ne " ${W}► Enter para continuar...   ${N}"; read
    fi
}

menu_ssr() {
while true; do
    clear
    ESTADO_SSR=$(systemctl is-active --quiet ssr-server && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")
    PT_SSR_M=$([ -f /etc/ssr/puerto.txt ] && cat /etc/ssr/puerto.txt || echo "NULL")
    echo -e "${C}================================================${N}"
    echo -e "     ${A}🛡️ CONTROLADOR DE SHADOWSOCKS-R | ZeroDay 🛡️   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}🔹 Puerto :${N} ${V}$PT_SSR_M${N}  ${W}| Estado :${N} $ESTADO_SSR"
    echo -e "${C}------------------------------------------------${N}"
    echo -e " ${V}[1]${N} ${W}🟢 Instalar / Configurar ShadowsocksR   ${N}"
    echo -e " ${A}[2]${N} ${W}👁️ Mostrar Información y Links (SSR / SS)   ${N}"
    echo -e " ${C}[3]${N} ${W}⚙️ Modificar Usuario / Puerto / Cifrado   ${N}"
    echo -e " ${V}[4]${N} ${W}▶️ Iniciar / Reiniciar ShadowsocksR   ${N}"
    echo -e " ${A}[5]${N} ${W}⏸️ Detener ShadowsocksR   ${N}"
    echo -e " ${C}[6]${N} ${W}📋 Ver Registro de Eventos (Logs)   ${N}"
    echo -e " ${R}[7]${N} ${W}🗑️ Desinstalar ShadowsocksR   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️ REGRESAR AL MENÚ   ${N}"
    echo -e "${C}------------------------------------------------${N}"
    echo -ne " ${W}► Opción :   ${N}"; read op_ssr

    case $op_ssr in
        1) instalar_ssr ;;
        2) mostrar_info_ssr ;;
        3)
            if [ ! -d /usr/local/shadowsocksr ]; then
                echo -e "\n ${R}[!] Primero instala ShadowsocksR con la Opción 1.   ${N}"
                sleep 2
            else
                configurar_cuenta_ssr
                systemctl restart ssr-server
                echo -e "\n ${V}¡Configuración actualizada y reiniciada!   ${N}"
                sleep 1
                mostrar_info_ssr
            fi
            ;;
        4)
            systemctl restart ssr-server 2>/dev/null
            sleep 1
            echo -e "\n ${V}¡Servicio ShadowsocksR reiniciado!   ${N}"
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            ;;
        5)
            systemctl stop ssr-server 2>/dev/null
            echo -e "\n ${A}Servicio ShadowsocksR detenido.   ${N}"
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            ;;
        6)
            clear
            echo -e "${A}=== LOGS EN TIEMPO REAL DE SHADOWSOCKS-R ===   ${N}"
            journalctl -u ssr-server -n 35 --no-pager
            echo -ne "\n ${W}► Enter para regresar...   ${N}"; read
            ;;
        7)
            echo -ne "\n ${W}► ¿Seguro que deseas eliminar ShadowsocksR? (s/n):   ${N}"; read conf_del
            if [[ "$conf_del" == "s" || "$conf_del" == "S" ]]; then
                systemctl stop ssr-server 2>/dev/null
                systemctl disable ssr-server 2>/dev/null
                rm -rf /usr/local/shadowsocksr /etc/ssr /etc/systemd/system/ssr-server.service
                systemctl daemon-reload
                echo -e "\n ${V}ShadowsocksR desinstalado por completo.   ${N}"
            fi
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            ;;
        0) break ;;
        *) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
    esac
done
}

menu_py() {
while true; do
clear
echo -e "${A}--- GESTOR DE PROXY PYTHON ---   ${N}"
echo -e " ${W}Estado:${N} $(es proxypy)"
echo -e "${C}----------------------------------------${N}"
echo -e " ${V}[3]${N} ${W}🟢 WebSocket PRO (Elegir Puerto)   ${N}"
echo -e " ${A}[4]${N} ${W}⏸️  Detener Proxy   ${N}"
echo -e " ${R}[5]${N} ${W}🗑️  Desinstalar   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion :   ${N}"; read op_py
case $op_py in
3)
echo -ne " ${W}► Puerto para el WebSocket (Ej: 80):   ${N}"; read pt; pt=${pt:-80}
echo -e " ${A}Liberando el puerto $pt y preparando Python...   ${N}"
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
echo -e " ${V}¡WebSocket PRO Activo en el puerto $pt!   ${N}"
read -p " Enter..." ;;
4) systemctl stop proxypy; echo -e " ${A}Detenido.   ${N}"; read -p " Enter..." ;;
5) systemctl stop proxypy; rm -f /etc/proxy.py /etc/systemd/system/proxypy.service; systemctl daemon-reload; echo -e " ${R}Desinstalado.   ${N}"; read -p " Enter..." ;;
0) break ;;
esac
done
}

menu_udp() {
while true; do
clear
echo -e "${A}--- UDP CUSTOM ---   ${N}"
echo -e " ${W}Estado:${N} $(es udp-custom)"
echo -e "${C}----------------------------------------${N}"
echo -e " ${V}[1]${N} ${W}🟢 Instalar UDP Custom   ${N}"
echo -e " ${A}[2]${N} ${W}⏸️  Detener UDP   ${N}"
echo -e " ${R}[3]${N} ${W}🗑️  Desinstalar UDP   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion :   ${N}"; read op_udp
case $op_udp in
1)
echo -e " ${W}Instalando servidor UDP Custom...   ${N}"
apt-get install -y iptables curl >/dev/null 2>&1
curl -sL -A "Mozilla/5.0" "https://raw.githubusercontent.com/Haris131/UDP-Custom/main/udp-custom-linux-amd64" -o /usr/bin/udp-custom
chmod +x /usr/bin/udp-custom; mkdir -p /root/udp
echo -e "{\n  \"listen\": \":36712\",\n  \"stream_buffer\": 33554432,\n  \"receive_buffer\": 8388608,\n  \"auth\": {\n    \"mode\": \"passwords\"\n  }\n}" > /root/udp/config.json
echo -e "[Unit]\nDescription=UDP Custom\n[Service]\nUser=root\nType=simple\nWorkingDirectory=/root/udp\nExecStart=/usr/bin/udp-custom server -exclude 53,5300,443\nRestart=always\nRestartSec=2\n[Install]\nWantedBy=default.target" > /etc/systemd/system/udp-custom.service
systemctl daemon-reload; systemctl enable udp-custom >/dev/null 2>&1; systemctl restart udp-custom
iptables -t nat -D PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null
iptables -t nat -A PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712
echo -e " ${V}¡UDP Custom Instalado y Activo (Puerto 36712)!   ${N}"
read -p " Enter..." ;;
2) systemctl stop udp-custom; echo -e " ${A}Detenido.   ${N}"; read -p " Enter..." ;;
3) systemctl stop udp-custom; rm -rf /usr/bin/udp-custom /root/udp /etc/systemd/system/udp-custom.service; systemctl daemon-reload; iptables -t nat -D PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null; echo -e " ${R}Desinstalado.   ${N}"; read -p " Enter..." ;;
0) break ;;
esac
done
}

menu_badvpn() {
while true; do
clear
P_BAD72=$(ss -tlnp | grep -q ":7200" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
P_BAD73=$(ss -tlnp | grep -q ":7300" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
echo -e "${A}--- BADVPN UDP (VIDEOLLAMADAS) ---   ${N}"
echo -e " ${W}Estado: 7200${N} $P_BAD72 ${W}| 7300${N} $P_BAD73"
echo -e "${C}----------------------------------------${N}"
echo -e " ${V}[1]${N} ${W}🟢 Instalar / Iniciar BadVPN   ${N}"
echo -e " ${A}[2]${N} ${W}⏸️  Detener BadVPN   ${N}"
echo -e " ${R}[3]${N} ${W}🗑️  Desinstalar BadVPN   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion :   ${N}"; read op_badvpn
case $op_badvpn in
1)
clear
echo -e "${C}=== INSTALACIÓN NATIVA BADVPN (ZERO-DEPENDENCIAS) ===   ${N}"
systemctl stop badvpn7200 2>/dev/null
systemctl stop badvpn7300 2>/dev/null
killall -9 badvpn-udpgw 2>/dev/null

echo -e " ${V}⏳ Preparando entorno oficial para Ubuntu / Debian...   ${N}"
apt-get update -y >/dev/null 2>&1
apt-get install -y curl wget coreutils lsof psmisc >/dev/null 2>&1

mkdir -p /usr/bin
rm -f /usr/bin/badvpn-udpgw

curl -4 -fsSL --connect-timeout 8 --max-time 20 "https://raw.githubusercontent.com/familipicomartinez-oss/menu22/main/badvpn-udpgw" -o /usr/bin/badvpn-udpgw 2>/dev/null
TAM_B=$(wc -c < /usr/bin/badvpn-udpgw 2>/dev/null || echo 0)
if [ "$TAM_B" -gt 50000 ]; then
    chmod +x /usr/bin/badvpn-udpgw 2>/dev/null
    if ! /usr/bin/badvpn-udpgw --version >/dev/null 2>&1 && ! /usr/bin/badvpn-udpgw --help >/dev/null 2>&1; then
        rm -f /usr/bin/badvpn-udpgw
    fi
else
    rm -f /usr/bin/badvpn-udpgw
fi

if [ ! -x /usr/bin/badvpn-udpgw ]; then
    echo -e " ${A}⚙️ Compilando motor BadVPN propio directamente en tu sistema...   ${N}"
    apt-get install -y cmake build-essential gcc g++ make git >/dev/null 2>&1
    rm -rf /tmp/badvpn_src
    git clone --depth 1 -q https://github.com/ambrop72/badvpn.git /tmp/badvpn_src 2>/dev/null
    if [ -d /tmp/badvpn_src ]; then
        mkdir -p /tmp/badvpn_src/build
        cd /tmp/badvpn_src/build || true
        cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Wno-dev >/dev/null 2>&1 || \
        cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 >/dev/null 2>&1
        make -j$(nproc) >/dev/null 2>&1
        if [ -f /tmp/badvpn_src/build/udpgw/badvpn-udpgw ]; then
            cp -f /tmp/badvpn_src/build/udpgw/badvpn-udpgw /usr/bin/badvpn-udpgw
            chmod +x /usr/bin/badvpn-udpgw
        fi
        cd /root 2>/dev/null || cd /
        rm -rf /tmp/badvpn_src
    fi
fi

if [ -x /usr/bin/badvpn-udpgw ]; then
    echo -e " ${V}Binario oficial instalado y purificado.   ${N}"
    
    echo -e "[Unit]\nDescription=BadVPN UDPGW 7300\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10\nRestart=always\nRestartSec=3\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/badvpn7300.service
    echo -e "[Unit]\nDescription=BadVPN UDPGW 7200\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 10\nRestart=always\nRestartSec=3\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/badvpn7200.service
    
    systemctl daemon-reload
    systemctl enable badvpn7300 >/dev/null 2>&1
    systemctl enable badvpn7200 >/dev/null 2>&1
    systemctl restart badvpn7300 >/dev/null 2>&1
    systemctl restart badvpn7200 >/dev/null 2>&1
    
    sleep 2
    if ss -tlnp | grep -q ":7300"; then
        echo -e " ${V}¡BadVPN activado exitosamente en los puertos 7200 y 7300!   ${N}"
    else
        echo -e " ${R}Fallo al encender el servicio. Revisa los permisos del sistema.   ${N}"
    fi
else
    echo -e "\n ${R}ERROR CRÍTICO: No se pudo compilar BadVPN. Verifica tu conexión a internet.   ${N}"
fi
echo -ne " ${W}► Enter para continuar...   ${N}"; read ;;
2)
systemctl stop badvpn7300 2>/dev/null
systemctl stop badvpn7200 2>/dev/null
killall badvpn-udpgw 2>/dev/null
echo -e " ${A}BadVPN Detenido.   ${N}"; read -p " Enter..." ;;
3)
systemctl stop badvpn7300 2>/dev/null
systemctl stop badvpn7200 2>/dev/null
systemctl disable badvpn7300 2>/dev/null
systemctl disable badvpn7200 2>/dev/null
rm -f /etc/systemd/system/badvpn*.service /usr/bin/badvpn-udpgw
apt-get purge badvpn -y >/dev/null 2>&1
systemctl daemon-reload
killall badvpn-udpgw 2>/dev/null
echo -e " ${R}BadVPN Desinstalado por completo.   ${N}"; read -p " Enter..." ;;
0) break ;;
esac
done
}

menu_v2ray() {
while true; do
clear
P_V2=$(systemctl is-active --quiet xray && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
echo -e "${C}================================================${N}"
echo -e "     ${A}⚜️  V2RAY / XRAY MANAGER (WebSocket) ⚜️   ${N}"
echo -e "${C}================================================${N}"
echo -e " ${W}Estado actual:${N} $P_V2"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${V}[1]${N} ${W}🟢 Instalar V2Ray/Xray (Modo WebSocket)   ${N}"
echo -e " ${A}[2]${N} ${W}➕ Generar Nuevo Usuario (UUID)   ${N}"
echo -e " ${C}[3]${N} ${W}⚙️  Modificar Puerto de Conexión   ${N}"
echo -e " ${V}[4]${N} ${W}👁️  Ver mis Datos y Link de Conexión   ${N}"
echo -e " ${R}[5]${N} ${W}🗑️  Desinstalar Todo   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver al Menú Principal   ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -ne " ${W}► Opcion :   ${N}"; read op_v2
case $op_v2 in
1)
    clear
    echo -e "${C}=== INSTALANDO NUCLEO XRAY (V2RAY OFICIAL) ===   ${N}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y jq uuid-runtime curl psmisc lsof openssl >/dev/null 2>&1
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    
    echo -e "\n${C}=== CONFIGURANDO CONEXIÓN WEBSOCKET ===   ${N}"
    echo -ne " ${W}► Puerto a usar (Recomendado: 443):   ${N}"; read pt_v2; pt_v2=${pt_v2:-443}
    echo -ne " ${W}► Tu Dominio del Servidor (Ej: movistar.zex.digital):   ${N}"; read dom_v2; dom_v2=${dom_v2:-$IP_VPS}
    UUID=$(uuidgen)
    
    systemctl stop proxypy stunnel4 apache2 nginx dropbear hcr-server 2>/dev/null
    fuser -k -9 $pt_v2/tcp >/dev/null 2>&1
    lsof -ti tcp:$pt_v2 | xargs kill -9 2>/dev/null
    sleep 2
    
    mkdir -p /usr/local/etc/xray
    openssl req -newkey rsa:2048 -nodes -keyout /usr/local/etc/xray/private.key -x509 -days 3650 -out /usr/local/etc/xray/cert.crt -subj "/C=CO/ST=Santander/L=ZeroDay/O=ZeroDay/CN=$dom_v2" >/dev/null 2>&1
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
      "wsSettings": { "path": "/zeroday" }
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
        echo -e "\n ${V}¡V2Ray Instalado y Activo con TLS!   ${N}"
    else
        echo -e "\n ${R}ERROR: V2Ray no pudo iniciar.   ${N}"
    fi
    echo -ne " ${W}► Enter para continuar...   ${N}"; read ;;
2)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e " ${R}V2Ray no está instalado. Instálalo primero (Opción 1).   ${N}"; read -p " Enter..."; continue
    fi
    UUID=$(uuidgen)
    sed -i -E "s/\"id\": \".*\"/\"id\": \"$UUID\"/" /usr/local/etc/xray/config.json
    echo "$UUID" > /usr/local/etc/xray/uuid.txt
    systemctl restart xray
    echo -e " ${V}¡Nuevo UUID generado y configurado exitosamente!   ${N}"
    echo -e " ${W}Nuevo UUID:${N} $UUID"
    echo -ne " ${W}► Enter para continuar...   ${N}"; read ;;
3)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e " ${R}V2Ray no está instalado. Instálalo primero (Opción 1).   ${N}"; read -p " Enter..."; continue
    fi
    pt_actual=$(cat /usr/local/etc/xray/puerto.txt)
    echo -e "\n${C}=== MODIFICAR PUERTO V2RAY ===   ${N}"
    echo -e " ${W}🔹 Puerto actual:  ${N}${V}$pt_actual   ${N}"
    echo -ne " ${W}► Ingresa el NUEVO puerto a usar (Ej: 80, 443):   ${N}"; read pt_nuevo
    if [ -z "$pt_nuevo" ]; then
        echo -e " ${R}Cancelado.   ${N}"; read -p " Enter..."; continue
    fi
    
    systemctl stop proxypy stunnel4 apache2 nginx dropbear hcr-server 2>/dev/null
    fuser -k -9 $pt_nuevo/tcp >/dev/null 2>&1
    lsof -ti tcp:$pt_nuevo | xargs kill -9 2>/dev/null
    
    sed -i -E "s/\"port\": [0-9]+/\"port\": $pt_nuevo/" /usr/local/etc/xray/config.json
    echo "$pt_nuevo" > /usr/local/etc/xray/puerto.txt
    ufw allow $pt_nuevo/tcp >/dev/null 2>&1
    systemctl restart xray
    
    sleep 2
    if systemctl is-active --quiet xray; then
        echo -e "\n ${V}¡Puerto modificado exitosamente al $pt_nuevo!   ${N}"
    else
        echo -e "\n ${R}ERROR: El puerto $pt_nuevo está bloqueado por el sistema. Intenta con otro.   ${N}"
    fi
    echo -ne " ${W}► Enter para continuar...   ${N}"; read ;;
4)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e " ${R}V2Ray no está instalado.   ${N}"; read -p " Enter..."; continue
    fi
    dom_v2=$(cat /usr/local/etc/xray/dominio.txt)
    pt_v2=$(cat /usr/local/etc/xray/puerto.txt)
    UUID=$(cat /usr/local/etc/xray/uuid.txt)
    
    cat <<EOF > /tmp/vmess.json
{
  "v": "2",
  "ps": "ZeroDay-V2Ray",
  "add": "$dom_v2",
  "port": "$pt_v2",
  "id": "$UUID",
  "aid": "0",
  "scy": "auto",
  "net": "ws",
  "type": "none",
  "host": "$dom_v2",
  "path": "/zeroday",
  "tls": "tls",
  "sni": "$dom_v2",
  "alpn": ""
}
EOF
    VMESS_BASE64=$(cat /tmp/vmess.json | base64 -w 0)
    VMESS_LINK="vmess://$VMESS_BASE64"
    
    clear
    echo -e "${C}=== TUS DATOS DE V2RAY ===   ${N}"
    echo -e " ${W}🔹 Dominio Server :  ${N}${V}$dom_v2   ${N}"
    echo -e " ${W}🔹 Puerto         :  ${N}${V}$pt_v2   ${N}"
    echo -e " ${W}🔹 UUID           :  ${N}${A}$UUID   ${N}"
    echo -e " ${W}🔹 Protocolo      : WebSocket (WS)   ${N}"
    echo -e " ${W}🔹 Path           : /zeroday   ${N}"
    echo -e " ${W}🔹 Seguridad      : TLS (Activada)   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " 🔗  ${V}LINK VMESS PARA IMPORTAR (Cópialo todo):   ${N}\n"
    echo -e " ${A}$VMESS_LINK   ${N}\n"
    echo -ne " ${W}► Enter para continuar...   ${N}"; read ;;
5)
    systemctl stop xray >/dev/null 2>&1
    systemctl disable xray >/dev/null 2>&1
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove >/dev/null 2>&1
    rm -rf /usr/local/etc/xray
    echo -e " ${R}V2Ray / Xray Desinstalado completamente.   ${N}"
    echo -ne " ${W}► Enter para continuar...   ${N}"; read ;;
0) break ;;
esac
done
}

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
    fi

    echo -e "${C}================================================${N}"
    echo -e "       ${W}MENU HCR SERVER - Estado:${N} $ESTADO"
    echo -e "${C}================================================${N}"
    echo -e " ${V}[1]${N} ${W}⚙️ Puerto Inyección [$P_INJ]   ${N}${V}[2]${N} ${W}⚙️ Puerto Destino [$P_DEST]   ${N}"
    echo -e " ${V}[3]${N} ${W}🛡️ Modo             [$MODO]   ${N}"
    echo -e " ${A}[5]${N} ${W}🟢 Iniciar / Configurar   ${N}    ${R}[6]${N} ${W}🗑️ Desinstalar HCR   ${N}"
    echo -e " ${C}[7]${N} ${W}👁️ Ver Errores del Servidor (Log Real)   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️ REGRESAR   ${N}"
    echo -e "${C}================================================${N}"
    echo -ne " ${W}► Opcion :   ${N}"; read op_hcr
    
    case $op_hcr in
        1|2|3)
            echo -e " ${W}Para cambiar puertos o modos, usa la Opción 5 de Instalación.   ${N}"
            sleep 1
            ;;
        5)
            instalar_hcr
            ;;
        6)
            systemctl stop hcr-server 2>/dev/null
            systemctl disable hcr-server 2>/dev/null
            rm -rf /etc/hcr /etc/systemd/system/hcr-server.service
            systemctl daemon-reload
            echo -e " ${R}HCR Desinstalado y Limpiado.   ${N}"; sleep 1
            ;;
        7)
            clear
            echo -e "${A}=== LOGS DEL MOTOR HCR ===   ${N}"
            journalctl -u hcr-server -n 40 --no-pager
            echo -ne " ${W}► Enter para regresar...   ${N}"; read
            ;;
        0) break ;;
    esac
done
}

instalar_hcr() {
    clear
    echo -e "${A}========= INSTALACION HCR SERVER =========   ${N}"
    mkdir -p /etc/hcr
    
    echo -ne " ${W}► Puerto de Inyección [Default 8080]:   ${N}"; read p_inj
    p_inj=${p_inj:-8080}
    
    echo -ne " ${W}► Puerto de redireccionamiento [Default 22]:   ${N}"; read p_dest
    p_dest=${p_dest:-22}
    
    echo -e "\n ${W}Seleccione Modo de transporte:   ${N}"
    echo -e " ${W}[1] Plain (Recomendado para HTTP Custom clásico)   ${N}"
    echo -e " ${W}[2] TLS (Con certificado SSL)   ${N}"
    echo -ne " ${W}► Opcion [Default 1]:   ${N}"; read op_m
    op_m=${op_m:-1}
    
    if [ "$op_m" == "2" ]; then
        MODO="TLS"
        echo -e "\n ${A}Generando certificado TLS...   ${N}"
        apt-get install openssl -y >/dev/null 2>&1
        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj "/C=CO/ST=Santander/L=ZeroDay/O=ZeroDay/CN=MiVPS" \
        -keyout /etc/hcr/key.pem -out /etc/hcr/cert.pem > /dev/null 2>&1
        cp -f /etc/hcr/key.pem /etc/hcr/hcr.key 2>/dev/null
        cp -f /etc/hcr/cert.pem /etc/hcr/hcr.crt 2>/dev/null
    else
        MODO="Plain"
    fi
    
    echo -e "P_INJ=\"$p_inj\"\nP_DEST=\"$p_dest\"\nMODO=\"$MODO\"" > /etc/hcr/config

    echo -e " ${C}Descargando Binario HCR Original...   ${N}"
    rm -f /etc/hcr/hcr-server
    apt-get install curl wget lsof coreutils -y >/dev/null 2>&1
    
    MIRRORS=(
    "https://raw.githubusercontent.com/familipicomartinez-oss/menu22/main/hcr-server"
)
    
    DESCARGA_EXITOSA=0
    for url in "${MIRRORS[@]}"; do
        echo -e " ${W}► Probando fuente: ${url:8:35}...   ${N}"
        curl -4 -sL --connect-timeout 10 "$url" -o /etc/hcr/hcr-server
        
        TAMANO=$(wc -c < /etc/hcr/hcr-server 2>/dev/null || echo 0)
        echo -e "   ${W}-> Tamaño obtenido: $TAMANO bytes   ${N}"
        
        if [ "$TAMANO" -gt 1000000 ]; then
            echo -e " ${V}¡Archivo binario original descargado correctamente!   ${N}"
            DESCARGA_EXITOSA=1
            break
        fi
        rm -f /etc/hcr/hcr-server
    done
    
    if [ "$DESCARGA_EXITOSA" -eq 0 ]; then
        echo -e "\n ${R}[!] ERROR CRÍTICO DE RED [!]   ${N}"
        echo -e " ${A}Ningún servidor entregó el archivo válido.   ${N}"
        echo -ne " ${W}► Enter para regresar...   ${N}"; read
        return
    fi
    
    chmod 777 /etc/hcr/hcr-server

    cat << 'EOF' > /etc/hcr/start.sh
#!/bin/bash
source /etc/hcr/config
cd /etc/hcr

if [ "$MODO" == "TLS" ]; then
    ./hcr-server -listen :$P_INJ -transport tls -tls-cert /etc/hcr/cert.pem -tls-key /etc/hcr/key.pem || ./hcr-server -port $P_INJ -transport tls -tls-cert /etc/hcr/cert.pem -tls-key /etc/hcr/key.pem
else
    ./hcr-server -listen :$P_INJ -transport plain || ./hcr-server -port $P_INJ -transport plain
fi
EOF
    chmod +x /etc/hcr/start.sh

    echo -e "[Unit]\nDescription=HCR Server Custom\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/etc/hcr/start.sh\nRestart=always\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/hcr-server.service
    
    fuser -k -9 $p_inj/tcp >/dev/null 2>&1
    lsof -ti tcp:$p_inj | xargs kill -9 2>/dev/null
    
    systemctl daemon-reload
    systemctl enable hcr-server >/dev/null 2>&1
    systemctl restart hcr-server
    
    iptables -I INPUT -p tcp --dport $p_inj -j ACCEPT >/dev/null 2>&1
    ufw allow $p_inj/tcp >/dev/null 2>&1
    
    sleep 3
    if ss -tlnp | grep -qw "$p_inj"; then
        echo -e "\n ${V}¡ÉXITO! El motor HCR encendió y el puerto $p_inj está verificado como ABIERTO.   ${N}"
    else
        echo -e "\n ${R}El motor falló al intentar abrir el puerto. Usa la Opción 7 para ver el log técnico.   ${N}"
    fi
    echo -ne " ${W}► Enter para continuar...   ${N}"; read
}

menu_slowdns() {
while true; do
    clear
    ESTADO=$(systemctl is-active --quiet slowdns && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")
    if [ -s /etc/slowdns/ns_domain.txt ]; then
        NS_ACT=$(cat /etc/slowdns/ns_domain.txt)
    else
        NS_ACT="NULL"
    fi
    if [ -s /etc/slowdns/puerto_local.txt ]; then
        PT_ACT=$(cat /etc/slowdns/puerto_local.txt)
    else
        PT_ACT="NULL"
    fi

    echo -e "${C}================================================${N}"
    echo -e "     ${A}🛡️ INSTALADOR SLOWDNS | ZeroDay 🛡️   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}🔹 Dominio NS :${N} ${A}$NS_ACT   ${N}"
    echo -e " ${W}🔹 Puerto     :${N} ${V}$PT_ACT${N}  ${W}| Estado:${N} $ESTADO   "
    echo -e "${C}------------------------------------------------${N}"
    echo -e " ${V}[1]${N} ${W}🟢 Instalar SlowDns   ${N}"
    echo -e " ${A}[2]${N} ${W}👁️ Ver Información / Llaves   ${N}"
    echo -e " ${C}[3]${N} ${W}🔄 Reiniciar SlowDns   ${N}"
    echo -e " ${R}[4]${N} ${W}🗑️ Remover SlowDns   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️ REGRESAR   ${N}"
    echo -e "${C}------------------------------------------------${N}"
    echo -ne " ${W}► Opcion :   ${N}"; read op_dns

    case $op_dns in
        1) instalar_slowdns ;;
        2) info_slowdns ;;
        3)
            echo -e "${C}================================================${N}"
            echo -e " ${V}⏳ Reiniciando servicio SlowDNS...   ${N}"
            systemctl restart slowdns 2>/dev/null
            sleep 2
            if systemctl is-active --quiet slowdns; then
                echo -e " ${V}¡Servicio reiniciado correctamente!   ${N}"
            else
                echo -e " ${R}Error al reiniciar el servicio.   ${N}"
            fi
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            ;;
        4)
            echo -e "${C}================================================${N}"
            echo -ne " ${W}► ¿Seguro de eliminar SlowDNS? (s/n):   ${N}"; read confirmar
            if [[ "$confirmar" == "s" || "$confirmar" == "S" ]]; then
                echo -e "\n ${R}Deteniendo y eliminando servicios...   ${N}"
                systemctl stop slowdns > /dev/null 2>&1
                systemctl disable slowdns > /dev/null 2>&1
                rm -f /etc/systemd/system/slowdns.service
                systemctl daemon-reload
                iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 > /dev/null 2>&1
                iptables -D INPUT -p udp --dport 5300 -j ACCEPT > /dev/null 2>&1
                rm -rf /etc/slowdns
                echo -e " ${V}SlowDNS desinstalado por completo.   ${N}"
            else
                echo -e "\n ${A}Operación cancelada.   ${N}"
            fi
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            ;;
        0) break ;;
        *) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
    esac
done
}

instalar_slowdns() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "       ${A}⚙️ INSTALACIÓN DE SLOWDNS ⚙️   ${N}"
    echo -e "${C}================================================${N}"
    
    if [ -d "/etc/slowdns" ]; then
        if [ -s "/etc/slowdns/pub_key.txt" ]; then
            echo -e " ${R}[!] SlowDNS ya se encuentra instalado.   ${N}"
            echo -e " ${W}Usa la opción 4 para removerlo primero.   ${N}"
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            return
        else
            systemctl stop slowdns >/dev/null 2>&1
            rm -rf /etc/slowdns
        fi
    fi

    echo -ne " ${W}► Puerto local (Ej: 22):   ${N}"; read puerto_local
    puerto_local=${puerto_local:-22}

    echo -e ""
    echo -ne " ${W}► Tu Dominio NS:   ${N}"; read dominio_ns

    if [ -z "$dominio_ns" ]; then
        echo -e "\n ${R}[!] El dominio NS es obligatorio.   ${N}"
        echo -ne " ${W}► Enter para continuar...   ${N}"; read
        return
    fi

    echo -e "\n ${V}⏳ Instalando dependencias...   ${N}"
    apt-get update -y > /dev/null 2>&1
    apt-get install iptables curl wget dnsutils -y > /dev/null 2>&1

    mkdir -p /etc/slowdns
    cd /etc/slowdns || return

    echo -e " ${V}⏳ Descargando motor DNSTT...   ${N}"
    MIRRORS_DNS=(
        "https://raw.githubusercontent.com/familipicomartinez-oss/menu22/main/dnstt-server"
    )

    DESCARGA_DNS=0
    for url_dns in "${MIRRORS_DNS[@]}"; do
        curl -4 -sL --connect-timeout 8 "$url_dns" -o /etc/slowdns/dnstt-server
        TAM_DNS=$(wc -c < /etc/slowdns/dnstt-server 2>/dev/null || echo 0)
        if [ "$TAM_DNS" -gt 1000000 ]; then
            chmod +x /etc/slowdns/dnstt-server
            if /etc/slowdns/dnstt-server -help >/dev/null 2>&1 || /etc/slowdns/dnstt-server -h >/dev/null 2>&1; then
                DESCARGA_DNS=1
                break
            fi
        fi
        rm -f /etc/slowdns/dnstt-server
    done

    if [ "$DESCARGA_DNS" -eq 0 ]; then
        echo -e " ${A}⚙️ Compilando motor DNSTT oficial (15s)...   ${N}"
        apt-get install golang-go git -y > /dev/null 2>&1
        rm -rf /tmp/dnstt_src
        git clone -q https://www.bamsoftware.com/git/dnstt.git /tmp/dnstt_src 2>/dev/null || git clone -q https://repo.or.cz/dnstt.git /tmp/dnstt_src 2>/dev/null
        if [ -d "/tmp/dnstt_src/dnstt-server" ]; then
            cd /tmp/dnstt_src/dnstt-server
            go build -o /etc/slowdns/dnstt-server >/dev/null 2>&1
            cd /etc/slowdns
            rm -rf /tmp/dnstt_src
            chmod +x /etc/slowdns/dnstt-server 2>/dev/null
        fi
    fi

    if [ ! -x "/etc/slowdns/dnstt-server" ]; then
        echo -e "\n ${R}[!] Error al obtener dnstt-server.   ${N}"
        rm -rf /etc/slowdns
        echo -ne " ${W}► Enter para continuar...   ${N}"; read
        return
    fi

    echo -e " ${V}🔑 Generando llaves criptográficas...   ${N}"
    /etc/slowdns/dnstt-server -gen-key -privkey-file /etc/slowdns/server.key -pubkey-file /etc/slowdns/server.pub > /etc/slowdns/keys.txt 2>&1

    if [ -s "/etc/slowdns/server.pub" ]; then
        priv_key=$(tr -d ' \n\r' < /etc/slowdns/server.key)
        pub_key=$(tr -d ' \n\r' < /etc/slowdns/server.pub)
    else
        priv_key=$(grep -i "priv" /etc/slowdns/keys.txt | awk '{print $NF}' | tr -d ' \n\r')
        pub_key=$(grep -i "pub" /etc/slowdns/keys.txt | awk '{print $NF}' | tr -d ' \n\r')
        echo "$priv_key" > /etc/slowdns/server.key
        echo "$pub_key" > /etc/slowdns/server.pub
    fi

    if [ -z "$pub_key" ]; then
        echo -e "\n ${R}[!] Error al generar la llave pública.   ${N}"
        rm -rf /etc/slowdns
        echo -ne " ${W}► Enter para continuar...   ${N}"; read
        return
    fi

    echo "$dominio_ns" > /etc/slowdns/ns_domain.txt
    echo "$pub_key" > /etc/slowdns/pub_key.txt
    echo "$puerto_local" > /etc/slowdns/puerto_local.txt

    echo -e " ${V}⚙️ Configurando servicio SystemD...   ${N}"
    cat <<EOF > /etc/systemd/system/slowdns.service
[Unit]
Description=SlowDNS Server (DNSTT)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/slowdns
ExecStart=/etc/slowdns/dnstt-server -udp :5300 -privkey-file /etc/slowdns/server.key $dominio_ns 127.0.0.1:$puerto_local
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    echo -e " ${V}🛡️ Aplicando reglas IPtables...   ${N}"
    iptables -D INPUT -p udp --dport 5300 -j ACCEPT 2>/dev/null
    iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null
    iptables -I INPUT -p udp --dport 5300 -j ACCEPT
    iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
    ufw allow 53/udp >/dev/null 2>&1
    ufw allow 5300/udp >/dev/null 2>&1
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null

    systemctl daemon-reload
    systemctl enable slowdns > /dev/null 2>&1
    systemctl restart slowdns

    echo -e "\n${C}================================================${N}"
    echo -e "   ${V}¡SLOWDNS INSTALADO Y ACTIVO CON ÉXITO!   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${A}🔹 REDIRECCIÓN :${N} ${V}$puerto_local -> 5300   ${N}"
    echo -e " ${A}🔹 DOMINIO NS  :${N} ${W}$dominio_ns   ${N}"
    echo -e " ${A}🔹 PUBLIC KEY  :${N} ${V}$pub_key   ${N}"
    echo -e "${C}================================================${N}"
    echo -ne " ${W}► Presiona Enter para continuar...   ${N}"; read
}

info_slowdns() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "       ${A}ℹ️ INFORMACIÓN SLOWDNS ℹ️   ${N}"
    echo -e "${C}================================================${N}"
    
    if [ ! -s "/etc/slowdns/pub_key.txt" ]; then
        echo -e " ${R}[!] SlowDNS no está instalado.   ${N}"
    else
        dominio_ns=$(cat /etc/slowdns/ns_domain.txt)
        pub_key=$(cat /etc/slowdns/pub_key.txt)
        puerto_local=$(cat /etc/slowdns/puerto_local.txt 2>/dev/null || echo "22")
        echo -e " ${V}Datos para tu app HTTP Custom:   ${N}\n"
        echo -e " ${A}🔹 PUERTO BASE :${N} ${V}$puerto_local   ${N}"
        echo -e " ${A}🔹 DOMINIO NS  :${N} ${W}$dominio_ns   ${N}"
        echo -e " ${A}🔹 PUBLIC KEY  :${N} ${V}$pub_key   ${N}"
    fi
    echo -e "${C}================================================${N}"
    echo -ne " ${W}► Presiona Enter para volver...   ${N}"; read
}

configurar_banner() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "       ${A}CONFIGURAR BANNER DE LA APLICACIÓN   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${V}Escribe el mensaje principal para tus clientes:   ${N}"
    echo -e " ${A}(Ej: SERVIDOR PREMIUM, PROHIBIDO TORRENT, etc.)   ${N}"
    echo ""
    echo -ne " ${W}► Mensaje:   ${N}"; read texto_banner
    
    if [ -z "$texto_banner" ]; then
        texto_banner="🚀 SERVIDOR PREMIUM ZERODAY 🚀"
    fi

    clear
    echo -e "${C}================================================${N}"
    echo -e "       ${A}ELIGE EL COLOR DE TU MENSAJE   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}[1] Azul       [5] Gris   ${N}"
    echo -e " ${W}[2] Amarillo   [6] Anaranjado   ${N}"
    echo -e " ${W}[3] Verde      [7] Fucsia   ${N}"
    echo -e " ${W}[4] Rojo       [8] Negro   ${N}"
    echo -e "${C}================================================${N}"
    echo -ne " ${W}► Opcion (1-8):   ${N}"; read op_color

    case $op_color in
        1) c_html="blue" ;;
        2) c_html="yellow" ;;
        3) c_html="green" ;;
        4) c_html="red" ;;
        5) c_html="gray" ;;
        6) c_html="orange" ;;
        7) c_html="magenta" ;; 
        8) c_html="black" ;;
        *) c_html="white" ;;
    esac

    cat <<EOF > /etc/issue.net
<font color="$c_html"><b>======================================</b></font><br>
<font color="$c_html"><b>      $texto_banner   </b></font><br>
<font color="$c_html"><b>======================================</b></font><br>
EOF

    sed -i 's/#Banner none/Banner \/etc\/issue.net/g' /etc/ssh/sshd_config
    sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
    sed -i '/^Banner /c\Banner \/etc\/issue.net' /etc/ssh/sshd_config

    systemctl restart ssh > /dev/null 2>&1
    systemctl restart sshd > /dev/null 2>&1

    echo ""
    echo -e " ${V}¡Banner configurado con éxito!   ${N}"
    echo -e " ${A}Ahora se mostrará tu mensaje en color en la app.   ${N}"
    echo ""
    echo -ne " ${W}► Presiona Enter para regresar al menú...   ${N}"; read
}

configurar_colores() {
    while true; do
        clear
        echo -e "${C}================================================${N}"
        echo -e "       ${A}🎨 CONFIGURADOR DE TEMAS (ALTA INTENSIDAD) 🎨   ${N}"
        echo -e "${C}================================================${N}"
        echo -e " ${W}Motor de 256 colores activos. Elige tu estilo.   ${N}"
        echo ""
        echo -e " ${V}[1]${N} ${W}💎 Diamante Neón       (Cyan 51 y Blanco Puro)   ${N}"
        echo -e " ${R}[2]${N} ${W}🔥 Oro Rojo Estallado  (Rojo 196 y Amarillo 226)   ${N}"
        echo -e " ${M}[3]${N} ${W}👾 Cyberpunk 2077      (Fucsia 201 y Cyan 51)   ${N}"
        echo -e " ${V}[4]${N} ${W}💻 Matrix Radiactivo   (Verde 46 Puro)   ${N}"
        echo -e " ${C}[5]${N} ${W}🌊 Océano Eléctrico    (Azul 33 y Cyan 51)   ${N}"
        echo -e " ${A}[6]${N} ${W}🌋 Fuego Solar         (Naranja 214 y Rojo 196)   ${N}"
        echo -e " ${M}[7]${N} ${W}🌌 Galaxia Profunda    (Morado 93 y Fucsia 201)   ${N}"
        echo -e " ${A}[8]${N} ${W}☢️ Tóxico Extremo      (Amarillo 226 y Verde 46)   ${N}"
        echo -e " ${C}[0]${N} ${W}↩️  Regresar al Menú Principal   ${N}"
        echo -e "${C}================================================${N}"
        echo -ne " ${W}► Elige un tema (1-8):   ${N}"; read op_tema

        case $op_tema in
            1)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;51m'; V='\033[38;5;46m'; A='\033[38;5;226m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;201m'; W='\033[38;5;231m'
EOF
                ;;
            2)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;196m'; V='\033[38;5;226m'; A='\033[38;5;214m'; R='\033[38;5;160m'; N='\033[0m'; M='\033[38;5;220m'; W='\033[38;5;231m'
EOF
                ;;
            3)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;201m'; V='\033[38;5;51m'; A='\033[38;5;226m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;198m'; W='\033[38;5;231m'
EOF
                ;;
            4)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;46m'; V='\033[38;5;82m'; A='\033[38;5;118m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;48m'; W='\033[38;5;84m'
EOF
                ;;
            5)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;33m'; V='\033[38;5;51m'; A='\033[38;5;39m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;45m'; W='\033[38;5;159m'
EOF
                ;;
            6)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;214m'; V='\033[38;5;196m'; A='\033[38;5;226m'; R='\033[38;5;160m'; N='\033[0m'; M='\033[38;5;202m'; W='\033[38;5;231m'
EOF
                ;;
            7)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;93m'; V='\033[38;5;51m'; A='\033[38;5;141m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;201m'; W='\033[38;5;231m'
EOF
                ;;
            8)
                cat << 'EOF' > /etc/zeroday_tema.conf
C='\033[38;5;226m'; V='\033[38;5;198m'; A='\033[38;5;46m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;214m'; W='\033[38;5;51m'
EOF
                ;;
            0) break ;;
            *) echo -e " ${R}Opción inválida.  ${N}"; sleep 1; continue ;;
        esac
        
        # Recargar configuración inmediatamente
        source /etc/zeroday_tema.conf
        echo -e "\n ${V}¡Tema Neón aplicado con éxito!   ${N}"
        sleep 1
    done
}

menu_protocolos() {
while true; do
clear
P22=$(ep 22); P80=$(es proxypy); PSSL=$(es stunnel4); PPY=$(es proxypy); PUDP=$(es udp-custom); PFB=$(es fail2ban)
PBAD=$(ss -tlnp | grep -q ":7300" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PV2=$(systemctl is-active --quiet xray && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PHCR=$(es hcr-server)
PDNS=$(es slowdns)
PSSR=$(es ssr-server)

echo -e "${A}🍄 INSTALACION DE PROTOCOLOS ( Script ZeroDay ) 🍄   ${N}"
echo -e "${C}--------------------------------------------------------${N}"
echo -e " ${C}[1]${N} ${W}OpenSSH       ${N}$P22    ${C}[11]${N} ${W}PSIPHON SERVER ${R}[OFF]  ${N}"
echo -e " ${C}[2]${N} ${W}DROPBEAR      ${R}[OFF]${N}   ${C}[12]${N} ${W}TCP DNS        ${A}(#BETA)  ${N}"
echo -e " ${C}[3]${N} ${W}OPENVPN       ${R}[OFF]${N}   ${C}[13]${N} ${W}WEBMIN         ${R}[OFF]  ${N}"
echo -e " ${C}[4]${N} ${W}SSL/TLS       ${N}$PSSL    ${C}[14]${N} ${W}SLOWDNS        ${N}$PDNS  ${N}"
echo -e " ${C}[5]${N} ${W}SHADOWSOCKS-R ${N}$PSSR    ${C}[15]${N} ${W}SSL->PYTHON    ${R}[OFF]  ${N}"
echo -e " ${C}[6]${N} ${W}SQUID         ${R}[OFF]${N}   ${C}[16]${N} ${W}SSLH MULTIPLEX ${R}[OFF]  ${N}"
echo -e " ${C}[7]${N} ${W}PROXY PYTHON  ${N}$PPY    ${C}[17]${N} ${W}OVER WEBSOCKET ${A}(#BETA)  ${N}"
echo -e " ${C}[8]${N} ${W}V2RAY MANAGER ${N}$PV2    ${C}[18]${N} ${W}SOCKS5         ${A}(#BETA)  ${N}"
echo -e " ${C}[9]${N} ${W}CFA ( CLASH ) ${R}[OFF]${N}   ${C}[19]${N} ${W}Protocolos UDP ${N}$PUDP  "
echo -e " ${C}[10]${N} ${W}TROJAN-GO     ${R}[OFF]${N}   ${C}[20]${N} ${M}FUNCIONES EN DISEÑO!  ${N}"
echo -e " "
echo -e "${A}🍄 INSTALACION DE HERRAMIENTAS Y SERVICIOS 🍄   ${N}"
echo -e "${C}--------------------------------------------------------${N}"
echo -e " ${C}[21]${N} ${W}BLOCK TORRENT        ${C}[22]${N} ${W}BadVPN         ${N}$PBAD  "
echo -e " ${C}[23]${N} ${W}TCP (BBR|Plus) ${R}[OFF]${N} ${C}[24]${N} ${W}FAILBAN        ${N}$PFB  "
echo -e " ${C}[25]${N} ${W}ARCHIVO ONLINE ${V}[81]${N}  ${C}[26]${N} ${W}UP|DOWN SpeedTest  ${N}"
echo -e " ${C}[27]${N} ${W}DETALLES DEL VPS     ${C}[28]${N} ${W}BLOCK ADS      ${R}[OFF]  ${N}"
echo -e " ${C}[29]${N} ${W}DNS CUSTOM (NETFLIX) ${C}[30]${N} ${W}HERRAMIENTAS EXTRAS  ${N}"
echo -e " ${C}[31]${N} ${W}REINICIAR SERVICIOS  ${C}[32]${N} ${W}Brook Server   ${R}[OFF]  ${N}"
echo -e " ${C}[33]${N} ${W}FIREWALL (IPTABLES)  ${C}[34]${N} ${W}Enable/Change PASSWD ROOT  ${N}"
echo -e " ${C}[35]${N} ${W}AToken [APP's] ${R}[OFF]${N} ${C}[36]${N} ${W}BHTTP [APP's]  ${R}[OFF]  ${N}"
echo -e " ${C}[37]${N} ${W}HCR [HTTP C.]  ${N}$PHCR ${C}[0]${N}  ${R}[ REGRESAR ]  ${N}"
echo -e "${C}--------------------------------------------------------${N}"
echo -ne " ${W}► Opcion :   ${N}"; read op_inst
case $op_inst in
4) menu_ssl ;;
5) menu_ssr ;;
7) menu_py ;;
8) menu_v2ray ;;
14) menu_slowdns ;;
19) menu_udp ;;
21) iptables -A FORWARD -m string --string "BitTorrent" --algo bm -j DROP; echo " Bloqueado   "; read -p " Enter..." ;;
22) menu_badvpn ;;
24) apt install fail2ban -y >/dev/null 2>&1; systemctl enable fail2ban >/dev/null 2>&1; systemctl start fail2ban; echo " Listo   "; read -p " Enter..." ;;
26) curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -; read -p " Enter..." ;;
27) info_sistema; echo -ne " ${W}Enter para continuar...   ${N}"; read ;;
31) systemctl restart ssh stunnel4 proxypy udp-custom fail2ban xray hcr-server slowdns ssr-server >/dev/null 2>&1; echo " Reiniciado   "; read -p " Enter..." ;;
33) ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 8080/tcp; ufw allow 53/udp; ufw allow 5300/udp; ufw allow 36712/udp; ufw allow 7200/udp; ufw allow 7300/udp; ufw --force enable; echo " Puertos Abiertos   "; read -p " Enter..." ;;
34) passwd root; read -p " Enter..." ;;
37) menu_hcr ;;
0) break ;;
*) echo -e " ${R}Inválido   ${N}"; sleep 1 ;;
esac
done
}

menu_bot() {
while true; do
    clear
    ESTADO_BOT=$(systemctl is-active --quiet zeroday-bot && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")
    echo -e "${C}================================================${N}"
    echo -e "     ${A}🤖 GESTOR BOT TELEGRAM (KEYS) | ZeroDay 🤖   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}Estado del Bot :${N} $ESTADO_BOT"
    echo -e "${C}------------------------------------------------${N}"
    echo -e " ${V}[1]${N} ${W}🟢 Instalar y Encender Bot (MongoDB)   ${N}"
    echo -e " ${A}[2]${N} ${W}⏸️  Detener Bot   ${N}"
    echo -e " ${V}[3]${N} ${W}▶️  Iniciar Bot   ${N}"
    echo -e " ${C}[4]${N} ${W}📋 Ver Registro (Log) del Bot   ${N}"
    echo -e " ${R}[5]${N} ${W}🗑️  Desinstalar Bot   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️  REGRESAR AL MENÚ   ${N}"
    echo -e "${C}------------------------------------------------${N}"
    echo -ne " ${W}► Opción :   ${N}"; read op_bot

    case $op_bot in
        1)
            clear
            echo -e "${C}================================================${N}"
            echo -e " ${V}⏳ Instalando dependencias de Python y Mongo...   ${N}"
            apt-get update -y >/dev/null 2>&1
            apt-get install python3 python3-pip python3-dnspython -y >/dev/null 2>&1
            echo -e " ${W}Esto puede tomar unos segundos...   ${N}"
            pip3 install pyTelegramBotAPI pymongo dnspython --break-system-packages >/dev/null 2>&1 || pip3 install pyTelegramBotAPI pymongo dnspython >/dev/null 2>&1
            
            mkdir -p /etc/zeroday_bot
            echo -e " ${A}⚙️ Escribiendo el cerebro del Bot con tus Keys...   ${N}"
            
            cat << 'EOF_BOT' > /etc/zeroday_bot/bot.py
import telebot
from pymongo import MongoClient
import subprocess
import random
import string
import os
from datetime import datetime, timedelta

# CREDENCIALES AUTOMATICAS ZERODAY
TOKEN = "8850791872:AAGGT83B_jnHTzmCf_uZVoMbHvgQov7RBHo"
MONGO_URI = "mongodb+srv://martinoswaldo01_db_user:nlcZvCf5uxcBuRKr@cluster0.1hzsh2n.mongodb.net/?retryWrites=true&w=majority"
ADMIN_SECRETO = "zerodayadmin"

try:
    bot = telebot.TeleBot(TOKEN)
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    db = client['zeroday_vpn']
    keys_collection = db['keys']
    admins_collection = db['admins']
except Exception as e:
    print("Error conectando a Mongo o Telegram:", e)
    exit(1)

def is_admin(chat_id):
    return admins_collection.find_one({"chat_id": chat_id, "role": "admin"}) is not None

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    texto = (
        "🚀 *Bienvenido al Bot ZeroDay* 🚀\n\n"
        "Para activar una cuenta SSH usa el formato:\n"
        "`/usar <TU_KEY> <usuario> <contraseña>`\n\n"
        "Ejemplo:\n`/usar ZD-1234 juan 123456`"
    )
    bot.reply_to(message, texto, parse_mode="Markdown")

@bot.message_handler(commands=['setadmin'])
def set_admin(message):
    args = message.text.split()
    if len(args) == 2 and args[1] == ADMIN_SECRETO:
        admins_collection.update_one({"chat_id": message.chat.id}, {"$set": {"role": "admin"}}, upsert=True)
        bot.reply_to(message, "✅ *¡Felicidades!* Ahora eres el Dueño Administrador del Bot. Puedes crear llaves con /gen.", parse_mode="Markdown")
    else:
        bot.reply_to(message, "❌ Código secreto incorrecto o formato inválido.")

@bot.message_handler(commands=['gen'])
def gen_key(message):
    if not is_admin(message.chat.id):
        bot.reply_to(message, "⛔ Cuidado: No tienes permisos para crear llaves.")
        return
    
    args = message.text.split()
    if len(args) != 3:
        bot.reply_to(message, "Uso: `/gen <dias> <limite_conexiones>`\nEjemplo: `/gen 30 2`", parse_mode="Markdown")
        return
    
    try:
        dias = int(args[1])
        limite = int(args[2])
        key = "ZD-" + ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
        
        keys_collection.insert_one({
            "key": key,
            "dias": dias,
            "limite": limite,
            "usada": False,
            "creada": datetime.now()
        })
        bot.reply_to(message, f"✅ *Key Generada con Éxito*\n\n🔑 Key: `{key}`\n⏳ Días: {dias}\n📈 Conexiones: {limite}\n\nEnvía esta Key a tu cliente para que use el comando /usar", parse_mode="Markdown")
    except ValueError:
        bot.reply_to(message, "❌ Días y límite deben ser números enteros.")

@bot.message_handler(commands=['usar'])
def usar_key(message):
    args = message.text.split()
    if len(args) != 4:
        bot.reply_to(message, "Uso correcto:\n`/usar <KEY> <usuario> <contraseña>`", parse_mode="Markdown")
        return
    
    key_input = args[1]
    user_ssh = args[2]
    pass_ssh = args[3]
    
    # Buscar en MongoDB
    key_data = keys_collection.find_one({"key": key_input})
    
    if not key_data:
        bot.reply_to(message, "❌ La Key ingresada no existe.")
        return
    if key_data.get("usada"):
        bot.reply_to(message, "❌ Esta Key ya fue utilizada por otra persona.")
        return
    
    # Verificar si el nombre de usuario ya existe en Linux
    check_user = subprocess.run(["id", user_ssh], capture_output=True)
    if check_user.returncode == 0:
        bot.reply_to(message, "❌ Ese nombre de usuario ya está registrado. Por favor intenta de nuevo con un nombre distinto.")
        return
        
    dias = key_data["dias"]
    limite = key_data["limite"]
    
    try:
        # Crear usuario nativo en el VPS
        subprocess.run(["useradd", "-m", "-s", "/bin/bash", user_ssh])
        
        # Ponerle la contraseña
        proc = subprocess.Popen(['chpasswd'], stdin=subprocess.PIPE)
        proc.communicate(input=f"{user_ssh}:{pass_ssh}".encode('utf-8'))
        
        # Ponerle fecha de caducidad
        date_exp = (datetime.now() + timedelta(days=dias)).strftime("%Y-%m-%d")
        subprocess.run(["chage", "-E", date_exp, user_ssh])
        
        # Fijar limite de conexiones simultaneas
        os.makedirs("/etc/vps_limites", exist_ok=True)
        with open(f"/etc/vps_limites/{user_ssh}", "w") as f:
            f.write(str(limite))
            
        # Marcar la Key como gastada en MongoDB
        keys_collection.update_one({"_id": key_data["_id"]}, {"$set": {"usada": True, "user_ssh": user_ssh}})
        
        # Instalar bloqueador de multi-login si no existe
        if not os.path.exists("/usr/local/bin/monitor_limites.sh"):
            monitor_code = "#!/bin/bash\nfor user in $(ls /etc/vps_limites/ 2>/dev/null); do\nlimite=$(cat /etc/vps_limites/$user)\nconex=$(ps -u$user 2>/dev/null | grep -c sshd)\nif [ \"$conex\" -gt \"$limite\" ]; then\npkill -u $user sshd\nfi\ndone\n"
            with open("/usr/local/bin/monitor_limites.sh", "w") as m:
                m.write(monitor_code)
            os.chmod("/usr/local/bin/monitor_limites.sh", 0o755)
            os.system("(crontab -l 2>/dev/null | grep -v 'monitor_limites.sh'; echo '* * * * * /usr/local/bin/monitor_limites.sh') | crontab -")

        bot.reply_to(message, f"✅ *¡Cuenta Creada Exitosamente en el Servidor!*\n\n👤 Usuario: `{user_ssh}`\n🔑 Clave: `{pass_ssh}`\n⏳ Válida hasta: {date_exp}\n📈 Límite: {limite} dispositivos", parse_mode="Markdown")
        
    except Exception as e:
        bot.reply_to(message, f"❌ Ocurrió un error al crear la cuenta en el VPS. Intenta de nuevo más tarde.")

bot.infinity_polling()
EOF_BOT
            
            echo -e " ${V}🛡️ Configurando servicio en segundo plano...   ${N}"
            cat << 'EOF_SRV' > /etc/systemd/system/zeroday-bot.service
[Unit]
Description=ZeroDay Telegram Bot (Key Manager)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zeroday_bot
ExecStart=/usr/bin/python3 /etc/zeroday_bot/bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF_SRV
            systemctl daemon-reload
            systemctl enable zeroday-bot >/dev/null 2>&1
            systemctl restart zeroday-bot
            sleep 2
            if systemctl is-active --quiet zeroday-bot; then
                echo -e "\n ${V}¡EL BOT FUE INSTALADO Y ESTÁ CORRIENDO EN SEGUNDO PLANO!   ${N}"
                echo -e " ${C}================================================${N}"
                echo -e " ${W}Ve a Telegram ahora mismo y envíale a tu bot esto:  ${N}"
                echo -e " ${A}/setadmin zerodayadmin${N}"
                echo -e " ${W}Para darte permisos de creador de llaves.${N}"
                echo -e " ${C}================================================${N}"
            else
                echo -e "\n ${R}Hubo un error al iniciar el Bot. Usa la opción 4 para ver logs.   ${N}"
            fi
            echo -ne " ${W}► Enter para continuar...   ${N}"; read
            ;;
        2) systemctl stop zeroday-bot; echo -e " ${A}Bot Detenido.${N}"; read -p " Enter..." ;;
        3) systemctl start zeroday-bot; echo -e " ${V}Bot Iniciado.${N}"; read -p " Enter..." ;;
        4) clear; echo -e "${A}=== REGISTRO DEL BOT EN VIVO ===${N}"; journalctl -u zeroday-bot -n 30 --no-pager; echo -ne "\n ${W}► Enter para regresar...   ${N}"; read ;;
        5) systemctl stop zeroday-bot >/dev/null 2>&1; systemctl disable zeroday-bot >/dev/null 2>&1; rm -rf /etc/zeroday_bot /etc/systemd/system/zeroday-bot.service; systemctl daemon-reload; echo -e " ${R}Bot Desinstalado por completo.${N}"; read -p " Enter..." ;;
        0) break ;;
    esac
done
}

while true; do
clear
info_sistema
echo -e " ${V}[01]${N}${W}⇨ CONTROL USUARIOS (SSH/SSL/VMESS)   ${N}"
echo -e " ${V}[02]${N} ${W}⇨ [!] OPTIMIZAR VPS      [${N}${R}OFF${N}${W}]${N}"
echo -e " ${V}[03]${N}${W}⇨ CONTADOR ONLINE USERS  [  ${N}${R}OFF${N}${W}]${N}"
echo -e " ${V}[04]${N}${W}⇨ AUTOINICIAR SCRIPT     [  ${N}${R}OFF${N}${W}]${N}"
echo -e " ${V}[05]${N}${W}⇨ INSTALADOR DE PROTOCOLOS   ${N}"
echo -e " ${V}[06]${N}${W}⇨ 📝 CONFIGURAR BANNER (MENSAJE)   ${N}"
echo -e " ${V}[07]${N}${W}⇨ 🎨 CAMBIAR COLORES DEL MENU   ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${V}[08]${N} ${W}⇨ [!] UPDATE / REMOVE${N}"
echo -e " ${V}[09]${N}${W}⇨ 🤖 GESTOR BOT TELEGRAM (KEYS)   ${N}"
echo -e " ${V}[0]${N}  ${W}⇨ [ SALIR ]${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -ne " ${W}► Opcion :   ${N}"; read opcion
case $opcion in
1) menu_usuarios ;;
2) clear; ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 8080/tcp; ufw allow 53/udp; ufw allow 5300/udp; ufw allow 36712/udp; ufw allow 7200/udp; ufw allow 7300/udp; ufw --force enable; echo -e " ${V}Firewall Activo.${N}"; echo -ne " ${W}Enter para continuar...${N}"; read ;;
3|4|5|8) menu_protocolos ;;
6) configurar_banner ;;
7) configurar_colores ;;
9) menu_bot ;;
0) exit 0 ;;
*) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
esac
done
