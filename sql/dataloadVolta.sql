
-- Data load · SQL
-- carga de dados de teste do volta (dados fictícios)
-- só tem avaliação de coleta concluída e incidente resolvido tem coleta concluída
 
begin;
 
insert into role values (id, type)
overriding system valueinsert
values (1, 'ADMINISTRADOR'), (2, 'FUNCIONARIO'), (3, 'GERENTE');
 
insert into company (id, name, cnpj, cep, address)
overriding system value
values
    (1, 'Empresa Verde Alimentos LTDA', '12345678000195', '01001000', 'Rua das Indústrias, 1200, São Paulo - SP'),
    (2, 'Alimentos Sustentáveis Brasil LTDA', '98765432000110', '01002000', 'Avenida Paulista, 850, São Paulo - SP');
 
insert into cooperative (id, name, cnpj, cep, latitude, longitude, opening_time, closing_time, monthly_capacity)
overriding system value
values
    (1, 'Cooperativa Recicla São Paulo', '11222333000181', '01001000', -23.5505200, -46.6333080, '08:00', '17:00', 5000.00),
    (2, 'Cooperativa Eco Futuro', '44555666000172', '01310100', -23.5616840, -46.6253780, '08:30', '17:30', 3500.00),
    (3, 'Cooperativa Circular Verde', '77888999000163', '04038001', -23.5733000, -46.6417000, '07:30', '16:30', 4200.00);
 
insert into users (id, company_id, cooperative_id, role_id, name, email, password, position)
overriding system value
values
    (1, 1, null, 1, 'Carlos Silva', 'carlos.silva@empresa.com', md5('volta-sintetico-carlos'), 'Administrador'),
    (2, 1, null, 2, 'Mariana Souza', 'mariana.souza@empresa.com', md5('volta-sintetico-mariana'), 'Funcionária'),
    (3, 1, null, 3, 'João Oliveira', 'joao.oliveira@empresa.com', md5('volta-sintetico-joao'), 'Gerente'),
    (4, 2, null, 1, 'Ana Costa', 'ana.costa@alimentos.com', md5('volta-sintetico-ana'), 'Administradora'),
    (5, null, 1, 2, 'Rafael Lima', 'rafael.lima@reciclasp.org', md5('volta-sintetico-rafael'), 'Operador de triagem'),
    (6, null, 2, 3, 'Paula Santos', 'paula.santos@ecofuturo.org', md5('volta-sintetico-paula'), 'Coordenadora'),
    (7, null, 3, 2, 'Marcos Pereira', 'marcos.pereira@circularverde.org', md5('volta-sintetico-marcos'), 'Operador de coleta');
 
insert into area (id, company_id, sector_name, location_description)
overriding system value
values
    (1, 1, 'Produção', 'Galpão principal da fábrica'),
    (2, 1, 'Estoque', 'Área de armazenamento de embalagens'),
    (3, 1, 'Expedição', 'Setor responsável pelo envio dos produtos'),
    (4, 2, 'Produção', 'Unidade de processamento de alimentos');
 
insert into waste_type (id, category, description, default_risk)
overriding system value
values
    (1, 'Plástico', 'Embalagens plásticas utilizadas nos produtos', 'MEDIO'),
    (2, 'Papelão', 'Caixas e embalagens de papelão', 'BAIXO'),
    (3, 'Metal', 'Latas e materiais metálicos', 'MEDIO'),
    (4, 'Resíduo Contaminado', 'Materiais contaminados que precisam de tratamento', 'ALTO');
 
-- Especialidades (antes: texto em cooperative.specialties).
-- 'Resíduos Industriais' foi associado a 'Resíduo Contaminado' (a confirmar pelo grupo).
insert into cooperative_waste_type (cooperative_id, waste_type_id)
values (1, 1), (1, 2), (1, 3), (2, 1), (2, 2), (3, 3), (3, 4);
 
insert into incident (id, user_id, area_id, waste_type_id, photo_url, employee_description, contamination_level, priority, status, registered_at, estimated_weight)
overriding system value
values
    (1, 2, 1, 1, 'https://exemplo.com/foto_plastico_01.jpg', 'Grande quantidade de embalagens plásticas acumuladas na área de produção.', 'MEDIO', 'ALTA', 'EM_ANALISE', '2026-09-01 08:30:00', 250.50),
    (2, 3, 2, 2, 'https://exemplo.com/foto_papelao_01.jpg', 'Caixas de papelão disponíveis para reciclagem.', 'BAIXO', 'MEDIA', 'EM_ANALISE', '2026-09-02 10:15:00', 180.00),
    (3, 2, 3, 3, 'https://exemplo.com/foto_metal_01.jpg', 'Materiais metálicos separados para coleta.', 'BAIXO', 'BAIXA', 'RESOLVIDA', '2026-09-03 13:45:00', 75.25),
    (4, 4, 4, 4, 'https://exemplo.com/foto_contaminado_01.jpg', 'Material contaminado identificado próximo à área de produção.', 'ALTO', 'URGENTE', 'EM_ANALISE', '2026-09-04 16:20:00', 40.00),
    (5, 3, 1, 2, 'https://exemplo.com/foto_papelao_02.jpg', 'Papelão de embalagens separado na produção.', 'BAIXO', 'BAIXA', 'RESOLVIDA', '2026-09-05 09:00:00', 120.00);
 
