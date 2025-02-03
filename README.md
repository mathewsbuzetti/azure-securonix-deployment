![Azure](https://img.shields.io/badge/Azure-blue?style=flat-square&logo=microsoftazure) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) ![ARM Template](https://img.shields.io/badge/ARM-Template-orange?style=flat-square)

✔️ Applies to: Azure Linux VMs

### Deployment Options

#### Automated Deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathewsbuzetti%2Fsecuronixish%2Fmain%2Fazuredeploy.json)

1. Click the "Deploy to Azure" button above
2. Configure deployment parameters:
   - Subscription
   - Resource Group 
   - Region
   - Admin Username
   - Authentication Type
   - Admin Credentials

#### Manual Deployment in Azure Portal

If you have already provisioned the machine manually in the Azure portal, follow the instructions below. Important: Verify that you selected the Oracle Linux 8.10 OS image as shown in the image:

![Oracle Linux Image Selection](https://github.com/user-attachments/assets/e77448fa-a663-4030-b6e5-d2c26312303d)

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

### Identificação dos Discos

1. Primeiro, identifique os discos usando o comando:
```bash
lsblk
```

Você verá uma estrutura similar a esta:
```
NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
**sda**                   8:0    0  100G  0 disk
├─**sda**1                8:1    0  800M  0 part /boot
├─**sda**2                8:2    0 28.7G  0 part
  ├─rootvg-rootlv   252:0    0 18.7G  0 lvm  /
  ├─rootvg-crashlv  252:1    0   10G  0 lvm  /var/crash
├─**sda**14               8:14   0    4M  0 part
└─**sda**15               8:15   0  495M  0 part /boot/efi
sdb                   8:16   0   32G  0 disk
**sdc**                   8:32   0  300G  0 disk
sr0                  11:0    1  634K  0 rom
```

### Comandos de Configuração

1. Para o disco do sistema (substitua **sda** pela letra correta do seu disco):
```bash
# Ajuste da partição
sudo parted /dev/**sda** disk_set pmbr_boot on

# Redimensionamento da partição
sudo parted /dev/**sda** resizepart 2 95%

# Redimensionamento do volume físico
sudo pvresize /dev/**sda**2

# Aumento do volume root
sudo lvextend -L 20G /dev/rootvg/rootlv
sudo xfs_growfs /
```

2. Criação de volumes lógicos:
```bash
sudo lvcreate -L 9.5G -n rootvg_swap rootvg
sudo lvcreate -L 10G -n rootvg_tmp rootvg
sudo lvcreate -L 10G -n rootvg_var rootvg
sudo lvcreate -L 20G -n rootvg_home rootvg
sudo lvcreate -L 10G -n rootvg_opt rootvg
```

3. Formatação dos volumes:
```bash
sudo mkswap /dev/rootvg/rootvg_swap
sudo mkfs.xfs -f /dev/rootvg/rootvg_tmp
sudo mkfs.xfs -f /dev/rootvg/rootvg_var
sudo mkfs.xfs -f /dev/rootvg/rootvg_home
sudo mkfs.xfs -f /dev/rootvg/rootvg_opt
```

4. Configuração do disco adicional de 300GB:
```bash
sudo parted --script /dev/**sdc** mklabel gpt
sudo parted --script /dev/**sdc** mkpart primary 0% 100%
sudo pvcreate /dev/**sdc**1
sudo vgcreate --physicalextentsize 32 vg_scnx /dev/**sdc**1
sudo lvcreate --extents 100%FREE vg_scnx --name securonix
sudo mkdir -p /Securonix
sudo mkfs.xfs -f /dev/vg_scnx/securonix
```

## 📝 Licença e Uso

- 🔓 Uso livre para projetos pessoais e comerciais
- 📝 Atribuição necessária em caso de uso ou redistribuição
- 🚫 Proibida a venda direta do código-fonte
- 🤝 Contribuições são bem-vindas

## ⚠️ Notas Importantes

- Letras de disco (**sda**, sdb, **sdc**) podem variar entre ambientes
- Sempre verifique a configuração do disco antes de executar comandos
- Recomenda-se backup antes de fazer alterações sistêmicas

## 🤔 Resolução de Problemas

- Verifique o alinhamento de partições usando `lsblk`
- Verifique o status do grupo de volumes com `vgs`
- Confirme a montagem do sistema de arquivos com `mount`
