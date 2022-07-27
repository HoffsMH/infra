ansible-playbook -i=$1,  import-public-gpg-key/deploy.yml \
    --extra-vars "ansible_user=root ansible_password=$2" -b
