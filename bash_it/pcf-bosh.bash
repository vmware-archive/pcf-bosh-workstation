alias fw="fly -t wings"
alias fwl="fw login -n system-team-pcf-bosh-pcf-bosh-1-2688"

function sp(){
  pushd "$HOME/workspace/pcf-bosh-ci" > /dev/null
    ./set-pipeline.sh
  popd > /dev/null
}
