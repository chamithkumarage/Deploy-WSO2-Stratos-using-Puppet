#!/bin/bash

export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

keystore=/mnt/<%= server_ip %>/<%= service_dir %>/repository/resources/security/stratos-jar-sign.jks
keyalias=stratoslive
keypass='TdTXVW7mzxu3oqWaHYm2mEgxoX88hHCVKMJ7K1rp'
root=/mnt/<%= server_ip %>/<%= service_dir %>

for p in $root/repository/components/plugins $root/repository/components/lib $root/lib $root/lib/patches $root/lib/api $root/lib/xboot $root/bin $root/lib/xboot
do
	for i in `find -iname "*.jar"`
	do
		echo $i
		jarsigner -keystore $keystore -storepass $keypass $i $keyalias
	done
done

