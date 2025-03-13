#!/bin/bash

# Funções para exibir saídas coloridas
function echo_verde() {
    echo -e "\e[32m$1\e[0m"
}

function echo_amarelo() {
    echo -e "\e[33m$1\e[0m"
}

function echo_vermelho() {
    echo -e "\e[31m$1\e[0m"
}

function echo_azul() {
    echo -e "\e[34m$1\e[0m"
}

function echo_ciano() {
    echo -e "\e[36m$1\e[0m"
}

# Limpa a tela
clear

# Desenhar a linha tracejada superior
echo_ciano "==================== CONFIGURADOR DE DISCOS SECURONIX 512GB ===================="
echo

# Tela inicial com informações dos discos (como na imagem 1)
echo_amarelo "Você precisará selecionar dois discos diferentes:"
echo
echo_ciano "DISCO DO SISTEMA:"
echo " • rootvg-rootlv (20G) - / (sistema operacional)"
echo " • rootvg-crashlv (10G) - /var/crash (logs de crash)"
echo " • rootvg-rootvg_swap (9.5G) - swap (memória virtual)"
echo " • rootvg-rootvg_tmp (10G) - /tmp (temporários)"
echo " • rootvg-rootvg_var (10G) - /var (logs/variáveis)"
echo " • rootvg-rootvg_home (20G) - /home/securonix"
echo " • rootvg-rootvg_opt (10G) - /opt (aplicativos)"
echo
echo_ciano "DISCO DE DADOS:"
echo " • vg_scnx-securonix (512GB) - /Securonix"
echo
echo_vermelho "IMPORTANTE: Recomenda-se usar discos físicos diferentes para melhor performance!"
echo
echo -n "Pressione ENTER para continuar..."
read

# Limpa a tela
clear

# Exibir cabeçalho
echo_ciano "==================== CONFIGURADOR DE DISCOS SECURONIX ===================="
echo
echo_verde "===== Script de Configuração de Discos para Securonix ====="
echo_amarelo "Este script configurará seus discos para implantação do Securonix."
echo_vermelho "AVISO: Este script modificará partições de disco. Pode ocorrer perda de dados!"
echo

# Exibir layout atual de discos
echo_azul "Layout atual de discos:"
lsblk
echo

# Confirmar antes de prosseguir
echo_amarelo "Este script modificará suas partições de disco. Certifique-se de ter backups."
read -p "Deseja continuar? (s/n): " continuar
if [[ $continuar != "s" && $continuar != "S" ]]; then
    echo_vermelho "Operação cancelada pelo usuário."
    exit 1
fi

# ===== Configuração do Disco do Sistema =====
echo_azul "===== Configuração do Disco do Sistema ====="
read -p "Digite a partição do disco do sistema a ser configurada (ex: sda2): " disco_sistema

# Validar se o disco do sistema existe
if ! lsblk | grep -q "$disco_sistema"; then
    echo_vermelho "Erro: Partição $disco_sistema não encontrada!"
    exit 1
fi

# ===== Configuração do Disco de Dados =====
echo_azul "===== Configuração do Disco de Dados ====="
read -p "Digite o disco de dados a ser configurado para o Securonix (ex: sdc): " disco_dados

# Verificar o tamanho do disco selecionado
disco_tamanho=$(lsblk -b -o SIZE -n -d /dev/$disco_dados 2>/dev/null)
if [ -z "$disco_tamanho" ]; then
    echo_vermelho "Erro: Não foi possível determinar o tamanho do disco $disco_dados!"
    exit 1
fi

# Converter para GB para exibição
disco_tamanho_gb=$(echo "scale=0; $disco_tamanho/1024/1024/1024" | bc)
echo_amarelo "Tamanho do disco: ${disco_tamanho_gb}GB"

# Verificar se o disco tem pelo menos 512GB
if [ "$disco_tamanho_gb" -lt 512 ]; then
    echo_vermelho "AVISO: O disco selecionado tem ${disco_tamanho_gb}GB, que é menor que o recomendado de 512GB!"
    read -p "Deseja continuar mesmo assim? (s/n): " continuar_tamanho
    if [[ $continuar_tamanho != "s" && $continuar_tamanho != "S" ]]; then
        echo_vermelho "Operação cancelada pelo usuário."
        exit 1
    fi
    echo_amarelo "Continuando com disco de tamanho menor que o recomendado..."
