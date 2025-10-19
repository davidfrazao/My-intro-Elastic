FROM dorowu/ubuntu-desktop-lxde-vnc

# Remove broken Chrome repo to avoid GPG errors
RUN rm -f /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y openjdk-17-jre && \
    apt-get clean

# Create autostart entry for LXDE
RUN mkdir -p /root/.config/lxsession/LXDE && \
    echo "@java -jar /root/luke/luke.jar" >> /root/.config/lxsession/LXDE/autostart

CMD ["/startup.sh"]

