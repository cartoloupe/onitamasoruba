#!/bin/bash
mkfifo $PWD/.wrench
while true; do cmd=`cat $PWD/.wrench`; clear; date +%s; echo $cmd; bundle exec rspec -fd $cmd; done
