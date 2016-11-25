
tomcat_install 'sp' do
  version '8.0.36'
end

tomcat_service 'sp' do
  action :start
  env_vars [{ 'CATALINA_PID' => '/tmp/tomcat.pid' }]
end

filename =  File.basename(node.shibboleth.idp.url)
cached_package_filename = "/tmp/#{filename}"

remote_file cached_package do
  source shibboleth.idp.url
  mode 0755
  action :create
  owner node['tomcat-all'][:user]
  group node['tomcat-all'][:group]
end

shib_dir="shibboleth-identity-provider-#{node.shibboleth.idp.version}"

template "#{node.shibboleth.idp.dir}/#{shib_dir}" do
  source "temp.properties.erb"
  owner node['tomcat-all'][:user]
  group node['tomcat-all'][:group]
  mode 0751
end



bash "idp-stuff" do
  owner node['tomcat-all'][:user]
  group node['tomcat-all'][:group]
    code <<-EOF
    set -e

INSTALLDIR=#{node.shibboleth.idp.dir}
if [ -d $INSTALLDIR ]; then
   rm -rf #{node.shibboleth.idp.dir}/shibboleth-idp
fi

cd /tmp
tar -xvzf #{filename} -C #{node.shibboleth.idp.dir}
cd #{node.shibboleth.idp.dir}/#{shib_dir}

DFLT = "#{node.shibboleth.idp.dlft}"
ADJDFLT = "idp"
ADJDFLT=${ADJDFLT:-$DFLT}
DFLT = $ADJDFLT
SVCNAME = "#{node.shibboleth.idp.svcname}"
SVCNAME=${SVCNAME:-$DFLT}

PASSWORD=$(openssl rand -base64 12)
# generate a password for client-side encryption
echo "idp.sealer.password = $PASSWORD" > credentials.properties
chmod 0600 credentials.properties

# run the installer
./install.sh -noinput -Didp.relying.party.present= -Didp.src.dir=. -Didp.target.dir=$INSTALLDIR -Didp.merge.properties=temp.properties -Didp.sealer.password=$(cut -d " " -f3 <credentials.properties) \
		-Didp.keystore.password= -Didp.conf.filemode=644 -Didp.host.name=$SVCNAME -Didp.scope=$ADJDFLT

mv credentials.properties $INSTALLDIR/conf

bin/keygen.sh --lifetime 3 \
	--certfile $INSTALLDIR/credentials/idp.crt \
	--keyfile $INSTALLDIR/credentials/idp.key \
	--hostname $SVCNAME \
	--uriAltName https://$SVCNAME/idp/shibboleth

chmod 600 $INSTALLDIR/credentials/idp.key

# adapt owner of key file and directories

chown -R node['tomcat-all'][:user] $INSTALLDIR/credentials/{idp.key,sealer.*}
chown -R node['tomcat-all'][:user] $INSTALLDIR/{metadata,logs}
chown -R node['tomcat-all'][:user] $INSTALLDIR/conf/credentials.properties


EOF
end


