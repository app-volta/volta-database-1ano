-- Tabelas SQL
-- Volta: criação do banco (postgresql 12 ou mais novo)
-- cuidado: os drops apagam tudo, usar só no banco de teste
 
drop table if exists complaint cascade;
drop table if exists esg_metric cascade;
drop table if exists notification cascade;
drop table if exists message_attachment cascade;
drop table if exists message cascade;
drop table if exists conversation cascade;
drop table if exists review cascade;
drop table if exists collection_status cascade;
drop table if exists collection cascade;
drop table if exists attachment cascade;
drop table if exists ai_report cascade;
drop table if exists incident cascade;
drop table if exists cooperative_waste_type cascade;
drop table if exists waste_type cascade;
drop table if exists area cascade;
drop table if exists users cascade;
drop table if exists cooperative cascade;
drop table if exists company cascade;
drop table if exists role cascade;
 
-- perfis de acesso (administrador, gerente, funcionario)
create table role (
    id integer generated always as identity primary key,
    type varchar(50) not null unique
);
 
create table company (
    id integer generated always as identity primary key,
    name varchar(150) not null,
    cnpj varchar(14) not null unique,
    cep varchar(8),
    address varchar(255) not null,
 
    constraint chk_company_cep check (cep ~ '^[0-9]{8}$'),
    constraint chk_company_cnpj check (cnpj ~ '^[0-9]{14}$')
);
 
-- as especialidades ficam em cooperative_waste_type
-- e a nota média na view vw_cooperative_rating
create table cooperative (
    id integer generated always as identity primary key,
    name varchar(150) not null,
    cnpj varchar(14) not null unique,
    cep varchar(8),
    latitude decimal(10,7),
    longitude decimal(10,7),
    opening_time time,
    closing_time time,
    monthly_capacity decimal(10,2),
 
    constraint chk_cooperative_cnpj check (cnpj ~ '^[0-9]{14}$'),
    constraint chk_cooperative_cep check (cep ~ '^[0-9]{8}$'),
    
    
    -- as coordenadas precisam estar dentro da cidade de são paulo
    constraint chk_cooperative_latitude check (latitude between -24.10 and -23.30),
    constraint chk_cooperative_longitude check (longitude between -46.90 and -46.30),
    constraint chk_cooperative_hours check (closing_time > opening_time),
    constraint chk_cooperative_capacity check (monthly_capacity >= 0)
);
 
-- cada usuário é de uma empresa ou de uma cooperativa, nunca dos dois
create table users (
    id integer generated always as identity primary key,
    company_id integer,
    cooperative_id integer,
    role_id integer not null,
    name varchar(150) not null,
    email varchar(150) not null unique,
    password varchar(255) not null,
    position varchar(100),
 
    constraint fk_users_company foreign key (company_id) references company(id) on delete restrict,
    constraint fk_users_cooperative foreign key (cooperative_id) references cooperative(id) on delete restrict,
    constraint fk_users_role foreign key (role_id) references role(id) on delete restrict,
    constraint chk_users_owner check (
        (company_id is not null and cooperative_id is null)
        or (company_id is null and cooperative_id is not null)
    ),
    constraint chk_users_email check (email like '%@%.%')
);
 
create table area (
    id integer generated always as identity primary key,
    company_id integer not null,
    sector_name varchar(150) not null,
    location_description varchar(255),
 
    constraint fk_area_company foreign key (company_id) references company(id) on delete restrict
);
 
create table waste_type (
    id integer generated always as identity primary key,
    category varchar(100) not null,
    description varchar(255),
    default_risk varchar(50) not null,
 
    constraint chk_waste_risk check (default_risk in ('BAIXO', 'MEDIO', 'ALTO'))
);
 
