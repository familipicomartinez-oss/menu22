#!/bin/bash

# ==========================================
# CEREBRO DE COLORES EXTENDIDOS 256 (NEÓN PURO MÁXIMO)
# ==========================================
C='\033[38;5;51m'; V='\033[38;5;46m'; A='\033[38;5;226m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;201m'; W='\033[38;5;231m'

if [ -f /etc/zeroday_tema.conf ]; then
    source /etc/zeroday_tema.conf
fi

# ==========================================
# AUTO-MANTENIMIENTO DE DISCO (EVITA DISCO AL 99.8%)
# ==========================================
limpiar_basura_disco() {
    local uso_disco=$(df / 2>/dev/null | awk 'NR==2 {gsub("%",""); print $5}')
    if [[ "$uso_disco" =~ ^[0-9]+$ ]] && [ "$uso_disco" -gt 85 ]; then
        journalctl --vacuum-size=10M >/dev/null 2>&1
        apt-get clean >/dev/null 2>&1
        rm -rf /tmp/* /var/log/*.gz /var/log/*.[0-9] >/dev/null 2>&1
    fi
}
limpiar_basura_disco

# ==========================================
# SINCRONIZACIÓN AUTOMÁTICA DE ZONA HORARIA
# ==========================================
sincronizar_hora_celular() {
    local ZONA_DEFAULT="America/Bogota"
    if [ -f /etc/zeroday_tz.conf ]; then
        ZONA_DEFAULT=$(cat /etc/zeroday_tz.conf)
    fi
    local ZONA_ACT=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
    if [ "$ZONA_ACT" != "$ZONA_DEFAULT" ]; then
        timedatectl set-timezone "$ZONA_DEFAULT" >/dev/null 2>&1
        ln -sf "/usr/share/zoneinfo/$ZONA_DEFAULT" /etc/localtime >/dev/null 2>&1
        timedatectl set-ntp true >/dev/null 2>&1
    fi
}
sincronizar_hora_celular

# ==========================================
# BLINDAJE AUTOMÁTICO DE ESTABILIDAD SSHD Y RED
# ==========================================
optimizar_sshd_estabilidad() {
    if [ -f /etc/ssh/sshd_config ] && ! grep -q "^MaxStartups 100:30:200" /etc/ssh/sshd_config 2>/dev/null; then
        sed -i '/^ClientAliveInterval/d;/^ClientAliveCountMax/d;/^TCPKeepAlive/d;/^MaxStartups/d;/^MaxSessions/d;/^UseDNS/d' /etc/ssh/sshd_config
        cat << 'EOF_SSH' >> /etc/ssh/sshd_config
TCPKeepAlive yes
ClientAliveInterval 30
ClientAliveCountMax 120
MaxStartups 100:30:200
MaxSessions 100
UseDNS no
EOF_SSH
        systemctl reload ssh >/dev/null 2>&1 || systemctl reload sshd >/dev/null 2>&1 || systemctl restart ssh >/dev/null 2>&1 || systemctl restart sshd >/dev/null 2>&1
    fi
    sysctl -w net.ipv4.tcp_keepalive_time=60 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_keepalive_intvl=10 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_keepalive_probes=6 >/dev/null 2>&1
}
optimizar_sshd_estabilidad

# ==========================================
# MOTOR ANTI-PUERTOS FANTASMAS Y RESETEADOR PROFUNDO
# ==========================================
liberar_puerto_fantasma() {
    local pt=$1
    local conservar=$2
    [ -z "$pt" ] && return

    fuser -k -9 "${pt}/tcp" >/dev/null 2>&1
    fuser -k -9 "${pt}/udp" >/dev/null 2>&1
    if command -v lsof >/dev/null 2>&1; then
        local pids=$(lsof -ti :"$pt" 2>/dev/null)
        [ -n "$pids" ] && kill -9 $pids >/dev/null 2>&1
    fi
    local ss_pids=$(ss -lptn "sport = :$pt" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | sort -u)
    [ -n "$ss_pids" ] && kill -9 $ss_pids >/dev/null 2>&1

    if [ "$conservar" != "v2ray" ] && [ -f /usr/local/etc/xray/puerto.txt ]; then
        if [ "$(cat /usr/local/etc/xray/puerto.txt 2>/dev/null | tr -d ' \n\r')" == "$pt" ]; then
            systemctl stop xray >/dev/null 2>&1
            pkill -9 xray >/dev/null 2>&1
            rm -f /usr/local/etc/xray/puerto.txt
        fi
    fi

    if [ "$conservar" != "reality" ] && [ -f /etc/reality/puerto.txt ]; then
        if [ "$(cat /etc/reality/puerto.txt 2>/dev/null | tr -d ' \n\r')" == "$pt" ]; then
            systemctl stop xray-reality >/dev/null 2>&1
            pkill -9 -f "xray run -c /etc/reality" >/dev/null 2>&1
            rm -f /etc/reality/puerto.txt
        fi
    fi

    if [ "$conservar" != "ssl" ] && [ -f /etc/stunnel/stunnel.conf ]; then
        if grep -qE "^accept[[:space:]]*=[[:space:]]*$pt$" /etc/stunnel/stunnel.conf 2>/dev/null; then
            systemctl stop stunnel4 >/dev/null 2>&1
            pkill -9 stunnel4 >/dev/null 2>&1
            awk -v p="$pt" 'BEGIN { RS=""; FS="\n" } { keep=1; for(i=1; i<=NF; i++) { if ($i ~ "^accept[ \t]*=[ \t]*" p "$") keep=0 } if (keep) print $0 "\n" }' /etc/stunnel/stunnel.conf > /etc/stunnel/stunnel.conf.tmp
            mv -f /etc/stunnel/stunnel.conf.tmp /etc/stunnel/stunnel.conf
            if grep -q '^accept' /etc/stunnel/stunnel.conf 2>/dev/null; then
                systemctl start stunnel4 >/dev/null 2>&1
            fi
        fi
    fi

    if [ "$conservar" != "python" ] && [ -f /etc/proxy.py ]; then
        local pt_py=$(grep "bind" /etc/proxy.py 2>/dev/null | awk -F',' '{print $2}' | tr -d ' )\n\r')
        if [ "$pt_py" == "$pt" ]; then
            systemctl stop proxypy >/dev/null 2>&1
            pkill -9 -f "/etc/proxy.py" >/dev/null 2>&1
            rm -f /etc/proxy.py /etc/systemd/system/proxypy.service
            systemctl daemon-reload
        fi
    fi

    if [ "$conservar" != "ssr" ] && [ -f /etc/ssr/puerto.txt ]; then
        if [ "$(cat /etc/ssr/puerto.txt 2>/dev/null | tr -d ' \n\r')" == "$pt" ]; then
            systemctl stop ssr-server >/dev/null 2>&1
            pkill -9 -f "shadowsocksr" >/dev/null 2>&1
            rm -f /etc/ssr/puerto.txt
        fi
    fi

    if [ "$conservar" != "hcr" ] && [ -f /etc/hcr/config ]; then
        source /etc/hcr/config 2>/dev/null
        if [ "$P_INJ" == "$pt" ]; then
            systemctl stop hcr-server >/dev/null 2>&1
            pkill -9 -f "hcr_server.conf" >/dev/null 2>&1
            pkill -9 -f "hcr_plain.py" >/dev/null 2>&1
            rm -f /etc/hcr/config
        fi
    fi

    if [ "$conservar" != "bhttp" ] && [ -f /etc/bhttp/config ]; then
        source /etc/bhttp/config 2>/dev/null
        if [ "$BHTTP_PORT" == "$pt" ]; then
            systemctl stop bhttp-server >/dev/null 2>&1
            pkill -9 -f "/etc/bhttp/bhttp_proxy.py" >/dev/null 2>&1
            rm -f /etc/bhttp/config
        fi
    fi

    fuser -k -9 "${pt}/tcp" >/dev/null 2>&1
    lsof -ti :"$pt" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
    sleep 0.5
}

resetear_ssl_completo() {
    echo -e " ${A}⏳ Reseteando SSL (Stunnel4) y eliminando puertos fantasmas...   ${N}"
    if [ -f /etc/stunnel/stunnel.conf ]; then
        for p_s in $(grep '^accept' /etc/stunnel/stunnel.conf | awk -F'=' '{print $NF}' | awk -F':' '{print $NF}' | tr -d ' \n\r'); do
            fuser -k -9 "${p_s}/tcp" >/dev/null 2>&1
            lsof -ti :"$p_s" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
        done
    fi
    systemctl stop stunnel4 >/dev/null 2>&1
    pkill -9 stunnel4 >/dev/null 2>&1
    rm -f /etc/stunnel/stunnel.conf /var/run/stunnel4.pid /var/run/stunnel4/stunnel.pid
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de SSL (Stunnel4) eliminados por completo.   ${N}"
}

resetear_v2ray_completo() {
    echo -e " ${A}⏳ Reseteando V2Ray / Xray y liberando puertos...   ${N}"
    if [ -f /usr/local/etc/xray/puerto.txt ]; then
        local p_v=$(cat /usr/local/etc/xray/puerto.txt | tr -d ' \n\r')
        fuser -k -9 "${p_v}/tcp" >/dev/null 2>&1
        lsof -ti :"$p_v" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
    fi
    systemctl stop xray >/dev/null 2>&1
    systemctl stop v2ray >/dev/null 2>&1
    pkill -9 xray >/dev/null 2>&1
    pkill -9 v2ray >/dev/null 2>&1
    rm -rf /usr/local/etc/xray
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de V2Ray/Xray reseteados por completo.   ${N}"
}

resetear_reality_completo() {
    echo -e " ${A}⏳ Reseteando VLESS+REALITY y liberando puertos...   ${N}"
    if [ -f /etc/reality/puerto.txt ]; then
        local p_r=$(cat /etc/reality/puerto.txt | tr -d ' \n\r')
        fuser -k -9 "${p_r}/tcp" >/dev/null 2>&1
        lsof -ti :"$p_r" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
    fi
    systemctl stop xray-reality >/dev/null 2>&1
    systemctl disable xray-reality >/dev/null 2>&1
    pkill -9 -f "xray run -c /etc/reality" >/dev/null 2>&1
    rm -rf /etc/reality /etc/systemd/system/xray-reality.service
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de REALITY reseteados por completo.   ${N}"
}

resetear_python_completo() {
    echo -e " ${A}⏳ Reseteando Proxy Python y liberando puertos...   ${N}"
    if [ -f /etc/proxy.py ]; then
        local p_py=$(grep "bind" /etc/proxy.py 2>/dev/null | awk -F',' '{print $2}' | tr -d ' )\n\r')
        [ -n "$p_py" ] && fuser -k -9 "${p_py}/tcp" >/dev/null 2>&1
        [ -n "$p_py" ] && lsof -ti :"$p_py" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
    fi
    systemctl stop proxypy >/dev/null 2>&1
    systemctl disable proxypy >/dev/null 2>&1
    pkill -9 -f "/etc/proxy.py" >/dev/null 2>&1
    rm -f /etc/proxy.py /etc/systemd/system/proxypy.service
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de Proxy Python reseteados por completo.   ${N}"
}

resetear_bhttp_completo() {
    echo -e " ${A}⏳ Reseteando BHTTP Server y liberando puertos...   ${N}"
    if [ -f /etc/bhttp/config ]; then
        source /etc/bhttp/config 2>/dev/null
        [ -n "$BHTTP_PORT" ] && fuser -k -9 "${BHTTP_PORT}/tcp" >/dev/null 2>&1
    fi
    systemctl stop bhttp-server >/dev/null 2>&1
    systemctl disable bhttp-server >/dev/null 2>&1
    pkill -9 -f "/etc/bhttp/bhttp_proxy.py" >/dev/null 2>&1
    rm -rf /etc/bhttp /etc/systemd/system/bhttp-server.service
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de BHTTP Server reseteados por completo.   ${N}"
}

resetear_ssr_completo() {
    echo -e " ${A}⏳ Reseteando ShadowsocksR y liberando puertos...   ${N}"
    if [ -f /etc/ssr/puerto.txt ]; then
        local p_ssr=$(cat /etc/ssr/puerto.txt | tr -d ' \n\r')
        fuser -k -9 "${p_ssr}/tcp" >/dev/null 2>&1
        fuser -k -9 "${p_ssr}/udp" >/dev/null 2>&1
    fi
    systemctl stop ssr-server >/dev/null 2>&1
    pkill -9 -f "shadowsocksr" >/dev/null 2>&1
    rm -f /etc/ssr/puerto.txt /etc/ssr/config.json /etc/ssr/datos.conf
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de ShadowsocksR reseteados por completo.   ${N}"
}

resetear_hcr_completo() {
    echo -e " ${A}⏳ Reseteando HCR Server y liberando puertos...   ${N}"
    if [ -f /etc/hcr/config ]; then
        source /etc/hcr/config 2>/dev/null
        [ -n "$P_INJ" ] && fuser -k -9 "${P_INJ}/tcp" >/dev/null 2>&1
    fi
    systemctl stop hcr-server >/dev/null 2>&1
    systemctl disable hcr-server >/dev/null 2>&1
    pkill -9 -f "hcr_server.conf" >/dev/null 2>&1
    pkill -9 -f "hcr_plain.py" >/dev/null 2>&1
    rm -rf /etc/hcr /etc/systemd/system/hcr-server.service
    systemctl daemon-reload
    echo -e " ${V}✓ Puertos y rastros de HCR Server reseteados por completo.   ${N}"
}

menu_limpiador_puertos() {
    while true; do
        clear
        echo -e "${C}================================================${N}"
        echo -e "   ${A}🧹 LIMPIADOR Y RESETEADOR DE PUERTOS FANTASMAS 🧹   ${N}"
        echo -e "${C}================================================${N}"
        echo -e " ${W}Elimina rastros de puertos que quedaron bloqueados.${N}"
        echo -e "${C}────────────────────────────────────────────────────────${N}"
        echo -e " ${V}[1]${N} ${W}🎯 Destrabar un Puerto Específico (Ej: 443, 80, 8080)   ${N}"
        echo -e " ${V}[2]${N} ${W}🔒 Resetear Puertos de SSL (Stunnel4)   ${N}"
        echo -e " ${V}[3]${N} ${W}🚀 Resetear Puertos de V2Ray / Xray   ${N}"
        echo -e " ${V}[4]${N} ${W}🐍 Resetear Puertos de Proxy Python   ${N}"
        echo -e " ${V}[5]${N} ${W}🛡️ Resetear Puertos de ShadowsocksR (SSR)   ${N}"
        echo -e " ${V}[6]${N} ${W}💉 Resetear Puertos de HCR Server   ${N}"
        echo -e " ${V}[7]${N} ${W}🌌 Resetear Puertos de VLESS+REALITY   ${N}"
        echo -e " ${V}[8]${N} ${W}⚡ Resetear Puertos de BHTTP Server   ${N}"
        echo -e " ${R}[9]${N} ${W}🔥 RESETEAR TODOS LOS PUERTOS Y PROTOCOLOS (TOTAL)   ${N}"
        echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
        echo -e "${C}================================================${N}"
        echo -ne " ${W}► Opcion : ${N}"; read op_clean

        case $op_clean in
            1)
                echo -e "\n ${W}► Ingresa el puerto fantasma a limpiar:${N}"
                echo -ne " ${V}► ${N}"; read pt_clean
                if [[ "$pt_clean" =~ ^[0-9]+$ ]] && [ "$pt_clean" != "22" ]; then
                    echo -e " ${A}⏳ Eliminando todo rastro del puerto $pt_clean...   ${N}"
                    liberar_puerto_fantasma "$pt_clean" "ninguno"
                    echo -e " ${V}¡Puerto $pt_clean completamente limpio y libre para usar!   ${N}"
                else
                    echo -e " ${R}Puerto inválido o protegido (22).   ${N}"
                fi
                echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
            2) resetear_ssl_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            3) resetear_v2ray_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            4) resetear_python_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            5) resetear_ssr_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            6) resetear_hcr_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            7) resetear_reality_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            8) resetear_bhttp_completo; echo -e "\n ${W}► Presiona Enter...${N}"; read ;;
            9)
                echo -e "\n ${R}⚠️ Ejecutando limpieza profunda de TODOS los puertos fantasmas...   ${N}"
                resetear_ssl_completo
                resetear_v2ray_completo
                resetear_python_completo
                resetear_ssr_completo
                resetear_hcr_completo
                resetear_reality_completo
                resetear_bhttp_completo
                for p_comun in 80 442 443 444 445 8080 8880 8888 8443; do
                    fuser -k -9 "${p_comun}/tcp" >/dev/null 2>&1
                    lsof -ti :"$p_comun" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
                done
                systemctl restart ssh >/dev/null 2>&1 || systemctl restart sshd >/dev/null 2>&1
                echo -e "\n ${V}¡LIMPIEZA TOTAL COMPLETADA! Todos los puertos están como nuevos.   ${N}"
                echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
            0) break ;;
            *) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
        esac
    done
}

menu_zona_horaria() {
    while true; do
        clear
        ZONA_ACTUAL=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
        HORA_ACTUAL=$(date +'%d/%m/%Y - %I:%M:%S %p')
        echo -e "${C}================================================${N}"
        echo -e "       ${A}🕒 CONFIGURADOR DE ZONA HORARIA 🕒   ${N}"
        echo -e "${C}================================================${N}"
        echo -e " ${W}🔹 Zona Actual :${N} ${V}$ZONA_ACTUAL   ${N}"
        echo -e " ${W}🔹 Hora Exacta :${N} ${A}$HORA_ACTUAL   ${N}"
        echo -e "${C}────────────────────────────────────────────────────────${N}"
        echo -e " ${V}[1]${N} ${W}🇨🇴 Hora de Colombia / Perú / Ecuador (America/Bogota)   ${N}"
        echo -e " ${V}[2]${N} ${W}🇲🇽 Hora de México CDMX (America/Mexico_City)   ${N}"
        echo -e " ${V}[3]${N} ${W}🇻🇪 Hora de Venezuela / Bolivia (America/Caracas)   ${N}"
        echo -e " ${V}[4]${N} ${W}🇦🇷 Hora de Argentina / Chile (America/Argentina/Buenos_Aires)   ${N}"
        echo -e " ${V}[5]${N} ${W}🇺🇸 Hora de Miami / New York (America/New_York)   ${N}"
        echo -e " ${V}[6]${N} ${W}✍️  Escribir otra Zona Horaria manualmente   ${N}"
        echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
        echo -e "${C}================================================${N}"
        echo -ne " ${W}► Opcion : ${N}"; read op_tz
        case $op_tz in
            1) TZ_SEL="America/Bogota" ;;
            2) TZ_SEL="America/Mexico_City" ;;
            3) TZ_SEL="America/Caracas" ;;
            4) TZ_SEL="America/Argentina/Buenos_Aires" ;;
            5) TZ_SEL="America/New_York" ;;
            6)
                echo -e " ${W}► Escribe tu Zona (Ej: America/Bogota):${N}"
                echo -ne " ${V}► ${N}"; read TZ_SEL
                ;;
            0) break ;;
            *) continue ;;
        esac
        if [ -n "$TZ_SEL" ] && [ -f "/usr/share/zoneinfo/$TZ_SEL" ]; then
            echo "$TZ_SEL" > /etc/zeroday_tz.conf
            timedatectl set-timezone "$TZ_SEL" >/dev/null 2>&1
            ln -sf "/usr/share/zoneinfo/$TZ_SEL" /etc/localtime >/dev/null 2>&1
            timedatectl set-ntp true >/dev/null 2>&1
            echo -e "\n ${V}¡Hora sincronizada con éxito!: $(date +'%d/%m/%Y - %I:%M:%S %p')   ${N}"
        else
            echo -e "\n ${R}Zona horaria no encontrada.   ${N}"
        fi
        echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
    done
}

IP_VPS=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$IP_VPS" ] && IP_VPS=$(curl -4 -s --connect-timeout 3 ifconfig.me 2>/dev/null || echo "Desconocida")
es() { systemctl is-active --quiet $1 && echo -e "${V}[ON] ${N}" || echo -e "${R}[OFF]${N}"; }
ep() { ss -tlnp | grep -qE ":$1\b" > /dev/null 2>&1 || ss -ulnp | grep -qE ":$1\b" > /dev/null 2>&1 && echo -e "${V}[ON] ${N}" || echo -e "${R}[OFF]${N}"; }

info_sistema() {
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USADA=$(free -m | awk '/Mem:/ {print $3}')
LIBRE_RAM=$(free -m | awk '/Mem:/ {print $4}')
PORCENT_RAM=$(( (MEM_USADA * 100) / MEM_TOTAL ))
S_OS=$(grep -oP '(?<=PRETTY_NAME=")[^"]+' /etc/os-release 2>/dev/null || echo "Linux VPS")
S_ARCH=$(uname -m)
S_CPU=$(nproc)
FECHA_ACT=$(date +'%d/%m/%Y - %I:%M %p')
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

ss -tlnp | grep -qE ":22\b" && agregar_puerto "🔹 SSH: ${V}22${N}"

if [ -f /usr/local/etc/xray/puerto.txt ]; then
    PT_V2=$(cat /usr/local/etc/xray/puerto.txt | tr -d ' \n\r')
    if [ -n "$PT_V2" ] && ss -tlnp | grep -qE ":${PT_V2}\b"; then
        agregar_puerto "🔹 V2RAY: ${V}$PT_V2${N}"
    fi
fi

if [ -f /etc/reality/puerto.txt ]; then
    PT_REAL=$(cat /etc/reality/puerto.txt | tr -d ' \n\r')
    if [ -n "$PT_REAL" ] && ss -tlnp | grep -qE ":${PT_REAL}\b"; then
        agregar_puerto "🔹 REALITY: ${A}$PT_REAL${N}"
    fi
fi

if [ -f /etc/ssr/puerto.txt ]; then
    PT_SSR=$(cat /etc/ssr/puerto.txt | tr -d ' \n\r')
    if [ -n "$PT_SSR" ] && ss -tlnp | grep -qE ":${PT_SSR}\b"; then
        agregar_puerto "🔹 SSR: ${V}$PT_SSR${N}"
    fi
fi

if [ -f /etc/proxy.py ]; then
    PT_PY=$(grep "bind" /etc/proxy.py | awk -F',' '{print $2}' | tr -d ' )\n\r')
    if [ -n "$PT_PY" ] && ss -tlnp | grep -qE ":${PT_PY}\b"; then
        agregar_puerto "🔹 PROXY: ${V}$PT_PY${N}"
    fi
fi

if [ -f /etc/bhttp/config ]; then
    source /etc/bhttp/config 2>/dev/null
    if [ -n "$BHTTP_PORT" ] && ss -tlnp | grep -qE ":${BHTTP_PORT}\b"; then
        agregar_puerto "🔹 BHTTP: ${V}$BHTTP_PORT${N}"
    fi
fi

if [ -f /etc/stunnel/stunnel.conf ]; then
    for p_ssl in $(grep '^accept' /etc/stunnel/stunnel.conf | awk -F'=' '{print $NF}' | awk -F':' '{print $NF}' | tr -d ' \n\r'); do
        if [ -n "$p_ssl" ] && ss -tlnp | grep -qE ":${p_ssl}\b"; then
            agregar_puerto "🔹 SSL: ${V}$p_ssl${N}"
        fi
    done
fi

ss -ulnp | grep -qE ":36712\b" && agregar_puerto "🔹 UDP: ${V}36712${N}"
ss -ulnp | grep -qE ":5300\b" && agregar_puerto "🔹 SlowDNS: ${V}5300${N}"
ss -tlnp | grep -qE ":7300\b" && agregar_puerto "🔹 BadVPN: ${V}7300${N}"
ss -tlnp | grep -qE ":7200\b" && agregar_puerto "🔹 BadVPN: ${V}7200${N}"

if [ -f /etc/hcr/config ]; then
    source /etc/hcr/config 2>/dev/null
    if [ -n "$P_INJ" ] && ss -tlnp | grep -qE ":${P_INJ}\b"; then
        agregar_puerto "🔹 HCR: ${V}$P_INJ${N}"
    else
        agregar_puerto "🔹 HCR: ${R}CERRADO ($P_INJ)${N}"
    fi
fi

[ -z "$STR_PORTS" ] && STR_PORTS="🔹  ${R}Sin puertos abiertos actualmente   ${N}"
echo -e "${C}=========>>>>> 🌿 Script ZeroDay 🌿 <<<<<=========   ${N}"
echo -e " ${V}$IP_VPS  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}🔹 S.O:  ${N}${V}$S_OS${N}  ${W}🔹 Base:  ${N}${V}$S_ARCH${N}  ${W}🔹 CPU:  ${N}${V}$S_CPU  ${N}"
echo -e " ${W}🔹 IP:  ${N}${V}$IP_VPS${N}  ${W}🔹 FECHA:  ${N}${A}$FECHA_ACT  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}Key: ${V}Verified [ ZeroDay © ] (V6.3)  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${M}🟢 PUERTOS ACTIVOS:   ${N}"
echo -e " $STR_PORTS"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${W}🔹 TOTAL:  ${N}${A}${MEM_TOTAL}M${N} ${W}🔹 M|LIBRE:  ${N}${V}${LIBRE_RAM}M${N} ${W}🔹 EN USO:  ${N}${R}${MEM_USADA}M  ${N}"
echo -e " ${W}🔹 U/RAM:  ${N}${M}${PORCENT_RAM}%  ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
}

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
                limite=$(cat /etc/vps_limites/$user | tr -d ' \n\r')
            else
                limite="?"
            fi

            conex=$(ps -u "$user" -o comm= 2>/dev/null | grep -c "^sshd$")

            if [ "$conex" -gt 0 ]; then
                INFO_CON=$(who | grep "^$user " | head -n 1)
                if [ -n "$INFO_CON" ]; then
                    HORA=$(echo "$INFO_CON" | awk '{print $4}')
                    IP_CLI=$(echo "$INFO_CON" | awk '{print $5}' | tr -d '()')
                else
                    HORA="Activo"
                    IP_CLI="Túnel/VPN"
                fi
                echo -e " 👤  ${W}$user  ${N}-> ${V}[ ONLINE ]  ${N}${W}(Conex: $conex/$limite | Desde: $HORA | IP: $IP_CLI)   ${N}"
            else
                ULTIMA=$(last -n 1 "$user" 2>/dev/null | head -n 1)
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
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
echo -ne " ${W}► Opcion : ${N}"; read op_user
case $op_user in
1)
clear
echo -e "${C}================================================${N}"
echo -e "       ${A}⚜️  CREADOR DE CUENTAS TIPO ⚜️   ${N}"
echo -e "${C}================================================${N}"

echo -e " ${W}👤 Nombre de usuario:${N}"
echo -ne " ${V}► ${N}"; read u

echo -e " ${W}🔑 Contraseña:${N}"
echo -ne " ${V}► ${N}"; read p

echo -e " ${W}⏳ Dias de duración (Ej: 30):${N}"
echo -ne " ${V}► ${N}"; read d; d=${d:-30}

echo -e " ${W}📈 Límite de conexiones simultáneas (Ej: 2):${N}"
echo -ne " ${V}► ${N}"; read l; l=${l:-2}

optimizar_sshd_estabilidad
useradd -m -s /bin/bash "$u" 2>/dev/null
echo "$u:$p" | chpasswd 2>/dev/null
chage -E $(date -d "+$d days" +%Y-%m-%d) "$u" 2>/dev/null || true
mkdir -p /etc/vps_limites
echo "$l" > "/etc/vps_limites/$u"

cat << 'EOF_MONITOR' > /usr/local/bin/monitor_limites.sh
#!/bin/bash
for user in $(ls /etc/vps_limites/ 2>/dev/null); do
    limite=$(cat /etc/vps_limites/$user 2>/dev/null | tr -d ' \n\r')
    [[ ! "$limite" =~ ^[0-9]+$ ]] && continue
    conex_reales=$(netstat -anp 2>/dev/null | grep ESTABLISHED | grep "sshd: $user\|dropbear" | awk '{print $5}' | cut -d: -f1 | sort | uniq | wc -l)
    if [ "$conex_reales" -gt "$limite" ]; then
        pkill -u "$user" > /dev/null 2>&1
        killall -u "$user" > /dev/null 2>&1
    fi
done
EOF_MONITOR
chmod +x /usr/local/bin/monitor_limites.sh
(crontab -l 2>/dev/null | grep -v "monitor_limites.sh"; echo "* * * * * /usr/local/bin/monitor_limites.sh") | crontab - 2>/dev/null

apt-get install figlet -y >/dev/null 2>&1
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
ss -tlnp | grep -qE ":22\b" && STR_P+="${W}🔹 SSH:  ${V}22${N}   "
if ss -tlnp | grep -qE ":80\b"; then
    systemctl is-active --quiet xray && grep -q '"port": 80' /usr/local/etc/xray/config.json 2>/dev/null && STR_P+="${W}🔹 V2RAY:  ${V}80${N}   " || STR_P+="${W}🔹 PROXY:  ${V}80${N}   "
fi
if ss -tlnp | grep -qE ":443\b"; then
    systemctl is-active --quiet xray && grep -q '"port": 443' /usr/local/etc/xray/config.json 2>/dev/null && STR_P+="${W}🔹 V2RAY:  ${V}443${N}   " || STR_P+="${W}🔹 SSL:  ${V}443${N}   "
fi
ss -ulnp | grep -qE ":36712\b" && STR_P+="${W}🔹 UDP:  ${V}36712${N}   "
ss -ulnp | grep -qE ":5300\b" && STR_P+="${W}🔹 SlowDNS:  ${V}5300${N}   "
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
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
;;
2)
    echo -e " ${W}👤 Usuario a eliminar:${N}"
    echo -ne " ${V}► ${N}"; read u
    pkill -u "$u" 2>/dev/null; userdel -r -f "$u" 2>/dev/null && rm -f /etc/vps_limites/$u && echo -e " ${V}Eliminado.   ${N}" || echo -e " ${R}Error.   ${N}"
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
;;
3)
    awk -F: '$3 >= 1000 && $1 != "nobody" {print " -> " $1}' /etc/passwd
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
;;
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
echo -e " ${A}[6]${N} ${W}🧹 Resetear / Limpiar Puertos Fantasmas SSL   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion : ${N}"; read op_ssl
case $op_ssl in
1)
p1=22
echo -e " ${W}► Puerto externo SSL a elegir (Ej: 443, 444):${N}"
echo -ne " ${V}► ${N}"; read p2; p2=${p2:-443}
echo -e " ${A}⏳ Limpiando posibles puertos fantasmas en $p2 y preparando Stunnel4...   ${N}"
apt-get update -y >/dev/null 2>&1
apt-get install stunnel4 openssl psmisc lsof -y >/dev/null 2>&1
optimizar_sshd_estabilidad
systemctl stop stunnel4 >/dev/null 2>&1
pkill -9 stunnel4 >/dev/null 2>&1
liberar_puerto_fantasma "$p2" "ssl"

mkdir -p /etc/stunnel
rm -f /var/run/stunnel4.pid
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem -subj "/CN=ZeroDay/O=VPN/C=CO" >/dev/null 2>&1
chmod 600 /etc/stunnel/stunnel.pem

cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
socket = l:SO_KEEPALIVE=1
socket = r:SO_KEEPALIVE=1
TIMEOUTidle = 86400
TIMEOUTclose = 0
TIMEOUTconnect = 300

[stunnel-custom-$p2]
accept = $p2
connect = 127.0.0.1:$p1
EOF

cat << 'EOF_S' > /etc/systemd/system/stunnel4.service
[Unit]
Description=SSL Tunnel Native Service (ZeroDay)
After=network.target

[Service]
Type=forking
PIDFile=/var/run/stunnel4.pid
ExecStart=/usr/bin/stunnel4 /etc/stunnel/stunnel.conf
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF_S

sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null || echo "ENABLED=1" > /etc/default/stunnel4
iptables -I INPUT -p tcp --dport $p2 -j ACCEPT >/dev/null 2>&1
ufw allow $p2/tcp >/dev/null 2>&1
systemctl daemon-reload
systemctl enable stunnel4 >/dev/null 2>&1
systemctl restart stunnel4
sleep 2

if systemctl is-active --quiet stunnel4 && ss -tlnp | grep -qE ":${p2}\b"; then
    echo -e " ${V}¡SSL instalado, blindado contra desconexiones y activo en puerto $p2!   ${N}"
else
    echo -e " ${R}ERROR: Stunnel4 no pudo iniciar en el puerto $p2. Detalles del sistema:   ${N}"
    journalctl -u stunnel4.service -n 5 --no-pager
fi
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
;;
2)
if [ ! -f /etc/stunnel/stunnel.conf ]; then
    echo -e "\n ${R}ERROR: Debes Instalar el SSL primero (Opción 1).   ${N}"
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
    continue
fi
echo -e "\n${C}=== ADICIONAR PUERTO SSL ===   ${N}"
echo -e " ${W}► Puerto Local Interno (Default: 22):${N}"
echo -ne " ${V}► ${N}"; read p_int; p_int=${p_int:-22}
echo -e " ${W}► NUEVO Puerto SSL a escuchar (Ej: 444, 445):${N}"
echo -ne " ${V}► ${N}"; read p_ext
if [ -z "$p_ext" ]; then
    echo -e " ${R}Cancelado.  ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read; continue
fi
systemctl stop stunnel4 >/dev/null 2>&1
pkill -9 stunnel4 >/dev/null 2>&1
awk -v p="$p_ext" 'BEGIN { RS=""; FS="\n" } { keep=1; for(i=1; i<=NF; i++) { if ($i ~ "^accept[ \t]*=[ \t]*" p "$") keep=0 } if (keep) print $0 "\n" }' /etc/stunnel/stunnel.conf > /etc/stunnel/stunnel.conf.tmp
mv -f /etc/stunnel/stunnel.conf.tmp /etc/stunnel/stunnel.conf

liberar_puerto_fantasma "$p_ext" "ssl"

echo -e "\n[stunnel-extra-$p_ext]\naccept = $p_ext\nconnect = 127.0.0.1:$p_int" >> /etc/stunnel/stunnel.conf
iptables -I INPUT -p tcp --dport $p_ext -j ACCEPT >/dev/null 2>&1
ufw allow $p_ext/tcp >/dev/null 2>&1
systemctl daemon-reload
systemctl restart stunnel4
sleep 1
if systemctl is-active --quiet stunnel4 && ss -tlnp | grep -qE ":${p_ext}\b"; then
    echo -e "\n ${V}¡Puerto SSL $p_ext adicionado exitosamente y redirigiendo al $p_int!   ${N}"
else
    echo -e "\n ${R}Error al levantar el puerto $p_ext. Verifica que no esté ocupado.   ${N}"
fi
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
;;
3)
if [ ! -f /etc/stunnel/stunnel.conf ]; then
    echo -e "\n ${R}ERROR: No hay SSL instalado.   ${N}"
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
    continue
fi
clear
echo -e "${C}=== ELIMINAR PUERTO SSL ===   ${N}"
echo -e " ${W}Puertos SSL actualmente activos:   ${N}"
PUERTOS_ACTUALES=$(grep '^accept' /etc/stunnel/stunnel.conf | awk -F'=' '{print $NF}' | awk -F':' '{print $NF}' | tr -d ' \n\r')
if [ -z "$PUERTOS_ACTUALES" ]; then
    echo -e " ${R}No se encontraron puertos configurados.   ${N}"
else
    for pt in $PUERTOS_ACTUALES; do
        echo -e " 🔹 Puerto:  ${V}$pt   ${N}"
    done
fi
echo -e "${C}────────────────────────────────────────${N}"
echo -e " ${W}► Ingresa el puerto a eliminar:${N}"
echo -ne " ${V}► ${N}"; read p_del
if [ -z "$p_del" ]; then
    echo -e " ${R}Cancelado.  ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read; continue
fi

if grep -qE "^accept[[:space:]]*=[[:space:]]*$p_del$" /etc/stunnel/stunnel.conf; then
    systemctl stop stunnel4 >/dev/null 2>&1
    pkill -9 stunnel4 >/dev/null 2>&1
    awk -v p="$p_del" 'BEGIN { RS=""; FS="\n" } { keep=1; for(i=1; i<=NF; i++) { if ($i ~ "^accept[ \t]*=[ \t]*" p "$") keep=0 } if (keep) print $0 "\n" }' /etc/stunnel/stunnel.conf > /etc/stunnel/stunnel.conf.tmp
    mv -f /etc/stunnel/stunnel.conf.tmp /etc/stunnel/stunnel.conf

    fuser -k -9 "${p_del}/tcp" >/dev/null 2>&1
    lsof -ti :"$p_del" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
    ufw delete allow $p_del/tcp >/dev/null 2>&1

    if grep -q '^accept' /etc/stunnel/stunnel.conf 2>/dev/null; then
        systemctl start stunnel4 >/dev/null 2>&1
    fi
    echo -e "\n ${V}¡Puerto SSL $p_del eliminado de raíz y liberado de la memoria!   ${N}"
else
    echo -e "\n ${R}El puerto $p_del no existe en la configuración.   ${N}"
fi
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
;;
4) systemctl stop stunnel4 >/dev/null 2>&1; pkill -9 stunnel4 >/dev/null 2>&1; echo -e " ${A}Detenido y puertos liberados.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
5) resetear_ssl_completo; rm -f /etc/systemd/system/stunnel4.service; systemctl daemon-reload; apt-get purge stunnel4 -y >/dev/null 2>&1; rm -rf /etc/stunnel/; echo -e " ${R}Desinstalado.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
6) resetear_ssl_completo; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
0) break ;;
*) echo -e " ${R}Opción inválida.  ${N}"; sleep 1 ;;
esac
done
}

b64_url() { echo -n "$1" | base64 -w 0 | tr '+/' '-_' | tr -d '='; }
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
        echo -e "\n ${W}► Presiona Enter para volver...${N}"; read
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
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
}

configurar_cuenta_ssr() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "     ${A}⚙️ PARÁMETROS DE CUENTA SHADOWSOCKS-R ⚙️   ${N}"
    echo -e "${C}================================================${N}"

    echo -e " ${W}► IP o Dominio [Enter = $IP_VPS]:${N}"
    echo -ne " ${V}► ${N}"; read ssr_ip
    ssr_ip=${ssr_ip:-$IP_VPS}

    echo -e " ${W}► Nombre de Usuario [Default: ZeroDay]:${N}"
    echo -ne " ${V}► ${N}"; read ssr_user
    ssr_user=${ssr_user:-ZeroDay}

    echo -e " ${W}► Puerto SSR (Ej: 110, 443) [Default: 110]:${N}"
    echo -ne " ${V}► ${N}"; read ssr_port
    ssr_port=${ssr_port:-110}

    echo -e " ${W}► Contraseña [Default: zeroday123]:${N}"
    echo -ne " ${V}► ${N}"; read ssr_pass
    ssr_pass=${ssr_pass:-zeroday123}

    echo -e "\n ${A}Seleccione Tipo de Encriptación:   ${N}"
    echo -e " ${V}[1]${N} ${W}aes-256-cfb (Recomendado)   ${N}"
    echo -e " ${V}[2]${N} ${W}aes-128-cfb   ${N}"
    echo -e " ${W}► Opción [Default 1]:${N}"
    echo -ne " ${V}► ${N}"; read op_enc
    case $op_enc in
        2) ssr_method="aes-128-cfb" ;;
        *) ssr_method="aes-256-cfb" ;;
    esac

    echo -e "\n ${A}Seleccione Protocolo SSR:   ${N}"
    echo -e " ${V}[1]${N} ${W}origin (Recomendado)   ${N}"
    echo -e " ${V}[2]${N} ${W}auth_sha1_v4   ${N}"
    echo -e " ${W}► Opción [Default 1]:${N}"
    echo -ne " ${V}► ${N}"; read op_proto
    case $op_proto in
        2) ssr_proto="auth_sha1_v4" ;;
        *) ssr_proto="origin" ;;
    esac
    ssr_proto_cfg="$ssr_proto"

    echo -e "\n ${A}Seleccione Método de Ofuscación (OBFS):   ${N}"
    echo -e " ${V}[1]${N} ${W}tls1.2_ticket_auth (Ideal para SNI)   ${N}"
    echo -e " ${V}[2]${N} ${W}http_simple   ${N}"
    echo -e " ${V}[3]${N} ${W}plain (Sin ofuscación)   ${N}"
    echo -e " ${W}► Opción [Default 1]:${N}"
    echo -ne " ${V}► ${N}"; read op_obfs
    case $op_obfs in
        2) ssr_obfs="http_simple" ;;
        3) ssr_obfs="plain" ;;
        *) ssr_obfs="tls1.2_ticket_auth" ;;
    esac

    if [ "$ssr_obfs" != "plain" ]; then
        ssr_obfs_cfg="$ssr_obfs"
        echo -e " ${W}► Obfs Param / Host Bug (Ej: c.whatsapp.net) [Opcional]:${N}"
        echo -ne " ${V}► ${N}"; read ssr_obfs_param
    else
        ssr_obfs_cfg="plain"
        ssr_obfs_param=""
    fi

    liberar_puerto_fantasma "$ssr_port" "ssr"

    mkdir -p /etc/ssr
    cat <<EOF > /etc/ssr/config.json
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "server_port": $ssr_port,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "$ssr_pass",
    "timeout": 300,
    "udp_timeout": 120,
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
    ufw allow "$ssr_port"/tcp >/dev/null 2>&1
}

instalar_ssr() {
    configurar_cuenta_ssr
    echo -e "\n ${V}⏳ Instalando dependencias y librerías C/C++...   ${N}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y python3 git curl wget libsodium-dev openssl lsof psmisc >/dev/null 2>&1
    rm -rf /usr/local/shadowsocksr
    git clone -q -b akkariiin/master https://github.com/shadowsocksrr/shadowsocksr.git /usr/local/shadowsocksr 2>/dev/null || \
    git clone -q https://github.com/shadowsocksr-backup/shadowsocksr.git /usr/local/shadowsocksr 2>/dev/null
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
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
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
        echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
    echo -e " ${R}[7]${N} ${W}🗑️ Desinstalar ShadowsocksR   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️ REGRESAR AL MENÚ   ${N}"
    echo -e "${C}------------------------------------------------${N}"
    echo -ne " ${W}► Opción : ${N}"; read op_ssr
    case $op_ssr in
        1) instalar_ssr ;;
        2) mostrar_info_ssr ;;
        3)
            if [ ! -d /usr/local/shadowsocksr ]; then
                echo -e "\n ${R}[!] Primero instala ShadowsocksR con la Opción 1.   ${N}"
                sleep 2
            else
                if [ -f /etc/ssr/puerto.txt ]; then
                    OLD_SSR_PT=$(cat /etc/ssr/puerto.txt | tr -d ' \n\r')
                    fuser -k -9 "${OLD_SSR_PT}/tcp" >/dev/null 2>&1
                fi
                configurar_cuenta_ssr
                systemctl restart ssr-server
                echo -e "\n ${V}¡Configuración actualizada y reiniciada!   ${N}"
                sleep 1
                mostrar_info_ssr
            fi
            ;;
        4) systemctl restart ssr-server 2>/dev/null; echo -e "\n ${V}¡Servicio ShadowsocksR reiniciado!   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
        5) systemctl stop ssr-server 2>/dev/null; echo -e "\n ${A}Servicio ShadowsocksR detenido.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
        7)
            echo -e "\n ${W}► ¿Seguro que deseas eliminar ShadowsocksR? (s/n):${N}"
            echo -ne " ${V}► ${N}"; read conf_del
            if [[ "$conf_del" == "s" || "$conf_del" == "S" ]]; then
                resetear_ssr_completo
                systemctl disable ssr-server 2>/dev/null
                rm -rf /usr/local/shadowsocksr /etc/ssr /etc/systemd/system/ssr-server.service
                systemctl daemon-reload
                echo -e "\n ${V}ShadowsocksR desinstalado por completo.   ${N}"
            fi
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
            ;;
        0) break ;;
        *) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
    esac
done
}

menu_ssl_python() {
    while true; do
        clear
        ESTADO_SP=$(systemctl is-active --quiet stunnel4 && grep -q "stunnel-python" /etc/stunnel/stunnel.conf 2>/dev/null && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")
        echo -e "${C}================================================${N}"
        echo -e "   ${A}🔗 SSL Encadenado a PYTHON (WEBSOCKET) 🔗   ${N}"
        echo -e "${C}================================================${N}"
        echo -e " ${W}Estado:${N} $ESTADO_SP"
        echo -e "${C}------------------------------------------------${N}"
        echo -e " ${V}[1]${N} ${W}🟢 Instalar y Configurar (SSL -> Python -> SSH)   ${N}"
        echo -e " ${A}[2]${N} ${W}👁️ Ver Configuración para HTTP Custom   ${N}"
        echo -e " ${R}[3]${N} ${W}🗑️ Desinstalar / Limpiar Puertos   ${N}"
        echo -e " ${C}[0]${N} ${W}↩️ REGRESAR   ${N}"
        echo -e "${C}------------------------------------------------${N}"
        echo -ne " ${W}► Opción : ${N}"; read op_sp

        case $op_sp in
            1)
                clear
                echo -e "${C}=== INSTALACIÓN DE SSL -> PYTHON ===${N}"
                echo -e " ${W}► Puerto Externo SSL (El que pones en la app, Ej: 443):${N}"
                echo -ne " ${V}► ${N}"; read p_ext
                p_ext=${p_ext:-443}

                echo -e " ${W}► Puerto Interno Python (Oculto, Ej: 80):${N}"
                echo -ne " ${V}► ${N}"; read p_int
                p_int=${p_int:-80}

                echo -e " ${A}⏳ Limpiando puertos fantasmas y preparando instalación...${N}"
                liberar_puerto_fantasma "$p_ext" "ninguno"
                liberar_puerto_fantasma "$p_int" "ninguno"

                apt-get update -y >/dev/null 2>&1
                apt-get install python3 stunnel4 openssl lsof psmisc -y >/dev/null 2>&1
                
                cat << 'EOF_PY' > /etc/proxy.py
import socket, threading
def f(x, y):
    try:
        while True:
            a = x.recv(8192)
            if not a: break
            y.sendall(a)
    except: pass
    finally:
        try: x.close()
        except: pass
        try: y.close()
        except: pass

def c(s):
    d = None
    try:
        s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        s.settimeout(15)
        s.recv(4096)
        s.sendall(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
        d = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        d.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        d.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        d.settimeout(15)
        d.connect(('127.0.0.1', 22))
        s.settimeout(None)
        d.settimeout(None)
        threading.Thread(target=f, args=(s, d), daemon=True).start()
        threading.Thread(target=f, args=(d, s), daemon=True).start()
    except:
        try: s.close()
        except: pass
        if d:
            try: d.close()
            except: pass

sv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sv.bind(('0.0.0.0', PUERTO_AQUI))
sv.listen(500)
while True:
    try:
        cl, a = sv.accept()
        threading.Thread(target=c, args=(cl,), daemon=True).start()
    except: pass
EOF_PY
                sed -i "s/PUERTO_AQUI/$p_int/g" /etc/proxy.py
                echo -e "[Unit]\nDescription=Proxy Python WS\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/python3 /etc/proxy.py\nRestart=always\nRestartSec=2\nLimitNOFILE=65535\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/proxypy.service

                mkdir -p /etc/stunnel
                rm -f /var/run/stunnel4.pid
                openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem -subj "/CN=ZeroDay/O=VPN/C=CO" >/dev/null 2>&1
                chmod 600 /etc/stunnel/stunnel.pem

                cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
socket = l:SO_KEEPALIVE=1
socket = r:SO_KEEPALIVE=1
TIMEOUTidle = 86400
TIMEOUTclose = 0
TIMEOUTconnect = 300

[stunnel-python]
accept = $p_ext
connect = 127.0.0.1:$p_int
EOF

                sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null || echo "ENABLED=1" > /etc/default/stunnel4

                systemctl daemon-reload
                systemctl enable proxypy >/dev/null 2>&1
                systemctl restart proxypy
                systemctl enable stunnel4 >/dev/null 2>&1
                systemctl restart stunnel4

                iptables -I INPUT -p tcp --dport $p_ext -j ACCEPT >/dev/null 2>&1
                ufw allow $p_ext/tcp >/dev/null 2>&1

                echo -e "\n ${V}¡Módulo SSL->PYTHON Instalado y Activo en el puerto externo $p_ext!   ${N}"
                echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
                ;;
            2)
                clear
                echo -e "${C}=== CÓMO CONFIGURAR HTTP CUSTOM ===${N}"
                echo -e " ${W}1. En la pantalla de inicio, marca estas 2 casillas:${N}"
                echo -e "    ☑️ ${V}Payload${N}"
                echo -e "    ☑️ ${V}SSL (SNI)${N}"
                echo -e "\n ${W}2. En la cajita de Payload, pega exactamente esto:${N}"
                echo -e " ${A}GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]${N}"
                echo -e "\n ${W}3. En la cajita de SNI:${N}"
                echo -e " ${A}Pon la página permitida (Ej: prepago.movistar.co)${N}"
                echo -e "\n ${W}4. Puerto y Servidor:${N}"
                echo -e " ${A}Pon tu IP y el puerto externo SSL (Ej: ${IP_VPS}:443)${N}"
                echo -e "\n ${W}5. Pon los datos del usuario SSH que hayas creado y dale a Connect.${N}"
                echo -e "\n ${W}► Presiona Enter para regresar...${N}"; read
                ;;
            3)
                resetear_python_completo
                resetear_ssl_completo
                echo -e "\n ${W}► Presiona Enter...${N}"; read
                ;;
            0) break ;;
            *) echo -e " ${R}Opción inválida.${N}"; sleep 1 ;;
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
echo -e " ${R}[5]${N} ${W}🗑️  Desinstalar / Resetear Puerto Python   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion : ${N}"; read op_py
case $op_py in
3)
echo -e " ${W}► Puerto para el WebSocket (Ej: 80):${N}"
echo -ne " ${V}► ${N}"; read pt; pt=${pt:-80}
echo -e " ${A}Liberando el puerto $pt de rastros fantasmas y preparando Python...   ${N}"
optimizar_sshd_estabilidad
systemctl stop apache2 nginx dropbear proxypy 2>/dev/null
liberar_puerto_fantasma "$pt" "python"
apt-get update -y >/dev/null 2>&1
apt-get install python3 lsof psmisc -y >/dev/null 2>&1
cat << 'EOF_PY' > /etc/proxy.py
import socket, threading

def f(x, y):
    try:
        while True:
            a = x.recv(8192)
            if not a: break
            y.sendall(a)
    except: pass
    finally:
        try: x.close()
        except: pass
        try: y.close()
        except: pass

def c(s):
    d = None
    try:
        s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        s.settimeout(15)
        s.recv(4096)
        s.sendall(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
        d = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        d.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        d.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        d.settimeout(15)
        d.connect(('127.0.0.1', 22))
        s.settimeout(None)
        d.settimeout(None)
        threading.Thread(target=f, args=(s, d), daemon=True).start()
        threading.Thread(target=f, args=(d, s), daemon=True).start()
    except:
        try: s.close()
        except: pass
        if d:
            try: d.close()
            except: pass

sv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sv.bind(('0.0.0.0', PUERTO_AQUI))
sv.listen(500)
while True:
    try:
        cl, a = sv.accept()
        threading.Thread(target=c, args=(cl,), daemon=True).start()
    except: pass
EOF_PY
sed -i "s/PUERTO_AQUI/$pt/g" /etc/proxy.py
echo -e "[Unit]\nDescription=Proxy Python WS\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/python3 /etc/proxy.py\nRestart=always\nRestartSec=2\nLimitNOFILE=65535\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/proxypy.service
systemctl daemon-reload; systemctl enable proxypy >/dev/null 2>&1; systemctl restart proxypy
iptables -I INPUT -p tcp --dport $pt -j ACCEPT >/dev/null 2>&1
ufw allow $pt/tcp >/dev/null 2>&1
echo -e " ${V}¡WebSocket PRO Activo y Blindado en el puerto $pt!   ${N}"
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
4) systemctl stop proxypy >/dev/null 2>&1; pkill -9 -f "/etc/proxy.py" >/dev/null 2>&1; echo -e " ${A}Detenido.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
5) resetear_python_completo; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
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
echo -ne " ${W}► Opcion : ${N}"; read op_udp
case $op_udp in
1)
echo -e " ${W}Instalando servidor UDP Custom...   ${N}"
apt-get update -y >/dev/null 2>&1
apt-get install -y iptables curl >/dev/null 2>&1
curl -sL -A "Mozilla/5.0" "https://raw.githubusercontent.com/Haris131/UDP-Custom/main/udp-custom-linux-amd64" -o /usr/bin/udp-custom
chmod +x /usr/bin/udp-custom; mkdir -p /root/udp
echo -e "{\n  \"listen\": \":36712\",\n  \"stream_buffer\": 33554432,\n  \"receive_buffer\": 8388608,\n  \"auth\": {\n    \"mode\": \"passwords\"\n  }\n}" > /root/udp/config.json
echo -e "[Unit]\nDescription=UDP Custom\nAfter=network.target\n[Service]\nUser=root\nType=simple\nWorkingDirectory=/root/udp\nExecStart=/usr/bin/udp-custom server -exclude 53,5300,443,7200,7300\nRestart=always\nRestartSec=2\nLimitNOFILE=65535\n[Install]\nWantedBy=default.target" > /etc/systemd/system/udp-custom.service
systemctl daemon-reload; systemctl enable udp-custom >/dev/null 2>&1; systemctl restart udp-custom
iptables -t nat -D PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null
iptables -t nat -A PREROUTING -p udp -m multiport ! --dports 53,5300,443,7200,7300 -j REDIRECT --to-ports 36712 2>/dev/null || iptables -t nat -A PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null
ufw allow 36712/udp >/dev/null 2>&1
echo -e " ${V}¡UDP Custom Instalado y Activo (Puerto 36712)!   ${N}"
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
2) systemctl stop udp-custom; echo -e " ${A}Detenido.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
3) systemctl stop udp-custom; rm -rf /usr/bin/udp-custom /root/udp /etc/systemd/system/udp-custom.service; systemctl daemon-reload; iptables -t nat -D PREROUTING -p udp -m multiport ! --dports 53,5300,443,7200,7300 -j REDIRECT --to-ports 36712 2>/dev/null; iptables -t nat -D PREROUTING -p udp --dport 1:65535 -j REDIRECT --to-ports 36712 2>/dev/null; echo -e " ${R}Desinstalado.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
0) break ;;
esac
done
}

menu_badvpn() {
while true; do
clear
P_BAD72=$(ss -tlnp | grep -qE ":7200\b" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
P_BAD73=$(ss -tlnp | grep -qE ":7300\b" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
echo -e "${A}--- BADVPN UDP (VIDEOLLAMADAS) ---   ${N}"
echo -e " ${W}Estado: 7200${N} $P_BAD72 ${W}| 7300${N} $P_BAD73"
echo -e "${C}----------------------------------------${N}"
echo -e " ${V}[1]${N} ${W}🟢 Instalar / Iniciar BadVPN   ${N}"
echo -e " ${A}[2]${N} ${W}⏸️  Detener BadVPN   ${N}"
echo -e " ${R}[3]${N} ${W}🗑️  Desinstalar BadVPN   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver   ${N}"
echo -e "${C}----------------------------------------${N}"
echo -ne " ${W}► Opcion : ${N}"; read op_badvpn
case $op_badvpn in
1)
clear
echo -e "${C}=== INSTALACIÓN NATIVA BADVPN ===   ${N}"
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
    echo -e " ${A}⚙️ Compilando motor BadVPN...   ${N}"
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
    echo -e " ${V}Binario oficial instalado.   ${N}"

    echo -e "[Unit]\nDescription=BadVPN UDPGW 7300\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 100 --client-socket-sndbuf 0\nRestart=always\nRestartSec=3\nLimitNOFILE=65535\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/badvpn7300.service
    echo -e "[Unit]\nDescription=BadVPN UDPGW 7200\nAfter=network.target\n[Service]\nType=simple\nExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 100 --client-socket-sndbuf 0\nRestart=always\nRestartSec=3\nLimitNOFILE=65535\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/badvpn7200.service

    systemctl daemon-reload
    systemctl enable badvpn7300 >/dev/null 2>&1
    systemctl enable badvpn7200 >/dev/null 2>&1
    systemctl restart badvpn7300 >/dev/null 2>&1
    systemctl restart badvpn7200 >/dev/null 2>&1

    sleep 2
    if ss -tlnp | grep -qE ":7300\b"; then
        echo -e " ${V}¡BadVPN activado exitosamente en los puertos 7200 y 7300!   ${N}"
    else
        echo -e " ${R}Fallo al encender el servicio.   ${N}"
    fi
else
    echo -e "\n ${R}ERROR CRÍTICO: No se pudo compilar BadVPN.   ${N}"
fi
echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
2)
systemctl stop badvpn7300 2>/dev/null
systemctl stop badvpn7200 2>/dev/null
killall badvpn-udpgw 2>/dev/null
echo -e " ${A}BadVPN Detenido.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
3)
systemctl stop badvpn7300 2>/dev/null
systemctl stop badvpn7200 2>/dev/null
systemctl disable badvpn7300 2>/dev/null
systemctl disable badvpn7200 2>/dev/null
rm -f /etc/systemd/system/badvpn*.service /usr/bin/badvpn-udpgw
apt-get purge badvpn -y >/dev/null 2>&1
systemctl daemon-reload
killall badvpn-udpgw 2>/dev/null
echo -e " ${R}BadVPN Desinstalado por completo.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
0) break ;;
esac
done
}

# ==========================================
# GESTOR INDIVIDUAL DE CLIENTES V2RAY/XRAY (VMESS)
# ==========================================
v2ray_generar_link_vmess() {
    local u_uuid=$1
    local u_nombre=$2
    local dom_v2=$(cat /usr/local/etc/xray/dominio.txt 2>/dev/null | tr -d ' \n\r')
    local pt_v2=$(cat /usr/local/etc/xray/puerto.txt 2>/dev/null | tr -d ' \n\r')
    cat <<EOF > /tmp/vmess_tmp.json
{
  "v": "2",
  "ps": "$u_nombre",
  "add": "$IP_VPS",
  "port": "$pt_v2",
  "id": "$u_uuid",
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
    local b64_vm=$(cat /tmp/vmess_tmp.json | base64 -w 0)
    rm -f /tmp/vmess_tmp.json
    echo "vmess://$b64_vm"
}

v2ray_sincronizar_json() {
    python3 - << 'EOF_PY'
import json

db_path = "/usr/local/etc/xray/usuarios.db"
cfg_path = "/usr/local/etc/xray/config.json"

try:
    with open(db_path, "r") as f:
        lines = [line.strip().split(":") for line in f if line.strip() and ":" in line]

    clients = [{"id": parts[1], "alterId": 0, "email": parts[0]} for parts in lines]

    with open(cfg_path, "r") as f:
        cfg = json.load(f)

    if cfg.get("inbounds") and len(cfg["inbounds"]) > 0:
        cfg["inbounds"][0]["settings"]["clients"] = clients

    with open(cfg_path, "w") as f:
        json.dump(cfg, f, indent=2)
except Exception as e:
    pass
EOF_PY
}

menu_v2ray() {
while true; do
clear
P_V2=$(systemctl is-active --quiet xray && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
C_USERS=$( [ -f /usr/local/etc/xray/usuarios.db ] && grep -c ":" /usr/local/etc/xray/usuarios.db 2>/dev/null || echo 0 )
echo -e "${C}================================================${N}"
echo -e "     ${A}⚜️  V2RAY / XRAY MANAGER (WebSocket) ⚜️   ${N}"
echo -e "${C}================================================${N}"
echo -e " ${W}Estado actual :${N} $P_V2  ${W}| Clientes Activos :${N} ${A}$C_USERS${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${V}[1]${N} ${W}🟢 Instalar / Reconfigurar V2Ray (Base)   ${N}"
echo -e " ${V}[2]${N} ${W}➕ Crear Nuevo Cliente (Nombre + UUID + Link)   ${N}"
echo -e " ${R}[3]${N} ${W}🗑️  Eliminar un Cliente Específico   ${N}"
echo -e " ${A}[4]${N} ${W}👥 Listar Clientes y Ver Links VMess   ${N}"
echo -e " ${C}[5]${N} ${W}⚙️  Modificar Puerto de Conexión   ${N}"
echo -e " ${R}[6]${N} ${W}🗑️  Desinstalar / Resetear Todo V2Ray   ${N}"
echo -e " ${C}[0]${N} ${W}↩️  Volver al Menú Principal   ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -ne " ${W}► Opcion : ${N}"; read op_v2
case $op_v2 in
1)
    clear
    echo -e "${C}=== INSTALANDO NUCLEO XRAY (V2RAY OFICIAL) ===   ${N}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y jq uuid-runtime curl psmisc lsof openssl python3 >/dev/null 2>&1
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

    echo -e "\n${C}=== CONFIGURANDO CONEXIÓN WEBSOCKET ===   ${N}"
    echo -e " ${W}► Puerto a usar (Recomendado: 443):${N}"
    echo -ne " ${V}► ${N}"; read pt_v2; pt_v2=${pt_v2:-443}

    echo -e " ${W}► Tu Dominio o SNI (Ej: movistar.com):${N}"
    echo -ne " ${V}► ${N}"; read dom_v2; dom_v2=${dom_v2:-$IP_VPS}

    echo -e " ${W}► Nombre del primer usuario (Ej: Admin):${N}"
    echo -ne " ${V}► ${N}"; read primer_user; primer_user=${primer_user:-Admin}

    UUID_P=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)

    systemctl stop xray apache2 nginx dropbear stunnel4 2>/dev/null
    liberar_puerto_fantasma "$pt_v2" "v2ray"
    sleep 1

    mkdir -p /usr/local/etc/xray
    openssl req -newkey rsa:2048 -nodes -keyout /usr/local/etc/xray/private.key -x509 -days 3650 -out /usr/local/etc/xray/cert.crt -subj "/CN=$dom_v2" >/dev/null 2>&1
    chmod 644 /usr/local/etc/xray/private.key /usr/local/etc/xray/cert.crt

    cat <<EOF > /usr/local/etc/xray/config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $pt_v2,
      "listen": "0.0.0.0",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID_P",
            "alterId": 0,
            "email": "$primer_user"
          }
        ]
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
        "wsSettings": {
          "path": "/zeroday"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
    echo "$dom_v2" > /usr/local/etc/xray/dominio.txt
    echo "$pt_v2" > /usr/local/etc/xray/puerto.txt
    echo "$primer_user:$UUID_P" > /usr/local/etc/xray/usuarios.db

    iptables -I INPUT -p tcp --dport $pt_v2 -j ACCEPT >/dev/null 2>&1
    ufw allow $pt_v2/tcp >/dev/null 2>&1
    systemctl daemon-reload
    systemctl enable xray >/dev/null 2>&1
    systemctl restart xray

    sleep 2
    if systemctl is-active --quiet xray && ss -tlnp | grep -qE ":${pt_v2}\b"; then
        echo -e "\n ${V}¡V2Ray Instalado y Activo con TLS en puerto $pt_v2!   ${N}"
        LNK_PRIMER=$(v2ray_generar_link_vmess "$UUID_P" "$primer_user")
        echo -e "\n 👤 ${W}Cliente Creado :${N} ${A}$primer_user${N}"
        echo -e " 🔑 ${W}UUID           :${N} ${V}$UUID_P${N}"
        echo -e "\n 🔗 ${A}$LNK_PRIMER${N}"
    else
        echo -e "\n ${R}ERROR: V2Ray no pudo iniciar. Detalles de SystemD:   ${N}"
        journalctl -u xray.service -n 5 --no-pager
    fi
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
2)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e " ${R}V2Ray no está instalado. Instálalo primero (Opción 1).   ${N}"
        echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
        continue
    fi
    clear
    echo -e "${C}=== CREAR NUEVO CLIENTE V2RAY / VMESS ===${N}"
    echo -e " ${W}► Ingresa el Nombre o Alias del Cliente (Ej: Pedro, Juan_VIP):${N}"
    echo -ne " ${V}► ${N}"; read nuevo_u
    nuevo_u=$(echo "$nuevo_u" | tr -d ' :')

    if [ -z "$nuevo_u" ]; then
        echo -e " ${R}Nombre inválido. Cancelado.${N}"
        echo -e "\n ${W}► Presiona Enter...${N}"; read
        continue
    fi

    if grep -q "^$nuevo_u:" /usr/local/etc/xray/usuarios.db 2>/dev/null; then
        echo -e " ${R}¡Ya existe un cliente con ese nombre! Elige otro nombre.${N}"
        echo -e "\n ${W}► Presiona Enter...${N}"; read
        continue
    fi

    N_UUID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)
    echo "$nuevo_u:$N_UUID" >> /usr/local/etc/xray/usuarios.db
    v2ray_sincronizar_json
    systemctl restart xray

    LINK_IND=$(v2ray_generar_link_vmess "$N_UUID" "$nuevo_u")
    dom_v2=$(cat /usr/local/etc/xray/dominio.txt 2>/dev/null | tr -d ' \n\r')
    pt_v2=$(cat /usr/local/etc/xray/puerto.txt 2>/dev/null | tr -d ' \n\r')

    clear
    echo -e "${C}================================================${N}"
    echo -e "     ${V}¡CLIENTE V2RAY REGISTRADO CON ÉXITO!   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " 👤 ${W}Cliente  : ${V}$nuevo_u${N}"
    echo -e " 🔑 ${W}UUID     : ${A}$N_UUID${N}"
    echo -e " 🌐 ${W}Host/SNI : ${V}$dom_v2${N}"
    echo -e " 🚪 ${W}Puerto   : ${V}$pt_v2${N}"
    echo -e "${C}────────────────────────────────────────────────────────${N}"
    echo -e " 🔗 ${V}LINK VMESS INDIVIDUAL (Copia y entrega a tu cliente):${N}\n"
    echo -e " ${A}$LINK_IND${N}\n"
    echo -e "${C}================================================${N}"
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
3)
    if [ ! -f /usr/local/etc/xray/usuarios.db ] || [ ! -s /usr/local/etc/xray/usuarios.db ]; then
        echo -e " ${R}No hay clientes creados en V2Ray.${N}"
        echo -e "\n ${W}► Presiona Enter...${N}"; read
        continue
    fi
    clear
    echo -e "${C}=== ELIMINAR CLIENTE V2RAY / VMESS ===${N}"
    echo -e " ${W}Selecciona el cliente a eliminar:${N}\n"
    i=1
    declare -A lista_nombres
    while IFS=":" read -r name uid; do
        [ -z "$name" ] && continue
        echo -e " ${V}[$i]${N} ${W}$name${N} (UUID: ${A}${uid:0:8}...${N})"
        lista_nombres[$i]="$name"
        ((i++))
    done < /usr/local/etc/xray/usuarios.db

    echo -e "\n ${W}► Ingresa el NÚMERO o NOMBRE del cliente a borrar:${N}"
    echo -ne " ${R}► ${N}"; read sel_del
    [ -z "$sel_del" ] && continue

    target_del=""
    if [[ "$sel_del" =~ ^[0-9]+$ ]] && [ -n "${lista_nombres[$sel_del]}" ]; then
        target_del="${lista_nombres[$sel_del]}"
    elif grep -q "^$sel_del:" /usr/local/etc/xray/usuarios.db 2>/dev/null; then
        target_del="$sel_del"
    fi

    if [ -n "$target_del" ]; then
        sed -i "/^$target_del:/d" /usr/local/etc/xray/usuarios.db
        v2ray_sincronizar_json
        systemctl restart xray
        echo -e "\n ${V}✓ Cliente '${target_del}' y su UUID fueron eliminados de raíz.${N}"
        echo -e " ${A}Su enlace VMess quedó invalidado de inmediato.${N}"
    else
        echo -e "\n ${R}Cliente no encontrado.${N}"
    fi
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
4)
    if [ ! -f /usr/local/etc/xray/usuarios.db ] || [ ! -s /usr/local/etc/xray/usuarios.db ]; then
        echo -e " ${R}No hay clientes creados en V2Ray.${N}"
        echo -e "\n ${W}► Presiona Enter...${N}"; read
        continue
    fi
    clear
    dom_v2=$(cat /usr/local/etc/xray/dominio.txt 2>/dev/null | tr -d ' \n\r')
    pt_v2=$(cat /usr/local/etc/xray/puerto.txt 2>/dev/null | tr -d ' \n\r')
    echo -e "${C}================================================${N}"
    echo -e "        ${A}👥 LISTADO DE CLIENTES V2RAY 👥   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}Dominio : ${V}$dom_v2${N} | ${W}Puerto : ${V}$pt_v2${N}"
    echo -e "${C}────────────────────────────────────────────────────────${N}"
    while IFS=":" read -r name uid; do
        [ -z "$name" ] && continue
        L_VM=$(v2ray_generar_link_vmess "$uid" "$name")
        echo -e " 👤 ${W}Cliente : ${V}$name${N}"
        echo -e " 🔑 ${W}UUID    : ${A}$uid${N}"
        echo -e " 🔗 ${W}Link    : ${C}$L_VM${N}"
        echo -e "${C}--------------------------------------------------------${N}"
    done < /usr/local/etc/xray/usuarios.db
    echo -e "\n ${W}► Presiona Enter para volver...${N}"; read ;;
5)
    if [ ! -f /usr/local/etc/xray/config.json ]; then
        echo -e " ${R}V2Ray no está instalado. Instálalo primero (Opción 1).   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read; continue
    fi
    pt_actual=$(cat /usr/local/etc/xray/puerto.txt | tr -d ' \n\r')
    echo -e "\n${C}=== MODIFICAR PUERTO V2RAY ===   ${N}"
    echo -e " ${W}🔹 Puerto actual:  ${N}${V}$pt_actual   ${N}"
    echo -e " ${W}► Ingresa el NUEVO puerto a usar (Ej: 80, 443):${N}"
    echo -ne " ${V}► ${N}"; read pt_nuevo
    if [ -z "$pt_nuevo" ]; then
        echo -e " ${R}Cancelado.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read; continue
    fi

    systemctl stop xray 2>/dev/null
    fuser -k -9 "${pt_actual}/tcp" >/dev/null 2>&1
    liberar_puerto_fantasma "$pt_nuevo" "v2ray"

    sed -i -E "s/\"port\": [0-9]+/\"port\": $pt_nuevo/" /usr/local/etc/xray/config.json
    echo "$pt_nuevo" > /usr/local/etc/xray/puerto.txt
    iptables -I INPUT -p tcp --dport $pt_nuevo -j ACCEPT >/dev/null 2>&1
    ufw allow $pt_nuevo/tcp >/dev/null 2>&1
    systemctl restart xray

    sleep 2
    if systemctl is-active --quiet xray && ss -tlnp | grep -qE ":${pt_nuevo}\b"; then
        echo -e "\n ${V}¡Puerto modificado exitosamente al $pt_nuevo!   ${N}"
    else
        echo -e "\n ${R}ERROR: El puerto $pt_nuevo está bloqueado por el sistema. Intenta con otro.   ${N}"
    fi
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
6)
    resetear_v2ray_completo
    systemctl disable xray >/dev/null 2>&1
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove >/dev/null 2>&1
    rm -rf /usr/local/etc/xray
    echo -e " ${R}V2Ray / Xray Desinstalado y puertos liberados completamente.   ${N}"
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
0) break ;;
esac
done
}

menu_reality() {
while true; do
    clear
    ESTADO_R=$(systemctl is-active --quiet xray-reality && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")
    PT_R=$([ -f /etc/reality/puerto.txt ] && cat /etc/reality/puerto.txt || echo "NULL")
    SNI_R=$([ -f /etc/reality/sni.txt ] && cat /etc/reality/sni.txt || echo "NULL")

    echo -e "${C}================================================${N}"
    echo -e "   ${A}🌌 VLESS + REALITY (ANTI-BLOQUEO DPI) 🌌   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}🔹 Puerto :${N} ${V}$PT_R${N}  ${W}| SNI :${N} ${A}$SNI_R${N}  ${W}| Estado :${N} $ESTADO_R"
    echo -e "${C}------------------------------------------------${N}"
    echo -e " ${V}[1]${N} ${W}🟢 Instalar / Configurar VLESS + REALITY   ${N}"
    echo -e " ${A}[2]${N} ${W}👁️ Ver Link de Conexión (Importar a App)   ${N}"
    echo -e " ${C}[3]${N} ${W}⚙️ Cambiar SNI / Bug Host (En vivo)   ${N}"
    echo -e " ${M}[4]${N} ${W}🔄 Generar Nuevo Usuario (UUID)   ${N}"
    echo -e " ${R}[5]${N} ${W}🗑️ Desinstalar REALITY   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️ REGRESAR   ${N}"
    echo -e "${C}------------------------------------------------${N}"
    echo -ne " ${W}► Opción : ${N}"; read op_r

    case $op_r in
        1)
            clear
            echo -e "${C}=== INSTALANDO VLESS + REALITY AISLADO ===${N}"
            limpiar_basura_disco
            apt-get update -y >/dev/null 2>&1
            apt-get install -y jq uuid-runtime curl openssl lsof psmisc >/dev/null 2>&1

            if [ ! -f /usr/local/bin/xray ]; then
                echo -e " ${V}⏳ Descargando motor Xray oficial...${N}"
                bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install >/dev/null 2>&1
            fi

            mkdir -p /etc/reality
            echo -e "\n ${W}► Puerto a usar para REALITY (Recomendado: 444, 8443):${N}"
            echo -ne " ${V}► ${N}"; read pt_r
            pt_r=${pt_r:-444}

            echo -e "\n ${W}► SNI de página permitida por tu operadora (Ej: www.microsoft.com):${N}"
            echo -ne " ${V}► ${N}"; read sni_r
            sni_r=${sni_r:-www.microsoft.com}

            liberar_puerto_fantasma "$pt_r" "reality"

            echo -e " ${A}⏳ Generando llaves criptográficas X25519...${N}"
            UUID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)
            KEYS=$(/usr/local/bin/xray x25519 2>/dev/null)
            PRIV_KEY=$(echo "$KEYS" | sed -n '1p' | awk -F':' '{print $2}' | tr -d ' \n\r')
            PUB_KEY=$(echo "$KEYS" | sed -n '2p' | awk -F':' '{print $2}' | tr -d ' \n\r')
            SHORT_ID=$(openssl rand -hex 8)

            echo "$pt_r" > /etc/reality/puerto.txt
            echo "$sni_r" > /etc/reality/sni.txt
            echo "$UUID" > /etc/reality/uuid.txt
            echo "$PRIV_KEY" > /etc/reality/priv.key
            echo "$PUB_KEY" > /etc/reality/pub.key
            echo "$SHORT_ID" > /etc/reality/short.id

            cat <<EOF > /etc/reality/config.json
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": $pt_r,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$sni_r:443",
          "xver": 0,
          "serverNames": ["$sni_r"],
          "privateKey": "$PRIV_KEY",
          "shortIds": ["$SHORT_ID"]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
            cat << 'EOF' > /etc/systemd/system/xray-reality.service
[Unit]
Description=Xray REALITY Service (ZeroDay)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/xray run -c /etc/reality/config.json
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
            iptables -I INPUT -p tcp --dport $pt_r -j ACCEPT >/dev/null 2>&1
            ufw allow $pt_r/tcp >/dev/null 2>&1

            systemctl daemon-reload
            systemctl enable xray-reality >/dev/null 2>&1
            systemctl restart xray-reality

            sleep 2
            if systemctl is-active --quiet xray-reality && ss -tlnp | grep -qE ":${pt_r}\b"; then
                echo -e "\n ${V}¡VLESS + REALITY Instalado y Activo en puerto $pt_r!   ${N}"
            else
                echo -e "\n ${R}ERROR: No pudo iniciar. Revisa que el SNI tenga puerto 443 válido.   ${N}"
            fi
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        2)
            if [ ! -f /etc/reality/config.json ]; then
                echo -e "\n ${R}REALITY no está instalado.${N}"
                echo -e "\n ${W}► Presiona Enter...${N}"; read
                continue
            fi
            PT=$(cat /etc/reality/puerto.txt | tr -d ' \n\r')
            SNI=$(cat /etc/reality/sni.txt | tr -d ' \n\r')
            UUID=$(cat /etc/reality/uuid.txt | tr -d ' \n\r')
            PUB=$(cat /etc/reality/pub.key | tr -d ' \n\r')
            SID=$(cat /etc/reality/short.id | tr -d ' \n\r')

            LINK="vless://${UUID}@${IP_VPS}:${PT}?type=tcp&security=reality&pbk=${PUB}&fp=chrome&sni=${SNI}&sid=${SID}&spx=%2F&flow=xtls-rprx-vision#ZeroDay-REALITY"

            clear
            echo -e "${C}=== DATOS VLESS + REALITY ===${N}"
            echo -e " ${W}🔹 IP Servidor : ${V}$IP_VPS${N}"
            echo -e " ${W}🔹 Puerto      : ${V}$PT${N}"
            echo -e " ${W}🔹 SNI Clón    : ${V}$SNI${N}"
            echo -e " ${W}🔹 UUID        : ${A}$UUID${N}"
            echo -e " ${W}🔹 Public Key  : ${A}$PUB${N}"
            echo -e " ${W}🔹 Short ID    : ${A}$SID${N}"
            echo -e "${C}================================================${N}"
            echo -e " 🔗 ${V}LINK VLESS (Copiar a HTTP Custom, v2rayNG o NekoBox):${N}\n"
            echo -e " ${A}$LINK${N}\n"
            echo -e " ${W}► Presiona Enter...${N}"; read
            ;;
        3)
            if [ ! -f /etc/reality/config.json ]; then continue; fi
            ACTUAL=$(cat /etc/reality/sni.txt | tr -d ' \n\r')
            echo -e "\n ${W}► SNI Actual: ${V}$ACTUAL${N}"
            echo -e " ${W}► Escribe el NUEVO SNI / Host:${N}"
            echo -ne " ${V}► ${N}"; read nuevo_sni
            [ -z "$nuevo_sni" ] && continue

            sed -i "s/\"dest\": \".*:443\"/\"dest\": \"$nuevo_sni:443\"/" /etc/reality/config.json
            sed -i "s/\"serverNames\": \[.*\]/\"serverNames\": [\"$nuevo_sni\"]/" /etc/reality/config.json
            echo "$nuevo_sni" > /etc/reality/sni.txt
            systemctl restart xray-reality
            echo -e " ${V}¡SNI cambiado con éxito a $nuevo_sni!${N}"
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        4)
            if [ ! -f /etc/reality/config.json ]; then continue; fi
            UUID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)
            sed -i -E "s/\"id\": \".*\"/\"id\": \"$UUID\"/" /etc/reality/config.json
            echo "$UUID" > /etc/reality/uuid.txt
            systemctl restart xray-reality
            echo -e " ${V}¡Nuevo UUID generado: $UUID!${N}"
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        5)
            resetear_reality_completo
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        0) break ;;
    esac
done
}

# ==========================================
# MÓDULO 36: BHTTP SERVER (WEBSOCKET RÁPIDO PARA APPS)
# ==========================================
menu_bhttp() {
while true; do
    clear
    ESTADO_BHTTP=$(systemctl is-active --quiet bhttp-server && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")
    if [ -f /etc/bhttp/config ]; then
        source /etc/bhttp/config 2>/dev/null
    else
        BHTTP_PORT="8080"
        BHTTP_DEST="22"
    fi

    echo -e "${C}================================================${N}"
    echo -e "       ${A}⚡ BHTTP SERVER [APPs] - FAST WS ⚡   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${W}🔹 Puerto Inyección :${N} ${V}$BHTTP_PORT${N}  ${W}| Destino :${N} ${A}$BHTTP_DEST${N}  ${W}| Estado :${N} $ESTADO_BHTTP"
    echo -e "${C}------------------------------------------------${N}"
    echo -e " ${V}[1]${N} ${W}🟢 Instalar / Configurar BHTTP Server   ${N}"
    echo -e " ${A}[2]${N} ${W}👁️ Ver Configuración y Payloads para APPs   ${N}"
    echo -e " ${C}[3]${N} ${W}⚙️ Cambiar Puerto de Inyección   ${N}"
    echo -e " ${V}[4]${N} ${W}▶️ Reiniciar BHTTP Server   ${N}"
    echo -e " ${A}[5]${N} ${W}⏸️ Detener BHTTP Server   ${N}"
    echo -e " ${C}[6]${N} ${W}📜 Ver Registro de Conexiones (Logs en Vivo)   ${N}"
    echo -e " ${R}[7]${N} ${W}🗑️ Desinstalar BHTTP Server   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️ REGRESAR AL MENÚ   ${N}"
    echo -e "${C}------------------------------------------------${N}"
    echo -ne " ${W}► Opción : ${N}"; read op_bh

    case $op_bh in
        1)
            clear
            echo -e "${C}=== INSTALACIÓN BHTTP SERVER (SOCKET ACELERADO) ===${N}"
            echo -e " ${W}► Puerto de Inyección para las Apps [Default 8080]:${N}"
            echo -ne " ${V}► ${N}"; read p_bh
            p_bh=${p_bh:-8080}

            echo -e " ${W}► Puerto Local de Redirección (SSH) [Default 22]:${N}"
            echo -ne " ${V}► ${N}"; read p_dest
            p_dest=${p_dest:-22}

            echo -e " ${A}⏳ Limpiando puertos y compilando entorno BHTTP...${N}"
            liberar_puerto_fantasma "$p_bh" "bhttp"

            apt-get update -y >/dev/null 2>&1
            apt-get install -y python3 lsof psmisc >/dev/null 2>&1

            mkdir -p /etc/bhttp
            cat << 'EOF_BH' > /etc/bhttp/bhttp_proxy.py
import socket
import threading
import sys

LISTEN_PORT = PUERTO_ESCUCHA
TARGET_PORT = PUERTO_SSH
BUFSIZE = 65536

def transfer(src, dst):
    try:
        while True:
            data = src.recv(BUFSIZE)
            if not data:
                break
            dst.sendall(data)
    except:
        pass
    finally:
        try: src.close()
        except: pass
        try: dst.close()
        except: pass

def handle_client(client_sock):
    target_sock = None
    try:
        client_sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        client_sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        client_sock.settimeout(15)

        req = client_sock.recv(4096)
        if not req:
            client_sock.close()
            return

        resp = b"HTTP/1.1 101 Switching Protocols\r\nContent-Length: 0\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
        client_sock.sendall(resp)

        target_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        target_sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        target_sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        target_sock.settimeout(15)
        target_sock.connect(('127.0.0.1', TARGET_PORT))

        client_sock.settimeout(None)
        target_sock.settimeout(None)

        t1 = threading.Thread(target=transfer, args=(client_sock, target_sock), daemon=True)
        t2 = threading.Thread(target=transfer, args=(target_sock, client_sock), daemon=True)
        t1.start()
        t2.start()
    except:
        try: client_sock.close()
        except: pass
        if target_sock:
            try: target_sock.close()
            except: pass

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', LISTEN_PORT))
    server.listen(1000)
    while True:
        try:
            client, _ = server.accept()
            threading.Thread(target=handle_client, args=(client,), daemon=True).start()
        except:
            pass

if __name__ == '__main__':
    main()
EOF_BH
            sed -i "s/PUERTO_ESCUCHA/$p_bh/g" /etc/bhttp/bhttp_proxy.py
            sed -i "s/PUERTO_SSH/$p_dest/g" /etc/bhttp/bhttp_proxy.py

            echo -e "BHTTP_PORT=\"$p_bh\"\nBHTTP_DEST=\"$p_dest\"" > /etc/bhttp/config

            cat << 'EOF_BHS' > /etc/systemd/system/bhttp-server.service
[Unit]
Description=BHTTP Fast WebSocket Native Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /etc/bhttp/bhttp_proxy.py
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF_BHS

            systemctl daemon-reload
            systemctl enable bhttp-server >/dev/null 2>&1
            systemctl restart bhttp-server

            iptables -I INPUT -p tcp --dport $p_bh -j ACCEPT >/dev/null 2>&1
            ufw allow $p_bh/tcp >/dev/null 2>&1

            sleep 2
            if systemctl is-active --quiet bhttp-server && ss -tlnp | grep -qE ":${p_bh}\b"; then
                echo -e "\n ${V}¡BHTTP Server Instalado y Activo en el puerto $p_bh!   ${N}"
            else
                echo -e "\n ${R}Error al iniciar BHTTP Server. Revisa si el puerto estaba libre.   ${N}"
            fi
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
            ;;
        2)
            clear
            echo -e "${C}================================================${N}"
            echo -e "     ${A}📱 CONFIGURACIÓN PARA BHTTP / HTTP CUSTOM 📱   ${N}"
            echo -e "${C}================================================${N}"
            echo -e " ${W}🔹 Servidor / Host :${N} ${V}$IP_VPS   ${N}"
            echo -e " ${W}🔹 Puerto Remoto   :${N} ${V}$BHTTP_PORT   ${N}"
            echo -e " ${W}🔹 Redirección SSH :${N} ${A}$BHTTP_DEST   ${N}"
            echo -e "${C}────────────────────────────────────────────────${N}"
            echo -e " ${V}Payload Directo (Sin Saldo / Bug Host):${N}"
            echo -e " ${A}GET / HTTP/1.1[crlf]Host: tudominio.com[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf][crlf]${N}"
            echo -e "${C}────────────────────────────────────────────────${N}"
            echo -e " ${W}Coloca tu usuario y contraseña SSH creados en el menú [01].${N}"
            echo -e "${C}================================================${N}"
            echo -e "\n ${W}► Presiona Enter para volver...${N}"; read
            ;;
        3)
            if [ ! -f /etc/bhttp/config ]; then
                echo -e "\n ${R}BHTTP Server no está instalado.${N}"
                sleep 1; continue
            fi
            echo -e "\n ${W}► Ingresa el NUEVO puerto para BHTTP:${N}"
            echo -ne " ${V}► ${N}"; read n_pt
            if [[ "$n_pt" =~ ^[0-9]+$ ]]; then
                liberar_puerto_fantasma "$n_pt" "bhttp"
                sed -i "s/LISTEN_PORT = .*/LISTEN_PORT = $n_pt/g" /etc/bhttp/bhttp_proxy.py
                sed -i "s/BHTTP_PORT=.*/BHTTP_PORT=\"$n_pt\"/g" /etc/bhttp/config
                systemctl restart bhttp-server
                iptables -I INPUT -p tcp --dport $n_pt -j ACCEPT >/dev/null 2>&1
                ufw allow $n_pt/tcp >/dev/null 2>&1
                echo -e "\n ${V}¡Puerto actualizado a $n_pt con éxito!   ${N}"
            else
                echo -e "\n ${R}Puerto no válido.   ${N}"
            fi
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        4)
            systemctl restart bhttp-server 2>/dev/null
            echo -e "\n ${V}¡BHTTP Server reiniciado correctamente!   ${N}"
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        5)
            systemctl stop bhttp-server 2>/dev/null
            echo -e "\n ${A}BHTTP Server detenido.   ${N}"
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        6)
            clear
            echo -e "${A}=== LOGS EN VIVO BHTTP SERVER ===${N}"
            journalctl -u bhttp-server -n 30 --no-pager
            echo -e "\n ${W}► Presiona Enter para regresar...${N}"; read
            ;;
        7)
            resetear_bhttp_completo
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
            ;;
        0) break ;;
        *) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
    esac
