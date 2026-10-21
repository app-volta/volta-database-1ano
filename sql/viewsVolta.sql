-- views


--Drops das views

drop view if exists vw_collection_status_check;
drop view if exists vw_chat_messages;
drop view if exists vw_user_owner;
drop view if exists vw_esg_by_period;
drop view if exists vw_company_summary;
drop view if exists vw_cooperative_specialties;
drop view if exists vw_collection_details;
drop view if exists vw_incident_details;
drop view if exists vw_cooperative_rating;




 
-- nota média de cada cooperativa, calculada pelas avaliações
create view vw_cooperative_rating as
select co.id as cooperative_id,
       co.name,
       round(avg(r.stars), 2) as average_rating,
       count(r.id) as total_reviews
from cooperative co
left join collection col on col.cooperative_id = co.id
left join review r on r.collection_id = col.id
group by co.id, co.name;
 
-- ocorrência com empresa, área, tipo de resíduo e quem registrou
create view vw_incident_details as
select i.id as incident_id,
       c.name as company,
       a.sector_name as area,
       w.category as waste_type,
       u.name as reported_by,
       i.priority,
       i.status,
       i.estimated_weight,
       i.photo_url,
       i.registered_at
from incident i
join area a on a.id = i.area_id
join company c on c.id = a.company_id
join waste_type w on w.id = i.waste_type_id
join users u on u.id = i.user_id;
 
-- coleta com empresa, cooperativa e tipo de resíduo
create view vw_collection_details as
select col.id as collection_id,
       c.name as company,
       co.name as cooperative,
       w.category as waste_type,
       col.current_status,
       col.urgent,
       col.request_date,
       col.scheduled_date
from collection col
join incident i on i.id = col.incident_id
join area a on a.id = i.area_id
join company c on c.id = a.company_id
join cooperative co on co.id = col.cooperative_id
join waste_type w on w.id = i.waste_type_id;
 
-- lista de especialidades de cada cooperativa em uma linha só
create view vw_cooperative_specialties as
select co.id as cooperative_id,
       co.name,
       string_agg(w.category, ', ' order by w.category) as specialties
from cooperative co
left join cooperative_waste_type cwt on cwt.cooperative_id = co.id
left join waste_type w on w.id = cwt.waste_type_id
group by co.id, co.name;
 
-- total de ocorrências e peso por empresa
create view vw_company_summary as
select c.id as company_id,
       c.name,
       count(i.id) as total_incidents,
       coalesce(sum(i.estimated_weight), 0) as total_weight_kg
from company c
left join area a on a.company_id = c.id
left join incident i on i.area_id = a.id
group by c.id, c.name;
 
-- percentual de reciclagem por mês, somando todas as empresas
create view vw_esg_by_period as
select period,
       sum(total_kg_waste) as kg_waste,
       sum(total_kg_recycled) as kg_recycled,
       round(sum(total_kg_recycled) * 100 / nullif(sum(total_kg_waste), 0), 2) as recycling_percentage
from esg_metric
group by period;
 
-- usuários com o nome da empresa ou da cooperativa (sem a senha)
create view vw_user_owner as
select u.id as user_id,
       u.name,
       u.email,
       r.type as role,
       case when u.company_id is not null then 'EMPRESA' else 'COOPERATIVA' end as owner_type,
       coalesce(c.name, co.name) as owner_name
from users u
join role r on r.id = u.role_id
left join company c on c.id = u.company_id
left join cooperative co on co.id = u.cooperative_id;
 
-- mensagens com o nome de quem enviou
create view vw_chat_messages as
select m.id as message_id,
       m.conversation_id,
       u.name as sender,
       m.text,
       m.reported,
       m.sent_at
from message m
join users u on u.id = m.user_id;
 
-- coletas em que current_status é diferente do último status do histórico
create view vw_collection_status_check as
select col.id as collection_id,
       col.current_status,
       cs.status as last_history_status
from collection col
join collection_status cs on cs.collection_id = col.id
where cs.change_date = (
    select max(change_date) from collection_status where collection_id = col.id
)
and cs.status <> col.current_status;