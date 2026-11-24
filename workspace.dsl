@startuml TONK_C4_Container
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

title TONK — C4 Nível 2: Contêineres da Gestão Comercial

Person(rep, "Representante / equipe comercial", "Cria e acompanha pedidos")
Person(aprovador, "Aprovador comercial", "Avalia pedidos fora da política")

System_Boundary(tonk, "Plataforma TONK") {
  Container(web, "Aplicação Web", "React + TypeScript + Vite / PWA", "Interface comercial, catálogo e pedidos")
  Container(api, "API de Gestão Comercial", "Node.js + TypeScript + REST", "Regras de negócio, autorização e workflow")
  ContainerDb(db, "Banco de Dados", "PostgreSQL", "Pedidos, clientes, produtos, aprovações e trilha de auditoria")
  Container(queue, "Mensageria", "RabbitMQ / AMQP", "Eventos duráveis e processamento assíncrono")
  Container(worker, "Worker de Integração", "Node.js + TypeScript", "Consome eventos, aplica mapeamento e controla retentativas")
  Container(storage, "Armazenamento de documentos", "Object Storage / S3 API", "PDFs e documentos comerciais")
}

System_Ext(protheus, "ERP TOTVS Protheus", "Sistema corporativo; integração depende de contrato e homologação")
System_Ext(logistica, "Operação logística", "Separação, conferência e expedição")

Rel(rep, web, "Usa", "HTTPS")
Rel(aprovador, web, "Aprova ou reprova", "HTTPS")
Rel(web, api, "Requisições de negócio", "HTTPS / REST + JSON")
Rel(api, db, "Consulta e grava transações", "SQL / TLS")
Rel(api, queue, "Publica eventos de pedido aprovado", "AMQP")
Rel(api, storage, "Armazena/consulta documentos", "HTTPS / S3 API")
Rel(queue, worker, "Entrega eventos", "AMQP")
Rel(worker, protheus, "Integra pedido e consulta retorno", "REST/JSON ou SOAP/XML — a confirmar com fornecedor")
Rel(worker, db, "Registra protocolo, status e falhas", "SQL / TLS")
Rel(worker, logistica, "Disponibiliza pedido liberado", "API ou evento — contrato futuro")

@enduml
