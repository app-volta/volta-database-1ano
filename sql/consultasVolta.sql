-- consultas do volta

-- 1. incidentes por área e empresa
SELECT c.name AS company,
       a.sector_name,
       COUNT(i.id) AS total_incidents
FROM area a
JOIN company c ON c.id = a.company_id
LEFT JOIN incident i ON i.area_id = a.id
GROUP BY c.name, a.sector_name
ORDER BY total_incidents DESC, c.name;

-- 2. ranking de cooperativas pela nota média (através das views)
SELECT name, average_rating, total_reviews
FROM vw_cooperative_rating
ORDER BY average_rating DESC;

-- 3. percentual de reciclagem por mês (através das views)
SELECT * FROM vw_esg_by_period ORDER BY period;

-- 4. coletas com status atual, cooperativa e tipo de resíduo (através das views)
SELECT collection_id, cooperative, waste_type, current_status, scheduled_date
FROM vw_collection_details
ORDER BY collection_id;

-- 5. cooperativas e suas especialidades (através das views)
SELECT name, specialties FROM vw_cooperative_specialties
ORDER BY name;

-- 6. ocorrências com empresa, área e quem registrou (através das views)
SELECT * FROM vw_incident_details
ORDER BY incident_id;

-- 7. resumo por empresa (através das views)
SELECT * FROM vw_company_summary ORDER BY total_incidents DESC;

-- 8. usuários e a quem pertencem (através das views)
SELECT * FROM vw_user_owner ORDER BY user_id;

-- 9. mensagens do chat com o nome de quem enviou (através das views)
SELECT * FROM vw_chat_messages ORDER BY conversation_id, sent_at;

-- verificações (todas devem voltar zero linhas)

-- 10. coletas sem nenhum histórico de status
SELECT col.id
FROM collection col
LEFT JOIN collection_status cs ON cs.collection_id = col.id
WHERE cs.id IS NULL;

-- 11. avaliações de coletas que não foram concluídas
SELECT r.id AS review_id, col.current_status
FROM review r
JOIN collection col ON col.id = r.collection_id
WHERE col.current_status <> 'CONCLUIDA';

-- 12. current_status diferente do último status do histórico (através das views)
SELECT * FROM vw_collection_status_check; 

-- 13. chaves estrangeiras do banco
SELECT tc.table_name AS tabela,
       kcu.column_name AS coluna,
       ccu.table_name AS referencia,
       ccu.column_name AS coluna_referencia
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
    AND tc.table_schema = ccu.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;