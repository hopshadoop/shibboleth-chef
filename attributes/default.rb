#include_attribute "shibboleth_idp"
#include_attribute "shibboleth_sp"


node.default.java.jdk_version                               = 7
node.default['tomcat-all'][:user]                           = "tomcat"
node.default['tomcat-all'][:group]                          = "tomcat"

default.shibboleth.sp.entityid                              = "https://hops.io/shibboleth"
default.shibboleth.idp.entityid                             = "https://saml.sys.kth.se/idp/shibboleth"

default.shibboleth.idp.dlft                                 = "hops.io"
default.shibboleth.idp.svcname                              = "idp"

default.shibboleth.idp.version                              = "3.2.1"

default.shibboleth.idp.dir                                  = "/opt"

default.shibboleth.idp.url                                  = "http://shibboleth.net/downloads/identity-provider/#{node.shibboleth.idp.version}/shibboleth-identity-provider-#{node.shibboleth.idp.version}.tar.gz"
