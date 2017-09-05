#!/bin/bash
echo "$(date) setup STARTED"
apt-get update
apt-get install -y unzip curl xvfb supervisor

export DISPLAY=:99.0
echo DISPLAY value is $DISPLAY

cd /tmp
if [ ! -f /usr/bin/chromedriver ]; then
    apt-get install -y libgconf-2-4 libnss3 libfontconfig
    curl -o chromedriver_2.31_linux64.zip https://chromedriver.storage.googleapis.com/2.31/chromedriver_linux64.zip
    echo "fb5ea8eaa9bd085432408f0d9da75e622b800b3d  chromedriver_2.31_linux64.zip" > chromedriver_2.31_linux64.sha1
    if [[ $(sha1sum -c chromedriver_2.31_linux64.sha1 | grep OK | wc -l) -eq 1 ]]; then
        echo "chromedriver installation file sha1sum check is OK!"
        unzip chromedriver_2.31_linux64.zip
        mv -f chromedriver /usr/bin/
        echo "chromedriver installation SUCCESSFUL!"
    else
        echo "chromedriver installation file sha1sum check is NOT OK!"
        echo "chromedriver installation UNSUCCESSFUL!"
        exit 1
    fi
else
    echo "chromedriver already INSTALLED!"
fi
chromedriver --version

if [ ! -f /usr/bin/google-chrome ]; then
    curl -o google-chrome-stable_60.0.3112.113-1_amd64.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_61.0.3163.79-1_amd64.deb
    echo "7e32ffb1941b64d91a5b6039015af1499f807ebf  google-chrome-stable_60.0.3112.113-1_amd64.deb" > google-chrome-stable_60.0.3112.113-1_amd64.sha1
    if [[ $(sha1sum -c google-chrome-stable_60.0.3112.113-1_amd64.sha1 | grep OK | wc -l) -eq 1 ]]; then
        echo "google-chrome installation file sha1sum check is OK!"
        dpkg -i google-chrome-stable_60.0.3112.113-1_amd64.deb
        apt-get install -f -y
        echo "google-chrome installation SUCCESSFUL!"
    else
        echo "google-chrome installation file sha1sum check is NOT OK!"
        echo "google-chrome installation UNSUCCESSFUL!"
        exit 1
    fi
else
    echo "google-chrome already INSTALLED!"
fi
google-chrome --version

if ! pgrep -x "supervisord" > /dev/null; then
    echo -e "[program:chromedriver]\ncommand=/usr/bin/chromedriver --verbose\nenvironment=DISPLAY=:99.0\npriority=0\nredirect_stderr=true\nstdout_logfile=/var/log/chromedriver.log\nstderr_logfile=/var/log/chromedriver-error.log" > /etc/supervisor/conf.d/chromedriver.conf
    echo -e "[program:xvfb]\ncommand=/usr/bin/Xvfb :99 -screen 0 1366x768x24 -terminate\nenvironment=DISPLAY=:99.0\npriority=10\nautorestart=true\nredirect_stderr=true\nstdout_logfile=/var/log/xvfb.log\nstderr_logfile=/var/log/xvfb-error.log" > /etc/supervisor/conf.d/xvfb.conf
    service supervisor start
    echo "supervisor service STARTED!"
fi

if [[ $(pgrep -x "chromedriver|Xvfb|supervisord" | wc -l) -eq 3 && -f /usr/bin/google-chrome ]]; then
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SETUP is SUCCESSFUL!!!"
fi
echo "$(date) setup FINISHED"
