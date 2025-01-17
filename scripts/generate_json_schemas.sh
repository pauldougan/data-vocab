#!/usr/bin/env bash
set -e

#
# Generates JSON Schema files from LinkML schemas.
#
# Prerequisites:
# - Python 3
# - Poetry
#

# format: <linkml schema file>,<linkml class>,<json schema file>
LINKML_ITEMS=(
  "credentials.yaml,AuthorizationRequestClass,AuthorizationRequest.json"
  "credentials.yaml,CoreIdentityJWTClass,CoreIdentityJWT.json"
  "lifeEvents.yaml,DeathRegisteredJWTClass,DeathRegisteredJWT.json",
  "lifeEvents.yaml,DeathRegistrationUpdatedJWTClass,DeathRegistrationUpdatedJWT.json"
  "document.yaml,DrivingPermitDetailsClass,DrivingPermit.json"
  "document.yaml,IdCardDetailsClass,IdCard.json"
  "identityCheckCredential.yaml,IdentityCheckCredentialClass,IdentityCheckCredential.json"
  "credentials.yaml,IdentityCheckCredentialJWTClass,IdentityCheckCredentialJWT.json"
  "credentials.yaml,IssuerAuthorizationRequestClass,IssuerAuthorizationRequest.json"
  "name.yaml,NameClass,Name.json"
  "credentials.yaml,OpenIDConnectAuthenticationRequestClass,OpenIDConnectAuthenticationRequest.json"
  "document.yaml,PassportDetailsClass,PassportDetails.json"
  "address.yaml,PostalAddressClass,PostalAddress.json"
  "document.yaml,ResidencePermitDetailsClass,ResidencePermit.json"
  "securityCheckCredential.yaml,SecurityCheckCredentialClass,SecurityCheckCredential.json"
  "document.yaml,SocialSecurityRecordDetailsClass,SocialSecurityRecord.json"
  "document.yaml,BankAccountDetailsClass,BankAccount.json"
)

ROOT_DIR="$( git rev-parse --show-toplevel )"
JSON_SCHEMA_DIR="${ROOT_DIR}/v1/json-schemas"
LINKML_SCHEMA_DIR="${ROOT_DIR}/v1/linkml-schemas"

rm -f "${JSON_SCHEMA_DIR}/*.json"

cp $JSON_SCHEMA_DIR/index.md.template $JSON_SCHEMA_DIR/index.md

for LINKML_ITEM in "${LINKML_ITEMS[@]}"; do
  ITEM_DETAILS=(${LINKML_ITEM//,/ })
  LINKML_SCHEMA="${ITEM_DETAILS[0]}"
  LINKML_CLASS="${ITEM_DETAILS[1]}"
  JSON_SCHEMA="${ITEM_DETAILS[2]}"
  echo -e "\nWriting JSON schema for ${LINKML_CLASS} to ${JSON_SCHEMA}"

  poetry run gen-json-schema --closed --no-metadata -t "${LINKML_CLASS}" \
    "${LINKML_SCHEMA_DIR}/${LINKML_SCHEMA}" > "${JSON_SCHEMA_DIR}/${JSON_SCHEMA}"
  echo "| [$JSON_SCHEMA]($JSON_SCHEMA) | [$LINKML_CLASS](../classes/$LINKML_CLASS) |" >> $JSON_SCHEMA_DIR/index.md
  poetry run python ./scripts/check_schema_see_also.py  "${LINKML_SCHEMA_DIR}/${LINKML_SCHEMA}" $LINKML_CLASS ../json-schemas/$JSON_SCHEMA
done