done
}

# ==========================================
# MÓDULO 37: HCR SERVER (NATIVO TLS 1.3 / PLAIN MULTIHILO)
# ==========================================
menu_hcr() {
while true; do
    clear
    ESTADO=$(systemctl is-active --quiet hcr-server && echo -e "${V}[ ACTIVO ]${N}" || echo -e "${R}[ INACTIVO ]${N}")

    if [ -f /etc/hcr/config ]; then
        source /etc/hcr/config 2>/dev/null
    else
        P_INJ="8080"
        P_DEST="22"
        MODO="TLS"
    fi

    echo -e "${C}================================================${N}"
    echo -e "       ${W}MENU HCR [HTTP C.] - Estado:${N} $ESTADO"
    echo -e "${C}================================================${N}"
    echo -e " ${W}🔹 Puerto Inyección :${N} ${V}$P_INJ${N}  ${W}| Destino :${N} ${A}$P_DEST${N}  ${W}| Modo :${N} ${M}$MODO${N}"
    echo -e "${C}────────────────────────────────────────────────────────${N}"
    echo -e " ${V}[1]${N} ${W}🟢 Instalar / Configurar HCR Server   ${N}"
    echo -e " ${A}[2]${N} ${W}👁️ Ver Configuración para HTTP Custom   ${N}"
    echo -e " ${C}[3]${N} ${W}🔄 Reiniciar HCR Server   ${N}"
    echo -e " ${A}[4]${N} ${W}⏸️  Detener HCR Server   ${N}"
    echo -e " ${R}[5]${N} ${W}🗑️  Desinstalar HCR Server   ${N}"
    echo -e " ${C}[6]${N} ${W}📜 Ver Errores / Logs del Servidor   ${N}"
    echo -e " ${C}[0]${N} ${W}↩️  REGRESAR   ${N}"
    echo -e "${C}================================================${N}"
    echo -ne " ${W}► Opcion : ${N}"; read op_hcr

    case $op_hcr in
        1) instalar_hcr ;;
        2)
            clear
            echo -e "${C}================================================${N}"
            echo -e "        ${A}📱 CONFIGURACIÓN EXACTA HTTP CUSTOM 📱   ${N}"
            echo -e "${C}================================================${N}"
            echo -e " ${W}1. En la pantalla principal de HTTP Custom:${N}"
            echo -e "    🔹 Modo         : ${V}Pestaña HCR${N}"
            echo -e "    🔹 Host:puerto  : ${V}$IP_VPS:$P_INJ${N}"
            echo -e "    🔹 Usuario SSH  : ${A}El que creaste en el menú [01]${N}"
            echo -e "    🔹 Passwd SSH   : ${A}Tu contraseña SSH${N}"
            echo -e "${C}────────────────────────────────────────────────────────${N}"
            if [ "$MODO" == "TLS" ]; then
                echo -e " ${W}2. Interruptores en la app:${N}"
                echo -e "    ☑️ ${V}Activar TLS      : ENCENDIDO (Azul)${N}"
                echo -e "    ☑️ ${V}Permitir inseguro: ENCENDIDO (Azul)${N}"
            else
                echo -e " ${W}2. Interruptores en la app:${N}"
                echo -e "    ⬜ ${R}Activar TLS      : APAGADO${N}"
                echo -e "    ⬜ ${R}Permitir inseguro: APAGADO${N}"
            fi
            echo -e "${C}────────────────────────────────────────────────────────${N}"
            echo -e " ${A}NOTA: En modo HCR no se usa cajita de Payload.${N}"
            echo -e "${C}================================================${N}"
            echo -e "\n ${W}► Presiona Enter para volver...${N}"; read
            ;;
        3)
            systemctl restart hcr-server 2>/dev/null
            echo -e "\n ${V}¡HCR Server reiniciado!   ${N}"
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        4)
            systemctl stop hcr-server 2>/dev/null
            echo -e "\n ${A}HCR Server detenido.   ${N}"
            echo -e "\n ${W}► Presiona Enter...${N}"; read
            ;;
        5)
            resetear_hcr_completo
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
            ;;
        6)
            clear
            echo -e "${A}=== LOGS DEL MOTOR HCR ===   ${N}"
            journalctl -u hcr-server -n 30 --no-pager
            echo -e "\n ${W}► Presiona Enter para regresar...${N}"; read
            ;;
        0) break ;;
    esac
