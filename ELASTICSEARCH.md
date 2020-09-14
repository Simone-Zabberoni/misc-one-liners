# Elasticsearch API

## Cluster and nodes

Elasticsearch base informations:

```
curl --location --request GET 'localhost:9200/'
{
  "name": "yournode",
  "cluster_name": "yourcluster",
  "cluster_uuid": "hDd_hZecd34ggyyeYlwkLQ",
  "version": {
    "number": "5.6.8",
    "build_hash": "688ecce",
    "build_date": "2018-02-16T16:46:30.010Z",
    "build_snapshot": false,
    "lucene_version": "6.6.1"
  },
  "tagline": "You Know, for Search"
}
```

Cluster health (yellow for single node systems):

```
curl --location --request GET 'localhost:9200/_cluster/health'
{
    "cluster_name": "your-cluster-name",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 5366,
    "active_shards": 5366,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 0,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 100.0
}
```

Node information and setup:

```
curl --location --request GET 'localhost:9200/_nodes'

{
    "_nodes": {
        "total": 1,
        "successful": 1,
        "failed": 0
    },
    "cluster_name": "yourcluster",
    "nodes": {
        "p0j_Ms-ccdsc232sdcc": {
            "name": "yournode",
            "transport_address": "127.0.0.1:9300",
            "host": "127.0.0.1",
            "ip": "127.0.0.1",
            "version": "5.6.8",
            "build_hash": "688ecce",
            "total_indexing_buffer": 855506944,
    [CUT]

```

## Templates

Get current templates

```
curl --location --request GET 'localhost:9200/_template'
```

Change the default replica and shard number for all:

```
curl --location --request PUT 'localhost:9200/_template/all' \
--header 'Content-Type: text/plain' \
--data-raw '{
  "template": "*",
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```

Verify:

```
curl --location --request GET 'localhost:9200/_template/all'
{
    "all": {
        "order": 0,
        "template": "*",
        "settings": {
            "index": {
                "number_of_shards": "1",
                "number_of_replicas": "0"
            }
        },
        "mappings": {},
        "aliases": {}
    }
}
```

## Get all indices and the status (note: red when starting up)

```
curl --location --request GET 'localhost:9200/_cat/indices'
green  open access-logs-2019.11.06 dmGpJCquT2a_cJwxpzodWw 5 0  8968 0  8.5mb  8.5mb
green  open access-logs-2020.07.22 oRQxpvrtRDyAoV_39H75Fw 5 0  8143 0  7.2mb  7.2mb
green  open access-logs-2020.05.30 bJyuw44hRaeVp_Qw6dGjgw 5 0  4643 0  4.7mb  4.7mb
green  open access-logs-2019.12.18 Flqtro7GSA6PlOr3xxbZxA 5 0 13425 0 10.5mb 10.5mb
green  open access-logs-2020.06.17 OHo_JqKxT0y8GwhZOmXl4Q 5 0  7568 0  7.8mb  7.8mb
green  open access-logs-2020.04.26 rcuuj2vFR5ytVzpEiAh65Q 5 0  9278 0  8.9mb  8.9mb
green  open access-logs-2020.07.03 u-ulsMuDSe-GFPACWrutQA 5 0  7763 0    8mb    8mb
green  open access-logs-2019.10.17 Qt450eI0T1mK_XXOSxrKzA 5 0 12854 0 10.4mb 10.4mb
```

## Shards and replicas management

Current shards for a specific index:

```
curl --location --request GET 'localhost:9200/_cat/shards/access-logs-2019.12.07'

access-logs-2019.12.07 4 p STARTED    2093 1.3mb 127.0.0.1 your-node
access-logs-2019.12.07 4 r UNASSIGNED
access-logs-2019.12.07 1 p STARTED    2176 1.4mb 127.0.0.1 your-node
access-logs-2019.12.07 1 r UNASSIGNED
access-logs-2019.12.07 2 p STARTED    2123 1.4mb 127.0.0.1 your-node
access-logs-2019.12.07 2 r UNASSIGNED
access-logs-2019.12.07 3 p STARTED    2146 1.4mb 127.0.0.1 your-node
access-logs-2019.12.07 3 r UNASSIGNED
access-logs-2019.12.07 0 p STARTED    2036 1.3mb 127.0.0.1 your-node
access-logs-2019.12.07 0 r UNASSIGNED
```

Remove replica shards (unassigned, as it's a single node setup):

```
curl --location --request PUT 'localhost:9200/_template/all' \
--header 'Content-Type: text/plain' \
--data-raw '{
  "template": "*",
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```

**Note**: use `*` for multiple indexes: `localhost:9200/access-logs-*/_settings`

Check it:

```
curl --location --request GET 'localhost:9200/_cat/shards/access-logs-2019.12.07'

access-logs-2019.12.07 4 p STARTED 2093 1.3mb 127.0.0.1 your-node
access-logs-2019.12.07 1 p STARTED 2176 1.4mb 127.0.0.1 your-node
access-logs-2019.12.07 2 p STARTED 2123 1.4mb 127.0.0.1 your-node
access-logs-2019.12.07 3 p STARTED 2146 1.4mb 127.0.0.1 your-node
access-logs-2019.12.07 0 p STARTED 2036 1.3mb 127.0.0.1 your-node
```

## Tasks

Current pending tasks (sample with Curator running):

```
curl --location --request GET 'localhost:9200/_cat/pending_tasks'

7514 14.2s URGENT delete-index [[access-logs-2018.05.09/OyxcUtTVS1-WbGDex9yVIA], [access-logs-2018.12.18/auP52HlfRcOTzQP3DQ4tww], [access-logs-2018.09.16/YNv_wBarRGmiJ181exIoEA], [access-logs-2019.08.03/9llzxxGjR4KVH3SyQxIlWg], [access-logs-2018.10.15/iCXa2oM6Tyy5cG5lgPoMaQ], [access-logs-2018.07.03/OsNK6NmYTaSC6mWfPHsE9w], [access-logs-2017.10.27/Y-qB3laWSUqksekSSbCGlQ], [access-logs-2018.09.15/Q-yP0bcgQ_inqOrcZyGSlw], [access-logs-2017.10.26/KmhxEf-SQdeL6nLn9RZhTg], [access-logs-2019.03.30/kYTBbpN9T8-UsoeitWkmuA], [access-logs-2019.08.02/fji3wSdETzyTQWoSvXLo9w], [access-logs-2019.08.01/WlB1npEUSD63SwGrDTiuhw], [access-logs-2018.08.27/H0qIBab4QB-A-Xtk5zCCNw], [access-logs-2018.09.11/pxKhpFocSe-gyelItrAtAA], [access-logs-2019.02.12/lVytxJtYR_qHBZ7RxlCpQA], [access-logs-2018.09.10/hSdcgweIRuGQb6MZLDNQpQ]]
```
