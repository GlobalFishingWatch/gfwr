

## This creates a local file with data!
res <- gfw_bulk_report(
  name = "fixed-infra-Chile-2020-2025", ## User define name por the report!
  dataset = "public-fixed-infrastructure-data:v1.1",
  format = "CSV",
  region_dataset = "public-eez-areas", ## We should try to test with a User Defines AOI
  region_id = 8465, #Chile -- #8466 #Argentina
  filters = c(
    "label = 'oil'",  #Oprtion are (oil, wind, unknown)
    "structure_start_date between '2020-01-01' and '2027-01-01'"
  ),
  out_dir = "data/gfw_bulk", #The data is saved in this directory
  quiet = FALSE,
  print_request = TRUE
)

#res$paths$csv
df <- read.csv(res$paths$csv)#, nrows = 5)
View(df)
