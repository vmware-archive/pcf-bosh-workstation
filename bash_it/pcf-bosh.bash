alias fw="fly -t wings"
alias fwl="fw login -n system-team-pcf-bosh-pcf-bosh-1-2688"

function sp(){
  pushd "$HOME/workspace/ci" > /dev/null
    lpass sync

    fly -t wings sp -p pcf-bosh -c pipelines/pcf-bosh.yml -l <(lpass show --notes 5986431050471091932) \
        --var env_name=ol-smokey \
        --var set_to_tag_filter_to_lock_cf_deployment=tag_filter \
        --var p-ert-branch=1.9

    fly -t wings sp -p pcf-bosh-floating -c pipelines/pcf-bosh.yml -l <(lpass show --notes 5986431050471091932) \
        --var env_name=monte-nuovo \
        --var set_to_tag_filter_to_lock_cf_deployment=ignoreme \
        --var p-ert-branch=master
  popd > /dev/null
}

function bosh_with_env() {
    env_name="$1"

    shift

    yaml="$(gsutil cat gs://pcf-bosh-ci/\"$env_name\"-bosh-creds.yml)"
    creds_json="$(echo "$yaml" | "$HOME/workspace/ci/scripts/yaml2json")"
    uaa_client_secret="$(echo "$creds_json" | jq -r .ci_secret)"

    ca_cert_file="$(mktemp)"
    ca_cert_contents="$(echo "$creds_json" | jq -r .director_ssl.ca > "$ca_cert_file")"

    bosh -e director.$env_name.gcp.pcf-bosh.cf-app.com --client=ci --client-secret=$uaa_client_secret --ca-cert="$ca_cert_file" $*
}

function bsmokey() {
    bosh_with_env ol-smokey $*
}

function bmonte() {
    bosh_with_env monte-nuovo $*
}

function env_cf_password() {
    local environment_name=$1

    gsutil cat gs://pcf-bosh-ci/\"$env_name\"-cf-creds.yml | \
    grep uaa_scim_users_admin_password | \
    awk '{print $2}'
}

function smokeypass() {
    env_cf_password ol-smokey
}

function montepass() {
    env_cf_password monte-nuovo
}
