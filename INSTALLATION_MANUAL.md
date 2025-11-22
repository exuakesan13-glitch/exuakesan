# Manual de Instalação - Sistema de Disparos em Massa de Torpedos de Voz

## Índice

1. [Requisitos do Sistema](#requisitos-do-sistema)
2. [Instalação Automatizada](#instalação-automatizada)
3. [Instalação Manual](#instalação-manual)
4. [Configuração Inicial](#configuração-inicial)
5. [Testes e Validação](#testes-e-validação)
6. [Troubleshooting](#troubleshooting)
7. [Manutenção](#manutenção)

---

## Requisitos do Sistema

### Hardware Mínimo

- **CPU**: 2 núcleos (recomendado 4 ou mais)
- **RAM**: 4 GB (recomendado 8 GB ou mais)
- **Disco**: 20 GB (para sistema + áudios)
- **Conexão**: Banda larga estável (mínimo 2 Mbps)

### Software

- **Sistema Operacional**: Debian 11 (Bullseye)
- **Asterisk**: 18.x ou superior
- **Node.js**: 22.x ou superior
- **MySQL**: 8.0 ou superior
- **Acesso Root**: Necessário para instalação

### Portas Necessárias

| Porta | Protocolo | Serviço | Descrição |
|-------|-----------|---------|-----------|
| 22 | TCP | SSH | Acesso remoto |
| 80 | TCP | HTTP | Aplicação web (redirecionado) |
| 443 | TCP | HTTPS | Aplicação web (recomendado) |
| 3000 | TCP | Node.js | Aplicação web |
| 5038 | TCP | Asterisk AMI | Manager Interface |
| 5060 | UDP | SIP | Protocolo VoIP |
| 5061 | TCP | SIP | Protocolo VoIP (TLS) |
| 3306 | TCP | MySQL | Banco de dados |

---

## Instalação Automatizada

### Passo 1: Preparação do Servidor

```bash
# Conectar ao servidor via SSH
ssh root@seu_servidor

# Atualizar o sistema
apt-get update && apt-get upgrade -y

# Instalar wget (se não estiver instalado)
apt-get install -y wget
```

### Passo 2: Download e Execução do Script

```bash
# Navegar para um diretório temporário
cd /tmp

# Download do script de instalação
wget https://seu_repositorio/install.sh

# Dar permissão de execução
chmod +x install.sh

# Executar o script
sudo bash install.sh
```

### Passo 3: Configuração Pós-Instalação

```bash
# Executar script de configuração pós-instalação
sudo bash /opt/asterisk-voice-blast/install/post-install.sh

# Verificar status dos serviços
sudo systemctl status asterisk
sudo systemctl status asterisk-voice-blast
sudo systemctl status mysql
```

---

## Instalação Manual

Se preferir instalar manualmente, siga os passos abaixo:

### 1. Instalar Dependências Básicas

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    vim \
    htop \
    net-tools \
    sudo \
    systemd \
    openssh-server \
    ufw
```

### 2. Instalar Asterisk

```bash
# Instalar dependências do Asterisk
sudo apt-get install -y \
    libssl-dev \
    libncurses5-dev \
    libnewt-dev \
    libxml2-dev \
    libsqlite3-dev \
    uuid-dev \
    libjansson-dev \
    linux-headers-$(uname -r)

# Download do Asterisk
cd /usr/src
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
sudo tar -xzf asterisk-18-current.tar.gz
cd asterisk-18*/

# Compilação
sudo ./contrib/scripts/install_prereq install -y
sudo ./configure --with-pjproject-bundled
sudo make menuselect.makeopts
sudo ./menuselect/menuselect --enable-extra-sounds-en-gsm menuselect.makeopts
sudo make -j$(nproc)
sudo make install
sudo make config

# Criar usuário Asterisk
sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk

# Configurar permissões
sudo chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/log/asterisk /var/spool/asterisk /usr/lib/asterisk

# Configurar para rodar como usuário asterisk
sudo sed -i 's/#AST_USER="asterisk"/AST_USER="asterisk"/' /etc/default/asterisk
sudo sed -i 's/#AST_GROUP="asterisk"/AST_GROUP="asterisk"/' /etc/default/asterisk
```

### 3. Instalar Node.js

```bash
# Adicionar repositório NodeSource
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Instalar Node.js
sudo apt-get install -y nodejs

# Instalar pnpm
sudo npm install -g pnpm
```

### 4. Instalar MySQL

```bash
sudo apt-get install -y mysql-server

# Iniciar MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Criar banco de dados
sudo mysql -e "CREATE DATABASE IF NOT EXISTS asterisk_voice_blast CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'asterisk'@'localhost' IDENTIFIED BY 'asterisk_secure_password_123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON asterisk_voice_blast.* TO 'asterisk'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

### 5. Instalar Aplicação Web

```bash
# Criar diretório da aplicação
sudo mkdir -p /opt/asterisk-voice-blast
cd /opt/asterisk-voice-blast

# Copiar arquivos da aplicação
# (Assumindo que você tem os arquivos em um repositório Git)
sudo git clone https://seu_repositorio/asterisk-voice-blast .

# Instalar dependências
sudo pnpm install

# Criar arquivo .env.local
sudo cat > .env.local << 'EOF'
DATABASE_URL="mysql://asterisk:asterisk_secure_password_123@localhost:3306/asterisk_voice_blast"
ASTERISK_HOST=localhost
ASTERISK_PORT=5038
ASTERISK_USER=admin
ASTERISK_PASSWORD=asterisk_ami_password_123
VITE_APP_TITLE="Sistema de Disparos de Voz"
NODE_ENV=production
PORT=3000
EOF

# Criar tabelas do banco de dados
sudo pnpm db:push
```

### 6. Configurar Asterisk Manager Interface (AMI)

```bash
# Editar arquivo de configuração
sudo nano /etc/asterisk/manager.conf

# Adicionar o seguinte conteúdo:
# [general]
# enabled = yes
# port = 5038
# bindaddr = 0.0.0.0
# timestampevents = yes
#
# [admin]
# secret = asterisk_ami_password_123
# deny=0.0.0.0/0.0.0.0
# permit=127.0.0.1/255.255.255.0
# permit=::1/128
# read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
# write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message

# Definir permissões
sudo chown asterisk:asterisk /etc/asterisk/manager.conf
sudo chmod 600 /etc/asterisk/manager.conf
```

### 7. Criar Serviço Systemd

```bash
# Criar arquivo de serviço
sudo cat > /etc/systemd/system/asterisk-voice-blast.service << 'EOF'
[Unit]
Description=Sistema de Disparos de Voz - Asterisk Voice Blast
After=network.target mysql.service asterisk.service
Wants=asterisk.service

[Service]
Type=simple
User=asterisk
WorkingDirectory=/opt/asterisk-voice-blast
ExecStart=/usr/bin/pnpm start
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=asterisk-voice-blast

[Install]
WantedBy=multi-user.target
EOF

# Recarregar systemd
sudo systemctl daemon-reload
sudo systemctl enable asterisk-voice-blast
```

### 8. Iniciar Serviços

```bash
# Iniciar Asterisk
sudo systemctl start asterisk
sudo systemctl enable asterisk

# Aguardar Asterisk iniciar
sleep 5

# Iniciar aplicação web
sudo systemctl start asterisk-voice-blast

# Verificar status
sudo systemctl status asterisk
sudo systemctl status asterisk-voice-blast
```

### 9. Configurar Firewall

```bash
# Habilitar firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5060/udp
sudo ufw allow 5061/tcp
sudo ufw allow 5038/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable
```

---

## Configuração Inicial

### 1. Acessar a Aplicação Web

Abra seu navegador e acesse:

```
http://seu_servidor:3000
```

### 2. Configurar Credenciais OAuth Manus

1. Acesse as configurações da aplicação
2. Configure suas credenciais OAuth Manus
3. Salve as alterações

### 3. Configurar Credenciais S3

1. Vá para Configurações → Armazenamento
2. Adicione suas credenciais AWS S3
3. Teste a conexão

### 4. Configurar Troncos SIP

1. Acesse Troncos SIP
2. Clique em "Novo Tronco"
3. Configure:
   - Nome do tronco
   - Servidor SIP
   - Usuário
   - Senha
   - Porta (geralmente 5060)
4. Salve e teste a conexão

### 5. Criar Ramais

1. Acesse Ramais
2. Clique em "Novo Ramal"
3. Configure:
   - Número do ramal
   - Nome
   - Tipo (SIP, IAX2, etc.)
   - Credenciais
4. Salve

### 6. Criar Filas de Atendimento

1. Acesse Filas
2. Clique em "Nova Fila"
3. Configure:
   - Nome da fila
   - Estratégia de atendimento
   - Timeout
   - Áudio de espera (MOH)
4. Adicione agentes à fila
5. Salve

### 7. Importar Contatos

1. Acesse Contatos
2. Clique em "Importar CSV"
3. Baixe o template
4. Preencha com seus contatos (nome, telefone, etc.)
5. Faça upload do arquivo
6. Revise e confirme a importação

### 8. Criar Campanhas

1. Acesse Campanhas
2. Clique em "Nova Campanha"
3. Configure:
   - Nome da campanha
   - Descrição
   - Selecione contatos
   - Selecione áudio
   - Defina quantidade de chamadas simultâneas
   - Configure menu IVR (opcional)
4. Salve e inicie a campanha

---

## Testes e Validação

### Teste de Conectividade

```bash
# Testar conexão com Asterisk AMI
telnet localhost 5038

# Testar conexão com MySQL
mysql -u asterisk -p asterisk_secure_password_123 -e "SELECT 1" asterisk_voice_blast

# Testar aplicação web
curl http://localhost:3000
```

### Teste de Chamada

1. Configure um ramal SIP em seu telefone
2. Faça uma chamada de teste
3. Verifique se a chamada é registrada no sistema
4. Verifique os logs

### Verificar Logs

```bash
# Logs da aplicação
sudo journalctl -u asterisk-voice-blast -f

# Logs do Asterisk
sudo tail -f /var/log/asterisk/full

# Logs do MySQL
sudo tail -f /var/log/mysql/error.log
```

---

## Troubleshooting

### Problema: Aplicação não inicia

```bash
# Verificar status
sudo systemctl status asterisk-voice-blast

# Ver logs detalhados
sudo journalctl -u asterisk-voice-blast -n 50

# Tentar iniciar manualmente
cd /opt/asterisk-voice-blast
pnpm start
```

### Problema: Asterisk não conecta

```bash
# Verificar se Asterisk está rodando
sudo systemctl status asterisk

# Reiniciar Asterisk
sudo systemctl restart asterisk

# Verificar logs
sudo tail -f /var/log/asterisk/full
```

### Problema: Banco de dados inacessível

```bash
# Verificar status do MySQL
sudo systemctl status mysql

# Testar conexão
mysql -u asterisk -p asterisk_secure_password_123 asterisk_voice_blast

# Reiniciar MySQL
sudo systemctl restart mysql
```

### Problema: Portas em uso

```bash
# Listar processos nas portas
sudo netstat -tlnp | grep -E "3000|5038|5060|3306"

# Matar processo na porta (exemplo: 3000)
sudo lsof -i :3000
sudo kill -9 <PID>
```

### Usar Script de Troubleshooting

```bash
# Executar diagnóstico completo
sudo asterisk-voice-blast-troubleshoot
```

---

## Manutenção

### Backup Regular

```bash
# Fazer backup manual
sudo /opt/asterisk-voice-blast/install/backup.sh backup

# Listar backups disponíveis
sudo /opt/asterisk-voice-blast/install/backup.sh list

# Restaurar backup
sudo /opt/asterisk-voice-blast/install/backup.sh restore 20240101_120000
```

### Atualizar Aplicação

```bash
# Parar serviço
sudo systemctl stop asterisk-voice-blast

# Atualizar código
cd /opt/asterisk-voice-blast
sudo git pull
sudo pnpm install
sudo pnpm db:push

# Iniciar serviço
sudo systemctl start asterisk-voice-blast
```

### Monitorar Sistema

```bash
# Ver status dos serviços
sudo asterisk-voice-blast-monitor

# Ver uso de recursos
free -h
df -h
top
```

### Rotação de Logs

```bash
# Logs são rotacionados automaticamente
# Configuração em: /etc/logrotate.d/asterisk-voice-blast

# Forçar rotação manual
sudo logrotate -f /etc/logrotate.d/asterisk-voice-blast
```

---

## Suporte e Documentação

- **Documentação Completa**: `/opt/asterisk-voice-blast/DOCUMENTATION.md`
- **Arquivo de Status**: `/opt/asterisk-voice-blast/INSTALLATION_STATUS.txt`
- **Logs da Aplicação**: `/var/log/asterisk-voice-blast/`
- **Logs do Asterisk**: `/var/log/asterisk/`
- **Logs do MySQL**: `/var/log/mysql/`

---

## Segurança

### Alterar Senhas Padrão

```bash
# Alterar senha do MySQL
mysql -u asterisk -p asterisk_secure_password_123 -e "ALTER USER 'asterisk'@'localhost' IDENTIFIED BY 'nova_senha';"

# Atualizar .env.local
sudo nano /opt/asterisk-voice-blast/.env.local
```

### Configurar HTTPS

```bash
# Instalar Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Gerar certificado
sudo certbot certonly --standalone -d seu_dominio.com

# Configurar Nginx (se usado como proxy)
# Adicionar certificado ao Nginx
```

### Firewall

```bash
# Verificar regras do firewall
sudo ufw status

# Adicionar regra específica
sudo ufw allow from 192.168.1.0/24 to any port 5038

# Remover regra
sudo ufw delete allow 3000/tcp
```

---

## Conclusão

Parabéns! Seu sistema de disparos de voz está pronto para uso. Para começar:

1. Acesse a aplicação em `http://seu_servidor:3000`
2. Configure os troncos SIP
3. Crie ramais e filas
4. Importe contatos
5. Crie e execute campanhas

Para suporte adicional, consulte a documentação ou os logs do sistema.

**Data de Criação**: 2024
**Versão**: 1.0
**Compatibilidade**: Debian 11, Asterisk 18.x, Node.js 22.x
