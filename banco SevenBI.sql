
-----------------------------------------------------------------------------------------------------------------
--                                      **   MODELAGEM DA BASE DO BI   **                                      --
-----------------------------------------------------------------------------------------------------------------

create sequence aux_saldos_contas_seq;
create sequence dim_contas_seq;
create sequence dim_empresas_seq;
create sequence dim_contas_deb_seq;
create sequence dim_contas_cred_seq;
create sequence dim_agrupadoras_seq;
create sequence dim_nota_fiscal_seq;
create sequence fato_faturamento_seq;
create sequence fato_financeiro_seq;
create sequence aux_estrutura_dre_seq;
create sequence fato_apuracao_dre_seq;
create sequence dim_clientes_seq;
create sequence fato_compras_seq;
create sequence dim_pedidos_seq;
create sequence dim_recebimentos_seq;

alter sequence fato_compras_seq restart with 1;
alter sequence dim_pedidos_seq restart with 1;
alter sequence dim_recebimentos_seq restart with 1;
alter sequence aux_saldos_contas_seq restart with 1;
alter sequence dim_contas_seq restart with 1;
alter sequence dim_empresas_seq restart with 1;
alter sequence dim_contas_deb_seq restart with 1;
alter sequence dim_contas_cred_seq restart with 1;
alter sequence dim_agrupadoras_seq restart with 1;
alter sequence dim_nota_fiscal_seq restart with 1;
alter sequence fato_faturamento_seq restart with 1;
alter sequence fato_financeiro_seq restart with 1;
alter sequence aux_estrutura_dre_seq restart with 1;
alter sequence fato_apuracao_dre_seq restart with 1;
alter sequence dim_clientes_seq restart with 1;

create table public.dim_empresas 
(indice integer default nextval('dim_empresas_seq'),
 seq integer,		-- seq original da base operacional de origem
 razao_social varchar(150),
 cnpj text,
 endereco varchar(200),
 cidade varchar(50),
 estado varchar(2),
 cep varchar(10),
 CONSTRAINT dim_empresas_pk PRIMARY KEY (seq)
);
grant all on public.dim_empresas to public;

create table public.dim_contas 
(indice integer default nextval('dim_contas_seq'),
seq integer,   		-- seq original da base operacional de origem
tipo varchar(20),
cod_banco varchar(10),
nome_banco varchar(100),
cod_agencia varchar(10),
cod_conta varchar(20),
data_inicio_saldo date,
saldo_inicial numeric,
seq_empresa integer
);
grant all on public.dim_contas to public;

create table public.dim_contas_ctb_debito
(indice integer default nextval('dim_contas_deb_seq'),
seq integer,			-- seq original da base operacional de origem
codigo varchar(20),
conta_debito varchar(100),
cod_agrupadora varchar(10),
conta_agrupadora varchar(100),
tipo varchar(20),
empresa integer,
CONSTRAINT dim_contas_debito_pk PRIMARY KEY (indice)
);
grant all on public.dim_contas_ctb_debito to public;

create table public.dim_contas_ctb_credito
(indice integer default nextval('dim_contas_cred_seq'),
seq integer,			-- seq original da base operacional de origem
codigo varchar(20),
conta_credito varchar(100),
cod_agrupadora varchar(10),
conta_agrupadora varchar(100),
tipo varchar(20),
empresa integer,
CONSTRAINT dim_contas_credito_pk PRIMARY KEY (indice)
);
grant all on public.dim_contas_ctb_credito to public;

create table public.dim_agrupadoras
(indice integer default nextval('dim_agrupadoras_seq'),
seq integer,
nome text,
nivel integer,
seq_superior integer,
grupo text,
ordem integer,
CONSTRAINT dim_agrupadoras_pk PRIMARY KEY (indice)
);
grant all on dim_agrupadoras to public;

create table public.dim_nota_fiscal
(indice integer default nextval('dim_nota_fiscal_seq'),
seq integer,			-- NF não tem seq na W&F
seq_empresa integer,
tipo varchar(20),
numero_nf varchar(20),
serie_nf varchar(10),
cnpj_cliente text,
cnpj_fornecedor text,
razao_social varchar(150),
cidade varchar(100),
estado varchar(2),
condicao_pagamento varchar(20),
cod_item varchar(10),
descricao_item varchar(150),
valor_unitario numeric,
quantidade numeric,
situacao varchar(20),
CONSTRAINT dim_nota_fiscal_pk PRIMARY KEY (indice)
);
grant all on public.dim_nota_fiscal to public;

create table public.dim_clientes
(indice integer default nextval('dim_clientes_seq'),
seq integer,			-- sequencia original da COBRANCA
razao_social text,
cpf_cnpj text,
email text,
cidade text,
estado text,
CONSTRAINT dim_clientes_pk PRIMARY KEY (indice)
);
grant all on public.dim_clientes to public;

