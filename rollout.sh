#!/bin/bash
rsync -rv www-built/ dstutzman_danielstutzman@ssh.phx.nearlyfreespeech.net:/home/public/vocab
rsync -rv media/ dstutzman_danielstutzman@ssh.phx.nearlyfreespeech.net:/home/public/media
