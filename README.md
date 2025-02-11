# 🚀 Template de Implantação de VM Securonix no Azure

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Mathews_Buzetti-blue)](https://www.linkedin.com/in/mathewsbuzetti)
![Azure](https://img.shields.io/badge/Azure-blue?style=flat-square&logo=microsoftazure) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) ![ARM Template](https://img.shields.io/badge/ARM-Template-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Production-green?style=flat-square)

Aplica-se a: ✔️ VMs Linux

## 🛠️ Metadados

| Campo | Detalhes |
|-------|----------|
| **Título** | Template ARM para Provisionamento de VM Securonix no Azure |
| **Versão** | 1.0.0 |
| **Autor** | Mathews Buzetti |
| **Data de Criação** | 03/02/2025 |
| **Tipo de Recurso** | Azure Virtual Machines |
| **Sistema Operacional** | Oracle Linux 8.10 |
| **Tags** | `azure`, `vm`, `securonix`, `arm-template`, `linux-deployment` |
| **Compatibilidade** | Azure Cloud |

## 📋 Índice

1. [Metadados](#-metadados)
2. [Visão Geral](#-visão-geral)
3. [Especificações da VM](#-especificações-da-vm)
4. [Opções de Implantação](#-opções-de-implantação)
5. [Configuração Pós-Implantação](#-configuração-pós-implantação)
6. [Versionamento](#-versionamento)

## 💡 Visão Geral

Este template ARM (Azure Resource Manager) oferece uma implantação otimizada de máquina virtual Securonix no ambiente de nuvem Azure.

### 🖥️ Especificações da VM

- **Sistema Operacional**: Oracle Linux 8.10
- **Recursos Computacionais**: 
  - Tipo de Instância: D4s v3
  - vCPUs: 4
  - RAM: 16GB
- **Configuração de Armazenamento**:
  - Disco SO: 128GB StandardSSD_LRS
  - Disco de Dados: 300GB Premium_LRS
- **Estrutura Final Após Configuração dos Volumes**:

```
sda                  128G disk
├─sda1               800M part /boot
├─sda2               120.3G part
  ├─rootvg-rootlv      20G lvm /
  ├─rootvg-crashlv     10G lvm /var/crash
  ├─rootvg-rootvg_swap 9.5G lvm [SWAP]
  ├─rootvg-rootvg_tmp  10G lvm /tmp
  ├─rootvg-rootvg_var  10G lvm /var
  ├─rootvg-rootvg_home 20G lvm /home/securonix
  └─rootvg-rootvg_opt  10G lvm /opt
sdb                   32G disk
└─sdb1                32G part /mnt
sdc                  300G disk
└─sdc1               300G part
  └─vg_scnx-securonix 300G lvm /Securonix
```

## 🚀 Opções de Implantação

### Passos de Implantação Automática

[![Implantar no Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathewsbuzetti%2Fsecuronixish%2Fmain%2Fazuredeploy.json)

1. Clique no botão acima "Deploy to Azure"
2. Configure os parâmetros de implantação:
   * Assinatura
   * Grupo de Recursos
   * Região
   * Nome de Usuário 
   * Tipo de Autenticação

### Implantação Manual no Portal do Azure

Caso já tenha provisionado a máquina manualmente no portal do Azure, verifique se selecionou a imagem do SO Oracle Linux 8.10, conforme a imagem:

![Seleção de Imagem Oracle Linux](https://github.com/user-attachments/assets/e77448fa-a663-4030-b6e5-d2c26312303d)

Caso deseje provisionar a VM pelo portal do Azure, lembre-se de selecionar a imagem do SO conforme informado acima e de adicionar dois discos, conforme descrito abaixo:

- Disco do SO: 128GB StandardSSD_LRS

![image](https://github.com/user-attachments/assets/f16e4d7a-38b1-46ec-8b49-a6295c20edd4)

- Disco de Dados: 300GB Premium_LRS

![image](https://github.com/user-attachments/assets/cd697783-6be9-4e7e-a335-726982a0026d)

![image](https://github.com/user-attachments/assets/602c04a0-4c2f-4a2a-9a3e-6b0bbecffc1d)

![image](https://github.com/user-attachments/assets/10aaadbd-3f0f-43f0-9ddb-789878f5bd3d)


## 📦 Configuração Pós-Implantação

### Visão Geral da Arquitetura de Volumes

#### Exemplo de Estrutura Inicial de Discos

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

**Observações:**
- As letras dos discos podem variar em seu ambiente
- Use `lsblk` para verificar a estrutura atual dos seus discos
- Ajuste os comandos de acordo com a estrutura específica do seu sistema

### Procedimento Detalhado de Configuração

#### 1. Identificação dos Discos

Primeiro, identifique os discos do sistema:

```bash
lsblk
```

#### 2. Configuração do Disco do Sistema

> **⚠️ Atenção:** Substitua `/dev/sda` pela letra do disco correto em seu ambiente.

> Como identificar a letra correta:
> - Use o comando `lsblk` para visualizar os discos
> - Verifique qual disco corresponde ao disco do sistema
> - Substitua todos os comandos abaixo com a letra do disco identificado

1. Ajuste da partição:
```bash
sudo parted /dev/sda disk_set pmbr_boot on
```
>  - *Substitua `sda` pela letra do seu disco do sistema*
>  - Responda "Fix" se perguntado
>  - Pressione ENTER para "Flag to Invert"
>  - Digite "on" para new state

2. Redimensionamento da partição:
```bash
sudo parted /dev/sda resizepart 2 95%
```
>  - *Substitua `sda` pela letra do seu disco do sistema*

3. Redimensionamento do volume físico:
```bash
sudo pvresize /dev/sda2
```
>  - *Substitua `sda` pela letra do seu disco do sistema*

4. Aumento do volume root:
```bash
sudo lvextend -L 20G /dev/rootvg/rootlv
sudo xfs_growfs /
```

#### 3. Criação de Volumes Lógicos

```bash
# Volumes lógicos adicionais
sudo lvcreate -L 9.5G -n rootvg_swap rootvg
sudo lvcreate -L 10G -n rootvg_tmp rootvg
sudo lvcreate -L 10G -n rootvg_var rootvg
sudo lvcreate -L 20G -n rootvg_home rootvg
sudo lvcreate -L 10G -n rootvg_opt rootvg
```

#### 4. Formatação dos Volumes

```bash
sudo mkswap /dev/rootvg/rootvg_swap
sudo mkfs.xfs -f /dev/rootvg/rootvg_tmp
sudo mkfs.xfs -f /dev/rootvg/rootvg_var
sudo mkfs.xfs -f /dev/rootvg/rootvg_home
sudo mkfs.xfs -f /dev/rootvg/rootvg_opt
```

#### 5. Configuração do Disco Adicional de 300GB

> [!WARNING]
> Substitua `/dev/sdc` e `/dev/sdc1` pelas letras corretas do disco adicional de 300GB em seu ambiente.
> 
> Como identificar a letra correta:
> 1. Use o comando `lsblk` para visualizar os discos
> 2. Identifique o disco de 300GB
> 3. Substitua todos os comandos abaixo com a letra do disco identificado
> 4. Preste atenção especial na numeração da partição (sdc**1**)

```bash
sudo parted --script /dev/sdc mklabel gpt
sudo parted --script /dev/sdc mkpart primary 0% 100%
sudo pvcreate /dev/sdc1
sudo vgcreate --physicalextentsize 32 vg_scnx /dev/sdc1
sudo lvcreate --extents 100%FREE vg_scnx --name securonix --yes
sudo mkdir -p /Securonix
sudo mkfs.xfs -f /dev/vg_scnx/securonix
```

**Exemplos práticos:**
- Se seu disco de 300GB for `sdb`, use:
  ```bash
  sudo parted --script /dev/sdb mklabel gpt
  sudo parted --script /dev/sdb mkpart primary 0% 100%
  sudo pvcreate /dev/sdb1
  sudo vgcreate --physicalextentsize 32 vg_scnx /dev/sdb1
  sudo lvcreate --extents 100%FREE vg_scnx --name securonix --yes
  sudo mkdir -p /Securonix
  sudo mkfs.xfs -f /dev/vg_scnx/securonix
  ```

> [!TIP]\
> Sempre verifique a saída do comando `lsblk` antes de executar qualquer operação de particionamento.

> [!WARNING]
> - A numeração da partição (sdc**1**) deve corresponder à partição criada no comando `mkpart`
> - Se o comando `lsblk` mostrar uma diferente numeração, ajuste os comandos de acordo

#### 6. Criação de Pontos de Montagem

```bash
sudo mkdir -p /tmp
sudo mkdir -p /var
sudo mkdir -p /home/securonix
sudo mkdir -p /opt
sudo mkdir -p /Securonix
```

#### 7. Configuração do /etc/fstab

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

#### 8. Montagem dos Volumes

```bash
sudo mount -a
sudo swapon -a
sudo systemctl daemon-reload
```

#### Estrutura Final Esperada Após Configuração

```
sda                  128G disk
├─sda1               800M part /boot
├─sda2               120.3G part
  ├─rootvg-rootlv      20G lvm /
  ├─rootvg-crashlv     10G lvm /var/crash
  ├─rootvg-rootvg_swap 9.5G lvm [SWAP]
  ├─rootvg-rootvg_tmp  10G lvm /tmp
  ├─rootvg-rootvg_var  10G lvm /var
  ├─rootvg-rootvg_home 20G lvm /home/securonix
  └─rootvg-rootvg_opt  10G lvm /opt
sdb                   32G disk
└─sdb1                32G part /mnt
sdc                  300G disk
└─sdc1               300G part
  └─vg_scnx-securonix 300G lvm /Securonix
```


## 🔄 Versionamento

- Versão: 1.0.0
- Última atualização: 03/02/2025


> [!WARNING]
> - A numeração da partição (sdc**1**) deve corresponder à partição criada no comando `mkpart`
> - Se o comando `lsblk` mostrar uma diferente numeração, ajuste os comandos de acordo
