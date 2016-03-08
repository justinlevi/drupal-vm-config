dpfs="/var/www/drupal-private-file-system"
dtp="/var/www/drupal-temporary-path"

sudo mkdir -p -m 777 $dpfs && sudo chmod -R 777 $dpfs && sudo chown -R vagrant:vagrant $dpfs
sudo mkdir -p -m 777 $dtp && sudo chmod -R 777 $dtp && sudo chown -R vagrant:vagrant $dtp

sudo npm install -g grunt-cli
sudo npm install -g jquery
sudo npm install -g phantomcss
sudo npm install -g webdriverio@"2.4.5"
sudo npm install -g phantomjs@"1.9.8"

sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

sudo dpkg -i google-chrome*.deb
sudo apt-get install -f
sudo apt-get install xvfb
sudo apt-get install unzip

wget -N http://chromedriver.storage.googleapis.com/2.20/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
chmod +x chromedriver

sudo mv -f chromedriver /usr/local/share/chromedriver
sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver
sudo apt-get install python-pip