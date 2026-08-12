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

-- Usada pelo dropdown de "Código de Ocorrência" da aba Ocorrências. Traz a responsabilidade
-- junto pra filtrar o dropdown no front conforme o toggle Todos/GBS/CEMIG, escopado pelo
-- mês selecionado (não a tabela impedimentos inteira, que cresce mês a mês).
-- p_mes_ref é text no formato 'yyyy-mm', comparado contra mes_ref::text via like -- assim
-- funciona independente do mes_ref real ser date ou text, e independente de ter sido
-- gravado como 'yyyy-mm-01' ou só 'yyyy-mm' (essa tabela não tem esse campo no create table
-- acima porque foi adicionado depois via migração avulsa; não dava pra confirmar o tipo
-- exato sem risco de repetir o erro de cast que aconteceu no projeto da Exata).
drop function if exists codigos_ocorrencia_mes(date);
drop function if exists codigos_ocorrencia_mes(text);
create or replace function codigos_ocorrencia_mes(p_mes_ref text)
returns table(ocorrencia text, responsabilidade text)
language sql
as $$
  select distinct ocorrencia, responsabilidade from impedimentos
  where mes_ref::text like p_mes_ref || '%' and ocorrencia is not null
  order by ocorrencia;
$$;

-- mes_ref é filtrado em praticamente toda consulta do módulo e não tem índice --
-- ajuda tanto as consultas existentes quanto essa nova função.
create index if not exists idx_imp_mesref on impedimentos(mes_ref);