else
    echo_verde "Disco com tamanho adequado detectado (${disco_tamanho_gb}GB)"
fi

# Exibir resumo da configuração (como na imagem 2)
clear
echo_ciano "==================== CONFIGURADOR DE DISCOS SECURONIX ===================="
echo
echo_ciano "Discos disponíveis no sistema:"
lsblk
echo

echo_ciano "DISCO DE DADOS:"
echo_amarelo "Digite o nome do disco para os dados (ex: sdc): $disco_dados"
echo_amarelo "Disco selecionado: $disco_dados"
echo

echo_amarelo "Resumo da configuração:"
echo_amarelo "Partição do sistema: /dev/$disco_sistema"
echo_amarelo "Disco de dados: /dev/$disco_dados"
echo
echo_vermelho "ATENÇÃO: Todos os dados no disco $disco_dados serão destruídos!"
read -p "Confirma estas configurações? (s/n): " confirma_final
if [[ $confirma_final != "s" && $confirma_final != "S" ]]; then
    echo_vermelho "Operação cancelada pelo usuário."
    exit 1
fi

# Obter o nome do disco sem o número da partição (ex: sda de sda2)
nome_disco_sistema=$(echo $disco_sistema | sed 's/[0-9]*$//')
numero_particao=$(echo $disco_sistema | sed 's/^[^0-9]*//')

echo_azul "Configurando disco do sistema: $nome_disco_sistema (partição $disco_sistema)"

# Mostrar instruções sobre o aviso do parted
clear
echo_ciano "==================== CONFIGURADOR DE DISCOS SECURONIX ===================="
echo
echo_azul "===== AVISO IMPORTANTE: POSSÍVEIS MENSAGENS DURANTE EXECUÇÃO ====="
echo_amarelo "Durante a execução, o sistema poderá exibir as seguintes mensagens:"
echo
echo_vermelho "1. Warning: Not all of the space available to /dev/sda appears to be used,"
echo_vermelho "   you can fix the GPT to use all of the space (an extra XXXXXX blocks)"
echo_vermelho "   or continue with the current setting?"
echo_vermelho "   Fix/Ignore?"
echo
echo_vermelho "2. Flag to Invert? [pmbr_boot]?"
echo
echo_vermelho "3. New state? [on]/off?"
echo
echo_verde "INSTRUÇÕES DE RESPOSTA:"
echo_verde " • Quando aparecer 'Fix/Ignore?' → Digite 'Fix' e pressione ENTER"
echo_verde " • Quando aparecer 'Flag to Invert? [pmbr_boot]?' → Apenas pressione ENTER"
echo_verde " • Quando aparecer 'New state? [on]/off?' → Digite 'on' e pressione ENTER"
echo
echo_amarelo "Importante: Siga exatamente estas instruções para uma configuração correta"
echo
echo_azul "O script continuará normalmente após suas respostas"
echo
read -p "Pressione ENTER para continuar e estar preparado para responder..." 
echo

# Configurar flag de inicialização PMBR
echo_amarelo "Configurando flag PMBR boot em $nome_disco_sistema"
parted /dev/$nome_disco_sistema disk_set pmbr_boot on

# Redimensionar partição para usar 95% do espaço em disco
echo_amarelo "Redimensionando partição $disco_sistema para usar 95% do espaço em disco"
parted /dev/$nome_disco_sistema resizepart $numero_particao 95%

# Redimensionar volume físico
echo_amarelo "Redimensionando volume físico em $disco_sistema"
pvresize /dev/$disco_sistema

# Verificar se existe um grupo de volumes
nome_vg=$(pvs --noheadings -o vg_name /dev/$disco_sistema 2>/dev/null | tr -d ' ')
if [ -z "$nome_vg" ]; then
    echo_amarelo "Nenhum grupo de volumes encontrado em $disco_sistema. Criando novo grupo 'rootvg'"
    vgcreate rootvg /dev/$disco_sistema
    nome_vg="rootvg"
