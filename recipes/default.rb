#
# Cookbook Name:: hops_shibboleth
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#



bash "download_extract_shibboleth" do
    user "root"
    code <<-EOF

EOF
#  not_if { ::File.exists?( "#{node.shibboleth}/.." ) }
end
