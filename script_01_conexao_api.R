#_______________________________________________________________________________
############### Carregando e salvando os dados de dengue VIA API ###############
#_______________________________________________________________________________

# Carregando os pacotes necessários
library(httr)
library(jsonlite)

# Definindo chave da API
api_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyenZxZGJyZGxqc3Nud3l4YWh1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyODYwNDE3MSwiZXhwIjoyMDQ0MTgwMTcxfQ.PNUt50QDeZS36yl6BXNIUac920TfCBg1A3LOzTggny4"

# Fazendo a requisição GET da tabela geral
response = GET(
  url = "https://irzvqdbrdljssnwyxahu.supabase.co/rest/v1/dados_dengue_brasil",
  add_headers(
    `apikey` = api_key,
    `Authorization` = paste("Bearer", api_key),
    `Content-Type` = "application/json"
  )
)

# Verificando o status da resposta
if (status_code(response) == 200) {
  # Parsear o conteúdo JSON
  dados_dengue_municipios = fromJSON(content(response, "text"))
} else {
  print(paste("Erro na requisição:", status_code(response)))
}

# Salvando os dados em csv na pasta
write.csv(dados_dengue_municipios,file = "app_dengue/dados_dengue/dados_dengue_brasil_api.csv", row.names = FALSE)
