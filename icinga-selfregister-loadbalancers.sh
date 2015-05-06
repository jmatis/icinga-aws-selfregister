#!/bin/bash

/bin/aws elb describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS | awk '{print $6" "$2}' > loadbalancer-instances.txt

restart=0
if [ -f instances-old.txt ]; then
        diff loadbalancer-instances.txt loadbalancer-instances-old.txt > /dev/null 2>&1
        restart=$?
fi


if [ ${restart} -ne 0 ]; then
	rm -f /etc/icinga/balancers/*.cfg
	while read line
	do
		balancername=$(echo ${line} | awk '{print $1}')
		balancerdns=$(echo ${line} | awk '{print $2}')
		echo "define host{
	use                     linux-server
	host_name		${balancername}
	alias			${balancerdns}
	address			${balancerdns}
	hostgroups		load-balancer
	}" > /etc/icinga/balancers/${balancername}.cfg
	done < loadbalancer-instances.txt


#load-ballancer

	mv -f loadbalancer-instances.txt loadbalancer-instances-old.txt
	#service icinga reload
fi
