
#_______________________________________________________________________________
###################### Processamento Inicial dos Dados #########################
#_______________________________________________________________________________

#-------------------------------------------------------------------------------
#----------------------------------PARTE 01-------------------------------------
#-------------------------------------------------------------------------------

## Tratando os dados dos municípios e criando uma base de dados unificada 
## (Municipios e Estados) contalibizando a quantidade de casos, internações 
## e óbitos entre os anos de 2014 e 2024

# Carregando os pacotes necessários
library(tidyr)
library(dplyr)
library(readxl)
library(stringi)

# Carregando a base de casos
Casos_Dengue_Municipios_2014a2024 = read_excel("app_dengue/dados_dengue/dados_dengue_drive/Casos_Dengue_Municipios_2014a2024.xlsx", 
                                                col_types = c("numeric", "skip", "numeric", 
                                                              "numeric", "numeric", "numeric", 
                                                              "numeric", "numeric", "numeric", 
                                                              "numeric", "numeric", "numeric", 
                                                              "numeric"))

# Carregando a base de internações
Internacoes_Dengue_Municipios_2014a2024 = read_excel("app_dengue/dados_dengue/dados_dengue_drive/Internacoes_Dengue_Municipios_2014a2024.xlsx", 
                                                      col_types = c("numeric", "skip", "numeric", 
                                                                    "numeric", "numeric", "numeric", 
                                                                    "numeric", "numeric", "numeric", 
                                                                    "numeric", "numeric", "numeric", 
                                                                    "numeric"))

# Carregando a base de óbitos de 2014 a 2023
Obitos_Dengue_Municipios_2014a2023 = read_excel("app_dengue/dados_dengue/dados_dengue_drive/Obitos_Dengue_Municipios_2014a2023.xlsx", 
                                                 col_types = c("numeric", "text", "numeric", 
                                                               "numeric", "numeric", "numeric", 
                                                               "numeric", "numeric", "numeric", 
                                                               "numeric", "numeric", "numeric"))
# Removendo os municipios ignorados
Obitos_Dengue_Municipios_2014a2023 = Obitos_Dengue_Municipios_2014a2023 |> 
  filter(municipio != "IPIO IGNORADO - ES") |> 
  select(-municipio)

# Carregando a base de óbitos de 2024
Obitos_Dengue_Municipios_2024 = read_excel("app_dengue/dados_dengue/dados_dengue_datasus/Obitos_Dengue_Municipios_2024.xlsx", 
                                            col_types = c("numeric", "skip", "numeric"))

#-------------------------------------------------------------------------------
#----------------------------------PARTE 02-------------------------------------
#-------------------------------------------------------------------------------

# Juntando uma base com os 5.570 municípios a essas bases para que seja possível 
# unificá-las posteriormente e pivotá-las com a mesma quantidade de linhas.

# Carregando a base de municipios

## Nesse link você consegue baixar os dados dos municipios do IBGE que contém a
## informação sobre o código e nome de cada estado:
## url(https://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/divisao_territorial/2022/DTB_2022.zip)

# Carregando a base de dados de municipios do BR
municipios_br = read_delim("app_dengue/dados_municipios_ibge/RELATORIO_DTB_BRASIL_MUNICIPIO.csv", 
                           delim = ";",locale = locale(encoding = "UTF-8"))

# Filtrando apenas as colunas que temos interesse (nome dos estados e codigo do municipio)
municipios_br = municipios_br |> dplyr::select(UF,Nome_UF,`Código Município Completo`,Nome_Município) |> 
  dplyr::rename(cod_uf = UF, estado = Nome_UF, cod_munic = `Código Município Completo`, municipio = Nome_Município)

# Removendo o 7º dígito do código dos municípios para que não hava divergência
# quando nós juntarmos as duas bases
municipios_br$cod_munic = substr(municipios_br$cod_munic, 1, 6)

# Transformando o codigo dos municipios em formato numérico
municipios_br$cod_munic = as.numeric(municipios_br$cod_munic)

# Transformando os nomes dos estados e municipios em caixa alta e removendo os acentos
municipios_br$estado = toupper(municipios_br$estado)
municipios_br$estado = stri_trans_general(municipios_br$estado, "latin-ascii")
municipios_br$municipio = toupper(municipios_br$municipio)
municipios_br$municipio = stri_trans_general(municipios_br$municipio, "latin-ascii")

#-------------------------------------------------------------------------------
#----------------------------------PARTE 03-------------------------------------
#-------------------------------------------------------------------------------

