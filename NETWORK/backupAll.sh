#!/bin/sh

xargs -I {} -P 20 -a switchList.conf -d '\n' ./backupSwitch.sh {};