done
}

instalar_hcr() {
    clear
    echo -e "${A}========= INSTALACIÓN NATIVA HCR SERVER =========   ${N}"
    echo -e " ${W}► Puerto de Inyección [Default 8080]:${N}"
    echo -ne " ${V}► ${N}"; read p_inj
    p_inj=${p_inj:-8080}

    echo -e " ${W}► Puerto Local de Redirección (SSH) [Default 22]:${N}"
    echo -ne " ${V}► ${N}"; read p_dest
    p_dest=${p_dest:-22}

    echo -e "\n ${W}Seleccione Modo de Transporte para HCR:${N}"
    echo -e " ${V}[1] TLS   ${N}${W}(Recomendado: Compatible con 'Activar TLS' en HTTP Custom)   ${N}"
    echo -e " ${V}[2] Plain ${N}${W}(Sin SSL, directo TCP)   ${N}"
    echo -e " ${W}► Opción [Default 1]:${N}"
    echo -ne " ${V}► ${N}"; read op_m
    op_m=${op_m:-1}

    mkdir -p /etc/hcr
    liberar_puerto_fantasma "$p_inj" "hcr"
    apt-get update -y >/dev/null 2>&1
    apt-get install stunnel4 openssl python3 lsof psmisc -y >/dev/null 2>&1

    if [ "$op_m" == "2" ]; then
        MODO="Plain"
        cat << 'EOF_HCP' > /etc/hcr/hcr_plain.py
import socket, threading, sys
P_IN = PUERTO_HCR_INJ
P_OUT = PUERTO_HCR_DEST
def f(a, b):
    try:
        while True:
            d = a.recv(65536)
            if not d: break
            b.sendall(d)
    except: pass
    finally:
        try: a.close()
        except: pass
        try: b.close()
        except: pass

def h(c):
    s = None
    try:
        c.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        c.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        s.connect(('127.0.0.1', P_OUT))
        threading.Thread(target=f, args=(c, s), daemon=True).start()
        threading.Thread(target=f, args=(s, c), daemon=True).start()
    except:
        try: c.close()
        except: pass
        if s:
            try: s.close()
            except: pass

def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(('0.0.0.0', P_IN))
    srv.listen(500)
    while True:
        try:
            cl, _ = srv.accept()
            threading.Thread(target=h, args=(cl,), daemon=True).start()
        except: pass

if __name__ == '__main__':
    main()
EOF_HCP
        sed -i "s/PUERTO_HCR_INJ/$p_inj/g" /etc/hcr/hcr_plain.py
        sed -i "s/PUERTO_HCR_DEST/$p_dest/g" /etc/hcr/hcr_plain.py

        cat << 'EOF_HCRS' > /etc/systemd/system/hcr-server.service
[Unit]
Description=HCR Native Plain Server (ZeroDay)
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /etc/hcr/hcr_plain.py
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF_HCRS
    else
        MODO="TLS"
        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
            -subj "/CN=HCR-Server/O=ZeroDay/C=CO" \
            -keyout /etc/hcr/hcr.pem -out /etc/hcr/hcr.pem >/dev/null 2>&1
        chmod 600 /etc/hcr/hcr.pem

        cat << EOF_ST > /etc/hcr/hcr_server.conf
pid = /var/run/hcr_stunnel.pid
cert = /etc/hcr/hcr.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
socket = l:SO_KEEPALIVE=1
socket = r:SO_KEEPALIVE=1
TIMEOUTidle = 86400
TIMEOUTclose = 0
TIMEOUTconnect = 300

[hcr-tunnel]
accept = $p_inj
connect = 127.0.0.1:$p_dest
EOF_ST

        cat << 'EOF_HCRS' > /etc/systemd/system/hcr-server.service
[Unit]
Description=HCR Native TLS High-Performance Tunnel (ZeroDay)
After=network.target

[Service]
Type=forking
PIDFile=/var/run/hcr_stunnel.pid
ExecStart=/usr/bin/stunnel4 /etc/hcr/hcr_server.conf
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF_HCRS
    fi

    echo -e "P_INJ=\"$p_inj\"\nP_DEST=\"$p_dest\"\nMODO=\"$MODO\"" > /etc/hcr/config

    iptables -I INPUT -p tcp --dport $p_inj -j ACCEPT >/dev/null 2>&1
    ufw allow $p_inj/tcp >/dev/null 2>&1

    systemctl daemon-reload
    systemctl enable hcr-server >/dev/null 2>&1
    systemctl restart hcr-server

    sleep 2
    if systemctl is-active --quiet hcr-server && ss -tlnp | grep -qE ":${p_inj}\b"; then
        echo -e "\n ${V}¡HCR SERVER NATIVO OPERATIVO EN PUERTO $p_inj [$MODO]!   ${N}"
        echo -e " ${W}En HTTP Custom: pestaña HCR, Activar TLS y Permitir inseguro encendidos.${N}"
    else
        echo -e "\n ${R}Error: HCR no pudo encender. Revisa que el puerto esté libre.   ${N}"
    fi
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
    echo -ne " ${W}► Opcion : ${N}"; read op_dns

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
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
            ;;
        4)
            echo -e "${C}================================================${N}"
            echo -e " ${W}► ¿Seguro de eliminar SlowDNS? (s/n):${N}"
            echo -ne " ${V}► ${N}"; read confirmar
            if [[ "$confirmar" == "s" || "$confirmar" == "S" ]]; then
                echo -e "\n ${R}Deteniendo y eliminando servicios...   ${N}"
                systemctl stop slowdns > /dev/null 2>&1
                systemctl disable slowdns > /dev/null 2>&1
                fuser -k -9 5300/udp >/dev/null 2>&1
                rm -f /etc/systemd/system/slowdns.service
                systemctl daemon-reload
                iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300 > /dev/null 2>&1
                iptables -D INPUT -p udp --dport 5300 -j ACCEPT > /dev/null 2>&1
                rm -rf /etc/slowdns
                echo -e " ${V}SlowDNS desinstalado por completo.   ${N}"
            else
                echo -e "\n ${A}Operación cancelada.   ${N}"
            fi
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
            echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
            return
        else
            systemctl stop slowdns >/dev/null 2>&1
            rm -rf /etc/slowdns
        fi
    fi

    echo -e " ${W}► Puerto local (Ej: 22):${N}"
    echo -ne " ${V}► ${N}"; read puerto_local
    puerto_local=${puerto_local:-22}

    echo -e ""
    echo -e " ${W}► Tu Dominio NS:${N}"
    echo -ne " ${V}► ${N}"; read dominio_ns

    if [ -z "$dominio_ns" ]; then
        echo -e "\n ${R}[!] El dominio NS es obligatorio.   ${N}"
        echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
        return
    fi

    echo -e "\n ${V}⏳ Instalando dependencias...   ${N}"
    apt-get update -y > /dev/null 2>&1
    apt-get install iptables curl wget dnsutils lsof psmisc -y > /dev/null 2>&1
    optimizar_sshd_estabilidad

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
        echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
        echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
