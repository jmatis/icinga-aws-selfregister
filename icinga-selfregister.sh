#!/bin/bash

/bin/aws ec2 describe-instances --query 'Reservations[*].Instances[*].[State.Name, InstanceId, PublicIpAddress, Platform, Tags[?Key==`Name`]| [0].Value ]' --output text | /bin/grep running  > instances.txt

restart=0
if [ -f instances-old.txt ]; then 
	diff instances.txt instances-old.txt > /dev/null 2>&1
	restart=$?
fi

if [ ${restart} -ne 0 ]; then

rm -f /etc/icinga/hosts/*.cfg

while read line
do
	# running i-6b9f20bd      50.16.120.205   windows astragalus
	# running i-b939ee51      54.157.112.125  None    proxy

	instanceid=$(echo ${line} | awk '{print $2}')
	publicip=$(echo ${line} | awk '{print $3}')
        publicdns=$(getent hosts ${publicip} | awk '{print $NF}')
	platform=$(echo ${line} | awk '{print $4}')
	instancename="$(echo ${line} | awk '{$1=$2=$3=$4=""; print}' | sed -e "s/ //g" )"

	case ${instancename} in 
	astragalus|astragalus-staging)
	echo "define host{
        use                     windows-server
        host_name               ${instancename}-${instanceid}
	alias			${publicdns}
	address			${publicdns}
	hostgroups		windows-servers
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
	;;
	proxy)
	echo "define host{
        use                     linux-server
	host_name		${instancename}-${instanceid}
	alias			${publicdns}
	address			${publicdns}
	hostgroups		linux-servers,proxy-servers
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
	;;
	vmsnagios)
	echo "define host{
	use			linux-server
	host_name		${instancename}-${instanceid}
	alias			${publicdns}
	address			${publicdns}
	hostgroups		linux-servers,nagios-servers
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
	;;
	access4-1|access4-2)
	echo "define host{
	use			linux-server
	host_name		${instancename}-${instanceid}
	alias			${publicdns}
	address			${publicdns}
	hostgroups		linux-servers,access4-servers,glassfish-servers-domain2,glassfish-servers-domain4,tomcat-servers
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
	;;
	vms-access-staging)
	echo "define host{
        use                     linux-server
        host_name               ${instancename}-${instanceid}
        alias                   ${publicdns}
        address                 ${publicdns}
        hostgroups              linux-servers,vms-access-servers,glassfish-servers-domain1,glassfish-servers-domain2,glassfish-servers-domain3,glassfish-servers-domain4,tomcat-servers
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
        ;;
	vms-access-dev)
	echo "define host{
        use                     linux-server
        host_name               ${instancename}-${instanceid}
        alias                   ${publicdns}
        address                 ${publicdns}
        hostgroups              linux-servers,vms-access-servers,glassfish-servers-domain1,glassfish-servers-domain2,glassfish-servers-domain3,tomcat-servers
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
        ;;
	vms-access1|vms-access2)
	echo "define host{
        use                     linux-server
        host_name               ${instancename}-${instanceid}
        alias                   ${publicdns}
        address                 ${publicdns}
        hostgroups              linux-servers,vms-access-servers,glassfish-servers-domain1,glassfish-servers-domain2
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
	;;
	*)
	echo "define host{
        use                     linux-server
	host_name		${instancename}-${instanceid}
	alias			${publicdns}
	address			${publicdns}
	hostgroups		selfregistered
	}" > /etc/icinga/hosts/${instancename}-${instanceid}.cfg
        ;;
	esac

done < instances.txt

service icinga reload

mv -f instances.txt instances-old.txt



fi
