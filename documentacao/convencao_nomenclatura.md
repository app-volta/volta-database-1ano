# Convenção de Nomenclatura — Banco de Dados VOLTA

Instituto J&F · Ensino Médio Técnico em Desenvolvimento de Sistemas · Banco de Dados 1 · 19 de outubro de 2026

Equipe: Gustavo Azenha da Silva, Gustavo Melo de Souza, Lucca Davi Begliomini e Miguel Lapa Sperandio.

## 1. Objetivo

Este documento define como nomear e escrever os objetos do banco de dados do VOLTA (PostgreSQL), para que o modelo conceitual, o modelo lógico e os scripts SQL sigam o mesmo padrão. O escopo do projeto é o município de São Paulo.

## 2. Arquivos do banco

Os scripts devem ser executados nesta ordem, em um banco novo:

| Ordem | Arquivo | O que faz |
| --- | --- | --- |
| 1 | `tabelasVolta.sql` | apaga as tabelas antigas e cria as 19 tabelas |
| 2 | `viewsVolta.sql` | cria as 9 views |
| 3 | `dataloadVolta.sql` | carga de dados de teste (fictícios) |
| 4 | `consultasVolta.sql` | consultas e verificações (só leitura) |

Cuidado: os comandos `drop` no início de `tabelasVolta.sql` apagam as tabelas e os dados. Usar só em banco de teste.

## 3. Tabelas e colunas

| Regra | Padrão | Exemplo |
| --- | --- | --- |
| Idioma | nomes em inglês | `waste_type`, `estimated_weight` |
| Formato | `snake_case`, tudo em minúsculas | `collection_status` |
| Tabela | singular | `incident`, `company` |
| Exceção | `users` fica no plural, porque `user` é palavra reservada do PostgreSQL | `users` |
| Chave primária | coluna `id`, `generated always as identity` | `id` |
| Exceção da PK | tabela de ligação usa chave primária composta, sem `id` | `cooperative_waste_type` |
| Chave estrangeira (coluna) | `<tabela_referenciada>_id` | `company_id`, `waste_type_id` |
| Tabela de ligação (N:N) | `<tabela_a>_<tabela_b>` | `cooperative_waste_type` |

As 19 tabelas do banco: `role`, `company`, `cooperative`, `users`, `area`, `waste_type`, `cooperative_waste_type`, `incident`, `ai_report`, `attachment`, `collection`, `collection_status`, `review`, `conversation`, `message`, `message_attachment`, `notification`, `esg_metric` e `complaint`.

## 4. Constraints

Toda constraint com nome próprio segue o padrão `<tipo>_<tabela>_<campo>`.

| Tipo | Padrão | Exemplo |
| --- | --- | --- |
| Chave estrangeira | `fk_<tabela>_<tabela referenciada ou campo>` | `fk_incident_area` |
| CHECK | `chk_<tabela>_<campo>` | `chk_company_cep`, `chk_incident_priority` |
| UNIQUE composto | `uq_<tabela>_<campos>` | `uq_esg_metric_company_period` |

A chave primária e os `unique` de uma coluna só (como `cnpj` e `email`) usam o nome padrão do PostgreSQL.

Recursos de integridade usados nos scripts:

- `not null` nos campos obrigatórios;
- `unique` em CNPJ e e-mail;
- `default` em prioridade, status, datas de registro e campos verdadeiro/falso;
- `check` para domínios fechados, faixas (`stars between 1 and 5`), formatos (CNPJ com 14 dígitos, CEP com 8 dígitos, período no formato AAAA-MM) e regras de negócio (por exemplo, o agendamento não pode ser anterior à solicitação).

## 5. Views

Toda view começa com o prefixo `vw_`.

