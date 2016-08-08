name             'hops_shibboleth'
maintainer       'Jim Dowling'
maintainer_email 'jdowling@kth.se'
license          'Apache v2.0'
description      'Installs/Configures hops_shibboleth'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'


%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

depends 'apache2'
depends 'tomcat'
depends 'shibboleth_idp"'
depends 'shibboleth_sp"'

recipe  "hops_shibboleth::install", "Installs binaries"

recipe  "hops_shibboleth::default", "base install"

recipe  "hops_shibboleth::idp", "shibboleth idp"

recipe  "hops_shibboleth::sp", "shibbloeth sp"

