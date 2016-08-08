include_attribute "shibboleth_idp"
include_attribute "shibboleth_sp"


node.default.java.jdk_version                          = 7
node.default['tomcat-all'][:user]                           = "tomcat"
node.default['tomcat-all'][:group]                          = "tomcat"
