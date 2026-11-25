# Defesa de Arquitetura de Software — Pull Request

## Autor do PR
- **Nome do Estudante:** João Pedro S. C. Lopes
- **Artefato(s) de Responsabilidade:** Diagrama de Classes e Interfaces, Diagrama de Sequência, Diagrama de Atividades, Máquina de Estados (`TermoCompromisso`), C4 L2/L3 e ADR 0001 — funcionalidade Candidatura → Termo de Compromisso → Assinatura Eletrônica (RF04 e RF05)

## O que este PR introduz na Documentação Viva?
- [x] **Visão Funcional / Estrutural:** `docs/architecture/classes.puml`
- [x] **Visão Comportamental:** `docs/architecture/sequencia.mmd`, `docs/architecture/atividades.mmd` e `docs/architecture/estados.mmd`
- [x] **Visão Arquitetural Macro:** `docs/architecture/c4-l2-containers.puml` e `docs/architecture/c4-l3-api-estagios.puml` (PlantUML + biblioteca C4)
- [x] **Governança:** `docs/adr/adr-0001.md` (Supabase como camada de dados)

## Defesa das Decisões de Design (Justificativa Técnica)
1. **Escolha de Abstrações e Desacoplamento:** `CandidaturaService` depende apenas de interfaces (`DemandaRepository`, `PerfilRepository`, `CandidaturaRepository`, `TermoRepository`, `SistemaAcademicoSGA`, `SistemaFiep`, `PlataformaAssinatura`, `ServicoEmail`). O domínio não conhece Supabase nem as APIs externas, o que limita o *vendor lock-in* citado no ADR e permite testar com dublês. A regra de transição de estados fica em `TermoCompromisso` (`registrarAssinatura`), e a orquestração fica no serviço. A chamada à plataforma de assinatura sai do serviço e não da entidade, para o domínio não depender de integração externa.
2. **Dinâmica e Resiliência:** SGA e Fiep são consultados em paralelo (`par` na sequência e Fork/Join nas atividades). O `alt` trata inelegibilidade, convênio vencido e empresa irregular. A assinatura é assíncrona: o termo é gravado como `AGUARDANDO_ASSINATURAS` **antes** de a solicitação ser enviada, evitando que o webhook chegue a um termo inexistente. O `loop` cobre os três desfechos (assinado, recusado, expirado), com guardas coerentes com `estados.mmd`. O webhook é idempotente via `eventoJaProcessado`. `Candidatura` e `Termo` são gravados em uma única transação (função RPC), para o termo nunca ficar inconsistente.
3. **Trade-offs:** (a) o RPC garante atomicidade, mas leva parte da regra para o banco e exige testes próprios; (b) enviar a solicitação só depois de gravar remove a corrida, mas, se o envio falhar, o termo fica sem solicitação (reconciliação periódica fica como evolução); (c) o Supabase acelera a entrega, com custo de dependência de fornecedor e limites do plano gratuito; (d) as interfaces de repositório adicionam indireção em troca de testabilidade.

## Consistência Cross-Diagramas (Checklist de Autoverificação)
- [x] Os métodos chamados na sequência existem nas interfaces/classes de `classes.puml` (`candidatar`, `receberEventoAssinatura`, `processarEventoAssinatura`, `buscarPorId`, `getConvenio`, `getCnpj`, `consultarAluno`, `consultarRegularidade`, `validarElegibilidade`, `estaVigente`, `buscarPorAlunoId`, `calcular`, `confirmar`, `salvarComTermo`, `enviarParaAssinatura`, `salvar`, `paraPayload`, `solicitarAssinatura`, `eventoJaProcessado`, `registrarAssinatura`, `notificar`, `enviarEmail`).
- [x] Contêineres e componentes citados correspondem ao C4 L2/L3 (`ReceptorWebhooks`, `CandidaturaController`, `CandidaturaService`, `PoliticaMatching`, repositórios, `NotificacaoService`, `SistemaAcademicoSGA`, `SistemaFiep`, `PlataformaAssinatura`, `ServicoEmail`). `DemandaTecnica`, `Convenio`, `Candidatura` e `TermoCompromisso` pertencem ao componente "Modelo de Domínio".
- [x] As transições de estado refletem os gatilhos da sequência: `enviarParaAssinatura` (Rascunho → AguardandoAssinaturas) e `registrarAssinatura` com `assinaturaRecebida`, `assinaturaRecusada` e `prazoExpirado`.

## Validação da Sintaxe Diagrams-as-Code / Models-as-Code
- **Ferramenta de Compilação/Renderização Utilizada:** PlantUML (`.puml`) e Mermaid (`.mmd`)
- **Status da Compilação:** [ ] Código limpo e sem erros de sintaxe ao renderizar. *(marque somente depois de renderizar todos os arquivos)*
