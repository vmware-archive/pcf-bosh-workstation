alias fw="fly -t wings"
alias fwl="fw login -n system-team-pcf-bosh-pcf-bosh-1-2688"

function sp(){
  pushd "$HOME/workspace/ci" > /dev/null
    lpass sync

    fly -t wings sp -p pcf-bosh -c pipelines/pcf-bosh.yml -l <(lpass show --notes 5986431050471091932) \
        --var env_name=ol-smokey \
        --var set_to_tag_filter_to_lock_cf_deployment=tag_filter

    fly -t wings sp -p pcf-bosh-floating -c pipelines/pcf-bosh.yml -l <(lpass show --notes 5986431050471091932) \
        --var env_name=monte-nuovo \
        --var set_to_tag_filter_to_lock_cf_deployment=ignoreme
  popd > /dev/null
}
