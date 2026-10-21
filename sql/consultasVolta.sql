-- consultas do Volta
--Testes para ver as informações

-- 1. incidentes por área e empresa
select c.name as company,
       a.sector_name,
       count(i.id) as total_incidents
from area a
join company c on c.id = a.company_id
left join incident i on i.area_id = a.id
group by c.name, a.sector_name
order by total_incidents desc, c.name;

-- 2. ranking de cooperativas pela nota média (através das views)
select name, average_rating, total_reviews
from vw_cooperative_rating
order by average_rating desc nulls last;

-- 3. percentual de reciclagem por mês (através das views)
select * from vw_esg_by_period order by period;

-- 4. coletas com status atual, cooperativa e tipo de resíduo (através das views)
select collection_id, cooperative, waste_type, current_status, scheduled_date
from vw_collection_details
order by collection_id;

-- 5. cooperativas e suas especialidades (através das views)
select name, specialties from vw_cooperative_specialties
order by name;

-- 6. ocorrências com empresa, área e quem registrou (através das views)
select * from vw_incident_details
order by incident_id;

-- 7. resumo por empresa (através das views)
select * from vw_company_summary order by total_incidents desc;

-- 8. usuários e a quem pertencem (através das views)
select * from vw_user_owner order by user_id;

-- 9. mensagens do chat com o nome de quem enviou (através das views)
select * from vw_chat_messages order by conversation_id, sent_at;

-- verificações (todas devem voltar zero linhas)

-- 10. coletas sem nenhum histórico de status
select col.id
from collection col
left join collection_status cs on cs.collection_id = col.id
where cs.id is null;

-- 11. avaliações de coletas que não foram concluídas
select r.id as review_id, col.current_status
from review r
join collection col on col.id = r.collection_id
where col.current_status <> 'CONCLUIDA';

-- 12. current_status diferente do último status do histórico (através das views)
select * from vw_collection_status_check; 
