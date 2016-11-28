#!/bin/bash -e
#
# Custom SP installer for Shibboleth
#

sudo su

# OS specific support.  $var _must_ be set to either true or false.

ubuntu=false;
centos=false;
ENTITY=hops.io
APACHE_LOG_DIR_UB=/var/log/apache2
APACHE_LOG_DIR_COS=/var/log/httpd

if [ -f /etc/debian_bersion ]; then
	OS=ubuntu
elif [ -f /etc/redhat-release ]; then
	OS=centos
elif [ -f /etc/lsb-release ]; then
	./etc/lsb-release
	OS=$DISTRIB_ID
fi
case "`$OS`" in
	ubuntu*) ubuntu=true ;;
centos*) centos=true ;;

# Ubuntu version
if $ubuntu ; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/sp.hops.io.key -out /etc/ssl/certs/sp.hops.io.crt
	apt-get install -y libapache2-mod-shib2
	#network 10.1.1.0
	sudo shibd -t
	apache2ctl configtest
	/etc/init.d/apache2 start
	/etc/init.d/apache2 restart
	network 10.1.1.0
	sed '1 a 10.1.1.11 sp.hops.io' /etc/hosts
	sed '2 a 10.1.1.10 idp.hops.io' /etc/hosts
	rm -rf /etc/shibboleth/shibboleth2.xml
	sed '0 a # set overall behavior' /etc/shibboleth/shibd.logger
	sed '1 a log4j.rootCategory=DEBUG, shibd_log, warn_log' /etc/shibboleth/shibd.logger
	echo "
	<SPConfig xmlns="urn:mace:shibboleth:2.0:native:sp:config"
	xmlns:conf="urn:mace:shibboleth:2.0:native:sp:config"
	xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
	xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"    
	xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
	clockSkew="180">

	<ApplicationDefaults entityID="https://sp.hops.io/shibboleth" 
	REMOTE_USER="eppn persistent-id targeted-id">

	<Sessions lifetime="28800" timeout="3600" relayState="ss:mem" 
	checkAddress="true" handlerSSL="false" cookieProps="https" 
	handlerURL="/Shibboleth.sso" idpHistory="false" idpHistoryDays="7"
	exportLocation="https://sp.hops.io/Shibboleth.sso/GetAssertion">

	<SessionInitiator type="Chaining" Location="/Login" isDefault="true" id="Login"
	entityID="https://idp.hops.io/idp/shibboleth">

	<SessionInitiator type="SAML2" template="bindingTemplate.html"/>
	<SessionInitiator type="Shib1"/>
	</SessionInitiator>

	<md:AssertionConsumerService Location="/SAML2/POST" index="1"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
	<md:AssertionConsumerService Location="/SAML2/POST-SimpleSign" index="2"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign"/>
	<md:AssertionConsumerService Location="/SAML2/Artifact" index="3"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>
	<md:AssertionConsumerService Location="/SAML2/ECP" index="4"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:PAOS"/>
	<md:AssertionConsumerService Location="/SAML/POST" index="5"
	Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post"/>
	<md:AssertionConsumerService Location="/SAML/Artifact" index="6"
	Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01"/>

	<LogoutInitiator type="Chaining" Location="/Logout">
	<LogoutInitiator type="SAML2" template="bindingTemplate.html"/>
	<LogoutInitiator type="Local"/>
	</LogoutInitiator>

	<md:SingleLogoutService Location="/SLO/SOAP"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>
	<md:SingleLogoutService Location="/SLO/Redirect" conf:template="bindingTemplate.html"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/>
	<md:SingleLogoutService Location="/SLO/POST" conf:template="bindingTemplate.html"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
	<md:SingleLogoutService Location="/SLO/Artifact" conf:template="bindingTemplate.html"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>

	<md:ManageNameIDService Location="/NIM/SOAP"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>
	<md:ManageNameIDService Location="/NIM/Redirect" conf:template="bindingTemplate.html"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/>
	<md:ManageNameIDService Location="/NIM/POST" conf:template="bindingTemplate.html"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>
	<md:ManageNameIDService Location="/NIM/Artifact" conf:template="bindingTemplate.html"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"/>


	<md:ArtifactResolutionService Location="/Artifact/SOAP" index="1"
	Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"/>

	<!-- Extension service that generates "approximate" metadata based on SP configuration. -->
	<Handler type="MetadataGenerator" Location="/Metadata" signing="false"/>

	<!-- Status reporting service. -->
	<Handler type="Status" Location="/Status" acl="127.0.0.1 ::1"/>

	<!-- Session diagnostic service. -->
	<Handler type="Session" Location="/Session" showAttributeValues="false"/>

	<!-- JSON feed of discovery information. -->
	<Handler type="DiscoveryFeed" Location="/DiscoFeed"/>

	<!-- Checks for required attribute(s) before login completes. -->
	<Handler type="AttributeChecker" Location="/AttrChecker" template="attrChecker.html"
	attributes="eppn" flushSession="true"/>

	<SSO entityID="https://sp.hops.io/idp/shibboleth">
	SAML2 SAML1
	</SSO>

	<!-- SAML and local-only logout. -->
	<Logout>SAML2 Local</Logout>

	<!-- Extension service that generates "approximate" metadata based on SP configuration. -->
	<Handler type="MetadataGenerator" Location="/Metadata" signing="true" https="true" http="false"/>

	</Sessions>

	<!--
	<Errors supportContact="root@localhost"
	helpLocation="/about.html"
	styleSheet="/shibboleth-sp/main.css"/>
	-->
	<!-- Example of remotely supplied batch of signed metadata. -->
	<MetadataProvider type="XML" uri="https://idp.hops.io/idp/profile/Metadata/SAML" 
	backingFilePath="federation-metadata.xml" reloadInterval="7200">
	<!--
	<MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
	<MetadataFilter type="Signature" certificate="fedsigner.pem"/>
	-->
	</MetadataProvider>
	<!-- TrustEngines run in order to evaluate peer keys and certificates. -->
	<TrustEngine type="ExplicitKey"/>
	<TrustEngine type="PKIX"/>

	<!-- Map to extract attributes from SAML assertions. -->
	<AttributeExtractor type="XML" validate="true" reloadChanges="false" path="attribute-map.xml"/>

	<!-- Extracts support information for IdP from its metadata. -->
	<AttributeExtractor type="Metadata" errorURL="errorURL" DisplayName="displayName"/>

	<!-- Use a SAML query if no attributes are supplied during SSO. -->
	<AttributeResolver type="Query" subjectMatch="true"/>

	<!-- Default filtering policy for recognized attributes, lets other data pass. -->
	<AttributeFilter type="XML" validate="true" path="attribute-policy.xml"/>

	<!-- Simple file-based resolver for using a single keypair. -->
	<CredentialResolver type="File" key="sp-key.pem" certificate="sp-cert.pem"/>

	<!--
	The default settings can be overridden by creating ApplicationOverride elements (see
	the https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApplicationOverride topic).
	Resource requests are mapped by web server commands, or the RequestMapper, to an
	applicationId setting.

	Example of a second application (for a second vhost) that has a different entityID.
	Resources on the vhost would map to an applicationId of "admin":
	-->
	<!--
	<ApplicationOverride id="admin" entityID="https://admin.example.org/shibboleth"/>
	-->
	</ApplicationDefaults>

	<!-- Policies that determine how to process and authenticate runtime messages. -->
	<SecurityPolicyProvider type="XML" validate="true" path="security-policy.xml"/>

	<!-- Low-level configuration about protocols and bindings available for use. -->
	<ProtocolProvider type="XML" validate="true" reloadChanges="false" path="protocols.xml"/>
	</SPConfig>

	" > /etc/shibboleth/shibboleth2.xml

	shib-keygen -h sp.hops.io -e https://sp.hops.io/shibboleth
	mkdir /var/www/html/secure
	sed /etc/apache2/apache2.conf
	sed -r -i '/<Directory //var//www//html//secure>\\AuthType Shibboleth\\ShibRequestSetting requireSession 1\\AuthName "Secret"\\AuthUserFile passwd\\Require valid-use\\<//Directory>' /etc/apache2/apache2.conf
	a2enmod shib2
	/etc/init.d/apache2 restart
	echo "
	<VirtualHost *:80>
	ServerAdmin webmaster@${ENTITY}
	DocumentRoot /var/www/html
	ServerName ${ENTITY}
	ErrorLog ${APACHE_LOG_DIR_UB}/error.log
	CustomLog ${APACHE_LOG_DIR_UB}/access.log combined
	<Location>
	AuthType shibboleth
	ShibRequire session on
	Require valid-user
	</Location>
	</VirtualHost>		
	">/etc/apache2/sites-enabled/sp.${ENTITY}.conf
fi

# CentOS version

if $centos ; then
	//TODO
fi


