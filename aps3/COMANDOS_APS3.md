# Organizar o repositório e abrir o PR

## 1. Branch e estrutura de pastas (conforme o manual)
```bash
git checkout main
git pull origin main
git checkout -b feature/joao-lopes-aps3

mkdir -p docs/architecture docs/adr
git mv docs/diagrams/sequencia.mmd   docs/architecture/sequencia.mmd
git mv docs/diagrams/atividades.mmd  docs/architecture/atividades.mmd
git mv docs/diagrams/estados.mmd     docs/architecture/estados.mmd
git mv docs/architecture/adr-0001.md docs/adr/adr-0001.md
git rm docs/architecture/workspace.mmd   # substituido pelos .puml
```
Copie para `docs/architecture/`: `classes.puml`, `sequencia.mmd` (substitui o antigo), `c4-l2-containers.puml`, `c4-l3-api-estagios.puml`. Copie `adr-0001.md` para `docs/adr/` (substitui). Se `docs/diagrams/` ficar vazia, apague.

## 2. Commits (Conventional Commits)
```bash
git add docs/architecture/classes.puml
git commit -m "feat(classes): adiciona diagrama de classes e interfaces da candidatura"
git add docs/architecture/c4-l2-containers.puml docs/architecture/c4-l3-api-estagios.puml
git rm -q docs/architecture/workspace.mmd 2>/dev/null
git commit -m "feat(c4): converte C4 L2 para PlantUML e adiciona L3 da API de estagios"
git add docs/architecture/sequencia.mmd
git commit -m "fix(sequencia): corrige ordem de gravacao, webhook, notificacao e fluxos de recusa/expiracao"
git add docs/architecture/atividades.mmd docs/architecture/estados.mmd
git commit -m "docs(arquitetura): move diagramas de atividades e estados para docs/architecture"
git add docs/adr/adr-0001.md
git commit -m "docs(adr): move ADR 0001 e registra transacao via RPC"
git add README.md
git commit -m "docs(readme): atualiza estrutura e referencias dos artefatos"
git push origin feature/joao-lopes-aps3
```

## 3. Ajustes no README.md
- Seção 2 (estrutura): trocar por `docs/architecture/{classes.puml, sequencia.mmd, atividades.mmd, estados.mmd, c4-l2-containers.puml, c4-l3-api-estagios.puml}` e `docs/adr/adr-0001.md`.
- Seção 3: substituir o bloco Mermaid pelo conteúdo do novo `sequencia.mmd` e atualizar a tabela de mensagem → operação (novas: `CandidaturaController.*`, `DemandaRepository`, `PerfilRepository`, `salvarComTermo`, `eventoJaProcessado`, `paraPayload`, `getConvenio`, `getCnpj`, `NotificacaoService`, `ServicoEmail`; alterada: `Candidatura.confirmar(grauCompatibilidade)`).
- Seção 6: apontar para os `.puml` do C4 (o bloco Mermaid C4 deixa de existir) e referenciar `docs/adr/adr-0001.md`.
- Seção 9: remover a pendência do diagrama de classes (agora existe em `classes.puml`).
- Atualizar o link do ADR (seção 7) para `docs/adr/adr-0001.md`.

## 4. Renderizar antes do PR
```bash
plantuml docs/architecture/*.puml
npx -p @mermaid-js/mermaid-cli mmdc -i docs/architecture/sequencia.mmd  -o /tmp/sequencia.svg
npx -p @mermaid-js/mermaid-cli mmdc -i docs/architecture/atividades.mmd -o /tmp/atividades.svg
npx -p @mermaid-js/mermaid-cli mmdc -i docs/architecture/estados.mmd    -o /tmp/estados.svg
```
(ou cole os `.mmd` no Mermaid Live e os `.puml` em plantuml.com.)

## 5. Abrir o PR
GitHub → Compare & pull request (feature → main). Cole o conteúdo de `PR_APS3.md` e marque "Código limpo" somente depois de renderizar tudo.
