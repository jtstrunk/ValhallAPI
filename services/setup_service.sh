#!/bin/bash
cp services/valhalla_api.service /etc/systemd/system/valhalla_api.service

systemctl daemon-reload

systemctl enable valhalla_api.service