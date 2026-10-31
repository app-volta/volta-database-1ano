-- views


--Drops das views

DROP VIEW IF EXISTS vw_collection_status_check;
DROP VIEW IF EXISTS vw_chat_messages;
DROP VIEW IF EXISTS vw_user_owner;
DROP VIEW IF EXISTS vw_esg_by_period;
DROP VIEW IF EXISTS vw_company_summary;
DROP VIEW IF EXISTS vw_cooperative_specialties;
DROP VIEW IF EXISTS vw_collection_details;
DROP VIEW IF EXISTS vw_incident_details;
DROP VIEW IF EXISTS vw_cooperative_rating;




 
-- nota média de cada cooperativa, calculada pelas avaliações
CREATE VIEW vw_cooperative_rating AS
SELECT co.id AS cooperative_id,
       co.name,
       ROUND(AVG(r.stars), 2) AS average_rating,
       COUNT(r.id) AS total_reviews
FROM cooperative co
LEFT JOIN collection col ON col.cooperative_id = co.id
LEFT JOIN review r ON r.collection_id = col.id
GROUP BY co.id, co.name;
 
-- ocorrência com empresa, área, tipo de resíduo e quem registrou
CREATE VIEW vw_incident_details AS
SELECT i.id AS incident_id,
       c.name AS company,
       a.sector_name AS area,
       w.category AS waste_type,
       u.name AS reported_by,
       i.priority,
       i.status,
       i.estimated_weight,
       i.photo_url,
       i.registered_at
FROM incident i
JOIN area a ON a.id = i.area_id
JOIN company c ON c.id = a.company_id
JOIN waste_type w ON w.id = i.waste_type_id
JOIN users u ON u.id = i.user_id;
 
-- coleta com empresa, cooperativa e tipo de resíduo
CREATE VIEW vw_collection_details AS
SELECT col.id AS collection_id,
       c.name AS company,
       co.name AS cooperative,
       w.category AS waste_type,
       col.current_status,
       col.urgent,
       col.request_date,
       col.scheduled_date
FROM collection col
JOIN incident i ON i.id = col.incident_id
JOIN area a ON a.id = i.area_id
JOIN company c ON c.id = a.company_id
JOIN cooperative co ON co.id = col.cooperative_id
JOIN waste_type w ON w.id = i.waste_type_id;
 
-- lista de especialidades de cada cooperativa em uma linha só
CREATE VIEW vw_cooperative_specialties AS
SELECT co.id AS cooperative_id,
       co.name,
       STRING_AGG(w.category, ', ' ORDER BY w.category) AS specialties
FROM cooperative co
LEFT JOIN cooperative_waste_type cwt ON cwt.cooperative_id = co.id
LEFT JOIN waste_type w ON w.id = cwt.waste_type_id
GROUP BY co.id, co.name;
 
-- total de ocorrências e peso por empresa
CREATE VIEW vw_company_summary AS
SELECT c.id AS company_id,
       c.name,
       COUNT(i.id) AS total_incidents,
       COALESCE(SUM(i.estimated_weight), 0) AS total_weight_kg
FROM company c
LEFT JOIN area a ON a.company_id = c.id
LEFT JOIN incident i ON i.area_id = a.id
GROUP BY c.id, c.name;
 
-- percentual de reciclagem por mês, somando todas as empresas
CREATE VIEW vw_esg_by_period AS
SELECT period,
       SUM(total_kg_waste) AS kg_waste,
       SUM(total_kg_recycled) AS kg_recycled,
       ROUND(SUM(total_kg_recycled) * 100 / NULLIF(SUM(total_kg_waste), 0), 2) AS recycling_percentage
FROM esg_metric
GROUP BY period;
 
-- usuários com o nome da empresa ou da cooperativa (sem a senha)
CREATE VIEW vw_user_owner AS
SELECT u.id AS user_id,
       u.name,
       u.email,
       r.type AS role,
       CASE WHEN u.company_id IS NOT NULL THEN 'EMPRESA' ELSE 'COOPERATIVA' END AS owner_type,
       COALESCE(c.name, co.name) AS owner_name
FROM users u
JOIN role r ON r.id = u.role_id
LEFT JOIN company c ON c.id = u.company_id
LEFT JOIN cooperative co ON co.id = u.cooperative_id;
 
-- mensagens com o nome de quem enviou
CREATE VIEW vw_chat_messages AS
SELECT m.id AS message_id,
       m.conversation_id,
       u.name AS sender,
       m.text,
       m.reported,
       m.sent_at
FROM message m
JOIN users u ON u.id = m.user_id;
 
-- coletas em que current_status é diferente do último status do histórico
CREATE VIEW vw_collection_status_check AS
SELECT col.id AS collection_id,
       col.current_status,
       cs.status AS last_history_status
FROM collection col
JOIN collection_status cs ON cs.collection_id = col.id
WHERE cs.change_date = (
    SELECT MAX(change_date) FROM collection_status WHERE collection_id = col.id
)
AND cs.status <> col.current_status;