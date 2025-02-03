# 🚀 Template de Implantação de VM Securonix no Azure

![Azure](https://img.shields.io/badge/Azure-blue?style=flat-square&logo=microsoftazure) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) ![ARM Template](https://img.shields.io/badge/ARM-Template-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Production-green?style=flat-square)

Aplica-se a: ✔️ VMs Linux

## 🛠️ Metadados

| Campo | Detalhes |
|-------|----------|
| **Título** | Template ARM para Provisionamento de VM Securonix no Azure |
| **Versão** | 1.0.0 |
| **Autor** | Mathews Buzetti |
| **Data de Criação** | 31/01/2025 |
| **Tipo de Recurso** | Azure Virtual Machines |
| **Sistema Operacional** | Oracle Linux 8.10 |
| **Classificação** | Início Rápido |
| **Tags** | `azure`, `vm`, `securonix`, `arm-template`, `linux-deployment` |
| **Licença** | Uso livre para projetos pessoais e comerciais |
| **Compatibilidade** | Azure Cloud |
| **Requisitos** | Assinatura Azure, Permissões de Implantação |


## 🚀 Opções de Implantação

### Passos de Implantação Automática

[![Implantar no Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathewsbuzetti%2Fsecuronixish%2Fmain%2Fazuredeploy.json)

1. Clique no botão acima "Deploy to Azure"
2. Configure os parâmetros de implantação:
   * Assinatura
   * Grupo de Recursos
   * Região
   * Nome de Usuário Administrador
   * Tipo de Autenticação
   * Credenciais de Administrador

### Implantação Manual no Portal do Azure

Caso já tenha provisionado a máquina manualmente no portal do Azure, siga as instruções abaixo. Importante: verifique se selecionou a imagem de SO Oracle Linux 8.10 conforme a imagem:

![Seleção de Imagem Oracle Linux](https://github.com/user-attachments/assets/e77448fa-a663-4030-b6e5-d2c26312303d)

## 📦 Configuração Pós-Implantação

### Montagem da Partição

```
├─rootvg-rootvg_swap 9.5G lvm   [SWAP]
├─rootvg-rootvg_tmp  10G  lvm   /tmp
├─rootvg-rootvg_var  10G  lvm   /var
├─rootvg-rootvg_home 20G  lvm   /home/securonix
└─rootvg-rootvg_opt  10G  lvm   /opt
```

### Aumento do Volume da Partição

```
├─rootvg-rootlv      20G  lvm   /
```

### Observações Importantes

- O sistema já vem com rootlv e crashlv configurados
- As letras dos discos (**sda**, sdb, **sdc**) podem variar em cada ambiente

Principais pontos:
- Partições de swap, tmp, var, home e opt
- Volume root expandido para 20GB


# 📦 Guia Completo de Particionamento de Disco para Infraestrutura Linux

## 🔍 Identificação Inicial dos Discos

Antes de iniciar qualquer procedimento, primeiro identifique os discos disponíveis:

```bash
lsblk
```

Exemplo de saída:
```
NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                   8:0    0  100G  0 disk
├─sda1                8:1    0  800M  0 part /boot
├─sda2                8:2    0 28.7G  0 part
  ├─rootvg-rootlv   252:0    0 18.7G  0 lvm  /
  ├─rootvg-crashlv  252:1    0   10G  0 lvm  /var/crash
├─sda14               8:14   0    4M  0 part
└─sda15               8:15   0  495M  0 part /boot/efi
sdb                   8:16   0   32G  0 disk
sdc                   8:32   0  300G  0 disk
sr0                  11:0    1  634K  0 rom
```

## 🛠️ Procedimento de Particionamento

### 1. Configuração do Disco do Sistema (Exemplo: sda)

#### 1.1 Ajuste da Partição Principal
```bash
sudo parted /dev/sda disk_set pmbr_boot on
```
- Responda "Fix" se solicitado
- Pressione ENTER para "Flag to Invert"
- Digite "on" para novo estado

#### 1.2 Redimensionamento da Partição
```bash
sudo parted /dev/sda resizepart 2 95%
```

#### 1.3 Redimensionamento do Volume Físico
```bash
sudo pvresize /dev/sda2
```

#### 1.4 Expansão do Volume Root
```bash
sudo lvextend -L 20G /dev/rootvg/rootlv
sudo xfs_growfs /
```

### 2. Criação de Volumes Lógicos Adicionais

```bash
# Swap
sudo lvcreate -L 9.5G -n rootvg_swap rootvg

# Volumes temporários
sudo lvcreate -L 10G -n rootvg_tmp rootvg
sudo lvcreate -L 10G -n rootvg_var rootvg
sudo lvcreate -L 20G -n rootvg_home rootvg
sudo lvcreate -L 10G -n rootvg_opt rootvg
```

### 3. Formatação dos Volumes

```bash
# Swap
sudo mkswap /dev/rootvg/rootvg_swap

# Formatação XFS para demais volumes
sudo mkfs.xfs -f /dev/rootvg/rootvg_tmp
sudo mkfs.xfs -f /dev/rootvg/rootvg_var
sudo mkfs.xfs -f /dev/rootvg/rootvg_home
sudo mkfs.xfs -f /dev/rootvg/rootvg_opt
```

### 4. Configuração de Disco Adicional (Exemplo: <font color="red">sdc</font> de 300GB)

```bash
# Criação de partição GPT
sudo parted --script /dev/<font color="red">sdc</font> mklabel gpt
sudo parted --script /dev/<font color="red">sdc</font> mkpart primary 0% 100%

# Criação de Volume Físico
sudo pvcreate /dev/<font color="red">sdc</font>1

# Criação de Grupo de Volume
sudo vgcreate --physicalextentsize 32 vg_scnx /dev/<font color="red">sdc</font>1

# Criação de Volume Lógico
sudo lvcreate --extents 100%FREE vg_scnx --name securonix

# Criação de Ponto de Montagem
sudo mkdir -p /Securonix

# Formatação
sudo mkfs.xfs -f /dev/vg_scnx/securonix
```

### 5. Criação de Pontos de Montagem

```bash
sudo mkdir -p /tmp
sudo mkdir -p /var
sudo mkdir -p /home/securonix
sudo mkdir -p /opt
sudo mkdir -p /Securonix
```

### 6. Configuração do /etc/fstab

```bash
sudo tee -a /etc/fstab << EOF
/dev/rootvg/rootvg_swap swap swap defaults 0 0
/dev/rootvg/rootvg_tmp /tmp xfs defaults 0 0
/dev/rootvg/rootvg_var /var xfs defaults 0 0
/dev/rootvg/rootvg_home /home/securonix xfs defaults 0 0
/dev/rootvg/rootvg_opt /opt xfs defaults 0 0
/dev/vg_scnx/securonix /Securonix xfs defaults 0 0
EOF
```

### 7. Montagem dos Volumes

```bash
sudo mount -a
sudo swapon -a
```

### 8. Recarregamento do Systemd

```bash
sudo systemctl daemon-reload
```

### 9. Verificação Final

```bash
lsblk
```

## ⚠️ Avisos Importantes

- **Backup**: Sempre faça backup antes de realizar alterações
- **Verificação**: Confirme cada comando antes de executar
- **Flexibilidade**: Letras de disco podem variar (sda, sdb, sdc)
- **Ambiente**: Testado em Oracle Linux 8.10

## 📋 Estrutura Final Esperada

```
sda                    128G disk
├─sda1                 800M part  /boot
├─sda2                120.3G part 
  ├─rootvg-rootlv      20G  lvm   /
  ├─rootvg-crashlv     10G  lvm   /var/crash
  ├─rootvg-rootvg_swap 9.5G lvm   [SWAP]
  ├─rootvg-rootvg_tmp  10G  lvm   /tmp
  ├─rootvg-rootvg_var  10G  lvm   /var
  ├─rootvg-rootvg_home 20G  lvm   /home/securonix
  └─rootvg-rootvg_opt  10G  lvm   /opt
sdb                     32G disk
└─sdb1                  32G part  /mnt
<font color="red">sdc</font>                    300G disk
└─<font color="red">sdc</font>1                 300G part
  └─vg_scnx-securonix 300G lvm   /Securonix
```

## 🚨 Resolução de Problemas

- Use `lsblk` para verificar o alinhamento de partições
- Use `vgs` para verificar o status do grupo de volumes
- Use `mount` para confirmar a montagem do sistema de arquivos

## 📝 Licença

Uso livre para projetos pessoais e comerciais. Atribuição necessária em caso de uso ou redistribuição.
