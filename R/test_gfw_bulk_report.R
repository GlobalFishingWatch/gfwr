

## This creates a local file with data!
res <- gfw_bulk_report(
  name = "fixed-infra-argentina-oil-2020-2025",
  dataset = "public-fixed-infrastructure-data:v1.1",
  format = "CSV",
  region_dataset = "public-eez-areas",
  region_id = 8465, #Chile -- #8466 #Argentina
  filters = c(
    "label = 'oil'",
    "structure_start_date between '2020-01-01' and '2025-01-01'"
  ),
  out_dir = "data/gfw_bulk",
  quiet = FALSE,
  print_request = TRUE
)

res$paths$csv
df_head <- read.csv(res$paths$csv, nrows = 5)
print(df_head)