create table public.fato_faturamento
(indice integer default nextval('fato_faturamento_seq'),
seq integer,			-- sequencia original da COBRANCA
seq_empresa integer,
numero_nf text,
valor_nf numeric,
valor_icms numeric,
valor_ipi numeric,
valor_pis numeric,
valor_cofins numeric,
valor_iss numeric,
tipo_duplicata varchar(10),
numero_duplicata varchar(20),
data_emissao date,
data_vencimento date,
valor numeric,
juros numeric,
desconto numeric,
situacao varchar(20),
data_recebimento date,
seq_cliente integer,
CONSTRAINT fato_faturamento_pk PRIMARY KEY (indice),
CONSTRAINT fato_faturamento_fk1 FOREIGN KEY (seq_empresa) REFERENCES public.dim_empresas(seq)
);
grant all on public.fato_faturamento to public;

create table public.fato_financeiro
(indice integer default nextval('fato_financeiro_seq'),
seq integer,
seq_empresa integer,
seq_faturamento integer,
categoria varchar(10),
data date,
seq_conta integer,
valor_credito numeric,
valor_debito numeric,
historico varchar(250),
tipo_movimento varchar(50),
seq_conta_debito integer,		-- seq original da tabela operacional
seq_conta_credito integer,		-- seq original da tabela operacional
previsao varchar(10),
CONSTRAINT fato_financeiro_pk PRIMARY KEY (indice),
CONSTRAINT fato_financeiro_fk1 FOREIGN KEY (seq_empresa) REFERENCES public.dim_empresas(seq)
);
grant all on public.fato_financeiro to public;

create table public.aux_saldos_contas
(indice integer default nextval('aux_saldos_contas_seq'),
seq integer,
seq_conta integer,
data date,
saldo_inicial numeric,
saldo_final numeric,
saldo_atual text default 'N',
CONSTRAINT aux_saldos_contas_pk PRIMARY KEY (indice)
);
grant all on public.aux_saldos_contas to public;

create table public.aux_estrutura_dre 
(indice integer default nextval('aux_estrutura_dre_seq'),
item text,
mascara text,
operacao text,
codigo integer,
ordem integer,
categoria varchar
);
grant all on aux_estrutura_dre to public;

CREATE TABLE public.fato_apuracao_dre (
	indice integer NOT NULL DEFAULT nextval('fato_apuracao_dre_seq'),
	empresa integer NULL,
	periodo date NULL,
	codigo_conta integer NULL,		-- seq das contas analíticas
	resultado text NULL,			-- nome da conta de resultado (quando aplicável)
	agrupadora text NULL,			-- nome da conta agrupadora das analíticas (quando aplicável)
	analitica text NULL,			-- nome da conta analítica (quando aplicável)
	seq_fato_financeiro integer,	-- VALIDAR SE É VIÁVEL (para detalhamento no dashboard do DRE)
	historico_fato_financeiro text,	-- VALIDAR SE É VIÁVEL (para detalhamento no dashboard do DRE)
	valor numeric NULL,				
	operacao text NULL,				-- + (receitas) , - (despesas) ou = (resultados)  -- agrupadoras recebem 0 (zero)
	ordem integer NULL,				-- ordem de acordo com a planilha de estrutura do DRE (ordem de exibição das contas no relatório)
	previsto text DEFAULT 'N',		-- S ou N
	CONSTRAINT fato_apuracao_dre_pk PRIMARY KEY (indice)
);
grant all on public.fato_apuracao_dre to public;

create table public.fato_compras
(indice integer default nextval('fato_compras_seq'),
seq integer, 					-- sequencia original da ORDEM DE COMPRA
seq_pedido integer, 			-- FK para a coluna INDICE da DIM_PEDIDOS
data_pedido date,
valor_pedido numeric,
desconto numeric,
situacao text default 'AGUARDANDO',  		-- AGUARDANDO, ATENDIDA, ATENDIDA PARCIALMENTE, CANCELADA, ATRASADA
CONSTRAINT fato_compras_pk PRIMARY KEY (indice)
);
grant all on public.fato_compras to public;

create table public.dim_pedidos
(indice integer default nextval('dim_pedidos_seq'),
seq integer, 								-- sequencia original da tabela de PEDIDOS de compras (se aplicável)
data_cotacao date,
data_pedido date,
seq_fornecedor integer,
nome_fornecedor text,
seq_item integer,
codigo_item text,
descricao_item text,
valor_unitario numeric,
quantidade numeric,
unidade_medida text,
desconto_item numeric,
CONSTRAINT dim_pedidos_pk PRIMARY KEY (indice)
);
grant all on public.dim_pedidos to public;

create table public.dim_recebimentos
(indice integer default nextval('dim_recebimentos_seq'),
seq_compra integer,							-- referência para a coluna INDICE na FATO_COMPRAS (que referncia também o item sendo recebido pois a chave é composta: SEQ_COMPRA + SEQ_ITEM)
data_recebimento date,
situacao text default 'AGUARDANDO',			-- AGUARDANDO, RECEBIDO, RECEBIDO PARCIALMENTE, DEVOLVIDO
CONSTRAINT dim_recebimentos_pk PRIMARY KEY (indice)
);
grant all on public.dim_recebimentos to public;

