#!/bin/zsh

ansible-playbook -i=$1, \
  configuration/playbooks/provision/yubi-ssh.yml  \
  --connection-password-file=.connection-pass \
  -u root

