# Function to get API endpoint name for identity search

Function to get API endpoint name for identity search

## Usage

``` r
gfw_identity_endpoint(dataset_type, search_type, ids, ...)
```

## Arguments

- dataset_type:

  Type of identity dataset to get API dataset name for. It can be a
  vector with any combination of "support_vessel", "carrier_vessel" or
  "fishing_vessel"

- search_type:

  Type of vessel search to perform. Can be "search" or "id". "advanced"
  is no longer in use as of gfwr 2.0.0 and basic and advanced options
  can be accessed with parameters query and where

- ids:

  optional, a vector with vessel ids

- ...:

  Other arguments that would depend on the dataset type.
