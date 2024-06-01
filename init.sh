ES_ENDPOINT=http://localhost:9200
INDEX=articles

# Create index
curl -XPUT "${ES_ENDPOINT}/${INDEX}" -H 'Content-Type: application/json' --data-binary @mapping.json

# Bulk insert data
curl -H "Content-Type: application/json" -X POST "${ES_ENDPOINT}/${INDEX}/_bulk" --data-binary @bulk.json
