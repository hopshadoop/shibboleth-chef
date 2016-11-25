


tomcat_install 'sp' do
  version '8.0.36'
end

tomcat_service 'sp' do
  action :start
  env_vars [{ 'CATALINA_PID' => '/tmp/tomcat.pid' }]
end



bash "idp-stuff" do
    user "root"
    code <<-EOF
    set -e


INSTALLDIR=/opt/shibboleth-idp
if [ -d $INSTALLDIR ]; then
	echo "$INSTALLDIR already exists."
	rm -rf /opt/shibboleth-idp
fi
#### download the Shibboleth identity provider
cd /opt
curl -LO http://shibboleth.net/downloads/identity-provider/3.2.1/shibboleth-identity-provider-3.2.1.tar.gz
tar -xvzf shibboleth-identity-provider-3.2.1.tar.gz
cd shibboleth-identity-provider-3.2.1/bin	


DFLT = "#{node.shibboleth.idp.dlft}"
ADJDFLT = "idp"
ADJDFLT=${ADJDFLT:-$DFLT}
DFLT = $ADJDFLT
SVCNAME = "#{node.shibboleth.idp.svcname}"
SVCNAME=${SVCNAME:-$DFLT}

cd shibboleth-identity-provider-3.2.1
PASSWORD=$(openssl rand -base64 12)
# generate a password for client-side encryption
echo "idp.sealer.password = $PASSWORD" > credentials.properties
chmod 0600 credentials.properties

# preconfigure settings for a typical sics deployment
cat >temp.properties <<EOF
idp.additionalProperties= /conf/ldap.properties, /conf/saml-nameid.properties, /conf/services.properties, /conf/credentials.properties
idp.sealer.storePassword= $PASSWORD
idp.sealer.keyPassword= $PASSWORD
idp.signing.key= ${INSTALLDIR}/credentials/idp.key
idp.signing.cert= ${INSTALLDIR}/credentials/idp.crt
idp.encryption.key= ${INSTALLDIR}/credentials/idp.key
idp.encryption.cert= ${INSTALLDIR}/credentials/idp.crt
idp.entityID= https://${SVCNAME}/idp/shibboleth
idp.scope= $ADJDFLT
idp.consent.StorageService= shibboleth.JPAStorageService
idp.consent.userStorageKey= shibboleth.consent.AttributeConsentStorageKey
idp.consent.userStorageKeyAttribute= %{idp.persistentId.sourceAttribute}
idp.consent.allowGlobal= false
idp.consent.compareValues= true
idp.consent.maxStoredRecords= -1
idp.ui.fallbackLanguages= en,de,fr,se
idp.entityID.metadataFile=
EOF



# run the installer
./install.sh -noinput -Didp.relying.party.present= -Didp.src.dir=. -Didp.target.dir=$INSTALLDIR -Didp.merge.properties=temp.properties -Didp.sealer.password=$(cut -d " " -f3 <credentials.properties) \
		-Didp.keystore.password= -Didp.conf.filemode=644 -Didp.host.name=$SVCNAME -Didp.scope=$ADJDFLT


	mv credentials.properties $INSTALLDIR/conf

echo -e "\nCreating self-signed certificate..."
bin/keygen.sh --lifetime 3 \
	--certfile $INSTALLDIR/credentials/idp.crt \
	--keyfile $INSTALLDIR/credentials/idp.key \
	--hostname $SVCNAME \
	--uriAltName https://$SVCNAME/idp/shibboleth

chmod 600 $INSTALLDIR/credentials/idp.key

# adapt owner of key file and directories
getent passwd tomcat7 >/dev/null && TCUSER=tomcat7 || TCUSER=tomcat
chown $TCUSER $INSTALLDIR/credentials/{idp.key,sealer.*}
chown $TCUSER $INSTALLDIR/{metadata,logs}
chown $TCUSER $INSTALLDIR/conf/credentials.properties


EOF
end