else
    echo_amarelo "Usando grupo de volumes existente: $nome_vg"
fi

# Estender volume lógico root se existir
if lvs 2>/dev/null | grep -q "$nome_vg-rootlv"; then
    echo_amarelo "Estendendo volume lógico root para 20G"
    lvextend -L 20G /dev/$nome_vg/rootlv
    xfs_growfs /
else
    echo_amarelo "Criando volume lógico root (20G)"
    lvcreate -L 20G -n rootlv $nome_vg
    mkfs.xfs -f /dev/$nome_vg/rootlv
fi

# Verificar volume lógico crash
if ! lvs 2>/dev/null | grep -q "$nome_vg-crashlv"; then
    echo_amarelo "Criando volume lógico crash (10G)"
    lvcreate -L 10G -n crashlv $nome_vg
    mkfs.xfs -f /dev/$nome_vg/crashlv
    mkdir -p /var/crash
fi

# Criar volumes lógicos restantes
echo_amarelo "Criando volume lógico swap (9.5G)"
if ! lvs 2>/dev/null | grep -q "$nome_vg-rootvg_swap"; then
    lvcreate -L 9.5G -n rootvg_swap $nome_vg
    mkswap /dev/$nome_vg/rootvg_swap
fi

echo_amarelo "Criando volume lógico tmp (10G)"
if ! lvs 2>/dev/null | grep -q "$nome_vg-rootvg_tmp"; then
    lvcreate -L 10G -n rootvg_tmp $nome_vg
    mkfs.xfs -f /dev/$nome_vg/rootvg_tmp
    mkdir -p /tmp
fi

echo_amarelo "Criando volume lógico var (10G)"
if ! lvs 2>/dev/null | grep -q "$nome_vg-rootvg_var"; then
    lvcreate -L 10G -n rootvg_var $nome_vg
    mkfs.xfs -f /dev/$nome_vg/rootvg_var
    mkdir -p /var
fi

echo_amarelo "Criando volume lógico home (20G)"
if ! lvs 2>/dev/null | grep -q "$nome_vg-rootvg_home"; then
    lvcreate -L 20G -n rootvg_home $nome_vg
    mkfs.xfs -f /dev/$nome_vg/rootvg_home
    mkdir -p /home/securonix
fi

echo_amarelo "Criando volume lógico opt (10G)"
if ! lvs 2>/dev/null | grep -q "$nome_vg-rootvg_opt"; then
    lvcreate -L 10G -n rootvg_opt $nome_vg
    mkfs.xfs -f /dev/$nome_vg/rootvg_opt
    mkdir -p /opt
fi

# Continuar com a configuração do disco de dados
echo_azul "===== Continuando com a Configuração do Disco de Dados ====="

# Confirmar seleção do disco de dados já não é necessário, já confirmamos anteriormente

# Mostrar instruções sobre o aviso do parted para o disco de dados
clear
echo_ciano "==================== CONFIGURADOR DE DISCOS SECURONIX ===================="
echo
echo_azul "===== AVISO IMPORTANTE: MENSAGENS PARA CONFIGURAÇÃO DO DISCO DE DADOS ====="
echo_amarelo "Durante a configuração do disco de dados, o sistema poderá exibir as seguintes mensagens:"
echo
echo_vermelho "1. Warning: Not all of the space available to /dev/$disco_dados appears to be used,"
echo_vermelho "   you can fix the GPT to use all of the space (an extra XXXXXX blocks)"
echo_vermelho "   or continue with the current setting?"
echo_vermelho "   Fix/Ignore?"
echo
echo_vermelho "2. Flag to Invert? [pmbr_boot]?"
echo
echo_vermelho "3. New state? [on]/off?"
echo
echo_verde "INSTRUÇÕES DE RESPOSTA:"
echo_verde " • Quando aparecer 'Fix/Ignore?' → Digite 'Fix' e pressione ENTER"
echo_verde " • Quando aparecer 'Flag to Invert? [pmbr_boot]?' → Apenas pressione ENTER"
echo_verde " • Quando aparecer 'New state? [on]/off?' → Digite 'on' e pressione ENTER"
echo
echo_amarelo "Importante: Siga exatamente estas instruções para uma configuração correta"
echo
echo_azul "O script continuará normalmente após suas respostas"
echo
read -p "Pressione ENTER para continuar e estar preparado para responder..." 
echo

