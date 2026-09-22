#!/bin/bash

set -e

PORT=${PORT:-22}
DEPLOY_DIR="/home/maxim/Desktop/catty-reminders-app"

echo "Deploying to $HOST:$PORT"
echo "User: $USER"
echo "Release branch: $RELEASE_BRANCH"

SSH_OPTIONS="-p $PORT -o StrictHostKeyChecking=no"

ssh $SSH_OPTIONS "$USER@$HOST" << EOF
    set -e
    
    cd $DEPLOY_DIR
    
    git fetch origin
    git checkout -f $RELEASE_HASH
    git reset --hard
    
    DEPLOY_REF=\$(git rev-parse HEAD)
    echo "DEPLOY_REF=\$DEPLOY_REF" | sudo tee /etc/app.env > /dev/null
    sudo chmod 644 /etc/app.env
    echo "Deployed version: \$DEPLOY_REF"
    
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv/
    fi
    
    source .venv/bin/activate
    
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    fi
    
    sudo systemctl restart app.service
    
    sleep 4
    
    if sudo systemctl is-active --quiet app.service; then
        echo "Deployment completed successfully"
    else
        echo "ERROR: Application failed to start"
        exit 1
    fi
EOF
