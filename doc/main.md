## Principles
- Future proof through
  - Simplicity
    - older technology where possible, with less code
  - as few external dependencies as possible.
  - as few online connections/dependencies as possible
    - ci servers
    - container registry
    - git server

- recoverable
  - document everything, with a clueless future self in mind

### Proxmox

#### Vm config
  - Debian 11
    - sshd enabled
    - docker installed
    - docker-compose
    - thats it!
  - when restoring from template
    - make sure that unique is checked so that a new mac address is formed
    - use full clone for now