-----------------------------------------------------------------------------------------------------------------
--                             **   DEFINIÇÃO DOS PROCESSOS DE IMPORTAÇÃO   **                                 --
--                                                                                                             --
-- W&F Premissa 1: importar movimentação a partir de 01/01/2023                                                --
-- W&F Premissa 2: contas do Santander não devem ser importadas                                                --
-- W&F Premissa 3: notas fiscais e duplicatas a partir da tabela COBRANCAS                                     --
--				   1 linha de cobrança = 1 duplicata (W&F não tem tabela de notas fiscais)                     --
-- W&F Premissa 4: 1 linha da fato_faturamento = 1 duplicata, mesmo que não tenha NF associada                 --
-- W&F Premissa 5: movimentos A PAGAR deverão gerar uma linha na FATO_FATURAMENTO                              --
-- W&F Premissa 6: somente notas fiscais NÃO CANCELADAS                                                        --
-- W&F Premissa 7: inicialmente o DRE deve considerar apenas os movimentos já REALIZADOS 			  	       --
-- W&F Premissa 8: registros de COMPRAS serão por planilha, por não existir sistema de controle 			   --
--                                                                                                             --   
-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_reinicia_base()
as
$$
begin 
	delete from fato_financeiro;
	delete from fato_faturamento;
	delete from fato_apuracao_dre;
	delete from dim_nota_fiscal;
	delete from aux_saldos_contas;
	delete from dim_contas;
	delete from dim_empresas;
	delete from dim_contas_ctb_debito;
	delete from dim_contas_ctb_credito;
	delete from dim_agrupadoras;
	delete from dim_clientes;
	delete from dim_recebimentos;
	delete from dim_pedidos;
	delete from fato_compras;

	alter sequence aux_saldos_contas_seq restart with 1;
	alter sequence dim_contas_seq restart with 1;
	alter sequence dim_empresas_seq restart with 1;
	alter sequence dim_contas_deb_seq restart with 1;
	alter sequence dim_contas_cred_seq restart with 1;
	alter sequence dim_nota_fiscal_seq restart with 1;
	alter sequence dim_agrupadoras_seq restart with 1;
	alter sequence fato_faturamento_seq restart with 1;
	alter sequence fato_financeiro_seq restart with 1;
	alter sequence aux_estrutura_dre_seq restart with 1;
	alter sequence fato_apuracao_dre_seq restart with 1;
	alter sequence dim_clientes_seq restart with 1;
	alter sequence fato_compras_seq restart with 1;
	alter sequence dim_pedidos_seq restart with 1;
	alter sequence dim_recebimentos_seq restart with 1;

	commit;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_dw()
as
$$
declare 
	dDataDRE date;
begin 
	call public.pr_reinicia_base();
	call public.pr_carga_empresas();
	call public.pr_carga_contas();
	call public.pr_carga_contas_contabeis();
	call public.pr_carga_agrupadoras();
	call public.pr_carga_clientes();
	call public.pr_carga_notas_fiscais();
	call public.pr_carga_fato_faturamento('R');
	call public.pr_carga_fato_financeiro();
	call public.pr_carga_fato_faturamento('P');
	call public.pr_carga_pedidos();
--	call public.pr_carga_compras();
--	call public.pr_carga_recebimentos();
	call public.pr_carga_saldos();

	dDataDRE = date_trunc('month', current_date) - interval '6 month'; 

	-- premissa: apurar DRE dos últimos 6 meses 
	while (date_trunc('month', dDataDRE) <= date_trunc('month', current_date)) loop
		call pr_calculo_dre(dDataDRE);
		dDataDRE = dDataDRE + interval '1 month';
	end loop;

	commit;

	call pr_calculo_dre_previsto(date_trunc('month', current_date)::date);
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_empresas()
as
$$
declare
	x record;
begin 
	for x in select seq, nome from imp_empresas loop 
		insert into dim_empresas 
		(seq, razao_social)
		values
		(x.seq, x.nome);
	end loop;

	-- processo específico: atribuir os demais dados das empresas
	update dim_empresas set cnpj = '07.402.540/0001.40', cidade = 'Criciúma', estado = 'SC' where seq = 1;
	update dim_empresas set cnpj = '016.102.099-23', cidade = 'Criciúma', estado = 'SC' where seq = 2;
	update dim_empresas set cnpj = '07.578.494/0001-35', cidade = 'Criciúma', estado = 'SC' where seq = 3;

	commit;	
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_clientes() as
$$
declare
	x record;
	vInscricao text;	
begin
	for x in select * from imp_clientes loop
		if(x.tipo_documento = 'CPF') then
			vInscricao = lpad(x.cpfcnpj, 11, '0');
			vInscricao = substr(vInscricao, 1, 3) || '.' ||substr(vInscricao, 4, 3) ||'.'||substr(vInscricao, 7, 3) ||'-'||substr(vInscricao, 10, 2) ;
		else
			vInscricao = lpad(x.cpfcnpj, 14, '0');
			vInscricao = substr(vInscricao, 1, 2) || '.' ||substr(vInscricao, 3, 3) ||'.'||substr(vInscricao, 6, 3) ||'/'||substr(vInscricao, 9, 4)||'-'|| substr(vInscricao, 13, 2);
		end if;
	
		insert into dim_clientes 
		(seq, razao_social, cpf_cnpj, email)
		values
		(x.seq, x.razao_social, vInscricao, x.email1);
	end loop;
	
	commit;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_contas()
