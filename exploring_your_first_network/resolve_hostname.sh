#!/usr/bin/env bash
# This script will resolve the hostname of the system
# It will use the hostname command to get the hostname and then resolve it to an IP address
hostname -I | awk '{print $1}'