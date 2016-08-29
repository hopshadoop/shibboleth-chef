
node.default.java.install_flavor = "oracle"
node.default.java.oracle.accept_oracle_download_terms = true
include_recipe "java"

include_recipe "apache2"

include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_balancer"
include_recipe "apache2::mod_proxy_ajp"


private_ip = my_private_ip()
public_ip = my_public_ip()


package "install apache shibboleth module" do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'httpd'
  when 'ubuntu', 'debian'
    package_name 'libapache2-mod-shib2'
  end
end


file "/etc/shibboleth/shibboleth2.xml" do
  user "root"
  action :delete
end

template "/etc/shibboleth/shibboleth2.xml" do
  source "shibboleth2.xml.erb"
  owner "www-data"
  group "www-data"
  mode 0755
  variables({ :public_ip => public_ip })
end

template "/etc/apache2/sites-available/hops-default.xml" do
  source "hops-default.xml.erb"
  owner "www-data"
  group "www-data"
  mode 0755
  variables({ :public_ip => public_ip })
end

link "/etc/apache2/sites-enabled/hops-default.xml" do
  owner "www-data"
  group "www-data"
  to "/etc/apache2/sites-available/hops-default.xml" 
end