insert into ai_report (id, incident_id, detected_waste, ai_contamination_level, recommendations, report_text, generated_at)
overriding system value
values
    (1, 1, 'Plástico', 'MEDIO', 'Separar o material e solicitar coleta de cooperativa especializada.', 'A inteligência artificial identificou uma grande concentração de resíduos plásticos recicláveis.', '2026-09-01 08:35:00'),
    (2, 4, 'Resíduo Contaminado', 'ALTO', 'Isolar a área e encaminhar o material para tratamento adequado.', 'A inteligência artificial identificou possível risco ambiental devido à contaminação do material.', '2026-09-04 16:25:00');
 
-- Arquivos extras da ocorrência (a foto principal fica em incident.photo_url)
insert into attachment (id, incident_id, file_url, file_type)
overriding system value
values
    (1, 1, 'https://exemplo.com/anexo_incidente_01.pdf', 'PDF'),
    (2, 2, 'https://exemplo.com/anexo_incidente_02.jpg', 'JPG');
 
-- current_status é o último status do histórico de cada coleta
insert into collection (id, incident_id, cooperative_id, request_date, scheduled_date, current_status, collection_type, urgent, estimated_time)
overriding system value
values
    (1, 1, 1, '2026-09-01 09:00:00', '2026-09-02 09:00:00', 'ACEITA', 'PADRAO', true, '02:00:00'),
    (2, 2, 2, '2026-09-02 11:00:00', '2026-09-03 14:00:00', 'AGENDADA', 'PADRAO', false, '01:30:00'),
    (3, 3, 3, '2026-09-03 14:30:00', '2026-09-04 09:00:00', 'CONCLUIDA', 'PADRAO', false, '01:00:00'),
    (4, 5, 1, '2026-09-05 09:30:00', '2026-09-06 10:00:00', 'CONCLUIDA', 'PADRAO', false, '01:30:00');
 
insert into collection_status (id, collection_id, status, change_date, observation)
overriding system value
values
    (1, 1, 'SOLICITADA', '2026-09-01 09:00:00', 'Solicitação enviada para a cooperativa.'),
    (2, 1, 'ACEITA', '2026-09-01 12:00:00', 'Cooperativa confirmou disponibilidade para coleta.'),
    (3, 2, 'SOLICITADA', '2026-09-02 11:00:00', 'Solicitação enviada para a cooperativa.'),
    (4, 2, 'AGENDADA', '2026-09-02 11:05:00', 'Coleta agendada para o período da tarde.'),
    (5, 3, 'SOLICITADA', '2026-09-03 14:30:00', 'Solicitação enviada para a cooperativa.'),
    (6, 3, 'ACEITA', '2026-09-03 15:00:00', 'Cooperativa aceitou a coleta.'),
    (7, 3, 'AGENDADA', '2026-09-03 15:30:00', 'Coleta agendada para a manhã seguinte.'),
    (8, 3, 'EM_ANDAMENTO', '2026-09-04 09:00:00', 'Equipe chegou ao local.'),
    (9, 3, 'CONCLUIDA', '2026-09-04 10:00:00', 'Material retirado.'),
    (10, 4, 'SOLICITADA', '2026-09-05 09:30:00', 'Solicitação enviada para a cooperativa.'),
    (11, 4, 'ACEITA', '2026-09-05 10:00:00', 'Cooperativa aceitou a coleta.'),
    (12, 4, 'AGENDADA', '2026-09-05 10:30:00', 'Coleta agendada para o dia seguinte.'),
    (13, 4, 'EM_ANDAMENTO', '2026-09-06 10:00:00', 'Equipe chegou ao local.'),
    (14, 4, 'CONCLUIDA', '2026-09-06 11:30:00', 'Material retirado.');
 
-- Avaliações apenas de coletas CONCLUIDA (coletas 3 e 4)
insert into review (id, user_id, collection_id, stars, comment, review_date)
overriding system value
values
    (1, 3, 3, 5, 'Cooperativa muito organizada e atendimento eficiente.', '2026-09-04 17:00:00'),
    (2, 3, 4, 4, 'A coleta foi organizada e realizada conforme o combinado.', '2026-09-06 18:00:00');
 
insert into conversation (id, company_id, cooperative_id, collection_id, created_at)
overriding system value
values
    (1, 1, 1, 1, '2026-09-01 09:10:00'),
    (2, 1, 2, 2, '2026-09-02 11:10:00'),
    (3, 1, 3, 3, '2026-09-03 14:40:00');
 
