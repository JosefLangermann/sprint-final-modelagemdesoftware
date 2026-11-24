# APS 3 — Serviço de Contratos

**Aluno:** João Pedro Costa Silva (Serviço de Contratos) | **Projeto:** Gestão de Aprendizagem e Estágios da UniSenai (Grupo 6)

## Funcionalidade
Depois que a candidatura do estudante é confirmada e considerada elegível, o **Serviço de Contratos** gera o Termo de Compromisso e envia para a plataforma de assinatura externa. Quando todas as assinaturas chegam, o contrato fica **Ativo**.

## 1. Diagrama de Classes
```mermaid
classDiagram
    class ServicoContratos {
        +gerarTermo(candidaturaId: String) TermoDTO
        +registrarAssinatura(contratoId: String, signatario: String) ContratoDTO
        -ativarContrato(contratoId: String) void
    }
    class ServicoCandidaturas {
        +verificarElegibilidade(candidaturaId: String) ElegibilidadeDTO
    }
    class Repositorio {
        +salvarContrato(contrato: ContratoDTO) ContratoDTO
        +atualizarEstado(contratoId: String, estado: String) ContratoDTO
    }
    class PlataformaAssinatura {
        +enviarParaAssinatura(termo: TermoDTO) void
    }
    class TermoDTO {
        -contratoId: String
        -candidaturaId: String
    }
    class ContratoDTO {
        -id: String
        -estado: String
    }
    class ElegibilidadeDTO {
        -elegivel: boolean
    }

    ServicoContratos ..> ServicoCandidaturas : usa
    ServicoContratos ..> Repositorio : usa
    ServicoContratos ..> PlataformaAssinatura : usa
    ServicoContratos ..> TermoDTO
    ServicoContratos ..> ContratoDTO
    ServicoCandidaturas ..> ElegibilidadeDTO
```

## 2. Diagrama de Sequência
```mermaid
sequenceDiagram
    actor Estudante
    participant API as API da Aplicação
    participant SC as ServicoContratos
    participant SCand as ServicoCandidaturas
    participant Repo as Repositorio
    participant Assin as PlataformaAssinatura

    Estudante->>API: POST /contratos (candidaturaId)
    API->>SC: gerarTermo(candidaturaId)
    SC->>SCand: verificarElegibilidade(candidaturaId)
    SCand-->>SC: ElegibilidadeDTO

    alt elegível
        SC->>Repo: salvarContrato(contrato)
        Repo-->>SC: ContratoDTO
        SC-)Assin: enviarParaAssinatura(TermoDTO)
        SC-->>API: TermoDTO
        API-->>Estudante: 201 Created
    else não elegível
        SC-->>API: ElegibilidadeInvalidaException
        API-->>Estudante: 422 Unprocessable Entity
    end

    Assin-)API: POST /webhooks/assinatura (contratoId, signatario)
    API->>SC: registrarAssinatura(contratoId, signatario)
    SC->>Repo: atualizarEstado(contratoId, Ativo)
    Repo-->>SC: ContratoDTO
```

## 3. Diagrama de Atividades
```mermaid
flowchart TB
    classDef bar fill:#000,stroke:#000,color:#fff;

    Inicio(("●"))

    subgraph R1["Estudante"]
        A1["Confirmar candidatura"]
        A2["Visualizar recusa"]
    end

    subgraph R2["Sistema (ServicoContratos)"]
        S1["verificarElegibilidade()"]
        D1{"Elegível?"}
        S2["gerarTermo()"]
        S3["enviarParaAssinatura()"]
        F1["FORK"]:::bar
        J1["JOIN"]:::bar
        S4["ativarContrato()"]
    end

    subgraph R3["Plataforma de Assinatura (externa)"]
        P1["Assinatura do estudante"]
        P2["Assinatura da empresa"]
        P3["Assinatura da instituição"]
    end

    Fim1(((" ")))
    Fim2(((" ")))

    Inicio --> A1 --> S1 --> D1
    D1 -->|"[elegível]"| S2 --> S3 --> F1
    D1 -->|"[não elegível]"| A2 --> Fim2
    F1 --> P1 --> J1
    F1 --> P2 --> J1
    F1 --> P3 --> J1
    J1 --> S4 --> Fim1
```

## 4. Diagrama de Estados
```mermaid
stateDiagram-v2
    [*] --> EmFormalizacao : candidaturaConfirmada [candidaturaElegivel] / criarContrato()

    EmFormalizacao : entry / gerarTermo()

    EmFormalizacao --> AguardandoAssinatura : termoGerado / enviarParaAssinatura()

    state AguardandoAssinatura {
        [*] --> SemAssinaturas
        SemAssinaturas --> ParcialmenteAssinado : assinaturaRecebida
    }

    AguardandoAssinatura --> Ativo : assinaturaRecebida [todasAssinadas] / ativarContrato()
    AguardandoAssinatura --> Rescindido : rescindir [motivoInformado] / registrarMotivo()
    Ativo --> Rescindido : rescindir [motivoInformado] / registrarMotivo()
    Ativo --> Finalizado : vigenciaEncerrada

    Rescindido --> [*]
    Finalizado --> [*]
```

## 5. C4 Nível 3 (Componentes)
Arquivo PlantUML: [c4-l3-servico-contratos.puml](architecture/c4-l3-servico-contratos.puml)

## 6. ADR 0001 — Assinatura assíncrona via webhook
**Status:** Proposto

**Decisão:** o termo é enviado de forma assíncrona (`enviarParaAssinatura`) e a API responde na hora. As assinaturas voltam por webhook (`POST /webhooks/assinatura`) e o contrato só vai para `Ativo` quando todas chegarem.

Texto completo: [adr-0001-assinatura-assincrona.md](adr/adr-0001-assinatura-assincrona.md)
