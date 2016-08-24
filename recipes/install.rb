include_recipe "apache2"




bash "download_extract_shibboleth" do
    user "root"
    code <<-EOF

  wget ....
  tar zxf ....
  mkdir ...
  mv ...



EOF
#  not_if { ::File.exists?( "#{node.shibboleth}/.." ) }
end
