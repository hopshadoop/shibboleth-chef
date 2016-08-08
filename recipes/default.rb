#
# Cookbook Name:: hops_shibboleth
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_balancer"
include_recipe "apache2::mod_proxy_ajp"
