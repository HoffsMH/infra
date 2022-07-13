#!/bin/zsh

ansible-playbook -i=$1, configuration/playbooks/provision/yubi-ssh.yml  -b
