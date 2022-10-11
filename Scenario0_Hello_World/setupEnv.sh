#!/bin/bash

## Copyright (c) Microsoft. All rights reserved.
## Licensed under the MIT license. See LICENSE file in the project root for full license information.

function update_ca_certificate_resources()
{
    local cert_path="${1}"

    local full_cert_value=""
    while read -r line
    do
        [[ $line = ----* ]] && continue
        full_cert_value="${full_cert_value}${line}"
    done < $cert_path
    
    local escaped_full_cert_value=$(printf '%s\n' "$full_cert_value" | sed -e 's/[\/&]/\\&/g')

    for file in ${2}/Scenario*/resources/CAC_*
    do
        echo "Updating cert value in file: $file"
        sed -i "s/<<ca-cert-pem-content>>/${escaped_full_cert_value}/" "$file"
    done
}

# WARNING: do this only once
az cloud register --name Dogfood --endpoint-active-directory-resource-id  https://management.core.windows.net/ --endpoint-resource-manager https://api-dogfood.resources.windows-int.net/ --endpoint-active-directory  https://login.windows-ppe.net/ --endpoint-active-directory-graph-resource-id https://graph.ppe.windows.net/

az cloud set --name Dogfood
az login

az account set -s ${sub_id}

pushd ../cert-gen
./certGen.sh create_root_and_intermediate

# get cert info
#openssl x509 -noout -text -in "certs/pub-client.cert.pem"

# get cert thumbprint
#openssl x509 -in certs/pub-client.cert.pem -fingerprint -sha256 -nocert  | sed 's/://g'
popd

update_ca_certificate_resources "../cert-gen/certs/azure-mqtt-test-only.intermediate.cert.pem" ".."