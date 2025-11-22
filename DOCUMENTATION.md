# Sistema de Disparos em Massa de Torpedos de Voz

## Visão Geral

Sistema completo e profissional para disparos em massa de torpedos de voz utilizando **Asterisk** como base de telefonia e interface web moderna para gerenciamento. O sistema foi desenvolvido para call centers e empresas que precisam realizar campanhas de voz automatizadas em larga escala.

## Características Principais

### Gerenciamento de Contatos
- **Importação em massa via CSV**: Faça upload de arquivos CSV com milhares de contatos de uma só vez
- **Campos customizáveis**: Além de nome, telefone e email, o sistema suporta até 5 campos personalizados por contato
- **Busca e filtros**: Encontre contatos rapidamente através de busca em tempo real
- **Validação automática**: O sistema valida números de telefone e formatos de dados durante a importação

### Gerenciamento de Áudios
- **Upload de áudios para campanhas**: Envie mensagens de voz que serão reproduzidas nas chamadas
- **Música de espera (MOH)**: Configure áudios para filas de atendimento
- **Formatos suportados**: WAV, MP3, GSM
- **Armazenamento em nuvem**: Todos os áudios são armazenados de forma segura em S3

### Campanhas de Disparo
- **Criação intuitiva**: Interface simples para criar campanhas em minutos
- **Seleção de contatos**: Escolha quais contatos receberão as chamadas
- **Controle de concorrência**: Configure quantas chamadas simultâneas o sistema deve realizar (1 a 1000)
- **Menu IVR**: Habilite menus interativos para capturar respostas dos clientes
- **Controles de execução**: Inicie, pause e retome campanhas a qualquer momento
- **Status em tempo real**: Acompanhe o progresso das campanhas no dashboard

### Configuração de Telefonia

#### Ramais SIP
- Crie e gerencie ramais SIP para agentes
- Configure Caller ID personalizado
- Ative/desative ramais conforme necessário

#### Filas de Atendimento
- Configure múltiplas filas de espera
- Estratégias de distribuição: Ring All, Least Recent, Fewest Calls, Random, Round Robin
- Configuração de timeout e retry
- Limite de chamadas por fila

#### Troncos SIP
- Conecte-se a provedores SIP externos
- Configure servidor, usuário, senha e porta
- Suporte a múltiplos troncos para redundância

### Relatórios e Monitoramento

#### Dashboard em Tempo Real
- Campanhas ativas no momento
- Total de contatos cadastrados
- Arquivos de áudio disponíveis
- Canais ativos do Asterisk
- Status do servidor de telefonia

#### Relatórios Detalhados
- **Chamadas atendidas**: Quantas pessoas atenderam
- **Chamadas não atendidas**: Números que não atenderam
- **Ocupado**: Linhas ocupadas durante a tentativa
- **Caixa postal**: Chamadas que caíram na caixa postal
- **Opções IVR**: Respostas digitadas pelos clientes no menu
- **Duração das chamadas**: Tempo de cada chamada
- **Histórico completo**: Data e hora de todas as tentativas

## Arquitetura Técnica

### Frontend
- **React 19** com TypeScript
- **Tailwind CSS 4** para estilização profissional
- **shadcn/ui** para componentes de interface
- **tRPC** para comunicação type-safe com backend
- **Tema escuro profissional** otimizado para call centers

### Backend
- **Node.js** com Express
- **tRPC** para APIs type-safe
- **MySQL/TiDB** como banco de dados
- **Drizzle ORM** para acesso ao banco
- **S3** para armazenamento de áudios

### Integração Asterisk
- **AMI (Asterisk Manager Interface)** para controle do Asterisk
- Geração automática de arquivos de configuração (.conf)
- Monitoramento de status em tempo real
- Controle de chamadas via API

## Estrutura do Banco de Dados

### Tabelas Principais

**users**: Usuários do sistema com controle de acesso

**contacts**: Lista de contatos para campanhas
- Campos: nome, telefone, email, customField1-5

**audioFiles**: Arquivos de áudio para campanhas e MOH
- Tipos: campaign (campanha) ou moh (música de espera)
- Armazenamento: URL do S3

**campaigns**: Campanhas de disparo
- Status: draft, scheduled, running, paused, completed, cancelled
- Controle de chamadas simultâneas
- Configuração de IVR

**extensions**: Ramais SIP
- Configuração de secret, caller ID

