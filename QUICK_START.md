# Guia Rápido - Sistema de Disparos de Voz

## Instalação em 5 Minutos

### Pré-requisitos
- Servidor Debian 11
- Acesso root via SSH
- Conexão à internet

### Instalação Automatizada

```bash
# 1. Conectar ao servidor
ssh root@seu_servidor

# 2. Baixar e executar script
cd /tmp
wget https://seu_repositorio/install.sh
chmod +x install.sh
sudo bash install.sh

# 3. Executar configuração pós-instalação
sudo bash /opt/asterisk-voice-blast/install/post-install.sh

# 4. Acessar a aplicação
# Abra no navegador: http://seu_servidor:3000
```

## Primeiros Passos

### 1. Configurar Tronco SIP (2 minutos)
```
Menu → Troncos SIP → Novo Tronco
- Nome: Meu Tronco
- Servidor: seu_provedor_sip.com
- Usuário: seu_usuario
- Senha: sua_senha
- Salvar
```

### 2. Criar Ramal (1 minuto)
```
Menu → Ramais → Novo Ramal
- Número: 1001
- Nome: Ramal 1
- Tipo: SIP
- Salvar
```

### 3. Criar Fila (1 minuto)
```
Menu → Filas → Nova Fila
- Nome: Suporte
- Estratégia: Round Robin
- Salvar
```

### 4. Importar Contatos (2 minutos)
```
Menu → Contatos → Importar CSV
- Baixar template
- Preencher com seus contatos
- Upload do arquivo
- Confirmar
```

### 5. Criar Campanha (2 minutos)
```
Menu → Campanhas → Nova Campanha
- Nome: Minha Campanha
- Selecionar contatos
- Upload de áudio
- Chamadas simultâneas: 5
- Iniciar
```

## Comandos Úteis

```bash
# Ver status dos serviços
sudo systemctl status asterisk-voice-blast

# Ver logs em tempo real
sudo journalctl -u asterisk-voice-blast -f

# Reiniciar aplicação
sudo systemctl restart asterisk-voice-blast

# Fazer backup
sudo /opt/asterisk-voice-blast/install/backup.sh backup

# Monitorar sistema
sudo asterisk-voice-blast-monitor

# Diagnosticar problemas
sudo asterisk-voice-blast-troubleshoot
```

## Acessar Asterisk CLI

```bash
# Conectar ao console do Asterisk
sudo asterisk -r

# Alguns comandos úteis:
core show channels          # Ver chamadas ativas
sip show peers              # Ver peers SIP
queue show                  # Ver filas
dialplan show               # Ver dialplan
```

## Configurações Importantes

### Arquivo de Configuração
```
/opt/asterisk-voice-blast/.env.local
```

### Credenciais Padrão
- **Banco de Dados**: asterisk / asterisk_secure_password_123
- **Asterisk AMI**: admin / asterisk_ami_password_123

### Alterar Senhas
```bash
# Editar arquivo de configuração
sudo nano /opt/asterisk-voice-blast/.env.local

# Reiniciar aplicação
sudo systemctl restart asterisk-voice-blast
```

## Troubleshooting Rápido

### Aplicação não inicia
```bash
sudo journalctl -u asterisk-voice-blast -n 20
sudo systemctl restart asterisk-voice-blast
```

### Asterisk não conecta
```bash
sudo systemctl restart asterisk
sudo asterisk -r
core show channels
```

### Banco de dados inacessível
```bash
sudo systemctl restart mysql
mysql -u asterisk -p asterisk_secure_password_123 asterisk_voice_blast
```

## Documentação Completa

Para instruções detalhadas, consulte:
- `INSTALLATION_MANUAL.md` - Manual de instalação completo
- `DOCUMENTATION.md` - Documentação técnica
- `/var/log/asterisk-voice-blast/` - Logs da aplicação

## Suporte

Para problemas, execute o script de diagnóstico:
```bash
sudo asterisk-voice-blast-troubleshoot
```

---

**Pronto para começar!** 🚀

Acesse `http://seu_servidor:3000` e comece a criar campanhas.
