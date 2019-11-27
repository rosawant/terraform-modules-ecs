
#!/bin/bash -xe
yum install -y ecs-init
# ECS config
{
  echo "ECS_CLUSTER=${cluster_name}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
sysctl -x net.core.somaxconn=65535
service docker start
start ecs