as
$$
declare
	x record;
begin 
	for x in select seq, tipo_conta, banco, conta, seq_empresa from imp_contas where banco <> 'Santander' loop 
		insert into dim_contas  
		(seq, tipo, nome_banco, cod_conta, seq_empresa)
		values
		(x.seq, x.tipo_conta, x.banco, x.conta, x.seq_empresa);
	end loop;

	-- processo específico: atribuir os saldos iniciais
	update dim_contas set saldo_inicial = 1093.73, data_inicio_saldo = '2023-01-01' where cod_conta = '7402-0';
	update dim_contas set saldo_inicial = 176.85, data_inicio_saldo = '2023-01-01' where cod_conta = '191-4';
	update dim_contas set saldo_inicial = 206.64, data_inicio_saldo = '2023-01-01' where cod_conta = '75784-5';
	update dim_contas set saldo_inicial = 480.80, data_inicio_saldo = '2023-01-01' where cod_conta = '20404-8';
	update dim_contas set saldo_inicial = 49.72, data_inicio_saldo = '2023-01-01' where cod_conta = '218-0';
	update dim_contas set saldo_inicial = 160.24, data_inicio_saldo = '2023-01-01' where cod_conta = '20165-8';
	update dim_contas set saldo_inicial = 96240.82, data_inicio_saldo = '2023-01-01' where cod_conta = 'APL 7402-0';
	update dim_contas set saldo_inicial = 0, data_inicio_saldo = '2023-01-01' where cod_conta = 'APL 75784-5';
	update dim_contas set saldo_inicial = 0, data_inicio_saldo = '2023-01-01' where cod_conta = 'APL 20404-8';
	update dim_contas set saldo_inicial = 0, data_inicio_saldo = '2023-01-01' where cod_conta = 'APL 218-0';
	update dim_contas set saldo_inicial = 0, data_inicio_saldo = '2023-01-01' where cod_conta = 'APL 191-4 Flex';
	update dim_contas set saldo_inicial = 28.87, data_inicio_saldo = '2023-01-01' where cod_conta = 'COFRE';
	update dim_contas set saldo_inicial = 0, data_inicio_saldo = '2023-01-01' where cod_conta = 'Carteira';
	update dim_contas set saldo_inicial = 0, data_inicio_saldo = '2023-01-01' where cod_conta = '20165-8 Poupança';

	commit;	
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_contas_contabeis()
as
$$
declare
	x record;
	y record;
begin 
	for x in select c.seq, c.codigo , c.nome , c.receita_despesa , c.seq_agrupadora , a.nome as nome_agrupadora  
				from imp_contas_contabeis_cred c full join imp_contas_agrupadoras a 
				on a.seq = c.seq_agrupadora  loop 
		insert into dim_contas_ctb_credito 
		(seq, codigo, conta_credito, tipo, cod_agrupadora, conta_agrupadora)
		values
		(x.seq, x.codigo, x.nome, x.receita_despesa, x.seq_agrupadora, x.nome_agrupadora);
	end loop;
	
	commit;

	for y in select c.seq, c.codigo , c.nome , c.receita_despesa , c.seq_agrupadora , a.nome as nome_agrupadora  
				from imp_contas_contabeis_deb c full join imp_contas_agrupadoras a 
				on a.seq = c.seq_agrupadora  loop					
		insert into dim_contas_ctb_debito  
		(seq, codigo, conta_debito, tipo, cod_agrupadora, conta_agrupadora)
		values
		(y.seq, y.codigo, y.nome, y.receita_despesa, y.seq_agrupadora, y.nome_agrupadora);
	end loop;
	
	commit;

	-- processo específico: identificar as empresas para as contas de receita
	update dim_contas_ctb_credito set empresa = 1 where seq = 87;
	update dim_contas_ctb_credito set empresa = 2 where seq in (85, 86, 88);
	update dim_contas_ctb_credito set empresa = 3 where seq in (90, 92);

	update dim_contas_ctb_debito set empresa = 1 where seq = 87;
	update dim_contas_ctb_debito set empresa = 2 where seq in (85, 86, 88);
	update dim_contas_ctb_debito set empresa = 3 where seq in (90, 92);

	commit;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_agrupadoras() as 
$$
declare 
	x record;
begin 
	for x in select * from imp_contas_agrupadoras loop
		insert into dim_agrupadoras 
		(seq, nome, nivel, seq_superior, grupo, ordem)
		values
		(x.seq, x.nome, x.nivel, x.seq_superior, x.grupo, x.ordem);
	end loop;

	commit;	
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure public.pr_carga_notas_fiscais()
as
$$
declare
	x record;
