# Gestão de Estágios UniSenai

## Política de Matching

O `MatchService` recebe o perfil de competências do estudante pelo RabbitMQ, consulta as vagas ativas no PostgreSQL e chama `PoliticaMatching` para calcular a compatibilidade com cada vaga.

A API grava o resultado da análise como `PROCESSADA` quando há vagas compatíveis, `SEM_MATCH` quando a análise termina sem correspondências ou `FALHA_PROCESSAMENTO` quando se esgotam as tentativas.

## Modelos do matching

- [Diagrama de classes](classes.mmd)
- [Diagrama de sequência](docs/architecture/sequencia-politica-matching.mmd)
- [Diagrama de atividades](docs/architecture/atividades-politica-matching.mmd)
- [Diagrama de estados](docs/architecture/estados-politica-matching.mmd)
- [C4 nível 3 do MatchService](docs/architecture/c4-l3-match-service.puml)
- [ADR 0003 — Isolar a política de cálculo do matching](docs/adr/adr-0003.md)
