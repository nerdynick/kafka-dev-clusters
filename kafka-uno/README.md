# Kafka Uno

Kafka Uno is a Simple Single Node Kafka Cluster with TLS for External/Client Connections.

To get started, run `setup.sh` to generate all the needed TLS Keys, Certs, and Keystores.
Followed by modifying the `compose.yml` to suite your environment.
See comments within `compose.yml` for more details.

By default and common CA is create with 3 Certs, 1 for the Kafka Broker to use and 2 additional Certs for Kafka Clients to use.
One of the client certs will not have key encryption, to allow clients that don't support this to work. 
However the PKCS12 file will as it's a requirement. All client certs and PKCS12 stores will use the same password.