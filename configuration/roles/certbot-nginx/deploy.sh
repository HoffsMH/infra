ansible-playbook -i=$1, certbot-nginx/deploy.yml \
    --extra-vars "ansible_user=root ansible_password=$2" -b