# Juntando os codigos e nomes dos municipios e estados as 4 bases anteriores

# Base de casos
Casos_Dengue_Municipios_2014a2024 = municipios_br |> 
  full_join(Casos_Dengue_Municipios_2014a2024, by = "cod_munic")

# Base de internações
Internacoes_Dengue_Municipios_2014a2024 = municipios_br |> 
  full_join(Internacoes_Dengue_Municipios_2014a2024, by = "cod_munic")

## Aqui vamos juntar os obitos de 2024 com os de 2024 a 2023

# Base de óbitos de 2014 a 2023
Obitos_Dengue_Municipios_2014a2023 = municipios_br |> 
  full_join(Obitos_Dengue_Municipios_2014a2023, by = "cod_munic")
  
# Base de óbitos de 2024
Obitos_Dengue_Municipios_2024 = municipios_br |> 
  full_join(Obitos_Dengue_Municipios_2024, by = "cod_munic") |> 
  select(cod_munic,`2024`)
  
# Base de óbitos de 2044 a 2024
Obitos_Dengue_Municipios_2014a2024 = Obitos_Dengue_Municipios_2014a2023 |> 
  full_join(Obitos_Dengue_Municipios_2024, by = "cod_munic")

#-------------------------------------------------------------------------------
#----------------------------------PARTE 04-------------------------------------
#-------------------------------------------------------------------------------

## Transformando essas bases no formato tidy e pivotando as colunas dos anos

# Base de casos
Casos_Dengue_Municipios_2014a2024 = Casos_Dengue_Municipios_2014a2024 |>
  
  tidyr::pivot_longer(
    cols = starts_with("20"),      # Seleciona as colunas que começam com "20" (2014 a 2024)
    names_to = "ano",             # Nova coluna para os nomes das colunas originais (anos)
    values_to = "qtde_casos",     # Nova coluna para os valores das colunas pivotadas
    ) |> 
  
  dplyr::mutate(
    ano = as.numeric(ano), # Converte a coluna em numérico
    qtde_casos = replace_na(qtde_casos, 0)  # Substitui NAs por 0
    )

# Base de internações
Internacoes_Dengue_Municipios_2014a2024 = Internacoes_Dengue_Municipios_2014a2024 |>
    
  tidyr::pivot_longer(
    cols = starts_with("20"),      # Seleciona as colunas que começam com "20" (2014 a 2024)
    names_to = "ano",             # Nova coluna para os nomes das colunas originais (anos)
    values_to = "qtde_internacoes"     # Nova coluna para os valores das colunas pivotadas
    ) |>
  
  dplyr::mutate(
    ano = as.numeric(ano), # Converte a coluna em numérico
    qtde_internacoes = replace_na(qtde_internacoes, 0)  # Substitui NAs por 0
    )

# Base de óbitos 2014 a 2024
Obitos_Dengue_Municipios_2014a2024 = Obitos_Dengue_Municipios_2014a2024 |>
  
  tidyr::pivot_longer(
    cols = starts_with("20"),      # Seleciona as colunas que começam com "20" (2014 a 2024)
    names_to = "ano",             # Nova coluna para os nomes das colunas originais (anos)
    values_to = "qtde_obitos"     # Nova coluna para os valores das colunas pivotadas
    ) |> 
  
  dplyr::mutate(
    ano = as.numeric(ano), # Converte a coluna em numérico
    qtde_obitos = replace_na(qtde_obitos, 0)  # Substitui NAs por 0
    )

# Transformando as 3 bases acima em uma única base geral contendo todas as informações
# sobre a quantidade de casos, internacoes e obitos por dengue de 2014 a 2024
dados_dengue_brasil = Casos_Dengue_Municipios_2014a2024 |> 
  select(cod_munic, ano, qtde_casos) |> 
  full_join(Internacoes_Dengue_Municipios_2014a2024, by = c("cod_munic","ano")) |>
  select(cod_munic, ano, qtde_casos, qtde_internacoes) |> 
  full_join(Obitos_Dengue_Municipios_2014a2024, by = c("cod_munic","ano")) |> 
  relocate(cod_munic, .after = estado) |> 
  relocate(ano, .after = municipio) |> 
  relocate(qtde_casos, .after = ano) |> 
  relocate(qtde_internacoes, .after = qtde_casos)
  
# Salvando a base de dados geral em csv
write.csv(dados_dengue_brasil, file = "app_dengue/dados_dengue/dados_dengue_brasil.csv", row.names = FALSE)
