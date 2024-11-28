#_______________________________________________________________________________
##### Obtendo os dados geográficos e adicionando-os em duas novas tabelas ######
###### Essas tabelas serão usadas para a criação dos mapas no dashboard ########
#_______________________________________________________________________________

# Carregando os pacotes necessários
library(geobr)

# Obtendo dados geográficos dos estados e municípios
estados = read_state(year = 2020)
municipios = read_municipality(year = 2020)

# Criando código de 6 dígitos para os municípios
municipios$cod_munic = as.numeric(substr(municipios$code_muni, 1, 6))

# Selecionando apenas as colunas necessárias
municipios = municipios |> 
  dplyr::select(cod_munic, geom)

estados = estados |> 
  dplyr::select(code_state, geom) |> 
  dplyr::rename("cod_uf" = "code_state")

# Juntando os dados geográficos com as tabelas padronizadas atualizadas
dados_dengue_municipios_geo = dados_dengue_brasil |> 
  left_join(municipios, by = "cod_munic")

dados_dengue_estados_geo = estados |> 
  left_join(dados_dengue_brasil, by = "cod_uf")

# Salvando os dados em csv na pasta
# write_csv2(dados_dengue_municipios, file = "app_dengue/dados_dengue/dados_dengue_municipios_geo.csv")
# write.csv(dados_dengue_estados, file = "app_dengue/dados_dengue/dados_dengue_estados_geo.csv")

# Transformando os dataframes em um objeto sf
dados_dengue_estados_sf = st_as_sf(dados_dengue_estados_geo)
dados_dengue_municipios_sf = st_as_sf(dados_dengue_municipios_geo)

# Salvando o dataset em um arquivo shapefile
st_write(dados_dengue_estados_sf, "app_dengue/dados_dengue/dados_dengue_estados_geo.gpkg")
st_write(dados_dengue_municipios_sf, "app_dengue/dados_dengue/dados_dengue_municipios_geo.gpkg")
