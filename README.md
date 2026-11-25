# 🎓 Sprint Final — Modelagem de Software

> **APS 4 — Dossiê de Arquitetura Viva**  
> Sistema de Gestão de Estágios UniSenai — API de Candidatura e Match de Competências

**Unidade Curricular:** Modelagem de Software  
**Curso:** Engenharia de Software — 4º Período — UniSenai  
**Docente:** Prof. Sidney L. da Silva  
**Modalidade:** Avaliação Prática Supervisionada

---

## 📋 Visão Geral

Este repositório contém o dossiê de arquitetura viva do sprint final da disciplina de Modelagem de Software. O projeto modela a funcionalidade crítica de **processamento de candidaturas e match de competências** para o sistema de gestão de estágios da UniSenai.

A funcionalidade central é: o aluno envia uma candidatura, o sistema valida, persiste e inicia um pipeline assíncrono que consulta o perfil acadêmico e calcula a compatibilidade com as vagas ativas — tudo desacoplado via RabbitMQ.

---

## 🏗️ Arquitetura

### Fluxo principal

```
Aluno → POST /candidaturas → API (valida + persiste) → RabbitMQ
        ↓                                                    ↓
  202 Accepted                              CompetenciaService → SistemaAcadêmico
                                                                       ↓
                                                              MatchService (score)
                                                                       ↓
                                                              API (atualiza status)
```

### Stack tecnológica (proposta)

| Camada             | Tecnologia               |
|--------------------|--------------------------|
| Frontend           | React + TypeScript       |
| API de Aplicação   | Node.js + Express        |
| CompetenciaService | Node.js                  |
| MatchService       | Python + FastAPI         |
| Banco de Dados     | PostgreSQL               |
| Message Broker     | RabbitMQ (AMQP 0-9-1)   |
| Sistema externo    | Sistema Acadêmico (REST) |

---

## 📁 Estrutura do Repositório

```text
sprint-final-modelagemdesoftware/
│
├── branch-gm/                         # Contribuição individual — Gabriel Medina
│   ├── docs/
│   │   ├── architecture/
│   │   │   ├── adr-0001.md            # ADR: RabbitMQ para processamento assíncrono
│   │   │   └── workspace.puml         # Visão C4 L2 — Contêineres (PlantUML)
│   │   └── diagrams/
│   │       ├── sequencia.mmd          # Diagrama de Sequência (Mermaid)
│   │       ├── atividades.mmd         # Diagrama de Atividades com Raias (Mermaid)
│   │       └── estados.mmd            # Diagrama de Transição de Estados (Mermaid)
│   └── README.md                      # Dossiê completo com todos os artefatos
│
├── classes.mmd                        # Diagrama de Classes — visão estrutural completa
├── c4-l3-api-aplicacao.puml           # C4 Nível 3 — Componentes da API (PlantUML)
├── adr-0002.md                        # ADR: Transactional Outbox
└── PULL_REQUEST_TEMPLATE.md           # Template de PR para defesa de artefatos
```

---

## 📐 Artefatos de Modelagem

### 1. Diagrama de Sequência
Modela o fluxo da requisição: validação síncrona, persistência, publicação de evento e continuação assíncrona via RabbitMQ. A API retorna `202 Accepted` sem aguardar o resultado do match.

📄 Fonte: [`branch-gm/docs/diagrams/sequencia.mmd`](branch-gm/docs/diagrams/sequencia.mmd)

---

### 2. Diagrama de Atividades com Raias
Separa as responsabilidades entre Aluno, API, RabbitMQ e Serviços de Domínio. Inclui fork/join explícito para publicação de evento e registro de auditoria em paralelo.

📄 Fonte: [`branch-gm/docs/diagrams/atividades.mmd`](branch-gm/docs/diagrams/atividades.mmd)

---

### 3. Diagrama de Transição de Estados
Representa o ciclo de vida completo da entidade `Candidatura`, com subestados em `RECEBIDA`, guards mutuamente exclusivos e estados finais `CONTRATADA`, `EXPIRADA` e `CANCELADA`.

```
RASCUNHO → RECEBIDA → PROCESSANDO → PROCESSADA → CONTRATADA
                   ↘              ↘ SEM_MATCH
                     FALHA_PROCESSAMENTO
```

📄 Fonte: [`branch-gm/docs/diagrams/estados.mmd`](branch-gm/docs/diagrams/estados.mmd)

---

### 4. Diagrama de Classes
Visão estrutural completa com `ApplicationController`, interfaces `ICandidaturaRepository` e `IMessageBroker`, implementações concretas, hierarquia de eventos e enum `StatusCandidatura`.

📄 Fonte: [`classes.mmd`](classes.mmd)

---

### 5. Visão Arquitetural C4

| Nível | Descrição | Arquivo |
|-------|-----------|---------|
| L2 — Contêineres | Visão macro dos serviços e conexões | [`branch-gm/docs/architecture/workspace.puml`](branch-gm/docs/architecture/workspace.puml) |
| L3 — Componentes | Internos da API de Aplicação | [`c4-l3-api-aplicacao.puml`](c4-l3-api-aplicacao.puml) |

---

## 📋 Registros de Decisão Arquitetural (ADRs)

### ADR 0001 — RabbitMQ para processamento assíncrono
**Status:** Aprovado

Adota RabbitMQ com AMQP 0-9-1 para desacoplar a API dos serviços de competências e match. A API confirma o recebimento com `202 Accepted`; o resultado é persistido após o consumo do evento de conclusão.

📄 Documento completo: [`branch-gm/docs/architecture/adr-0001.md`](branch-gm/docs/architecture/adr-0001.md)

---

### ADR 0002 — Transactional Outbox para publicação confiável de eventos
**Status:** Proposto

Resolve a janela de perda de evento entre a persistência da `Candidatura` e a publicação no RabbitMQ. Na mesma transação SQL que salva a candidatura, o evento é gravado na tabela `outbox_eventos`. Um processo relay lê e publica os eventos pendentes, marcando `publicadoEm` após confirmação do broker.

📄 Documento completo: [`adr-0002.md`](adr-0002.md)

---

## 🔄 Como Renderizar os Diagramas

**Arquivos `.mmd` (Mermaid):**
- [Mermaid Live Editor](https://mermaid.live) — cole o conteúdo do arquivo
- VS Code com extensão [Mermaid Preview](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
- GitHub renderiza automaticamente blocos Mermaid em Markdown

**Arquivos `.puml` (PlantUML com C4):**
- [PlantUML Online](https://www.plantuml.com/plantuml/uml/)
- [Structurizr](https://structurizr.com) para modelos C4
- VS Code com extensão [PlantUML](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml)

---

## 🤝 Contribuindo

Consulte o [`PULL_REQUEST_TEMPLATE.md`](PULL_REQUEST_TEMPLATE.md) antes de abrir um PR. O template exige defesa técnica das decisões de design, checklist de consistência cross-diagramas e confirmação de sintaxe válida nos arquivos de modelagem.

---

## 📝 Observações

- A arquitetura descrita é uma **proposta de solução** para a funcionalidade modelada; tecnologias e integrações devem ser confirmadas conforme a implementação real do projeto.
- Retentativas, dead-letter queue e idempotência (via `eventId` + estado atual) são mecanismos previstos para lidar com falhas e reentregas.
- A resposta `202 Accepted` é intencional: confirma que a solicitação foi aceita para processamento, não que o match já terminou.
