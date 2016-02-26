dpfs="/var/www/drupal-private-file-system"
dtp="/var/www/drupal-temporary-path"

sudo mkdir -p -m 777 $dpfs && sudo chmod -R 777 $dpfs && sudo chown -R vagrant:vagrant $dpfs
sudo mkdir -p -m 777 $dtp && sudo chmod -R 777 $dtp && sudo chown -R vagrant:vagrant $dtp

sudo npm install -g grunt-cli
sudo npm install -g jquery
sudo npm install -g phantomcss
sudo npm install -g webdriverio@"2.4.5"
sudo npm install -g phantomjs@"1.9.8"