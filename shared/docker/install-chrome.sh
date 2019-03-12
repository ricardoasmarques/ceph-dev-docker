#!/bin/bash

wget https://dl.google.com/linux/linux_signing_key.pub
rpm --import linux_signing_key.pub
zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 google
zypper -n in google-chrome-stable