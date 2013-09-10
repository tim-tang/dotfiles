#!/bin/bash
read -p "Commit description: " desc
git add -i && \
#git add -u && \
git commit -m "$desc" && \
git push origin master