LimitNOFILE=65535

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
    echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read
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
    echo -e "\n ${W}► Presiona Enter para volver...${N}"; read
}

configurar_banner() {
    clear
    echo -e "${C}================================================${N}"
    echo -e "       ${A}CONFIGURAR BANNER DE LA APLICACIÓN   ${N}"
    echo -e "${C}================================================${N}"
    echo -e " ${V}Escribe el mensaje principal para tus clientes:   ${N}"
    echo -e " ${A}(Ej: SERVIDOR PREMIUM, PROHIBIDO TORRENT, etc.)   ${N}"
    echo ""
    echo -e " ${W}► Mensaje:${N}"
    echo -ne " ${V}► ${N}"; read texto_banner

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
    echo -e " ${W}► Opcion (1-8):${N}"
    echo -ne " ${V}► ${N}"; read op_color

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

    sed -i '/^Banner /d' /etc/ssh/sshd_config
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    optimizar_sshd_estabilidad

    systemctl reload ssh > /dev/null 2>&1 || systemctl restart ssh > /dev/null 2>&1
    systemctl reload sshd > /dev/null 2>&1 || systemctl restart sshd > /dev/null 2>&1

    echo ""
    echo -e " ${V}¡Banner configurado con éxito!   ${N}"
    echo -e " ${A}Ahora se mostrará tu mensaje en color en la app.   ${N}"
    echo -e "\n ${W}► Presiona Enter para regresar al menú...${N}"; read
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
        echo -e " ${W}► Elige un tema (1-8):${N}"
        echo -ne " ${V}► ${N}"; read op_tema

        case $op_tema in
            1) echo "C='\033[38;5;51m'; V='\033[38;5;46m'; A='\033[38;5;226m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;201m'; W='\033[38;5;231m'" > /etc/zeroday_tema.conf ;;
            2) echo "C='\033[38;5;196m'; V='\033[38;5;226m'; A='\033[38;5;214m'; R='\033[38;5;160m'; N='\033[0m'; M='\033[38;5;220m'; W='\033[38;5;231m'" > /etc/zeroday_tema.conf ;;
            3) echo "C='\033[38;5;201m'; V='\033[38;5;51m'; A='\033[38;5;226m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;198m'; W='\033[38;5;231m'" > /etc/zeroday_tema.conf ;;
            4) echo "C='\033[38;5;46m'; V='\033[38;5;82m'; A='\033[38;5;118m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;48m'; W='\033[38;5;84m'" > /etc/zeroday_tema.conf ;;
            5) echo "C='\033[38;5;33m'; V='\033[38;5;51m'; A='\033[38;5;39m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;45m'; W='\033[38;5;159m'" > /etc/zeroday_tema.conf ;;
            6) echo "C='\033[38;5;214m'; V='\033[38;5;196m'; A='\033[38;5;226m'; R='\033[38;5;160m'; N='\033[0m'; M='\033[38;5;202m'; W='\033[38;5;231m'" > /etc/zeroday_tema.conf ;;
            7) echo "C='\033[38;5;93m'; V='\033[38;5;51m'; A='\033[38;5;141m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;201m'; W='\033[38;5;231m'" > /etc/zeroday_tema.conf ;;
            8) echo "C='\033[38;5;226m'; V='\033[38;5;198m'; A='\033[38;5;46m'; R='\033[38;5;196m'; N='\033[0m'; M='\033[38;5;214m'; W='\033[38;5;51m'" > /etc/zeroday_tema.conf ;;
            0) break ;;
            *) echo -e " ${R}Opción inválida.  ${N}"; sleep 1; continue ;;
        esac

        source /etc/zeroday_tema.conf
        echo -e "\n ${V}¡Tema Neón aplicado con éxito!   ${N}"
        sleep 1
    done
}

