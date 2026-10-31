VOLTA | Banco de Dados
Visão geral
O VOLTA é uma plataforma de gestão de ocorrências operacionais industriais, com foco inicial no acompanhamento de resíduos sólidos. Seu banco de dados organiza informações de empresas, cooperativas, usuários, áreas operacionais, resíduos e ocorrências, permitindo registrar demandas, acompanhar solicitações de coleta e reunir informações para análise e rastreabilidade.

O projeto está relacionado ao Objetivo de Desenvolvimento Sustentável 12 (ODS 12), voltado ao consumo e à produção responsáveis. O escopo territorial do VOLTA é o município de São Paulo.
Objetivo do banco de dados
A estrutura relacional busca:
- Centralizar o cadastro de empresas, cooperativas e usuários.
- Registrar ocorrências industriais, suas características e os resíduos envolvidos.
- Relacionar cooperativas aos tipos de resíduos que podem receber.
- Permitir o registro e o acompanhamento das solicitações de coleta.
- Manter informações complementares para comunicação, histórico e indicadores gerenciais.
Tecnologia utilizada
- SGBD: PostgreSQL.
- Linguagem: SQL.
- Modelagem: modelo conceitual e modelo lógico relacional.
- Organização dos dados: tabelas relacionadas por chaves primárias e estrangeiras, com restrições de integridade.
Modelagem completa
O modelo lógico completo possui 19 tabelas, distribuídas por grupos funcionais:
Área	Tabelas	Finalidade
Cadastros e acesso	role, users, company, cooperative, area	Perfis, usuários, empresas, cooperativas e áreas operacionais.
Resíduos e ocorrências	waste_type, cooperative_waste_type, incident, attachment, ai_report	Tipos de resíduos, especialidades das cooperativas, ocorrências, anexos e relatórios de IA.
Coletas e acompanhamento	collection, collection_status, review, complaint	Solicitações de coleta, histórico de situações, avaliações e reclamações.
Comunicação	conversation, message, message_attachment, notification	Conversas, mensagens, anexos de mensagens e notificações.
Indicadores	esg_metric	Métricas relacionadas ao gerenciamento de resíduos.


Relacionamentos principais
- Uma empresa pode possuir usuários e áreas operacionais.
- Uma cooperativa pode estar associada a diferentes tipos de resíduos pela tabela cooperative_waste_type.
- Uma ocorrência relaciona um usuário, uma área e um tipo de resíduo.
- Uma solicitação de coleta relaciona uma ocorrência a uma cooperativa.
- A estrutura também prevê registros associados às ocorrências, como anexos e relatórios de inteligência artificial, além de recursos de comunicação e acompanhamento.
MVP e solução completa
A modelagem conceitual e lógica descreve a solução completa do VOLTA. Para a entrega de Banco de Dados 1, foi preparado um script SQL reduzido, proposto para o MVP, com nove tabelas:

role, company, cooperative, users, area, waste_type, cooperative_waste_type, incident e collection.

Esse recorte concentra os cadastros essenciais, a classificação de resíduos, o registro de ocorrências e a associação de solicitações de coleta a cooperativas. A equipe deve validar se essas estruturas correspondem às funcionalidades efetivamente implementadas na primeira versão.
Arquivos do banco
Arquivo	Descrição
tabelasVolta.sql	Criação das tabelas da modelagem completa do VOLTA.
volta_mvp.sql	Proposta de script de criação das tabelas necessárias ao MVP.
dataloadVolta.sql	Inserção de registros para popular a estrutura completa e apoiar testes.
consultasVolta.sql	Consultas SQL sobre os dados do projeto.
viewsVolta.sql	Visões para facilitar consultas e análises.
modeloConceitual.brM3	Arquivo editável do modelo conceitual, quando incluído no repositório.


As imagens dos modelos conceitual e lógico devem ser disponibilizadas na documentação da disciplina. O arquivo dataloadVolta.sql foi elaborado para o banco completo e não deve ser executado diretamente no esquema reduzido do MVP sem adaptação.
Como executar
1. Instale e configure o PostgreSQL e conecte-se a um banco de dados de testes utilizando, por exemplo, o DBeaver.
2. Para trabalhar com o modelo completo, execute tabelasVolta.sql e depois dataloadVolta.sql.
3. Para trabalhar apenas com o MVP proposto, execute volta_mvp.sql em um banco de testes separado, sem executar o DataLoad completo.
4. Após a criação e, quando aplicável, a carga dos dados, execute viewsVolta.sql e consultasVolta.sql na estrutura completa para analisar os resultados.
Atenção: os scripts de criação podem conter comandos DROP TABLE, que removem tabelas e seus dados existentes. Confira o arquivo antes de executar e utilize um banco de testes.
Integridade e validações
Os scripts contemplam mecanismos relacionais como chaves primárias, chaves estrangeiras, NOT NULL, UNIQUE, DEFAULT e CHECK. No recorte do MVP, essas regras incluem, entre outros exemplos, valores permitidos para prioridade e situação de ocorrências, verificação de quantidades não negativas e associação dos registros às entidades correspondentes.
Escopo acadêmico
Na disciplina Banco de Dados 1, a entrega inclui os modelos conceitual e lógico da solução completa, o script SQL textual do MVP, as restrições DEFAULT e CHECK, o script de carga de dados e a convenção de nomenclatura, acompanhados das respectivas evidências ou links diretos.

O banco de dados do 1º ano é independente do banco do 2º ano. A comunicação entre eles é prevista por meio de RPA, conforme as exigências do projeto interdisciplinar.
Projeto VOLTA
VOLTA | Gestão Inteligente de Ocorrências Industriais
Instituto J&F | Germinare Tech
Projeto Interdisciplinar 2026
