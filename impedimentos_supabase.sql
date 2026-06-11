-- Tabela de impedimentos (calculada no upload do arquivo cru)
create table if not exists impedimentos (
  id            bigserial primary key,
  data          date not null,
  matricula     text,
  base          text,
  rz            text,
  ul            text,
  instalacao    text,
  medidor       text,
  ocorrencia    text,
  endereco      text,
  cidade        text,
  qtd_digitacao integer default 1,
  responsabilidade text,  -- 'GBS' ou 'CEMIG'
  created_at    timestamptz default now()
);

create index if not exists idx_imp_data       on impedimentos(data);
create index if not exists idx_imp_matricula  on impedimentos(matricula);
create index if not exists idx_imp_base       on impedimentos(base);
create index if not exists idx_imp_ul         on impedimentos(ul);

-- Tabela de leituras acertadas (instalações que saíram de impedimento)
create table if not exists leituras_acertadas (
  id          bigserial primary key,
  mes_ref     text not null,  -- 'yyyy-mm'
  instalacao  text not null,
  reg         text,
  ul          text,
  oc_original integer,
  oc_acertada integer,
  created_at  timestamptz default now()
);

create index if not exists idx_acert_mes  on leituras_acertadas(mes_ref);
create index if not exists idx_acert_inst on leituras_acertadas(instalacao);

alter table impedimentos      disable row level security;
alter table leituras_acertadas disable row level security;
