sudo apt-get install -y chrony
# /etc/chrony/chrony.conf:
# (leave servers), add/ensure:
# rtcsync
# makestep 1.0 3   # only step in the first 3 updates; afterwards, slew only
sudo systemctl disable --now systemd-timesyncd || true
sudo systemctl enable --now chrony
chronyc tracking; chronyc sources -v
