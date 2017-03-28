node.default.java.install_flavor = "oracle"
node.default.java.oracle.accept_oracle_download_terms = true
include_recipe "java"


include_recipe "apache2"

include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_proxy_balancer"
include_recipe "apache2::mod_proxy_ajp"


private_ip = my_private_ip()
public_ip = my_public_ip()


group node.hops_shibboleth.group do
  action :create
  not_if "getent group #{node.hops_shibboleth.group}"
end

user node.hops_shibboleth.user do
  home "/home/#{node.hops_shibboleth.user}"
  gid node.hops_shibboleth.group
  system true
  shell "/bin/bash"
  manage_home true
  action :create
  not_if "getent passwd #{node.hops_shibboleth.user}"
end


package "install apache shibboleth module" do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'httpd'

    # install shibboleth

    
  when 'ubuntu', 'debian'
    package_name 'libapache2-mod-shib2'

    template "/etc/shibboleth/shibboleth2.xml" do
      source "shibboleth2.xml.erb"
      owner node.hops_shibboleth.user
      group node.hops_shibboleth.group
      mode 0755
      variables({ :public_ip => public_ip })
    end

    template "/etc/apache2/sites-available/hops-default.conf" do
      source "hops-default.conf.erb"
      owner node.hops_shibboleth.user
      group node.hops_shibboleth.group
      mode 0755
      variables({ :public_ip => public_ip })
    end

    link "/etc/apache2/sites-enabled/hops-default.xml" do
      owner node.hops_shibboleth.user
      group node.hops_shibboleth.group
      to "/etc/apache2/sites-available/hops-default.xml" 
    end



  end
end



case node['platform']
when 'debian', 'ubuntu'
  node[:hops_shibboleth][:default][:private_ips].each_with_index do |ip, index| 
    hostsfile_entry "#{ip}" do
      hostname  "dn#{index}"
      action    :create
      unique    true
    end
  end

when 'redhat', 'centos', 'fedora'

  template "/etc/hosts" do
    source "hosts.erb"
    owner "root"
    group "root"
    mode 0644
  end

# Fix bug: https://github.com/mitchellh/vagrant/issues/8115    
bash "restart_network" do
    user "root"
    code <<-EOF
  /etc/init.d/network restart  
EOF
end

end
