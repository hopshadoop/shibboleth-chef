


tomcat_install 'sp' do
  version '8.0.36'
end

tomcat_service 'sp' do
  action :start
  env_vars [{ 'CATALINA_PID' => '/tmp/tomcat.pid' }]
end



#include_recipe "shibboleth_idp"

