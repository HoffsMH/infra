ansible-playbook -i=$1, ssh/deploy.yml \
    --extra-vars "ansible_user=root ansible_password=$2" -b

