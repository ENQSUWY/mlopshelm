#!/usr/bin/env bash

set -eo pipefail
set -x

hn=$(curl ifconfig.me)
wait-for-service.sh "KEYCLOAK" "180" "https://keycloak2.52-190-40-228.h2o.sslip.io" "HTTP/1.1 200 OK"
KEYCLOAK_ADMIN_PASSWORD=$(kubectl get secret -n keycloak keycloak-secrets --template={{.data.password}} | base64 -d)
kcadm.sh config credentials --server "https://keycloak2.52-190-40-228.h2o.sslip.io/auth" --realm master --user admin --password "${KEYCLOAK_ADMIN_PASSWORD}"

#
# First-time install of mlops.  Create mlops keycloak entries.
#

REALM=Mop

kcadm.sh \
    create client-scopes \
    -r "${REALM}" \
    -o --fields=id \
    -f - << EOF
{
  "name" : "ai.h2o.storage",
  "protocol" : "openid-connect",
  "attributes" : {
    "include.in.token.scope" : "true",
    "display.on.consent.screen" : "true"
  }
}
EOF

kcadm.sh \
    create client-scopes \
    -r "${REALM}" \
    -o --fields=id \
    -f - << EOF
{
  "name" : "ai.h2o.deploy",
  "protocol" : "openid-connect",
  "attributes" : {
    "include.in.token.scope" : "true",
    "display.on.consent.screen" : "true"
  }
}
EOF

kcadm.sh \
    create client-scopes \
    -r "${REALM}" \
    -o --fields=id \
    -f - << EOF
{
  "name" : "ai.h2o.driverless",
  "protocol" : "openid-connect",
  "attributes" : {
    "include.in.token.scope" : "true",
    "display.on.consent.screen" : "true"
  }
}
EOF

DOMAIN="52-190-40-228.h2o.sslip.io"
PROTOCOL=https
kcadm.sh \
    create clients \
    -r ${REALM} \
    -o --fields=id \
    -f - << EOF
{
  "clientId" : "h2oai-storage-web",
  "rootUrl" : "",
  "adminUrl" : "",
  "surrogateAuthRequired" : false,
  "enabled" : true,
  "clientAuthenticatorType" : "client-secret",
  "redirectUris" : [ "${PROTOCOL}://ui.${DOMAIN}/*" ],
  "webOrigins" : [ "${PROTOCOL}://ui.${DOMAIN}" ],
  "notBefore" : 0,
  "bearerOnly" : false,
  "consentRequired" : false,
  "standardFlowEnabled" : true,
  "implicitFlowEnabled" : false,
  "directAccessGrantsEnabled" : false,
  "serviceAccountsEnabled" : false,
  "publicClient" : false,
  "frontchannelLogout" : true,
  "protocol" : "openid-connect",
  "attributes" : { },
  "authenticationFlowBindingOverrides" : { },
  "fullScopeAllowed" : true,
  "nodeReRegistrationTimeout" : -1,
  "defaultClientScopes" : [ "profile", "email" ],
  "optionalClientScopes" : [ "ai.h2o.deploy", "ai.h2o.storage" ],
  "access" : {
    "view" : true,
    "configure" : true,
    "manage" : true
  }
}
EOF

kcadm.sh \
    create clients \
    -r ${REALM} \
    -o --fields=id \
    -f - << EOF
{
  "clientId" : "h2oai-storage",
  "rootUrl" : "",
  "adminUrl" : "",
  "surrogateAuthRequired" : false,
  "enabled" : true,
  "clientAuthenticatorType" : "client-secret",
  "redirectUris" : [ ],
  "webOrigins" : [ ],
  "notBefore" : 0,
  "bearerOnly" : false,
  "consentRequired" : false,
  "standardFlowEnabled" : true,
  "implicitFlowEnabled" : false,
  "directAccessGrantsEnabled" : false,
  "serviceAccountsEnabled" : false,
  "publicClient" : false,
  "frontchannelLogout" : true,
  "protocol" : "openid-connect",
  "attributes" : { },
  "authenticationFlowBindingOverrides" : { },
  "fullScopeAllowed" : true,
  "nodeReRegistrationTimeout" : -1,
  "defaultClientScopes" : [ "profile", "email" ],
  "optionalClientScopes" : [ ],
  "access" : {
    "view" : true,
    "configure" : true,
    "manage" : true
  }
}
EOF

kcadm.sh \
    create clients \
    -r ${REALM} \
    -o --fields=id \
    -f - << EOF
{
  "clientId" : "h2oai-driverless",
  "rootUrl" : "",
  "adminUrl" : "",
  "surrogateAuthRequired" : false,
  "enabled" : true,
  "clientAuthenticatorType" : "client-secret",
  "redirectUris" : [ "${PROTOCOL}://driverless-01.${DOMAIN}/*" ],
  "webOrigins" : [ "${PROTOCOL}://driverless-01.${DOMAIN}" ],
  "notBefore" : 0,
  "bearerOnly" : false,
  "consentRequired" : false,
  "standardFlowEnabled" : true,
  "implicitFlowEnabled" : false,
  "directAccessGrantsEnabled" : false,
  "serviceAccountsEnabled" : false,
  "publicClient" : false,
  "frontchannelLogout" : true,
  "protocol" : "openid-connect",
  "attributes" : { },
  "authenticationFlowBindingOverrides" : { },
  "fullScopeAllowed" : true,
  "nodeReRegistrationTimeout" : -1,
  "defaultClientScopes" : [ "profile", "email" ],
  "optionalClientScopes" : [ "ai.h2o.storage" ],
  "access" : {
    "view" : true,
    "configure" : true,
    "manage" : true
  }
}
EOF

kcadm.sh \
    create clients \
    -r ${REALM} \
    -o --fields=id \
    -f - << EOF
{
  "clientId" : "h2oai-driverless-pkce",
  "rootUrl" : "",
  "adminUrl" : "",
  "surrogateAuthRequired" : false,
  "enabled" : true,
  "clientAuthenticatorType" : "client-secret",
  "redirectUris" : [ "${PROTOCOL}://driverless-01.${DOMAIN}/*" ],
  "webOrigins" : [ "${PROTOCOL}://driverless-01.${DOMAIN}" ],
  "notBefore" : 0,
  "bearerOnly" : false,
  "consentRequired" : false,
  "standardFlowEnabled" : true,
  "implicitFlowEnabled" : false,
  "directAccessGrantsEnabled" : false,
  "serviceAccountsEnabled" : false,
  "publicClient" : true,
  "frontchannelLogout" : true,
  "protocol" : "openid-connect",
  "attributes" : { },
  "authenticationFlowBindingOverrides" : { },
  "fullScopeAllowed" : true,
  "nodeReRegistrationTimeout" : -1,
  "defaultClientScopes" : [ "profile", "email" ],
  "optionalClientScopes" : [ "ai.h2o.storage" ],
  "access" : {
    "view" : true,
    "configure" : true,
    "manage" : true
  }
}
EOF