begin
	for x in select ic2.seq_empresa , 'SERVIÇO' as tipo, numero_nf , '1' as serie_nf, 
					case 
						when icc.tipo_documento = 'CPF' then regexp_replace(lpad(icc.cpfcnpj::text, 11, '0'), '^([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})$', '\1.\2.\3-\4')
						else regexp_replace(lpad(icc.cpfcnpj::text, 14, '0'), '^([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})$', '\1.\2.\3/\4-\5')						
					end as cnpj_cliente, 
					icc.razao_social, 
					case 
						when ic.seq_tipo_contrato = 1 then 'Honorários contabilidade'
						when ic.seq_tipo_contrato = 2 then 'Honorários advocatícios'
						when ic.seq_tipo_contrato = 6 then 'Honorários contabilidade'
						else 'Serviços adicionais'
					end as descricao_item,		
					ic.valor as valor_unitario, 1 as quantidade, ic.situacao  
			from imp_cobrancas ic , imp_contas ic2 , imp_clientes icc , imp_tipo_contrato itc 
			where ic2.seq = ic.seq_conta and to_date(data_vencimento, 'DD/MM/YYYY') >= '2023-01-01' and situacao <> 'CANCELADA'  and icc.seq = ic.seq_cliente and itc.seq = ic.seq_tipo_contrato 
			order by ic.seq
	loop 
		insert into dim_nota_fiscal 
		(seq_empresa, tipo, numero_nf, serie_nf, cnpj_cliente, razao_social, descricao_item, valor_unitario, quantidade, situacao)
		values
		(x.seq_empresa, x.tipo, x.numero_nf, x.serie_nf, x.cnpj_cliente, x.razao_social, x.descricao_item, x.valor_unitario, x.quantidade, x.situacao);
	end loop;
	
	commit;
end;
$$ 
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure public.pr_carga_fato_faturamento(iTipo text)
as
$$
declare
	x record;
	cRecebimentos record;
begin
	if(iTipo = 'R') then
		-- CONTAS A RECEBER
		for x in select ic.seq, seq_empresa, dnf.numero_nf, 
						sum(dnf.valor_unitario * dnf.quantidade) as valor_nf, 0 as valor_icms, 0 as valor_ipi, 0 as valor_pis, 0 as valor_cofins, 0 as valor_iss, 
						case 
							when dnf.tipo = 'ENTRADA' then 'PAGAR'
							else 'RECEBER'
						end as tipo_duplicata,
						ic.seq as numero_duplicata, to_date(ic.data_emissao,'DD/MM/YYYY') as data_emissao , to_date(ic.data_vencimento, 'DD/MM/YYYY') as data_vencimento , sum(ic.valor) as valor, sum(ic.valor_juros) as juros, 0 as desconto, ic.situacao ,
						ic.seq_cliente
				from dim_nota_fiscal dnf , imp_cobrancas ic 
				where dnf.numero_nf = ic.numero_nf 
				and (dnf.numero_nf is not null and dnf.numero_nf <> '')
				group by seq_empresa , dnf.numero_nf , ic.seq, ic.data_emissao , ic.data_vencimento, dnf.tipo, ic.situacao, ic.seq_cliente
				order by ic.seq 
		loop 
			insert into fato_faturamento 
			(seq, seq_empresa, numero_nf, valor_nf, valor_icms, valor_ipi, valor_pis, valor_cofins, valor_iss, tipo_duplicata, numero_duplicata, data_emissao, data_vencimento, valor, juros, desconto, situacao, seq_cliente)
			values
			(x.seq, x.seq_empresa, x.numero_nf, x.valor_nf, x.valor_icms, x.valor_ipi, x.valor_pis, x.valor_cofins, x.valor_iss, x.tipo_duplicata, x.numero_duplicata, x.data_emissao, x.data_vencimento, x.valor, x.juros, x.desconto, x.situacao, x.seq_cliente);
		end loop;
	
		commit;
	
		update fato_faturamento set situacao = 'Atrasada' where data_vencimento < current_date and situacao <> 'Recebida';
	
		commit;
	
	else
		-- CONTAS A PAGAR ?
		-- módulo de COMPRAS
		null;
	end if;

	for cRecebimentos in select ff2.seq , ff.historico , ff2.data_vencimento , ff."data" as recebimento , ff2.situacao  from public.fato_financeiro ff , public.fato_faturamento ff2 where ff2.seq_empresa = ff.seq_empresa and ff2.seq = ff.seq_faturamento and ff.previsao = 'R' loop 
		update fato_faturamento set data_recebimento = cRecebimentos.recebimento where seq = cRecebimentos.seq;
	end loop;
	
	commit;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace function fn_tipo_movimento(iSeqTransf integer, ivalorEntrada numeric, iValorSaida numeric, iTipoEntrada integer, iSeqConta numeric) returns text
as
$$
declare
	vTipo text;
	vTipoConta text;
	cConta CURSOR (iConta numeric) FOR SELECT tipo FROM dim_contas WHERE seq = iConta;
begin
	if(iSeqTransf is not null) then
		if(iValorSaida > 0 ) then
			vTipo = 'Transferência (-)';
		else
			vTipo = 'Transferência (+)';
		end if;
	else
		if(iTipoEntrada is not null) then
			open  cConta(iSeqConta);
			fetch cConta into vTipoConta;
			close cConta;
		
			if(vTipoConta = 'Aplicação') then
				vTipo = 'Aporte/Rendimento';
			else
				vTipo = 'Recebimento';
			end if;
		else
			vTipo = 'Pagamento';
		end if;
	end if;

	return vTipo;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_fato_financeiro() as