-- Mensagens de usuários da empresa e das cooperativas
insert into message (id, conversation_id, user_id, text, reported, sent_at)
overriding system value
values
    (1, 1, 2, 'Olá, gostaríamos de confirmar a coleta dos materiais plásticos.', false, '2026-09-01 09:11:00'),
    (2, 1, 5, 'Confirmado! Nossa equipe passa amanhã às 9h.', false, '2026-09-01 09:20:00'),
    (3, 1, 3, 'A empresa estará disponível para a retirada no horário agendado.', false, '2026-09-01 09:25:00'),
    (4, 2, 2, 'Precisamos confirmar o horário da coleta.', false, '2026-09-02 11:11:00'),
    (5, 2, 6, 'O horário está confirmado para as 14h.', false, '2026-09-02 11:30:00'),
    (6, 3, 7, 'Nossa equipe chega às 9h para retirar o metal.', false, '2026-09-03 14:45:00');
 
insert into message_attachment (id, message_id, file_url, file_type)
overriding system value
values
    (1, 1, 'https://exemplo.com/comprovante_coleta.pdf', 'PDF'),
    (2, 4, 'https://exemplo.com/foto_residuo.jpg', 'JPG');
 
insert into notification (id, user_id, type, title, message, read, created_at)
overriding system value
values
    (1, 2, 'INCIDENTE', 'Novo relatório gerado', 'A inteligência artificial gerou um relatório para o incidente registrado.', false, '2026-09-01 08:40:00'),
    (2, 3, 'COLETA', 'Coleta agendada', 'Uma coleta foi agendada para os próximos dias.', false, '2026-09-02 11:15:00'),
    (3, 1, 'SISTEMA', 'Atualização do sistema', 'Os dados ambientais foram atualizados com sucesso.', true, '2026-09-04 17:00:00');
 
-- recycling_percentage é gerada pelo banco: não entra no INSERT
insert into esg_metric (id, company_id, period, total_kg_waste, total_kg_recycled, calculated_at)
overriding system value
values
    (1, 1, '2026-07', 1300.00, 910.00, '2026-08-01 08:00:00'),
    (2, 1, '2026-08', 1500.00, 1125.00, '2026-09-01 08:00:00'),
    (3, 2, '2026-08', 980.00, 686.00, '2026-09-01 08:30:00');
 
insert into complaint (id, cooperative_id, incident_id, photo, description, complaint_date)
overriding system value
values
    (1, 1, 1, 'https://exemplo.com/denuncia_01.jpg', 'Material recebido não correspondia ao descrito na ocorrência.', '2026-09-02'),
    (2, 3, 3, null, 'Peso do metal retirado diferente do peso estimado.', '2026-09-04');
 
-- ids fixos não avançam as sequences, então ajusta para o próximo insert
select setval(pg_get_serial_sequence('role', 'id'), max(id)) from role;
select setval(pg_get_serial_sequence('company', 'id'), max(id)) from company;
select setval(pg_get_serial_sequence('cooperative', 'id'), max(id)) from cooperative;
select setval(pg_get_serial_sequence('users', 'id'), max(id)) from users;
select setval(pg_get_serial_sequence('area', 'id'), max(id)) from area;
select setval(pg_get_serial_sequence('waste_type', 'id'), max(id)) from waste_type;
select setval(pg_get_serial_sequence('incident', 'id'), max(id)) from incident;
select setval(pg_get_serial_sequence('ai_report', 'id'), max(id)) from ai_report;
select setval(pg_get_serial_sequence('attachment', 'id'), max(id)) from attachment;
select setval(pg_get_serial_sequence('collection', 'id'), max(id)) from collection;
select setval(pg_get_serial_sequence('collection_status', 'id'), max(id)) from collection_status;
select setval(pg_get_serial_sequence('review', 'id'), max(id)) from review;
select setval(pg_get_serial_sequence('conversation', 'id'), max(id)) from conversation;
select setval(pg_get_serial_sequence('message', 'id'), max(id)) from message;
select setval(pg_get_serial_sequence('message_attachment', 'id'), max(id)) from message_attachment;
select setval(pg_get_serial_sequence('notification', 'id'), max(id)) from notification;
select setval(pg_get_serial_sequence('esg_metric', 'id'), max(id)) from esg_metric;
select setval(pg_get_serial_sequence('complaint', 'id'), max(id)) from complaint;
 
-- Conferência: quantidade de registros por tabela
select 'role' as table_name, count(*) as records from role
union all select 'company', count(*) from company
union all select 'cooperative', count(*) from cooperative
union all select 'users', count(*) from users
union all select 'area', count(*) from area
union all select 'waste_type', count(*) from waste_type
union all select 'cooperative_waste_type', count(*) from cooperative_waste_type
union all select 'incident', count(*) from incident
union all select 'ai_report', count(*) from ai_report
union all select 'attachment', count(*) from attachment
union all select 'collection', count(*) from collection
union all select 'collection_status', count(*) from collection_status
union all select 'review', count(*) from review
union all select 'conversation', count(*) from conversation
union all select 'message', count(*) from message
union all select 'message_attachment', count(*) from message_attachment
union all select 'notification', count(*) from notification
union all select 'esg_metric', count(*) from esg_metric
union all select 'complaint', count(*) from complaint
order by table_name;
 
commit;
 
