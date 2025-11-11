# test_shape exists and is a valid sf object

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["geom_type", "bbox", "crs"]
        }
      },
      "value": [
        {
          "type": "integer",
          "attributes": {
            "levels": {
              "type": "character",
              "attributes": {},
              "value": ["GEOMETRY", "POINT", "LINESTRING", "POLYGON", "MULTIPOINT", "MULTILINESTRING", "MULTIPOLYGON", "GEOMETRYCOLLECTION", "CIRCULARSTRING", "COMPOUNDCURVE", "CURVEPOLYGON", "MULTICURVE", "MULTISURFACE", "CURVE", "SURFACE", "POLYHEDRALSURFACE", "TIN", "TRIANGLE"]
            },
            "class": {
              "type": "character",
              "attributes": {},
              "value": ["factor"]
            }
          },
          "value": [7]
        },
        {
          "type": "double",
          "attributes": {
            "class": {
              "type": "character",
              "attributes": {},
              "value": ["bbox"]
            },
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["xmin", "ymin", "xmax", "ymax"]
            },
            "crs": {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["input", "wkt"]
                },
                "class": {
                  "type": "character",
                  "attributes": {},
                  "value": ["crs"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["4326"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["GEOGCS[\"WGS 84\",\n      DATUM[\"WGS_1984\",\n        SPHEROID[\"WGS 84\",6378137,298.257223563,\n          AUTHORITY[\"EPSG\",\"7030\"]],\n        AUTHORITY[\"EPSG\",\"6326\"]],\n      PRIMEM[\"Greenwich\",0,\n        AUTHORITY[\"EPSG\",\"8901\"]],\n      UNIT[\"degree\",0.0174532925199433,\n        AUTHORITY[\"EPSG\",\"9122\"]],\n      AXIS[\"Latitude\",NORTH],\n      AXIS[\"Longitude\",EAST],\n    AUTHORITY[\"EPSG\",\"4326\"]]"]
                }
              ]
            }
          },
          "value": [56.74815493, 0, 70, 21.79798885]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["input", "wkt"]
            },
            "class": {
              "type": "character",
              "attributes": {},
              "value": ["crs"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["4326"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["GEOGCS[\"WGS 84\",\n      DATUM[\"WGS_1984\",\n        SPHEROID[\"WGS 84\",6378137,298.257223563,\n          AUTHORITY[\"EPSG\",\"7030\"]],\n        AUTHORITY[\"EPSG\",\"6326\"]],\n      PRIMEM[\"Greenwich\",0,\n        AUTHORITY[\"EPSG\",\"8901\"]],\n      UNIT[\"degree\",0.0174532925199433,\n        AUTHORITY[\"EPSG\",\"9122\"]],\n      AXIS[\"Latitude\",NORTH],\n      AXIS[\"Longitude\",EAST],\n    AUTHORITY[\"EPSG\",\"4326\"]]"]
            }
          ]
        }
      ]
    }

# marine_regions dataset exists and has expected structure

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["nrows", "ncols", "colnames", "sample"]
        }
      },
      "value": [
        {
          "type": "integer",
          "attributes": {},
          "value": [285]
        },
        {
          "type": "integer",
          "attributes": {},
          "value": [5]
        },
        {
          "type": "character",
          "attributes": {},
          "value": ["iso", "name", "MRGID", "GEONAME", "POL_TYPE"]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["iso", "name", "MRGID", "GEONAME", "POL_TYPE"]
            },
            "row.names": {
              "type": "integer",
              "attributes": {},
              "value": [1, 2, 3]
            },
            "class": {
              "type": "character",
              "attributes": {},
              "value": ["tbl_df", "tbl", "data.frame"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["ASM", "SHN", "COK"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["American Samoa", "Ascension", "Cook Islands"]
            },
            {
              "type": "double",
              "attributes": {},
              "value": [8444, 8379, 8446]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["United States Exclusive Economic Zone (American Samoa)", "British Exclusive Economic Zone (Ascension)", "New Zealand Exclusive Economic Zone (Cook Islands)"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["200NM", "200NM", "200NM"]
            }
          ]
        }
      ]
    }