echo_amarelo "Criando rótulo GPT em $disco_dados"
parted --script /dev/$disco_dados mklabel gpt

echo_amarelo "Criando partição primária em $disco_dados"
parted --script /dev/$disco_dados mkpart primary 0% 100%

# Aguardar o udev criar os nós de dispositivo
sleep 2

echo_amarelo "Criando volume físico em ${disco_dados}1"
pvcreate /dev/${disco_dados}1

echo_amarelo "Criando grupo de volumes vg_scnx em ${disco_dados}1"
if ! vgs 2>/dev/null | grep -q "vg_scnx"; then
    vgcreate --physicalextentsize 32 vg_scnx /dev/${disco_dados}1
fi

echo_amarelo "Criando volume lógico securonix usando todo o espaço disponível"
if ! lvs 2>/dev/null | grep -q "vg_scnx-securonix"; then
    lvcreate --extents 100%FREE vg_scnx --name securonix --yes
    echo_amarelo "Formatando /dev/vg_scnx/securonix com XFS"
    mkfs.xfs -f /dev/vg_scnx/securonix
fi

echo_amarelo "Criando diretório /Securonix"
mkdir -p /Securonix

# Atualizar /etc/fstab
echo_azul "===== Atualizando /etc/fstab ====="
echo_amarelo "Fazendo backup do /etc/fstab atual"
cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d-%H%M%S)

# Verificar se o sistema usa UUID para boot e EFI
boot_uuid=$(blkid -s UUID -o value /dev/sda1 2>/dev/null || echo "")
efi_uuid=$(blkid -s UUID -o value /dev/sda15 2>/dev/null || echo "")

echo_amarelo "Recriando /etc/fstab com as entradas corretas"
cat > /etc/fstab.new << EOF
# /etc/fstab criado pelo script de configuração Securonix
/dev/mapper/$nome_vg-rootlv /                       xfs     defaults        0 0
EOF

# Adicionar entradas UUID para boot e EFI se existirem
if [ -n "$boot_uuid" ]; then
    echo "UUID=$boot_uuid /boot                   xfs     defaults        0 0" >> /etc/fstab.new
fi

if [ -n "$efi_uuid" ]; then
    echo "UUID=$efi_uuid /boot/efi               vfat    defaults,uid=0,gid=0,umask=077,shortname=winnt 0 2" >> /etc/fstab.new
fi

# Adicionar as entradas restantes
cat >> /etc/fstab.new << EOF
/dev/mapper/$nome_vg-crashlv /var/crash              xfs     defaults        0 0
/dev/$nome_vg/rootvg_swap swap                    swap    defaults        0 0
/dev/$nome_vg/rootvg_tmp /tmp                     xfs     defaults        0 0
/dev/$nome_vg/rootvg_var /var                     xfs     defaults        0 0
/dev/$nome_vg/rootvg_home /home/securonix         xfs     defaults        0 0
/dev/$nome_vg/rootvg_opt /opt                     xfs     defaults        0 0
/dev/vg_scnx/securonix /Securonix              xfs     defaults        0 0
EOF

# Verificar se há alguma entrada especial para /mnt
if grep -q "/mnt" /etc/fstab; then
    grep "/mnt" /etc/fstab >> /etc/fstab.new
fi

# Substituir o fstab original
mv /etc/fstab.new /etc/fstab

# Montar volumes
echo_azul "===== Montando Volumes ====="
echo_amarelo "Montando todos os volumes"
systemctl daemon-reload
mount -a
swapon -a

# Exibir layout final de discos
echo_azul "===== Layout Final de Discos ====="
lsblk

echo_verde "Configuração de disco concluída com sucesso!"
