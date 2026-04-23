# Kafka Dev Clusters

Collections of Docker Compose files and needed utility scripts for standing up simple Kafka Clusters for use in development and expirementation.
Unless otherwise stated, each setup uses the Apache Kafka provided docker images. 

# The Clusters/Envs/Collections

| Name.      | # of Clusters | # of Brokers/Cluster | Desc                                                                                |
| ---------- | ------------- | -------------------- | ----------------------------------------------------------------------------------- |
| Kafka Uno  | 1             | 1                    | A single node Kafka Cluster. Suited for local development of Kafka applications     |
| Kafka Tres | 1             | 3                    | A 3 node Kafka Cluster. Suited for local & remote development of Kafka applications |