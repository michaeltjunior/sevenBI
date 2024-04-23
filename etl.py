import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import text
import sqlalchemy

def abreCursor(conexao):
    cur = conexao.cursor()
    return cur

def busca_tabela(engineOrigem, nomeTabela, engineDest, tabelaDestino):
    # este bloco de DELETE deve ser comentado para a carga inicial da base de importação do sistema de origem
    # após a importação,conferir quais campos tem que ser diferentes de TEXT(estacarga improta todos como TEXT)
    # a alternativa é criar todas as tabelas de importação manualmente na base do BI
    with engineDest.connect() as connectionDestino:
        connectionDestino.execute(text("delete from "+tabelaDestino))
        connectionDestino.commit()

    connectionOrigem = engineOrigem.raw_connection()
    cursorBanco = connectionOrigem.cursor()

    cursorBanco.execute("select column_name from information_schema.columns c where c.table_name = '"+nomeTabela+"' and table_schema = 'public' order by ordinal_position")
    colunas = pd.DataFrame(cursorBanco.fetchall())

    lista = colunas[0].values.tolist()

    cursorBanco.execute("select * from "+nomeTabela)
    conjunto = pd.DataFrame(cursorBanco.fetchall(), columns=lista)

    return conjunto

engine = create_engine("postgresql://postgres:wfassessoria@localhost:5432/postgres")
engineDestino = create_engine("postgresql://postgres:wfassessoria@localhost:5432/sevenbi")

busca_tabela(engine, "contas", engineDestino, "imp_contas").to_sql("imp_contas", engineDestino, if_exists="append")
busca_tabela(engine, "movimentos", engineDestino, "imp_movimentos").to_sql("imp_movimentos", engineDestino, if_exists="append")
busca_tabela(engine, "empresas", engineDestino, "imp_empresas").to_sql("imp_empresas", engineDestino, if_exists="append")
busca_tabela(engine, "contas_contabeis", engineDestino, "imp_contas_contabeis_deb").to_sql("imp_contas_contabeis_deb", engineDestino, if_exists="append")
busca_tabela(engine, "contas_contabeis", engineDestino, "imp_contas_contabeis_cred").to_sql("imp_contas_contabeis_cred", engineDestino, if_exists="append")
busca_tabela(engine, "contas_agrupadoras", engineDestino, "imp_contas_agrupadoras").to_sql("imp_contas_agrupadoras", engineDestino, if_exists="append")
busca_tabela(engine, "cobrancas", engineDestino, "imp_cobrancas").to_sql("imp_cobrancas", engineDestino, if_exists="append")
busca_tabela(engine, "tipo_contrato", engineDestino, "imp_tipo_contrato").to_sql("imp_tipo_contrato", engineDestino, if_exists="append")
busca_tabela(engine, "clientes", engineDestino, "imp_clientes").to_sql("imp_clientes", engineDestino, if_exists="append")

# importação da planilha de estrutura do DRE para o banco
# (** CONFIGURAR LOCAL **)
df_dre = pd.read_excel("Estrutura DRE oficial.xlsx")
df_dre = df_dre.fillna(0)

df_dre.to_sql('aux_estrutura_dre', engineDestino, if_exists='replace', 
    dtype={'index': sqlalchemy.types.INTEGER(), 
           'item': sqlalchemy.types.VARCHAR(length=255), 
           'mascara': sqlalchemy.types.VARCHAR(length=20), 
           'operacao': sqlalchemy.types.VARCHAR(length=2), 
           'codigo': sqlalchemy.types.INTEGER(),
           'ordem': sqlalchemy.types.INTEGER(),
           'categoria':sqlalchemy.types.VARCHAR(length=50)})