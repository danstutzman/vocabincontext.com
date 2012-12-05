#!/bin/bash
cd `dirname $0`/..

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

cd backend

ENV=production bundle exec ruby task_runner.rb \
   >>/mnt/vic-production/shared/log/task_runner.log \
  2>>/mnt/vic-production/shared/log/task_runner.log