$$
declare
	x record;
begin
	for x in select im.seq, ic.seq_empresa , seq_cobranca as seq_faturamento , 
				case 
					when im.valor_entrada > 0 then 'C'
					else 'D'
				end as categoria ,
				to_date(im."data", 'DD/MM/YYYY') as data,
				im.seq_conta , im.valor_entrada as valor_credito, im.valor_saida as valor_debito, historico ,
				fn_tipo_movimento(im.seq_transferencia::integer, im.valor_entrada, im.valor_saida, im.seq_tipo_entrada::integer, im.seq_conta) as tipo_movimento,		
				im.conta_debito as seq_conta_debito , im.conta_credito as seq_conta_credito , im.previsao , im.seq_transferencia 		
		from	imp_movimentos im , imp_contas ic 
		where 	im.seq_conta  = ic.seq
		and 	to_date(im."data", 'DD/MM/YYYY') >= '2023-01-01'
	loop 
		insert into fato_financeiro 
		(seq, seq_empresa, seq_faturamento, categoria, data, seq_conta, valor_credito, valor_debito, historico, tipo_movimento, seq_conta_debito, seq_conta_credito, previsao)
		values
		(x.seq, x.seq_empresa, x.seq_faturamento, x.categoria, x.data, x.seq_conta, x.valor_credito, x.valor_debito, x.historico, x.tipo_movimento, x.seq_conta_debito, x.seq_conta_credito, x.previsao);
	end loop;

	commit;
	
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_carga_saldos() as
$$
declare
	x record;
	y record;
	nSaldoInicial numeric;
	dDataSaldo date;
	nSaldoEncontrado text;
	vSaldoAtual text;
begin
	nSaldoInicial = 0;
	nSaldoEncontrado = 'N';
	vSaldoAtual = 'N';

	for x in select * from dim_contas order by seq_empresa, seq loop
		dDataSaldo = x.data_inicio_saldo;
		nSaldoInicial = x.saldo_inicial;
	
		while dDataSaldo <= current_date loop			
			if(to_char(dDataSaldo, 'D') not in ('7','1')) then
				if(dDataSaldo = current_date) then
					vSaldoAtual = 'S';
				end if;
				
				for y in select seq_empresa , seq_conta , sum(valor_credito) - sum(abs(valor_debito)) as variacao from fato_financeiro ff where seq_empresa = x.seq_empresa and seq_conta = x.seq and data = dDataSaldo and previsao = 'R' group by seq_empresa , seq_conta order by 1, 2 loop 			
					insert into aux_saldos_contas 
					(seq_conta, data, saldo_inicial, saldo_final, saldo_atual)
					values
					(y.seq_conta, dDataSaldo, nSaldoInicial, nSaldoInicial + y.variacao, vSaldoAtual);
				
					nSaldoInicial = nSaldoInicial + y.variacao;
					nSaldoEncontrado = 'S';
					vSaldoAtual = 'N';
				end loop;
				
				if(nSaldoEncontrado = 'N') then
					insert into aux_saldos_contas 
					(seq_conta, data, saldo_inicial, saldo_final, saldo_Atual)
					values
					(x.seq, dDataSaldo, nSaldoInicial, nSaldoInicial, vSaldoAtual);
					vSaldoAtual = 'N';
				else
					nSaldoEncontrado = 'N';
					vSaldoAtual = 'N';	
				end if;
			end if;			
		
			dDataSaldo = dDataSaldo + interval '1 day';
		end loop;
	
		nSaldoInicial = 0;
	end loop;
	
	commit;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_calculo_dre(iPeriodo date) as 
$$
declare 
	cEstrutura record;
	cEmpresas record;
	cAnaliticas record;
	cDRE record;

	vResultado varchar;
	vAgrupadora varchar;
	vAnalitica varchar;

	nValor numeric;
	nSoma numeric;