menu_protocolos() {
while true; do
clear
P22=$(ep 22); P80=$(es proxypy); PSSL=$(es stunnel4); PPY=$(es proxypy); PUDP=$(es udp-custom); PFB=$(es fail2ban)
PBAD=$(ss -tlnp | grep -qE ":7300\b" && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PV2=$(systemctl is-active --quiet xray && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PHCR=$(es hcr-server)
PDNS=$(es slowdns)
PSSR=$(es ssr-server)
PREAL=$(es xray-reality)
P15=$(systemctl is-active --quiet stunnel4 && grep -q "stunnel-python" /etc/stunnel/stunnel.conf 2>/dev/null && echo -e "${V}[ON]${N}" || echo -e "${R}[OFF]${N}")
PBHTTP=$(es bhttp-server)

echo -e "${A}🍄 INSTALACION DE PROTOCOLOS ( Script ZeroDay ) 🍄   ${N}"
echo -e "${C}--------------------------------------------------------${N}"
echo -e " ${C}[1]${N} ${W}OpenSSH       ${N}$P22    ${C}[11]${N} ${W}PSIPHON SERVER ${R}[OFF]  ${N}"
echo -e " ${C}[2]${N} ${W}DROPBEAR      ${R}[OFF]${N}   ${C}[12]${N} ${W}TCP DNS        ${A}(#BETA)  ${N}"
echo -e " ${C}[3]${N} ${W}OPENVPN       ${R}[OFF]${N}   ${C}[13]${N} ${W}WEBMIN         ${R}[OFF]  ${N}"
echo -e " ${C}[4]${N} ${W}SSL/TLS       ${N}$PSSL    ${C}[14]${N} ${W}SLOWDNS        ${N}$PDNS  ${N}"
echo -e " ${C}[5]${N} ${W}SHADOWSOCKS-R ${N}$PSSR    ${C}[15]${N} ${W}SSL->PYTHON    ${N}$P15  ${N}"
echo -e " ${C}[6]${N} ${W}SQUID         ${R}[OFF]${N}   ${C}[16]${N} ${W}SSLH MULTIPLEX ${R}[OFF]  ${N}"
echo -e " ${C}[7]${N} ${W}PROXY PYTHON  ${N}$PPY    ${C}[17]${N} ${W}VLESS REALITY  ${N}$PREAL  "
echo -e " ${C}[8]${N} ${W}V2RAY MANAGER ${N}$PV2    ${C}[18]${N} ${W}SOCKS5         ${A}(#BETA)  ${N}"
echo -e " ${C}[9]${N} ${W}CFA ( CLASH ) ${R}[OFF]${N}   ${C}[19]${N} ${W}Protocolos UDP ${N}$PUDP  "
echo -e " ${C}[10]${N} ${W}TROJAN-GO     ${R}[OFF]${N}   ${C}[20]${N} ${A}🧹 LIMPIADOR PUERTOS  ${N}"
echo -e " "
echo -e "${A}🍄 INSTALACION DE HERRAMIENTAS Y SERVICIOS 🍄   ${N}"
echo -e "${C}--------------------------------------------------------${N}"
echo -e " ${C}[21]${N} ${W}BLOCK TORRENT        ${C}[22]${N} ${W}BadVPN         ${N}$PBAD  "
echo -e " ${C}[23]${N} ${W}TCP (BBR|Plus) ${R}[OFF]${N} ${C}[24]${N} ${W}FAILBAN        ${N}$PFB  "
echo -e " ${C}[25]${N} ${W}ARCHIVO ONLINE ${V}[81]${N}  ${C}[26]${N} ${W}UP|DOWN SpeedTest  ${N}"
echo -e " ${C}[27]${N} ${W}DETALLES DEL VPS     ${C}[28]${N} ${W}BLOCK ADS      ${R}[OFF]  ${N}"
echo -e " ${C}[29]${N} ${W}DNS CUSTOM (NETFLIX) ${C}[30]${N} ${W}ZONA HORARIA (RELOJ)  ${N}"
echo -e " ${C}[31]${N} ${W}REINICIAR SERVICIOS  ${C}[32]${N} ${W}Brook Server   ${R}[OFF]  ${N}"
echo -e " ${C}[33]${N} ${W}FIREWALL (IPTABLES)  ${C}[34]${N} ${W}Enable/Change PASSWD ROOT  ${N}"
echo -e " ${C}[35]${N} ${W}AToken [APPs]  ${R}[OFF]${N} ${C}[36]${N} ${W}BHTTP [APPs]   ${N}$PBHTTP"
echo -e " ${C}[37]${N} ${W}HCR [HTTP C.]  ${N}$PHCR ${C}[0]${N}  ${R}[ REGRESAR ]  ${N}"
echo -e "${C}--------------------------------------------------------${N}"
echo -ne " ${W}► Opcion : ${N}"; read op_inst
case $op_inst in
4) menu_ssl ;;
5) menu_ssr ;;
7) menu_py ;;
8) menu_v2ray ;;
14) menu_slowdns ;;
15) menu_ssl_python ;;
17) menu_reality ;;
19) menu_udp ;;
20) menu_limpiador_puertos ;;
21) iptables -A FORWARD -m string --string "BitTorrent" --algo bm -j DROP; echo " Bloqueado   "; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
22) menu_badvpn ;;
24) apt install fail2ban -y >/dev/null 2>&1; systemctl enable fail2ban >/dev/null 2>&1; systemctl start fail2ban; echo " Listo   "; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
26) curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
27) info_sistema; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
30) menu_zona_horaria ;;
31) optimizar_sshd_estabilidad; systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null; systemctl restart stunnel4 proxypy udp-custom fail2ban xray hcr-server slowdns ssr-server xray-reality bhttp-server >/dev/null 2>&1; echo " Reiniciado   "; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
33) ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 444/tcp; ufw allow 8080/tcp; ufw allow 8888/tcp; ufw allow 8443/tcp; ufw allow 53/udp; ufw allow 5300/udp; ufw allow 36712/udp; ufw allow 7200/udp; ufw allow 7300/udp; ufw --force enable; echo " Puertos Abiertos   "; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
34) passwd root; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
36) menu_bhttp ;;
37) menu_hcr ;;
0) break ;;
*) echo -e " ${R}Inválido   ${N}"; sleep 1 ;;
esac
done
}

