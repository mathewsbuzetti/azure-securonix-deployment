# Azure VM Securonix

Template ARM para criar uma VM Oracle Linux com configurações específicas para Securonix.

## Especificações

- VM Oracle Linux 8
- 4 vCPUs, 16GB RAM
- Disco SO: 100GB StandardSSD_LRS
- Disco Dados: 300GB Premium_LRS

## Configurações LVM automáticas
- vg_system_swap (9.5GB) para SWAP
- vg_system_root (20GB) para /
- vg_system_tmp (10GB) para /tmp
- vg_system_var (10GB) para /var
- vg_system_home (20GB) para /home/securonix
- vg_system_opt (10GB) para /opt

## Deploy

Clique no botão abaixo para fazer o deploy no Azure:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathewsbuzetti%2Fsecuronixish%2Fmain%2Fazuredeploy.json)

## Como usar

1. Clique no botão "Deploy to Azure" acima
2. Preencha os parâmetros necessários:
   - Subscription: selecione sua subscrição
   - Resource Group: crie novo ou use existente
   - Region: selecione a região desejada
   - Admin Username: nome do usuário administrador
   - Authentication Type: password ou SSH key
   - Admin Password: senha do usuário (se escolher autenticação por senha)
