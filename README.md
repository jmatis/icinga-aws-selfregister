# icinga-aws-selfregister
this will contain my shell scripts that use aws command line tool to selfregister ec2 instances and elb loadballancers into icinga monitoring server. It presumes you have relevant hostgroups configured in icinga

this is not intended as final product but as an inspiration if somebody is interested. 

<pre>
Usage: 
cat /etc/crontab
*/5 * * * * root /git/icinga-aws-selfregister/icinga-selfregister.sh
2 * * * * root /git/icinga-aws-selfregister/icinga-selfregister-loadbalancers.sh
</pre>

