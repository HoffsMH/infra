#!/bin/zsh

ansible-playbook -i=$1, configuration/playbooks/yubi-ssh.yml  -b
