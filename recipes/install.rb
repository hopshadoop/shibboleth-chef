
node.default.java.install_flavor = "oracle"
node.default.java.oracle.accept_oracle_download_terms = true
include_recipe "java"

include_recipe "apache2"

include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_balancer"
include_recipe "apache2::mod_proxy_ajp"

