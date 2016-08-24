include_recipe "apache2"




include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_balancer"
include_recipe "apache2::mod_proxy_ajp"

