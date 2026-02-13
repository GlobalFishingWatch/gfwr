# Transforms a vector to a named vector for httr2

Transforms a vector to a named vector for httr2

## Usage

``` r
vector_to_array(x, type = "vessel")
```

## Arguments

- x:

  The vector to transform

- type:

  The type of data to paste, will be "events", "datasets", or "vessel"
  depending on the context

## Value

A named vector in the format required by the API, with names followed by
a zero-indexed suffix (ex. datasets\\0\\)

## Examples

``` r
vector_to_array(x = 1, type = "vessel")
#> vessel[0] 
#>         1 
vector_to_array(x = "a", type = "vessel")
#> vessel[0] 
#>       "a" 
vector_to_array(x = c(1, 2), type = "dataset")
#> dataset[0] dataset[1] 
#>          1          2 
vector_to_array(x = c(1, 2, 3), type = "dataset")
#> dataset[0] dataset[1] dataset[2] 
#>          1          2          3 
vector_to_array(x = "fishing", type = "dataset")
#> dataset[0] 
#>  "fishing" 
vector_to_array(x = c("fishing", "port-visits"), type = "event")
#>      event[0]      event[1] 
#>     "fishing" "port-visits" 
```
