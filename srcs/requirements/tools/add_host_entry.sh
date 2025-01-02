#!/bin/bash

# Define the host entry
HOST_ENTRY="127.0.0.1 sgluck.42.fr"

# Check if the entry exists
if ! grep -qF "$HOST_ENTRY" /etc/hosts; then
    echo "$HOST_ENTRY" | sudo tee -a /etc/hosts > /dev/null
    echo "Entry added to /etc/hosts."
else
    echo "Entry already exists in /etc/hosts."
fi
