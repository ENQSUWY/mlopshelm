# mlopsctl

## Installation


---

### Stage 1 - user-created cryptography

Create PKI (assisted by mlopsctl).

#### Inputs

- prefix
- namespace
- spiffe "base" (needed by some PKI client certs)
- OIDC client openid (not kub) secrets

#### Outputs

- mTLS PKI pem files


---

### Stage 2 - deployments

Install ambassador and the deployer service account.

#### Components

- ambassador
- deployer service account

#### Inputs

- deployer_kubernetes_cluster_server
- deployer_namespace
- base64_driverless_license_key
- base64_ca_certificate
- base64_fetcher_tls_client_certificate
- base64_fetcher_tls_client_key

#### Outputs

- base64_deployer_kubernetes_certificate_authority_data
- deployer_kubernetes_token

#### Created Kubernetes Secrets

- {prefix}-ca
- {prefix}-driverless-license
- {prefix}-fetcher-tls-client
  

---

### Stage 3 - state

Install and configure holders of state.

#### Components

- grafana persistent volume
- influx persistent volume
- storage persistent volume

#### Inputs

#### Outputs

- grafana pvc name
- influx pvc name
- storage pvc name


---

### Stage 4 - third party services

Install third-party services.

#### Components

- grafana
- influxdb
- postgres (optionally outside the kub cluster)

#### Inputs

- grafana_admin_username
- grafana_admin_password
- postgres_hostname
- postgres_dbname
- postgres_username
- postgres_password

#### Outputs

- grafana_api_key

#### Secrets

- {prefix}-postgres-storage (storage database connection string)


---

### Stage 5 - mlops application services

Install MLOps services.

#### Components

- api-gateway
- deployer
- drift detection
- ingestion
- storage
- storage-web

#### Inputs

- cookie_auth_secret
- cookie_encrypt_secret

#### Outputs
