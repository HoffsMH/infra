## To Do

- umasking when from scratch so that syncthing can create everything
- syncthing
- steamlink
- searx
- stagit or cgit on web host
- settime on everything
- pihole invidiual settins setup
- pikvm
- attempt to place PW hash in syncthing config file
- dashboard/portal to selfhosted services?
- retropie
- mnt/storage/data is a variable for workstation in the context of ansible scripts
- should just everything be on this? monorepo for dotfiles
- feeds taking up instant 90g on any workstation needs fixing so hurry up and get syncthing going
- restic
- jellyfin
- base vm cfg file for storage/dir passthrough
- cron on  base vm that always docker compose up on boot

## Doing

- re do minimal debian template
- proxmox template service file auto compose up on boot
    > this shall just be a role
- after re provision consolidate away from disk3/ orange and decomission as it is not mounting reliably upon boot
- re-provision proxmox

## Done

- listenaddr in syncthing setup
- better naming for pi inventory- static ips
- self ansible fstab entry for samba
- pi-hole on pi-3
- nas mergerfs rebalance
- change passwords on every install?
- migrate iac roles over
- final bit of pcloud data on to drives
- final snapraid sync before migrating to thinkcentre for nas
- pihole start cronie
- get rid of proxmox nag
- enable cronie on workstation
- workstation backup automated
- workstation cron to just backup ~/code on daily weekly and monthly
- proxmox template ready for apps to be deployed on
- investigate can you just mount a directory such as /mnt/storage
    > yes but it uses unpopular/experimental technology and requires  too much digging/research and snowflaking of the vm -- best to just use the cifs mount role
- if not then cifs speed an reliability?
    > Speed of cord -well see
- only one linux kernel should have a device mounted at a time
    > agree
- proxmox template autconnect to storage
    * [ ] ansible role no problem host ip works just finr
