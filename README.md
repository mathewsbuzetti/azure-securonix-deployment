# 🚀 Template de Implantação de VM Securonix no Azure

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Mathews_Buzetti-blue)](https://www.linkedin.com/in/mathewsbuzetti)
![Azure](https://img.shields.io/badge/Azure-blue?style=flat-square&logo=microsoftazure) 
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) 
![ARM Template](https://img.shields.io/badge/ARM-Template-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Production-green?style=flat-square)
![Documentation](https://img.shields.io/badge/Documentation-Technical-blue?style=flat-square)

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
  - Disco de Dados: 512GB Premium_LRS
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
sdc                  512G disk
└─sdc1               512G part
  └─vg_scnx-securonix 512G lvm /Securonix
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

- Disco de Dados: 512GB Premium_LRS

![image](https://github.com/user-attachments/assets/cd697783-6be9-4e7e-a335-726982a0026d)

![image](https://github.com/user-attachments/assets/602c04a0-4c2f-4a2a-9a3e-6b0bbecffc1d)

![image](https://github.com/user-attachments/assets/10aaadbd-3f0f-43f0-9ddb-789878f5bd3d)


## 📦 Configuração Pós-Implantação

### Opções de Configuração

Para configurar os discos da sua VM Securonix, você tem duas opções:

1. **[Recomendado] Configuração Automatizada** - Utilizando o script `securonix-disk-configurator.sh`
2. **Configuração Manual** - Seguindo o procedimento detalhado passo a passo

### Opção 1: Configuração Automatizada com Script

O script `securonix-disk-configurator.sh` automatiza todo o processo de configuração dos volumes necessários para o Securonix. Siga os passos abaixo, acompanhados por capturas de tela para facilitar o entendimento.

#### Passos para Execução do Script

1. **Criar o arquivo do script**:
   ```bash
   nano securonix-disk-configurator.sh
   ```
   * Cole o conteúdo do script disponibilizado
   
   > [!WARNING]
   > - Certifique-se de copiar **TODO** o conteúdo do script sem modificações
   > - Execute este comando no diretório onde deseja manter o script
   > - Não altere o nome do arquivo para garantir compatibilidade com as instruções
   > - O script deve ser executado em uma VM recém-criada antes de qualquer outra configuração

2. **Tornar o script executável**:
   ```bash
   chmod +x securonix-disk-configurator.sh
   ```

3. **Executar o script com privilégios de superusuário**:
   ```bash
   sudo ./securonix-disk-configurator.sh
   ```

4. **Tela inicial**: O script mostrará a tela de boas-vindas com a configuração que será aplicada nos discos.

   ![Tela inicial do script de configuração](https://github.com/user-attachments/assets/668ab670-8da0-45a6-9222-91dc9719b9f7)
   
   Esta tela inicial apresenta:
   * A estrutura de volumes que será criada no disco do sistema
   * A estrutura do volume de dados que será montado em `/Securonix`

5. **Visualização de discos e seleção**: O script exibirá os discos disponíveis e solicitará que você selecione os discos apropriados.

   ![Layout de discos e seleção](https://github.com/user-attachments/assets/c407a73e-f085-4041-a06d-c95d9aa03065)
   
> [!WARNING]
> Nesta tela: 
> * Observe todos os discos disponíveis no sistema
> * Identifique o disco do sistema (que contém o SO) e o disco de dados não formatado
> * Utilize o comando `lsblk` para verificar o tamanho e estrutura de cada disco
> * Não prossiga até ter certeza de quais discos serão utilizados
   
6. **Seleção da partição do sistema**: Digite a partição do disco do sistema que contém os volumes lógicos.

   ![Seleção de partição do sistema](https://github.com/user-attachments/assets/898dd06e-3eb0-4852-b3c5-c5b9c30e9569)
   
   > [!WARNING]
   > * Neste exemplo, o usuário selecionou `sdb2` como a partição do sistema
   > * Em seguida, você deverá selecionar o disco para dados (ex: `sda`)
   > * Selecionar a partição errada pode causar perda de dados ou falha na instalação
   > * Certifique-se de selecionar a partição que contém os volumes lógicos rootvg

7. **Resumo da configuração**: O script apresentará um resumo das escolhas feitas para confirmação.

   ![Resumo da configuração](https://github.com/user-attachments/assets/7e3b1b50-4b7d-48c5-96ec-d483ac29d78b)
   
   > [!WARNING]
   > * Verifique se os discos selecionados estão corretos
   > * TODOS os dados no disco selecionado para dados serão destruídos
   > * Confirme digitando `s` quando solicitado
   > * Esta é sua última chance de cancelar antes que as mudanças sejam aplicadas

8. **Mensagens durante a execução**: Durante a configuração, você verá avisos do sistema que requerem sua interação:

   ![Avisos durante execução](https://github.com/user-attachments/assets/cd3e6b53-6d23-451d-8245-60f440d12926)
   
   > [!WARNING]
   > Quando essas mensagens aparecerem, responda **EXATAMENTE** da seguinte forma:
   > * Quando aparecer "Fix/Ignore?" → Digite `Fix` e pressione ENTER
   > * Quando aparecer "Flag to Invert? [pmbr_boot]?" → Apenas pressione ENTER
   > * Quando aparecer "New state? [on]/off?" → Digite `on` e pressione ENTER
   >
   > Responder incorretamente a essas mensagens pode resultar em falha na configuração!

9. **Conclusão**: Ao término da execução, o script exibirá a configuração final dos discos.

   ![Configuração concluída](https://github.com/user-attachments/assets/2d7966b9-2ec5-458d-9de8-fde27d1244eb)
   
   > [!NOTE]
   > * Verifique a estrutura final dos discos
   > * Confirme que todos os volumes foram criados corretamente
   > * A mensagem "Configuração de disco concluída com sucesso!" indica que o processo foi finalizado sem erros
   > * Anote essa configuração para referência futura

### Opção 2: Configuração Manual

Caso prefira configurar os discos manualmente, siga o procedimento detalhado abaixo.

#### Visão Geral da Arquitetura de Volumes

#### Exemplo de Estrutura Inicial de Discos

```
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                  8:0    0  512G  0 disk
sdb                  8:16   0  128G  0 disk
├─sdb1               8:17   0  800M  0 part /boot
├─sdb2               8:18   0 28.7G  0 part
│ ├─rootvg-rootlv  252:0    0 18.7G  0 lvm  /
│ └─rootvg-crashlv 252:1    0   10G  0 lvm  /var/crash
├─sdb14              8:30   0    4M  0 part
└─sdb15              8:31   0  495M  0 part /boot/efi
sdc                  8:32   0   32G  0 disk
└─sdc1               8:33   0   32G  0 part /mnt
sr0                 11:0    1  634K  0 rom
```

> [!WARNING]
> - As letras dos discos podem variar em seu ambiente
> - Use `lsblk` para verificar a estrutura atual dos seus discos
> - Ajuste os comandos de acordo com a estrutura específica do seu sistema

### Procedimento Detalhado de Configuração

#### 1. Identificação dos Discos

Primeiro, identifique os discos do sistema:

```bash
lsblk
```

#### 2. Configuração do Disco do Sistema

> [!WARNING]
> Nos exemplos abaixo, estamos usando `/dev/sdb` como o disco do sistema e `/dev/sdb2` como a partição principal. Substitua por suas letras de disco corretas.
> 
> Como identificar a letra correta:
> - Use o comando `lsblk` para visualizar os discos
> - Verifique qual disco contém as partições do sistema operacional
> - Identifique a partição principal (que normalmente contém os volumes lógicos rootvg)
> - Substitua todos os comandos abaixo com as letras de disco identificadas

1. Ajuste da partição:
```bash
sudo parted /dev/sdb disk_set pmbr_boot on
```
> [!WARNING]
>  - *Substitua `sdb` pela letra do seu disco do sistema*
>  - Responda "Fix" se perguntado
>  - Pressione ENTER para "Flag to Invert"
>  - Digite "on" para new state

2. Redimensionamento da partição:
```bash
sudo parted /dev/sdb resizepart 2 95%
```
> [!WARNING]\
> *Substitua `sdb` pela letra do seu disco do sistema e `2` pelo número correto da partição*

3. Redimensionamento do volume físico:
```bash
sudo pvresize /dev/sdb2
```
> [!WARNING]\
> *Substitua `sdb2` pela letra e número da partição correta em seu sistema*

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

#### 5. Configuração do Disco Adicional de 512GB

> [!WARNING]
> Nos exemplos abaixo, estamos usando `/dev/sda` como o disco de dados de 512GB. Substitua pela letra do seu disco de dados.
> 
> Como identificar a letra correta:
> 1. Use o comando `lsblk` para visualizar os discos
> 2. Identifique o disco não formatado de 512GB
> 3. Substitua todos os comandos abaixo com a letra do disco identificado

```bash
sudo parted --script /dev/sda mklabel gpt
sudo parted --script /dev/sda mkpart primary 0% 100%
sudo pvcreate /dev/sda1
sudo vgcreate --physicalextentsize 32 vg_scnx /dev/sda1
sudo lvcreate --extents 100%FREE vg_scnx --name securonix --yes
sudo mkdir -p /Securonix
sudo mkfs.xfs -f /dev/vg_scnx/securonix
```

**Exemplos práticos:**
- Se seu disco de 512GB for `sdc`, use:
  ```bash
  sudo parted --script /dev/sdc mklabel gpt
  sudo parted --script /dev/sdc mkpart primary 0% 100%
  sudo pvcreate /dev/sdc1
  sudo vgcreate --physicalextentsize 32 vg_scnx /dev/sdc1
  sudo lvcreate --extents 100%FREE vg_scnx --name securonix --yes
  sudo mkdir -p /Securonix
  sudo mkfs.xfs -f /dev/vg_scnx/securonix
  ```

> [!TIP]\
> Sempre verifique a saída do comando `lsblk` antes de executar qualquer operação de particionamento.

> [!WARNING]
> - Após a criação da partição com `mkpart`, o sistema normalmente cria automaticamente o nó de dispositivo (ex: `/dev/sda1`)
> - Aguarde alguns segundos após o comando `mkpart` antes de prosseguir para garantir que o sistema reconheça a nova partição
> - Se o dispositivo não aparecer, pode ser necessário executar `partprobe` para atualizar as tabelas de partição

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

Dependendo da sua configuração inicial, a estrutura final pode variar. Abaixo está um exemplo com base na configuração mostrada anteriormente:

```
sda                  512G disk
└─sda1               512G part
  └─vg_scnx-securonix 512G lvm /Securonix
sdb                  128G disk
├─sdb1               800M part /boot
├─sdb2               120.3G part
  ├─rootvg-rootlv      20G lvm /
  ├─rootvg-crashlv     10G lvm /var/crash
  ├─rootvg-rootvg_swap 9.5G lvm [SWAP]
  ├─rootvg-rootvg_tmp  10G lvm /tmp
  ├─rootvg-rootvg_var  10G lvm /var
  ├─rootvg-rootvg_home 20G lvm /home/securonix
  └─rootvg-rootvg_opt  10G lvm /opt
sdc                   32G disk
└─sdc1                32G part /mnt
```

> [!NOTE]
> A ordem e as letras dos discos podem variar no seu ambiente. O importante é que os volumes lógicos estejam configurados corretamente com os tamanhos e pontos de montagem especificados.

## 🔄 Versionamento

- Versão: 1.0.0
- Última atualização: 03/02/2025
