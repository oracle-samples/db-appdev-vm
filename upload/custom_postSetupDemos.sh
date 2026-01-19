#!/bin/bash
if test -f /tmp/1/loadCoffeeShopApplication.sh
then
su oracle -c "bash -x /tmp/1/loadCoffeeShopApplication.sh"
fi
if test -f /tmp/1/buildTimeFatRelease.sh
then
su - oracle -c "bash -x /tmp/1/buildTimeFatRelease.sh"
fi