| View | O que mostra |
| --- | --- |
| `vw_cooperative_rating` | nota média de cada cooperativa, calculada pelas avaliações |
| `vw_incident_details` | ocorrência com empresa, área, tipo de resíduo e quem registrou |
| `vw_collection_details` | coleta com empresa, cooperativa e tipo de resíduo |
| `vw_cooperative_specialties` | tipos de resíduo aceitos por cooperativa, em uma linha |
| `vw_company_summary` | total de ocorrências e peso por empresa |
| `vw_esg_by_period` | percentual de reciclagem por mês |
| `vw_user_owner` | usuário com o nome da empresa ou da cooperativa (sem a senha) |
| `vw_chat_messages` | mensagens com o nome de quem enviou |
| `vw_collection_status_check` | coletas cujo status atual difere do último status do histórico (deve ficar vazia) |

## 6. Datas, horas e medidas

| Tipo de campo | Padrão | Exemplo |
| --- | --- | --- |
| Momento em que algo foi registrado | sufixo `_at` (`timestamp`) | `registered_at`, `sent_at`, `created_at` |
| Data de um evento do negócio | sufixo `_date` | `request_date`, `scheduled_date`, `review_date` |
| Campo verdadeiro ou falso | nome afirmativo, tipo `boolean` | `urgent`, `reported`, `read` |
| Duração | tipo `interval` | `estimated_time` |
| Mês de referência | texto `AAAA-MM` validado por `check` | `esg_metric.period` |
| Peso e capacidade | sempre em quilogramas (kg) | `estimated_weight`, `monthly_capacity`, `total_kg_waste` |


## 7. Estilo dos scripts SQL

- palavras do SQL em minúsculas (`create table`, `select`, `join`); os valores entre aspas simples continuam como na seção 7;
- indentação de 4 espaços, uma coluna ou constraint por linha;
- comentários com ` --  ` (traço, traço, espaço), curtos e em minúsculas;
- cada tabela segue a ordem: colunas, depois constraints;
- tabelas criadas respeitando a ordem das chaves estrangeiras (a tabela referenciada antes da que referencia);
- sem linhas decorativas nos comentários.

## 8. Regra de exclusão (`on delete`)

| Regra | Onde se aplica |
| --- | --- |
| `cascade` | tabelas que só existem em função de outra: `ai_report`, `attachment`, `collection_status`, `message`, `message_attachment`, `notification` e o lado da cooperativa em `cooperative_waste_type` |
| `restrict` | todas as demais chaves estrangeiras, para não perder histórico ao apagar um registro que ainda é usado |
|  |  |

## 9. Decisões de modelagem

1. **Usuário de empresa ou de cooperativa.** `users` tem `company_id` e `cooperative_id`, e o `check` `chk_users_owner` exige exatamente um dos dois preenchidos.
2. **Especialidades da cooperativa.** Uma cooperativa aceita vários tipos de resíduo e cada tipo pode ser aceito por várias cooperativas (N:N), por isso existe a tabela `cooperative_waste_type`, que substitui um campo de texto com vários valores.
3. **Valores calculados não são gravados.** A nota média da cooperativa vem de `vw_cooperative_rating`, e o percentual de reciclagem de `esg_metric` é uma coluna gerada pelo banco.
4. **Status atual da coleta.** `collection.current_status` guarda o último status para consulta rápida. A aplicação atualiza essa coluna na mesma transação em que insere a linha em `collection_status`, e a view `vw_collection_status_check` mostra qualquer divergência.
5. **Foto da ocorrência.** `incident.photo_url` guarda a foto principal, e `attachment` guarda arquivos extras (PDF e outras fotos).
6. **Conversa.** `conversation` guarda `company_id` e `cooperative_id` porque `collection_id` é opcional: a conversa pode existir antes de uma coleta.
7. **Origem de dados.** A empresa de uma ocorrência vem da área (`area.company_id`), a cooperativa de uma avaliação vem da coleta (`collection.cooperative_id`) e a empresa de uma denúncia vem da ocorrência, para não repetir informação.
8. **Senhas.** `users.password` guarda o hash da senha. Nos dados de teste usa `md5`; na aplicação deve usar bcrypt.