begin
	delete from fato_apuracao_dre fad where periodo = iPeriodo;
	commit;

	nSoma = 0;

	-- primeiro passo: obter os lançamentos de DESPESA nas analíticas
	for cEstrutura in select * from aux_estrutura_dre where operacao in ('-', '=') order by ordem loop
		for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop
			for cAnaliticas in select (sum(valor_credito) + sum(valor_debito))*-1 as valor from fato_financeiro where date_trunc('month', data) = date_trunc('month', iPeriodo) and previsao = 'R' and seq_conta_debito = cEstrutura.codigo and seq_empresa = cEmpresas.seq loop
				if(cEstrutura.operacao = '=') then
					/* resultado */
					vResultado = cEstrutura.item;
					vAnalitica = '';
					vAgrupadora = '';
				else
					if(cEstrutura.operacao = '') then
						/* agrupadora */ 
						vResultado = '';
						vAnalitica = '';
						vAgrupadora = cEstrutura.item;
					else
						/* analitica*/
						vResultado = '';
						vAnalitica = cEstrutura.item;
						vAgrupadora = '';
					end if;
				end if;
			
				if (cAnaliticas.valor is null) then
					nValor = 0;
				else
					nValor = cAnaliticas.valor;
				end if;
			
				insert into fato_apuracao_dre 
				(empresa, periodo, codigo_conta, resultado, agrupadora, analitica, valor, operacao, ordem)
				values
				(cEmpresas.seq, iPeriodo, cEstrutura.codigo, vResultado, vAgrupadora, vAnalitica, nValor, cEstrutura.operacao, cEstrutura.ordem);
			end loop;			
		end loop;
	end loop;
	--
	-- segundo passo: obter os lançamentos de RECEITA nas analíticas (contas de débito passam a ser as EMPRESAS)	
	for cEstrutura in select * from aux_estrutura_dre where operacao in ('+') order by ordem loop
		for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop
			-- receita das empresas ou outras receitas (p.ex.: rendimentos de aplicações financeiras)
			for cAnaliticas in select (sum(valor_credito) + sum(valor_debito)) as valor from fato_financeiro where date_trunc('month', data) = date_trunc('month', iPeriodo) and previsao = 'R' and (seq_conta_credito = cEstrutura.codigo or seq_conta_debito = cEstrutura.codigo) and seq_empresa = cEmpresas.seq loop
				if (cAnaliticas.valor is null) then
					nValor = 0;
				else
					nValor = cAnaliticas.valor;
				end if;

				insert into fato_apuracao_dre 
				(empresa, periodo, codigo_conta, resultado, agrupadora, analitica, valor, operacao, ordem)
				values
				(cEmpresas.seq, iPeriodo, cEstrutura.codigo, null, null, cEstrutura.item, nValor, cEstrutura.operacao, cEstrutura.ordem);
			end loop;		
		end loop;	
	end loop;
	--
	-- terceiro passo: totalizar as agrupadoras
	for cEstrutura in select * from aux_estrutura_dre where operacao = '0' order by ordem loop 
		for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop	
			for cAnaliticas in select sum(valor) as total from fato_apuracao_dre where empresa = cEmpresas.seq and codigo_conta in (select seq from dim_contas_ctb_debito where cod_agrupadora::integer = cEstrutura.codigo) loop 
				insert into fato_apuracao_dre 
				(empresa, periodo, codigo_conta, resultado, agrupadora, analitica, valor, operacao, ordem)
				values
				(cEmpresas.seq, iPeriodo, cEstrutura.codigo, null, cEstrutura.item, null, cAnaliticas.total, cEstrutura.operacao, cEstrutura.ordem);
			end loop;			
		end loop;		
	end loop;
	--
	nSoma = 0;
	--
	-- quarto passo: calcular as contas de resultado
	-- começando da primeira linha, soma-se (ou diminui-se) o valor até encontrar uma conta de resultado (operacao '=')
	for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop
		nSoma = 0;
	
		for cDRE in select * from fato_apuracao_dre where periodo = iPeriodo and empresa = cEmpresas.seq order by empresa, ordem loop
			if (cDRE.operacao = '=') then
				/* encontrou uma conta de resultado - atualiza o valor */
				update fato_apuracao_dre 
				set		valor = nSoma
				where 	periodo = iPeriodo
				and 	codigo_conta = cDRE.codigo_conta
				and 	empresa = cDRE.empresa
				and 	operacao = cDRE.operacao
				and 	ordem = cDRE.ordem;
			else
				if (cDRE.operacao in ('+', '-')) then
					nSoma = nSoma + cDRE.valor;
				else
					nSoma = nSoma;
				end if;
			end if;
		end loop;
	end loop;

	commit;	
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure pr_calculo_dre_previsto(iPeriodo date) as 
$$
declare 
	cEstrutura record;
	cEmpresas record;
	cAnaliticas record;
	cDRE record;

	vResultado varchar;
	vAgrupadora varchar;
	vAnalitica varchar;

	nValor numeric;
	nSoma numeric;