**queues**: Filas de atendimento
- Estratégias de distribuição
- Timeout e retry

**trunks**: Troncos SIP externos
- Conexão com provedores

**callLogs**: Logs de todas as chamadas
- Status: answered, no-answer, busy, failed, voicemail
- Duração, opção IVR digitada

**campaignContacts**: Relacionamento entre campanhas e contatos

**queueMembers**: Agentes das filas

## Instalação e Configuração

### Pré-requisitos
- Debian 11 (recomendado)
- Asterisk 18.x ou superior
- Node.js 22.x
- MySQL 8.0 ou TiDB
- Acesso a bucket S3

### Instalação do Asterisk no Debian 11

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y build-essential wget libssl-dev libncurses5-dev libnewt-dev libxml2-dev linux-headers-$(uname -r) libsqlite3-dev uuid-dev libjansson-dev

# Baixar Asterisk
cd /usr/src
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
sudo tar -xvzf asterisk-18-current.tar.gz
cd asterisk-18*/

# Instalar dependências do Asterisk
sudo contrib/scripts/install_prereq install

# Configurar e compilar
sudo ./configure
sudo make menuselect  # Selecione os módulos necessários
sudo make -j$(nproc)
sudo make install
sudo make samples
sudo make config

# Criar usuário asterisk
sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
sudo chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/log/asterisk /var/spool/asterisk /usr/lib/asterisk

# Configurar Asterisk para rodar como usuário asterisk
sudo sed -i 's/#AST_USER="asterisk"/AST_USER="asterisk"/' /etc/default/asterisk
sudo sed -i 's/#AST_GROUP="asterisk"/AST_GROUP="asterisk"/' /etc/default/asterisk

# Iniciar Asterisk
sudo systemctl start asterisk
sudo systemctl enable asterisk
```

### Configuração do AMI (Asterisk Manager Interface)

Edite o arquivo `/etc/asterisk/manager.conf`:

```ini
[general]
enabled = yes
port = 5038
bindaddr = 0.0.0.0

[admin]
secret = SuaSenhaSegura123
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate
write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate
```

Reinicie o Asterisk:
```bash
sudo asterisk -rx "manager reload"
```

### Configuração do Sistema Web

1. **Clone o repositório** (ou extraia os arquivos do projeto)

2. **Configure as variáveis de ambiente**:
   - As variáveis principais já estão configuradas automaticamente pelo Manus
   - Configure as credenciais do Asterisk AMI no código se necessário

3. **Instale as dependências**:
```bash
pnpm install
```

4. **Configure o banco de dados**:
```bash
pnpm db:push
```

5. **Inicie o servidor de desenvolvimento**:
```bash
pnpm dev
```

O sistema estará disponível em `http://localhost:3000`

## Uso do Sistema

### 1. Importar Contatos

1. Acesse **Contatos** no menu lateral
2. Clique em **Importar CSV**
3. Baixe o template CSV para ver o formato correto
4. Preencha o CSV com seus contatos
5. Faça upload do arquivo
6. O sistema importará todos os contatos automaticamente

### 2. Upload de Áudios

1. Acesse **Áudios** no menu lateral
2. Clique em **Upload de Áudio**
3. Escolha o tipo: Campanha ou Música de Espera
4. Selecione o arquivo de áudio (WAV, MP3 ou GSM)
5. O áudio será enviado para o S3 e ficará disponível para uso

### 3. Configurar Tronco SIP

1. Acesse **Troncos SIP** no menu lateral
2. Clique em **Novo Tronco**
3. Preencha:
   - Nome do tronco
   - Servidor (host do provedor SIP)
   - Usuário
   - Senha
   - Porta (geralmente 5060)
4. O sistema gerará automaticamente a configuração do Asterisk

### 4. Criar Campanha

1. Acesse **Campanhas** no menu lateral
2. Clique em **Nova Campanha**
3. Configure:
   - Nome da campanha
   - Selecione o áudio que será reproduzido
   - Escolha o tronco SIP para fazer as chamadas
   - Defina quantas chamadas simultâneas (recomendado: 10-50)
   - Habilite IVR se quiser menu interativo
   - Selecione os contatos que receberão as chamadas
4. Clique em **Criar Campanha**
5. Use o botão **Play** para iniciar a campanha

### 5. Monitorar Resultados

