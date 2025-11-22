# Sistema de Disparos em Massa - TODO List

## Backend e Banco de Dados
- [x] Configurar schema do banco de dados (contatos, campanhas, áudios, ramais, filas, troncos, relatórios)
- [x] Criar helpers de integração com Asterisk (AMI - Asterisk Manager Interface)
- [x] Implementar sistema de upload e armazenamento de áudios (S3)
- [x] Criar sistema de processamento de arquivos CSV
- [x] Criar módulo de integração com TTS

## Importação de Contatos
- [x] Implementar importação de lista de contatos via CSV
- [x] Criar interface de visualização e edição de contatos
- [x] Implementar busca e filtros de contatos

## Gerenciamento de Áudios
- [x] Criar upload de áudios para campanhas
- [x] Criar upload de áudios para fila de espera (MOH)
- [x] Criar listagem e gerenciamento de áudios

## Gerenciamento de Ramais
- [x] Criar interface para adicionar ramais
- [x] Adicionar funcionalidade de deletar ramais
- [x] Implementar edição de ramais

## Gerenciamento de Filas
- [x] Criar interface para adicionar filas de espera
- [x] Adicionar edição e exclusão de filas
- [x] Implementar adição de agentes à fila

## Gerenciamento de Troncos SIP
- [x] Criar interface para adicionar tronco SIP
- [x] Implementar configuração de servidor, usuário e senha
- [x] Adicionar edição e exclusão de troncos

## Gerenciamento de Campanhas
- [x] Criar interface de criação de campanhas
- [x] Implementar seleção de contatos para campanha
- [x] Adicionar seleção de áudio para disparo
- [x] Implementar controle de chamadas simultâneas por campanha
- [x] Criar sistema de pausa/retomada de campanhas

## Dashboard e Interface
- [x] Criar dashboard com estatísticas em tempo real
- [x] Implementar relatório de chamadas atendidas
- [x] Adicionar relatório de chamadas rejeitadas
- [x] Criar relatório de chamadas não atendidas
- [x] Implementar relatório de caixa postal
- [x] Adicionar relatório de opções digitadas pelo cliente
- [x] Criar layout profissional com dashboard
- [x] Implementar navegação lateral para call center
- [x] Adicionar tema escuro profissional
- [x] Criar indicadores visuais de status de campanhas

## Monitoramento em Tempo Real
- [x] Criar painel de monitoramento em tempo real
- [x] Implementar visualização de chamadas ativas
- [x] Adicionar métricas ao vivo de campanhas em execução
- [x] Criar sistema de atualização automática (polling)
- [x] Adicionar indicadores visuais de status
- [x] Implementar lista de chamadas em andamento com detalhes

## IVR Avançado
- [x] Criar tabelas de configuração IVR
- [x] Implementar módulo de TTS
- [x] Criar tabelas de pausa/retomada de campanhas
- [x] Implementar tabelas de status de ramais
- [ ] Criar interface de configuração de ações IVR
- [ ] Implementar ações por tecla (1-9, 0, *)
- [ ] Adicionar opção de transferir para fila
- [ ] Implementar opção de transferir para ramal específico

## Instalação Automatizada
- [x] Criar script de instalação do Asterisk
- [x] Gerar script de configuração do banco de dados
- [x] Criar script de deploy da aplicação web
- [x] Implementar script de configuração do Systemd
- [x] Gerar script de backup e restauração
- [x] Criar script de pós-instalação e validação

## Documentação
- [x] Criar manual de instalação passo a passo
- [x] Gerar documentação de configuração
- [x] Criar guia de troubleshooting
- [x] Adicionar exemplos de uso
- [x] Gerar guia rápido de início

## Segurança e Permissões
- [ ] Implementar controle de acesso baseado em roles
- [ ] Adicionar logs de auditoria
- [ ] Criar sistema de backup de configurações
- [ ] Implementar validação de inputs

## Testes
- [x] Criar testes unitários básicos
- [x] Implementar testes de procedures tRPC
- [x] Testar integração com Asterisk
- [ ] Criar testes de carga
- [ ] Implementar testes de integração completos
