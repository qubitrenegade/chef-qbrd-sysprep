# habichef_demo/habitat/plan.sh
if [ -z ${CHEF_POLICYFILE+x} ]; then
  policy_name="base"
else
  policy_name="${CHEF_POLICYFILE}"
fi

scaffold_policy_name="${policy_name}"
pkg_name="qbrd-sysprep"
pkg_origin="qbrd"
pkg_version="0.1.0"
pkg_maintainer="QubitRenegade"
pkg_description="The Chef ${pkg_name}-${scaffold_policy_name} Policy"
pkg_upstream_url="http://chef.io"
pkg_scaffolding="chef/scaffolding-chef-infra"
pkg_svc_user="root"
pkg_svc_group="root"
