#cloud-config
repo_update: true
repo_upgrade: all
packages:
- git
- mlocate
- telnet
- wget
- bind-utils
- epel-release
runcmd:
- wget  https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
- python /tmp/get-pip.py
- /bin/pip install awscli
- wget http://s3.amazonaws.com/ec2metadata/ec2-metadata -O /usr/bin/ec2-metadata
- chmod +x /usr/bin/ec2-metadata
- REGION=`ec2-metadata -z | awk '{print substr($2, 1, length($2)-1)}'`
- INSTANCE_ID=`ec2-metadata -i | awk '{print $2}'`
- IP_ADDRESS=`ec2-metadata -o | awk '{print $2}'`
- DOMAIN=`cat /etc/resolv.conf | grep search | awk '{print $2}'`
- aws configure set default.region $REGION
- aws configure set default.output text
- ENVIRONMENT="${environment}"
- ROLE="${role}"
- aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$ENVIRONMENT-$ROLE-$INSTANCE_ID
- FQDN=$ENVIRONMENT-$ROLE-$INSTANCE_ID.$DOMAIN
- hostname $FQDN
- sed -i "s/#compress/compress/g" /etc/logrotate.conf
- sed -i "s/HOSTNAME=localhost.localdomain/HOSTNAME=$FQDN/g" /etc/sysconfig/network
- echo "$IP_ADDRESS $FQDN" >> /etc/hosts
- aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$ENVIRONMENT-$ROLE-$INSTANCE_ID