-- tabela de ligação: uma cooperativa aceita vários tipos de resíduo
-- e um tipo de resíduo pode ser aceito por várias cooperativas
create table cooperative_waste_type (
    cooperative_id integer not null,
    waste_type_id integer not null,
 
    primary key (cooperative_id, waste_type_id),
    constraint fk_cooperative_waste_type_cooperative foreign key (cooperative_id) references cooperative(id) on delete cascade,
    constraint fk_cooperative_waste_type_waste_type foreign key (waste_type_id) references waste_type(id) on delete restrict
);
 
-- a empresa da ocorrência vem da área (area.company_id)
-- photo_url é a foto principal, outros arquivos ficam em attachment
create table incident (
    id integer generated always as identity primary key,
    user_id integer not null,
    area_id integer not null,
    waste_type_id integer not null,
    photo_url varchar(500),
    employee_description text,
    contamination_level varchar(50),
    priority varchar(50) not null default 'MEDIA',
    status varchar(50) not null default 'PENDENTE',
    registered_at timestamp not null default current_timestamp,
    estimated_weight decimal(10,2),
 
    constraint fk_incident_user foreign key (user_id) references users(id) on delete restrict,
    constraint fk_incident_area foreign key (area_id) references area(id) on delete restrict,
    constraint fk_incident_waste_type foreign key (waste_type_id) references waste_type(id) on delete restrict,
    constraint chk_incident_contamination check (contamination_level in ('BAIXO', 'MEDIO', 'ALTO')),
    constraint chk_incident_weight check (estimated_weight >= 0),
    constraint chk_incident_priority check (priority in ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE')),
    constraint chk_incident_status check (status in ('PENDENTE', 'EM_ANALISE', 'RESOLVIDA', 'CANCELADA'))
);
 
-- um relatório de ia por ocorrência
create table ai_report (
    id integer generated always as identity primary key,
    incident_id integer not null unique,
    detected_waste varchar(100),
    ai_contamination_level varchar(50),
    recommendations text,
    report_text text,
    generated_at timestamp not null default current_timestamp,
 
    constraint fk_ai_report_incident foreign key (incident_id) references incident(id) on delete cascade,
    constraint chk_ai_report_contamination check (ai_contamination_level in ('BAIXO', 'MEDIO', 'ALTO'))
);
 
create table attachment (
    id integer generated always as identity primary key,
    incident_id integer not null,
    file_url varchar(500) not null,
    file_type varchar(50) not null,
 
    constraint fk_attachment_incident foreign key (incident_id) references incident(id) on delete cascade,
    constraint chk_attachment_file_type check (file_type in ('PDF', 'JPG', 'PNG'))
);
 
-- current_status guarda o último status da coleta, para consultar rápido.
-- toda vez que entrar uma linha em collection_status, a aplicação também
-- atualiza esta coluna (na mesma transação). a view vw_collection_status_check
-- mostra se algum valor ficou diferente do histórico.
create table collection (
    id integer generated always as identity primary key,
    incident_id integer not null,
    cooperative_id integer not null,
    request_date timestamp not null default current_timestamp,
    scheduled_date timestamp,
    current_status varchar(50) not null default 'SOLICITADA',
    collection_type varchar(50),
    urgent boolean not null default false,
    estimated_time interval,
 
    constraint fk_collection_incident foreign key (incident_id) references incident(id) on delete restrict,
    constraint fk_collection_cooperative foreign key (cooperative_id) references cooperative(id) on delete restrict,
    constraint chk_collection_current_status check (current_status in ('SOLICITADA', 'AGENDADA', 'ACEITA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')),
    constraint chk_collection_type check (collection_type in ('PADRAO', 'RECORRENTE')),
    constraint chk_collection_scheduled_date check (scheduled_date >= request_date)
);
 
-- histórico: cada mudança de status da coleta vira uma linha
create table collection_status (
    id integer generated always as identity primary key,
    collection_id integer not null,
    status varchar(50) not null,
    change_date timestamp not null default current_timestamp,
    observation text,
 
    constraint fk_collection_status_collection foreign key (collection_id) references collection(id) on delete cascade,
    constraint chk_collection_status_status check (status in ('SOLICITADA', 'AGENDADA', 'ACEITA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA'))
);
 
-- a cooperativa avaliada vem da coleta (collection.cooperative_id)
create table review (
    id integer generated always as identity primary key,
    user_id integer not null,
    collection_id integer not null,
    stars integer not null,
    comment text,
    review_date timestamp not null default current_timestamp,
 
    constraint fk_review_user foreign key (user_id) references users(id) on delete restrict,
    constraint fk_review_collection foreign key (collection_id) references collection(id) on delete restrict,
    constraint chk_review_stars check (stars between 1 and 5)
);
 
-- collection_id pode ficar vazio: dá para conversar antes de existir uma coleta,
-- por isso a empresa e a cooperativa ficam guardadas aqui
create table conversation (
    id integer generated always as identity primary key,
    company_id integer not null,
    cooperative_id integer not null,
    collection_id integer,
    created_at timestamp not null default current_timestamp,
 
    constraint fk_conversation_company foreign key (company_id) references company(id) on delete restrict,
    constraint fk_conversation_cooperative foreign key (cooperative_id) references cooperative(id) on delete restrict,
    constraint fk_conversation_collection foreign key (collection_id) references collection(id) on delete restrict
);
 
create table message (
    id integer generated always as identity primary key,
    conversation_id integer not null,
    user_id integer not null,
    text text not null,
    reported boolean not null default false,
    sent_at timestamp not null default current_timestamp,
 
    constraint fk_message_conversation foreign key (conversation_id) references conversation(id) on delete cascade,
    constraint fk_message_user foreign key (user_id) references users(id) on delete restrict,
    constraint chk_message_text check (length(trim(text)) > 0)
);
 
create table message_attachment (
    id integer generated always as identity primary key,
    message_id integer not null,
    file_url varchar(500) not null,
    file_type varchar(50) not null,
 
    constraint fk_message_attachment_message foreign key (message_id) references message(id) on delete cascade,
    constraint chk_message_attachment_file_type check (file_type in ('PDF', 'JPG', 'PNG'))
);
 
create table notification (
    id integer generated always as identity primary key,
    user_id integer not null,
    type varchar(50) not null,
    title varchar(150) not null,
    message text not null,
    read boolean not null default false,
    created_at timestamp not null default current_timestamp,
 
    constraint fk_notification_user foreign key (user_id) references users(id) on delete cascade,
    constraint chk_notification_type check (type in ('INCIDENTE', 'COLETA', 'SISTEMA'))
);
 
-- period é o mês no formato AAAA-MM
-- recycling_percentage o banco calcula sozinho, não entra no insert
create table esg_metric (
    id integer generated always as identity primary key,
    company_id integer not null,
    period varchar(20) not null,
    total_kg_waste decimal(12,2) not null default 0,
    total_kg_recycled decimal(12,2) not null default 0,
    recycling_percentage decimal(5,2) generated always as (
        round(total_kg_recycled * 100 / nullif(total_kg_waste, 0), 2)
    ) stored,
    calculated_at timestamp not null default current_timestamp,
 
    constraint fk_esg_metric_company foreign key (company_id) references company(id) on delete restrict,
    constraint uq_esg_metric_company_period unique (company_id, period),
    constraint chk_esg_metric_period check (period ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
    constraint chk_esg_total_waste check (total_kg_waste >= 0),
    constraint chk_esg_total_recycled check (total_kg_recycled >= 0),
    constraint chk_esg_recycled_not_above_waste check (total_kg_recycled <= total_kg_waste)
);
 
-- a empresa da denúncia vem da ocorrência
create table complaint (
    id integer generated always as identity primary key,
    cooperative_id integer not null,
    incident_id integer not null,
    photo varchar(500),
    description text not null,
    complaint_date date not null default current_date,
 
    constraint fk_complaint_cooperative foreign key (cooperative_id) references cooperative(id) on delete restrict,
    constraint fk_complaint_incident foreign key (incident_id) references incident(id) on delete restrict
);
 
 