begin
	delete from fato_apuracao_dre fad where periodo = iPeriodo and previsto = 'S';
	commit;

	nSoma = 0;

	-- primeiro passo: obter os lançamentos de DESPESA nas analíticas
	for cEstrutura in select * from aux_estrutura_dre where operacao in ('-', '=') order by ordem loop
		for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop
			for cAnaliticas in select (sum(valor_credito) + sum(valor_debito))*-1 as valor from fato_financeiro where date_trunc('month', data) = date_trunc('month', iPeriodo) and previsao = 'P' and seq_conta_debito = cEstrutura.codigo and seq_empresa = cEmpresas.seq loop
				if(cEstrutura.operacao = '=') then
					/* resultado */
					vResultado = cEstrutura.item;
					vAnalitica = '';
					vAgrupadora = '';
				else
					if(cEstrutura.operacao = '') then
						/* agrupadora */ 
						vResultado = '';
						vAnalitica = '';
						vAgrupadora = cEstrutura.item;
					else
						/* analitica*/
						vResultado = '';
						vAnalitica = cEstrutura.item;
						vAgrupadora = '';
					end if;
				end if;
			
				if (cAnaliticas.valor is null) then
					nValor = 0;
				else
					nValor = cAnaliticas.valor;
				end if;
			
				insert into fato_apuracao_dre 
				(empresa, periodo, codigo_conta, resultado, agrupadora, analitica, valor, operacao, ordem, previsto)
				values
				(cEmpresas.seq, iPeriodo, cEstrutura.codigo, vResultado, vAgrupadora, vAnalitica, nValor, cEstrutura.operacao, cEstrutura.ordem, 'S');
			end loop;			
		end loop;
	end loop;
	--
	-- segundo passo: obter os lançamentos de RECEITA nas analíticas (contas de débito passam a ser as EMPRESAS)	
	for cEstrutura in select * from aux_estrutura_dre where operacao in ('+') order by ordem loop
		for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop
			-- receita das empresas ou outras receitas (p.ex.: rendimentos de aplicações financeiras)
			for cAnaliticas in select (sum(valor_credito) + sum(valor_debito)) as valor from fato_financeiro where date_trunc('month', data) = date_trunc('month', iPeriodo) and previsao = 'P' and (seq_conta_credito = cEstrutura.codigo or seq_conta_debito = cEstrutura.codigo) and seq_empresa = cEmpresas.seq loop
				if (cAnaliticas.valor is null) then
					nValor = 0;
				else
					nValor = cAnaliticas.valor;
				end if;

				insert into fato_apuracao_dre 
				(empresa, periodo, codigo_conta, resultado, agrupadora, analitica, valor, operacao, ordem, previsto)
				values
				(cEmpresas.seq, iPeriodo, cEstrutura.codigo, null, null, cEstrutura.item, nValor, cEstrutura.operacao, cEstrutura.ordem, 'S');
			end loop;		
		end loop;	
	end loop;
	--
	-- terceiro passo: totalizar as agrupadoras
	for cEstrutura in select * from aux_estrutura_dre where operacao = '0' order by ordem loop 
		for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop	
			for cAnaliticas in select sum(valor) as total from fato_apuracao_dre where empresa = cEmpresas.seq and codigo_conta in (select seq from dim_contas_ctb_debito where cod_agrupadora::integer = cEstrutura.codigo) loop 
				insert into fato_apuracao_dre 
				(empresa, periodo, codigo_conta, resultado, agrupadora, analitica, valor, operacao, ordem, previsto)
				values
				(cEmpresas.seq, iPeriodo, cEstrutura.codigo, null, cEstrutura.item, null, cAnaliticas.total, cEstrutura.operacao, cEstrutura.ordem, 'S');
			end loop;			
		end loop;		
	end loop;
	--
	nSoma = 0;
	--
	-- quarto passo: calcular as contas de resultado
	-- começando da primeira linha, soma-se (ou diminui-se) o valor até encontrar uma conta de resultado (operacao '=')
	for cEmpresas in select * from dim_empresas where seq in (1, 2, 3) loop
		nSoma = 0;
	
		for cDRE in select * from fato_apuracao_dre where periodo = iPeriodo and empresa = cEmpresas.seq order by empresa, ordem loop
			if (cDRE.operacao = '=') then
				/* encontrou uma conta de resultado - atualiza o valor */
				update fato_apuracao_dre 
				set		valor = nSoma
				where 	periodo = iPeriodo
				and 	codigo_conta = cDRE.codigo_conta
				and 	empresa = cDRE.empresa
				and 	operacao = cDRE.operacao
				and 	ordem = cDRE.ordem
				and 	previsto = 'S';
			else
				if (cDRE.operacao in ('+', '-')) then
					nSoma = nSoma + cDRE.valor;
				else
					nSoma = nSoma;
				end if;
			end if;
		end loop;
	end loop;

	commit;	
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

create or replace procedure public.pr_carga_pedidos() as
$$
declare
	x record;
begin
	for x in select ip.seq , icc."data" as data_cotacao , ip.data_pedido , icc.seq_fornecedor , icc.nome_fornecedor , iip.seq_item , null as codigo_item , iip.descricao_item , iip.valor_unitario , iip.quantidade , iip.desconto , null as unidade_medida 
				from imp_pedidos ip , imp_itens_pedidos iip , imp_compras_cotacao icc  
				where ip.seq = iip.seq_pedido 
				and icc.seq_cotacao = ip.seq_cotacao
	loop 
		insert into dim_pedidos 
		(seq , data_cotacao , data_pedido ,seq_fornecedor ,nome_fornecedor , seq_item ,codigo_item , descricao_item , valor_unitario , quantidade , unidade_medida, desconto_item )
		values
		(x.seq , x.data_cotacao , x.data_pedido , x.seq_fornecedor , x.nome_fornecedor , x.seq_item , x.codigo_item , x.descricao_item , x.valor_unitario , x.quantidade , x.unidade_medida, x.desconto);
	end loop;

	commit;
end;
$$
language plpgsql;

-----------------------------------------------------------------------------------------------------------------

call pr_carga_dw();

-----------------------------------------------------------------------------------------------------------------
 
