curl -X PUT  http://127.0.0.1:9200/_ingest/pipeline/uint-pipeline  -H 'content-type:application/json'  -d '{
  "description": "zabbix-uint",
  "processors": [
    {
      "date_index_name": {
        "field": "clock",
        "date_formats": ["UNIX"],
        "index_name_prefix": "uint-",
        "date_rounding": "7d"
      }
    }
  ]
}'
curl -X PUT  http://127.0.0.1:9200/_ingest/pipeline/str-pipeline  -H 'content-type:application/json'  -d '{
  "description": "zabbix-str",
  "processors": [
    {
      "date_index_name": {
        "field": "clock",
        "date_formats": ["UNIX"],
        "index_name_prefix": "str-",
        "date_rounding": "7d"
      }
    }
  ]
}'
curl -X PUT  http://127.0.0.1:9200/_ingest/pipeline/log-pipeline  -H 'content-type:application/json'  -d '{
  "description": "zabbix-log",
  "processors": [
    {
      "date_index_name": {
        "field": "clock",
        "date_formats": ["UNIX"],
        "index_name_prefix": "log-",
        "date_rounding": "7d"
      }
    }
  ]
}'
curl -X PUT  http://127.0.0.1:9200/_ingest/pipeline/dbl-pipeline  -H 'content-type:application/json'  -d '{
  "description": "zabbix-dbl",
  "processors": [
    {
      "date_index_name": {
        "field": "clock",
        "date_formats": ["UNIX"],
        "index_name_prefix": "dbl-",
        "date_rounding": "7d"
      }
    }
  ]
}'
curl -X PUT  http://127.0.0.1:9200/_ingest/pipeline/text-pipeline  -H 'content-type:application/json'  -d '{
  "description": "zabbix-text",
  "processors": [
    {
      "date_index_name": {
        "field": "clock",
        "date_formats": ["UNIX"],
        "index_name_prefix": "text-",
        "date_rounding": "7d"
      }
    }
  ]
}'
