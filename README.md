# Azure VM Securonix

Template ARM para criar uma VM Oracle Linux com configurações específicas para Securonix.

## Especificações

- VM Oracle Linux 8
- 4 vCPUs, 16GB RAM
- Disco SO: 100GB StandardSSD_LRS
- Disco Dados: 300GB Premium_LRS
- Configurações LVM automáticas:
  - vgsystemswap (9.5GB) para SWAP
  - vgsystemroot (20GB) para /
  - vgsystemtmp (10GB) para /tmp
  - vgsystemvar (10GB) para /var
  - vgsystemhome (20GB) para /home/securonix
  - vgsystemopt (10GB) para /opt

## Deploy

Clique no botão abaixo para fazer o deploy no Azure:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathewsbuzetti%2Fsecuronixish%2Fmain%2Fazuredeploy.json)

## Como usar

1. Clique no botão "Deploy to Azure" acima
2. Preencha os parâmetros necessários:
   - Subscription: Selecione sua subscrição
   - Resource Group: Crie novo ou use existente
   - Region: Selecione a região desejada
   - Admin Username: Nome do usuário administrador
   - Authentication Type: Password ou SSH key
   - Admin Password: Senha do usuário (se escolher autenticação por senha)

## Detalhes do Template ARM

### Descrição do Template

Este template ARM cria uma VM Oracle Linux 8 configurada especificamente para Securonix. A VM é provisionada com 4 vCPUs, 16GB de RAM, e dois discos: um disco do sistema operacional de 100GB usando StandardSSDLRS e um disco de dados de 300GB usando PremiumLRS. O disco de dados é configurado automaticamente com várias partições LVM para diferentes pontos de montagem, conforme necessário para a instalação do Securonix.

### Estrutura do Template

O template define os seguintes recursos:

- `Microsoft.Network/virtualNetworks`: Cria uma rede virtual.
- `Microsoft.Network/subnets`: Cria uma sub-rede dentro da rede virtual.
- `Microsoft.Network/networkSecurityGroups`: Cria um grupo de segurança de rede para controlar o tráfego de entrada e saída.
- `Microsoft.Network/publicIPAddresses`: Cria um endereço IP público para a VM.
- `Microsoft.Network/networkInterfaces`: Cria uma interface de rede para a VM.
- `Microsoft.Compute/virtualMachines`: Cria a VM com a configuração especificada.
- `Microsoft.Compute/disks`: Cria discos gerenciados para a VM.

### Parâmetros do Template

Os parâmetros do template permitem personalizar a implantação da VM:

- `vmName`: Nome da máquina virtual.
- `adminUsername`: Nome do usuário administrador.
- `authenticationType`: Tipo de autenticação (password ou sshPublicKey).
- `adminPasswordOrKey`: Senha ou chave SSH para o usuário administrador.
- `dnsLabelPrefix`: Prefixo do rótulo DNS para o IP público.
- `location`: Região do Azure onde os recursos serão criados.
- `vmSize`: Tamanho da VM (por exemplo, StandardD4sv3).
- `virtualNetworkName`: Nome da rede virtual.
- `subnetName`: Nome da sub-rede.
- `networkSecurityGroupName`: Nome do grupo de segurança de rede.
- `securityType`: Tipo de segurança da VM (Standard ou TrustedLaunch).

### Script de Inicialização (Custom Data)

O script de inicialização configura automaticamente as partições LVM no disco de dados:

```bash
#!/bin/bash

# Aguarda o disco ficar disponível
while [ ! -b /dev/sdb ]; do
    sleep 1
done

# Inicializa o disco
pvcreate /dev/sdb

# Cria grupo de volumes
vgcreate vg_system /dev/sdb

# Cria volumes lógicos
lvcreate -L 9.5G -n vg_system_swap vg_system
lvcreate -L 20G -n vg_system_root vg_system
lvcreate -L 10G -n vg_system_tmp vg_system
lvcreate -L 10G -n vg_system_var vg_system
lvcreate -L 20G -n vg_system_home vg_system
lvcreate -L 10G -n vg_system_opt vg_system

# Formata os volumes
mkswap /dev/vg_system/vg_system_swap
mkfs.xfs /dev/vg_system/vg_system_root
mkfs.xfs /dev/vg_system/vg_system_tmp
mkfs.xfs /dev/vg_system/vg_system_var
mkfs.xfs /dev/vg_system/vg_system_home
mkfs.xfs /dev/vg_system/vg_system_opt

# Cria pontos de montagem
mkdir -p /mnt/root
mkdir -p /mnt/tmp
mkdir -p /mnt/var
mkdir -p /mnt/home/securonix
mkdir -p /mnt/opt

# Monta os volumes
mount /dev/vg_system/vg_system_root /mnt/root
mount /dev/vg_system/vg_system_tmp /mnt/tmp
mount /dev/vg_system/vg_system_var /mnt/var
mount /dev/vg_system/vg_system_home /mnt/home/securonix
mount /dev/vg_system/vg_system_opt /mnt/opt

# Adiciona entradas ao fstab
echo "/dev/vg_system/vg_system_swap swap swap defaults 0 0" >> /etc/fstab
echo "/dev/vg_system/vg_system_root /root xfs defaults 0 0" >> /etc/fstab
echo "/dev/vg_system/vg_system_tmp /tmp xfs defaults 0 0" >> /etc/fstab
echo "/dev/vg_system/vg_system_var /var xfs defaults 0 0" >> /etc/fstab
echo "/dev/vg_system/vg_system_home /home/securonix xfs defaults 0 0" >> /etc/fstab
echo "/dev/vg_system/vg_system_opt /opt xfs defaults 0 0" >> /etc/fstab

# Ativa a swap
swapon /dev/vg_system/vg_system_swap
```

## Limpeza dos Recursos

Quando não for mais necessário, exclua o grupo de recursos para remover todos os recursos associados:

1. Selecione o Grupo de Recursos.
2. Na página do grupo de recursos, selecione "Excluir Grupo de Recursos".
3. Quando solicitado, digite o nome do grupo de recursos e selecione "Excluir".
