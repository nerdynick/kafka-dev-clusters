#! /bin//bash

function join_sans {
    local SAN=""
    for domain in "${@}"; do
        if [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            SAN="${SAN},IP:${domain}"
        else
            SAN="${SAN},DNS:${domain}"
        fi
    done
    echo "${SAN#,}"
}

echo "======================================================="
echo "Creating Secrets & Data Directories"
echo "======================================================="

mkdir -p secrets
mkdir -p data

echo "======================================================="
echo "Fetching TLS Creation Script(s)"
echo "======================================================="

# We use a utility from https://github.com/nerdynick/keystore-scripts/ to generate our TLS certs.
# You can check out the repo for more info on how it works, but essentially it leverages OpenSSL under the hood to generate the certs.
rm -f Makefile.tls
wget -O Makefile.tls https://raw.githubusercontent.com/nerdynick/keystore-scripts/refs/heads/master/Makefile

echo "======================================================="
echo "Generating TLS Certificates"
echo "======================================================="

# General Info
read -p "Enter Subject Location Info (Space Separated: City, State ABV, Country ABV): " SUB_CITY SUB_STATE SUB_COUNTRY
SUBJECT_LOCAL="/L=${SUB_CITY}/ST=${SUB_STATE}/C=${SUB_COUNTRY}"

# CA Info
read -p "Enter CA Domains (Space Separated): " -a CA_DOMAINS
read -sp "Enter CA Password: " CA_PASSWORD
echo ""

export CA_PASSWORD="$CA_PASSWORD"
export CA_FILENAME_PREFIX="KafkaClusterCA"
export CA_SUBJECT="/CN=${CA_DOMAINS[0]}${SUBJECT_LOCAL}"
export CA_SANS=$(join_sans "${CA_DOMAINS[@]}")

# Kafka Broker Info
# We need the DNS Domains to setup the CN/SANs correctly.
# We also ask for IP Addresses for a similar reason but just in case you wish to connect via IP rather then full DNS
#    Usually this is because you are running a local deployment and don't want to setup fake DNS for it, but still want TLS.
read -p "Enter Kafka Broker Domains and/or IPs (space separated, including Bootstrap Addresses): " -a KAFKA_BROKERS
read -sp "Enter Kafka Broker TLS Password: " SERVER_PASSWORD
echo ""

SERVER_DOMAINS=("KafkaBroker" "${KAFKA_BROKERS[@]}")
export SERVER_PASSWORD="$SERVER_PASSWORD"
export SERVER_FILENAME_PREFIX="KafkaBroker"
export SERVER_SUBJECT="/CN=KafkaBroker${SUBJECT_LOCAL}"
export SERVER_SANS=$(join_sans "${KAFKA_BROKERS[@]}")

# Kafka Client Info
read -sp "Enter Kafka Client TLS Password: " CLIENT_PASSWORD
echo ""

CLIENT_DOMAINS=("KafkaClient" "${KAFKA_BROKERS[@]}")
export CLIENT_PASSWORD="$CLIENT_PASSWORD"
export CLIENT_FILENAME_PREFIX="KafkaClient"
export CLIENT_SUBJECT="/CN=KafkaClient${SUBJECT_LOCAL}"

# Run all the actually generating commands from the Makefile.tls Makefile
make -f Makefile.tls create-ca
make -f Makefile.tls create-server
make -f Makefile.tls create-client

# Generate a no encryption client cert as well.
# Since some tools (like kafkactl) require a client cert but does not support client certs with encryption enabled.
# NOTE: `kafkactl` doesn't support encrypted client keys due in part to Sarama, it's underlying Kafka Client Library.
export CLIENT_FILENAME_PREFIX="KafkaClientNoEnc"
make -f Makefile.tls create-client-noenc

echo "======================================================="
echo "Done Generating TLS Certificates"
echo "======================================================="
echo "======================================================="
echo "Setting up TLS Keystores, Truststores, and Secrets"
echo "======================================================="

cp output/KafkaClusterCA.p12 secrets/KafkaClusterCA.p12
cp output/KafkaBroker.p12 secrets/KafkaBroker.p12
cp output/KafkaClient.p12 secrets/KafkaClient.p12

echo $CA_PASSWORD > secrets/ca_password.txt
echo $SERVER_PASSWORD > secrets/server_password.txt
echo $CLIENT_PASSWORD > secrets/client_password.txt

echo "======================================================="
echo "Done Setting up TLS Keystores, Truststores, and Secrets"
echo "======================================================="