while true; do
clear
info_sistema
echo -e " ${V}[01]${N} ${W}⇨ CONTROL USUARIOS (SSH/SSL/VMESS)   ${N}"
echo -e " ${V}[02]${N} ${W}⇨ [!] OPTIMIZAR VPS      [  ${N}${R}OFF${N}${W}]   ${N}"
echo -e " ${V}[03]${N} ${W}⇨ CONTADOR ONLINE USERS  [  ${N}${R}OFF${N}${W}]   ${N}"
echo -e " ${V}[04]${N} ${W}⇨ AUTOINICIAR SCRIPT     [  ${N}${R}OFF${N}${W}]   ${N}"
echo -e " ${V}[05]${N} ${W}⇨ INSTALADOR DE PROTOCOLOS   ${N}"
echo -e " ${V}[06]${N} ${W}⇨ 📝 CONFIGURAR BANNER (MENSAJE)   ${N}"
echo -e " ${V}[07]${N} ${W}⇨ 🎨 CAMBIAR COLORES DEL MENU   ${N}"
echo -e " ${A}[09]${N} ${W}⇨ 🧹 LIMPIADOR DE PUERTOS FANTASMAS (RESET)   ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -e " ${V}[08]${N} ${W}⇨ [!] UPDATE / REMOVE   |  ${V}[0]${N} ${W}⇨ [ SALIR ]   ${N}"
echo -e "${C}────────────────────────────────────────────────────────${N}"
echo -ne " ${W}► Opcion : ${N}"; read opcion
case $opcion in
1|01) menu_usuarios ;;
2|02) clear; optimizar_sshd_estabilidad; limpiar_basura_disco; ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; ufw allow 444/tcp; ufw allow 8080/tcp; ufw allow 8888/tcp; ufw allow 8443/tcp; ufw allow 53/udp; ufw allow 5300/udp; ufw allow 36712/udp; ufw allow 7200/udp; ufw allow 7300/udp; ufw --force enable; echo -e " ${V}Firewall y Red Optimizados.   ${N}"; echo -e "\n ${W}► Presiona Enter para continuar...${N}"; read ;;
3|03) ver_usuarios_online ;;
4|04|5|05|8|08) menu_protocolos ;;
6|06) configurar_banner ;;
7|07) configurar_colores ;;
9|09) menu_limpiador_puertos ;;
0|00) exit 0 ;;
*) echo -e " ${R}Opción inválida.   ${N}"; sleep 1 ;;
esac
done
