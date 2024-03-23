set dotenv-load

[private]
default:
    @just --list --unsorted

# Copy repo content to remote host with 'rsync' and watch for changes
sync hostname="deck" password="ubuntu":
    #!/bin/bash
    sshpass -p "{{password}}" rsync -vRr --exclude='.git/' --delete ./ deck@{{hostname}}:/home/deck/${PWD##*/}
    while inotifywait -r -e modify,create,delete,move ./ --exclude='.git/' ; do
        sshpass -p "{{password}}" rsync -vRr --exclude='.git/' --delete ./ deck@{{hostname}}:/home/deck/${PWD##*/}
    done

brightness value="1000":
    #!/bin/bash
    echo "{{value}}" | sudo tee /sys/class/backlight/amdgpu_bl0/brightness