#!/bin/bash -e
# custom idp installer for Shibboleth IdP version 3.2.1
#

set -e

INSTALLDIR=/opt/shibboleth-idp
if [ -d $INSTALLDIR ]; then
	echo "$INSTALLDIR already exists."
	echo
	read -p "Do you want to reinstall the IdP: (y/n)" ANS
	if ["$ANS" == 'y'];then
		rm -rf /opt/shibboleth-idp
	else

		exit 1;
	fi
fi
#### download the Shibboleth identity provider
curl -LO http://shibboleth.net/downloads/identity-provider/3.2.1/shibboleth-identity-provider-3.2.1.tar.gz
tar -xvzf shibboleth-identity-provider-3.2.1.tar.gz
cd shibboleth-identity-provider-3.2.1/bin	
while ["$ANS" != "y"]; do
	DFLT = hops.io
	read -p "Please enter the name of your home organization [$DFLT]: " ADJDFLT
	ADJDFLT=${ADJDFLT:-$DFLT}
	DFLT = idp.$ADJDFLT
	read -p "Please specify the service name for your IdP [ADJDFLT]: " SVCNAME
	SVCNAME=${SVCNAME:-$DFLT}

	-Didp.relying.party.present= \
		-Didp.src.dir=. \
		-Didp.target.dir=$INSTALLDIR \
		-Didp.merge.properties=temp.properties \
		-Didp.sealer.password=$(cut -d " " -f3 <credentials.properties) \
		-Didp.keystore.password= \
		-Didp.conf.filemode=644 \
		-Didp.host.name=$SVCNAME \
		-Didp.scope=$ADJDFLT
	echo
	cat<<-EOM
	Proceed with the installation using the following parameters?

	Service name:			$SVCNAME
	Home organization name:		$ADJDFLT
	Installation directory: 	$INSTALLDIR

	EOM

	read -p "Enter 'y' to continue:  " ANS
	echo
done

# generate a password for client-side encryption
echo "idp.sealer.password = $(openssl rand -base64 12)" >credentials.properties
chmod 0600 credentials.properties

# preconfigure settings for a typical sics deployment
cat >temp.properties <<EOF
idp.additionalProperties= /conf/ldap.properties, /conf/saml-nameid.properties, /conf/services.properties, /conf/credentials.properties
idp.sealer.storePassword= %{idp.sealer.password}
idp.sealer.keyPassword= %{idp.sealer.password}
idp.signing.key= %{idp.home}/credentials/idp.key
idp.signing.cert= %{idp.home}/credentials/idp.crt
idp.encryption.key= %{idp.home}/credentials/idp.key
idp.encryption.cert= %{idp.home}/credentials/idp.crt
idp.entityID= https://$SVCNAME/idp/shibboleth
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
./install.sh \


	mv credentials.properties $INSTALLDIR/conf

echo -e "\nCreating self-signed certificate..."
bin/keygen.sh --lifetime 3 \
	--certfile $INSTALLDIR/credentials/idp.crt \
	--keyfile $INSTALLDIR/credentials/idp.key \
	--hostname $SVCNAME \
	--uriAltName https://$SVCNAME/idp/shibboleth
echo ...done
chmod 600 $INSTALLDIR/credentials/idp.key

# adapt owner of key file and directories
getent passwd tomcat7 >/dev/null && TCUSER=tomcat7 || TCUSER=tomcat
chown $TCUSER $INSTALLDIR/credentials/{idp.key,sealer.*}
chown $TCUSER $INSTALLDIR/{metadata,logs}
chown $TCUSER $INSTALLDIR/conf/credentials.properties

echo
echo "Done ! ..."
#END
