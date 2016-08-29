#include_attribute "shibboleth_idp"
#include_attribute "shibboleth_sp"


node.default.java.jdk_version                               = 7
node.default['tomcat-all'][:user]                           = "tomcat"
node.default['tomcat-all'][:group]                          = "tomcat"

default.shibboleth.sp.entityid                              = "https://hops.io/shibboleth"
default.shibboleth.idp.entityid                             = "https://saml.sys.kth.se/idp/shibboleth"