1. Acesse **Relatórios** no menu lateral
2. Selecione a campanha que deseja analisar
3. Visualize:
   - Total de chamadas
   - Chamadas atendidas
   - Não atendidas
   - Ocupado
   - Caixa postal
   - Histórico completo com data/hora

## Fluxo de Chamadas

### Campanha sem IVR
1. Sistema origina chamada via Asterisk
2. Quando atendida, reproduz o áudio da campanha
3. Registra status: atendida, não atendida, ocupado, etc.
4. Passa para próximo contato

### Campanha com IVR
1. Sistema origina chamada via Asterisk
2. Quando atendida, reproduz o áudio da campanha
3. Aguarda digitação de opção pelo cliente (0-9)
4. Registra a opção digitada
5. Encerra ou transfere para fila/ramal conforme configuração
6. Passa para próximo contato

## Controle de Chamadas Simultâneas

O sistema controla automaticamente quantas chamadas podem ocorrer ao mesmo tempo para evitar:
- Sobrecarga do servidor Asterisk
- Bloqueio pelo provedor SIP
- Custos excessivos

**Recomendações**:
- Campanhas pequenas (até 1000 contatos): 10-20 chamadas simultâneas
- Campanhas médias (1000-10000 contatos): 30-50 chamadas simultâneas
- Campanhas grandes (10000+ contatos): 50-100 chamadas simultâneas

## Segurança

### Controle de Acesso
- Sistema de autenticação via Manus OAuth
- Roles de usuário: admin e user
- Apenas administradores podem criar campanhas e configurar troncos

### Proteção de Dados
- Senhas de troncos SIP armazenadas de forma segura
- Áudios em S3 com acesso controlado
- Logs de auditoria de todas as ações

### Validações
- Validação de números de telefone
- Sanitização de inputs
- Proteção contra SQL injection via Drizzle ORM

## Troubleshooting

### Asterisk não está conectando
- Verifique se o serviço está rodando: `sudo systemctl status asterisk`
- Verifique as credenciais do AMI em `/etc/asterisk/manager.conf`
- Teste a conexão: `telnet localhost 5038`

### Chamadas não estão sendo originadas
- Verifique se o tronco SIP está configurado corretamente
- Teste o tronco manualmente no Asterisk CLI
- Verifique os logs: `sudo tail -f /var/log/asterisk/full`

### Áudios não estão sendo reproduzidos
- Verifique se o arquivo foi enviado corretamente para o S3
- Confirme que o formato é compatível (WAV, MP3, GSM)
- Verifique se o Asterisk tem permissão para acessar o arquivo

### Campanhas não iniciam
- Verifique se há contatos selecionados
- Confirme que há um áudio e tronco SIP configurados
- Verifique o status do Asterisk

## Suporte e Manutenção

### Logs do Sistema
- **Asterisk**: `/var/log/asterisk/full`
- **Aplicação**: Console do navegador e logs do servidor Node.js

### Backup
- Faça backup regular do banco de dados
- Mantenha cópia dos arquivos de áudio
- Exporte configurações do Asterisk periodicamente

### Atualizações
- Mantenha o Asterisk atualizado para correções de segurança
- Atualize as dependências do Node.js regularmente
- Monitore o espaço em disco do servidor

## Limitações Conhecidas

- O sistema web não instala o Asterisk automaticamente (instalação manual necessária)
- Geração de arquivos .conf do Asterisk está implementada no backend mas requer reload manual
- Exportação de relatórios em PDF ainda não implementada
- Gráficos de desempenho em desenvolvimento

## Roadmap Futuro

- [ ] Instalação automatizada do Asterisk
- [ ] Reload automático de configurações do Asterisk
- [ ] Exportação de relatórios em PDF e Excel
- [ ] Gráficos interativos de desempenho
- [ ] Agendamento de campanhas
- [ ] Notificações em tempo real via WebSocket
- [ ] API REST para integrações externas
- [ ] Gravação de chamadas
- [ ] Reconhecimento de voz (speech-to-text)

## Conclusão

Este sistema oferece uma solução completa e profissional para disparos em massa de torpedos de voz, combinando a robustez do Asterisk com uma interface web moderna e intuitiva. Ideal para call centers, empresas de cobrança, pesquisas de opinião, campanhas políticas e qualquer negócio que precise alcançar milhares de pessoas por telefone de forma automatizada.

---

**Desenvolvido por**: Manus AI  
**Versão**: 1.0.0  
**Data**: Novembro 2025
