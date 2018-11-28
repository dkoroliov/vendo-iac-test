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
- httpd
- php
- php-mysql
- mariadb
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
#- sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
- setsebool -P httpd_can_network_connect=1
- systemctl enable httpd
- systemctl start httpd

# Ansible
- yum install -y ansible
- wget  https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
- python /tmp/get-pip.py
- /bin/pip install awscli boto boto3
- /bin/pip install --upgrade jinja2

# phpMiniAdmin
- git clone https://github.com/osalabs/phpminiadmin.git /var/www/html/
- cp /var/www/html/samples/phpminiconfig.php /var/www/html/
- sed -i "s/'user'=>''.*$/'user'=>'${db_user}',/" /var/www/html/phpminiconfig.php
- sed -i "s/'pwd'=>''.*$/'pwd'=>'${db_pass}',/" /var/www/html/phpminiconfig.php
- sed -i "s/'host'=>''.*$/'host'=>'${db_host}',/" /var/www/html/phpminiconfig.php
- sed -i "s/'port'=>''.*$/'port'=>'${db_port}',/" /var/www/html/phpminiconfig.php
- ln -s /var/www/html/phpminiadmin.php /var/www/html/index.php
