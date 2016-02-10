#My Config & Setup Instructions for Drupal-VM
Below is a step-by-step guide of what worked for me


[Drupal VM](http://www.drupalvm.com/) is A VM for local Drupal development, built with Vagrant + Ansible.


Prerequisites
============
- Install Vagrant 1.7.4 (should work w/ vagrant-1.8.1 too)
- Install VirtualBox (latest version) **
- Git Clone https://github.com/geerlingguy/drupal-vm ( latest release )
- Install Drush globally ( http://docs.drush.org/en/master/install/ )

** Potential issue w/ Intel Ix Core situation.  You might need to turn on virtualization in the BIOS


INSTRUCTIONS
============

* Download the above prerequisites. Note, that my workflow consisted of using Acquia Dev Desktop to first clone the sites I want to work with locally. This guide does not cover setting up a new Drupal site when the VM instance is created.

### WINDOWS USERS - [START]
* Unzip  the `ansible.zip` file at: `C_Hashicorp/Vagrant/embedded/gems/gems/vagrant-1.xx/plugins/provisioners/`
* Navigate to your local drive: `C:/Hashicorp/Vagrant/embedded/gems/gems/vagrant-1.xx/plugins/provisioners/` and replace the ansible folder with what came in the zip file.

Make sure your .ssh keys are setup and in the right place
- https://help.github.com/articles/generating-an-ssh-key/
-  Duplicate all .ssh files that live somewhere else into your c:/Users/YOUR-USERNAME/.ssh folder

### Forward `ssh-agent` TO Virtual Machine (Windows only?)
Windows - The ssh-agent does not run by default and/or does not startup even after you run these commands.
Solution: Run these commands each time, or add them to your .bash_profile or a shell script of some sort.
This is a miserable problem and is documented here: http://stackoverflow.com/questions/17846529/could-not-open-a-connection-to-your-authentication-agent
Below are three solutions that worked for me. YMMV

### \#3 below is my personal fav because it fires when I open Cmder

- 1. Run this from git bash
eval `ssh-agent -s`
ssh-add
Note: You can use the above command to indicate whether or not your ssh-agent is setup and running too.

or

- 2. "C:\Program Files (x86)\Git\cmd\start-ssh-agent.cmd"
from the Command Prompt

or

If you're using Cmder, do this:
- 3. https://github.com/cmderdev/cmder/issues/193#issuecomment-63041617

### WINDOWS USERS - [END]

# Make required config.yml changes
create a `config.yml` file in the drupal-vm cloned folder at the same level as the example.config.yml
You can either copy the https://github.com/justinlevi/drupal-vm-config/blob/master/justin.windows.config.yml, the `windows.config.yml`, or `mac.config.yml` from this repository or you can modify the `example.config.yml` provided with the drupal-vm repo. 

You'll want to minimally change the following:
```yaml
vagrant_synced_folders:
  # The first synced folder will be used for the default Drupal installation, if
  # build_makefile: is 'true'.
  - local_path: C:\drupal\sites\<SITE-YOU-WANT-TO-WORK-WITH>
```

#### (Advanced) Setting up multiple Virtual Hosts

I wanted a single VM that would run multiple sites. You would make the following updates within the config.yml file for a multi-site setup. Note, this can get a bit complicated and the file paths are not always obvious. This can require a bit of tinkering.:

```yaml
  - local_path: ~/Sites/<SITE-A>
    destination: /var/www/<SITE-A>
    type: nfs
    create: true

  - local_path: ~/Sites/<SITE-B>
    destination: /var/www/<SITE-B>
    type: nfs
    create: true

  - local_path: ~/Sites/<SITE-C>
    destination: /var/www/<SITE-C>
    type: nfs
    create: true
```

Further down the config.yml file you will see a section for `vagrant_synced_folders`.

  For additional notes, see the following:
  https://github.com/geerlingguy/drupal-vm/issues/168

  For a multisite setup you would need to make the following changes
  ```
  vagrant_synced_folders:

    - local_path: C:\drupal\sites\<SITE-A>
      destination: /var/www/<SITE-A>
      type: nfs
      create: true

    - local_path: C:\drupal\sites\<SITE-B>
      destination: /var/www/<SITE-B>
      type: nfs
      create: true

      - local_path: C:\drupal\sites\<SITE-C>
      destination: /var/www/<SITE-C>
      type: nfs
      create: true

   ```
   
   Here is what it looks like in my config.yml file
```yaml
vagrant_synced_folders:
  # The first synced folder will be used for the default Drupal installation, if
  # build_makefile: is 'true'.
  - local_path: C:\drupal\sites\nysptracs-dev
    destination: /var/www/devdesktop/nysptracs
    type: nfs
    create: true
  
  - local_path: C:\drupal\sites\nysafeschools-dev
    destination: /var/www/devdesktop/nysafeschools
    type: nfs
    create: true
```


   Scroll down a bit further and make the following updates to the apache_vhosts section:


   ```
  - servername: "<SITE-A>.dev"
    documentroot: "/var/www/devdesktop/<SITE-A>/docroot"
    extra_parameters: |
          ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/devdesktop/<SITE-A>/docroot"

  - servername: "<SITE-B>.dev"
    documentroot: "/var/www/devdesktop/<SITE-A>/docroot"
    extra_parameters: |
          ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/devdesktop/<SITE-B>/docroot"

  - servername: "<SITE-C>.dev"
  documentroot: "/var/www/devdesktop/<SITE-A>/docroot"
  extra_parameters: |
        ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/devdesktop/<SITE-C>/docroot"
   ```
   
   Here is what it looks like in my config.yml
```yaml
apache_vhosts:
  - servername: "nysptracs.dev"
    documentroot: "/var/www/devdesktop/nysptracs/docroot"
    extra_parameters: |
          ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/devdesktop/nysptracs/docroot"

  - servername: "nysafeschools.dev"
    documentroot: "/var/www/devdesktop/nysafeschools/docroot"
    extra_parameters: |
          ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/devdesktop/nysafeschools/docroot"

  - servername: "adminer.vm.dev"
    documentroot: "/opt/adminer"
    extra_parameters: |
          ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/opt/adminer"

  - servername: "xhprof.vm.dev"
    documentroot: "/usr/share/php/xhprof_html"
    extra_parameters: |
          ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/usr/share/php/xhprof_html"
```


  Note: If you're updating an existing `config.yml` file for an existing VM
  * you need to run `vagrant reload` and `vagrant provision` which should reboot the VM and pick up the new synced folders. Note - This didn't seem to work for me even though it should. The ultimate fix was to do a `vagrant destroy` and then run `vagrant up` again. Annoying, but fixed the issue.
  * you would need to add/update your drush aliases for any new sites
  * you also need to add these domains to your hosts file


# Setup the Virtual Machine instance
- Open a terminal and `cd` into the `drupal-vm` repository folder
- run `vagrant up`
- **NOTE** If you receive any errors during install, when you get back to your command prompt you can try the following commands:
 - `vagrant halt`
 - `vagrant destroy`
 - `vagrant box update`
 - `vagrant provision`
 - `vagrant reload`
 - Then run `vagrant up` again


===================

## Download your Acquia Drush aliases
https://docs.acquia.com/cloud/drush-aliases

Extract them to your $HOME Directory
- run this at your command prompt to find this location : echo %USERPROFILE%
- Also, copy both .acquia & .drush folders into your site root


## Create an alias for each site in a drush folder one level up from the root of each drupal site. 

For the nysptracs site, for me, that path looks like:
`C:\drupal\sites\nysptracs-dev\drush`

Note, there are different spots you could place your drush alias but this will keep the alias with the site. Unfortunately, this means you will need to run your sql-sync commands from within the docroot.
`aliases.drushrc.php`

```php
<?php
$aliases['<SITE-A>.dev'] = array(
  'uri' => '<SITE-A>.dev',
  'root' => '/var/www/devdesktop/<SITE-A>/docroot',
  'remote-host' => '<SITE-A>.vm.dev',
  'remote-user' => 'vagrant',
  'ssh-options' => '-o PasswordAuthentication=no -i ~/.vagrant.d/insecure_private_key',
);
```

Here is my alias for nysptracs
```php
<?php

$aliases['nysptracs.vm'] = array(
  'uri' => 'nysptracs.dev',
  'root' => '/var/www/devdesktop/nysptracs/docroot',
  'remote-host' => 'nysptracs.dev',
  'remote-user' => 'vagrant',
  'ssh-options' => '-o PasswordAuthentication=no -i ~/.vagrant.d/insecure_private_key',
);
```


## Connect to the database

Create the following directory and settings.php file for your drupal site
`sites/<SITE-A>.dev/settings.php`

```php
<?php
$databases['default']['default'] = array(
    'driver' => 'mysql',
    'database' => '<SITE-A>',
    'username' => 'root',
    'password' => 'root',
    'host' => 'localhost',
   'prefix' => '',
);

$conf['securepages_enable'] = FALSE;
$conf['file_private_path'] = '/var/www/drupal-private-file-system';
$conf['file_temporary_path'] = '/var/www/drupal-temporary-path';
  ```

Rinse & repeat for the other sites.

Here is my settings.php file for nysptracs
```php
<?php
$databases['default']['default'] = array(
    'driver' => 'mysql',
    'database' => 'nysptracs',
    'username' => 'root',
    'password' => 'root',
    'host' => 'localhost',
   'prefix' => '',
);

$conf['securepages_enable'] = FALSE;
$conf['file_private_path'] = '/var/www/drupal-private-file-system';
$conf['file_temporary_path'] = '/var/www/drupal-temporary-path';
```

### Update your hosts file
Edit C:Windows/System32/drivers/etc/hosts
Add the following line
`192.168.88.88 vm.dev <SITE-A>.dev <SITE-B>.dev <SITE-C>.dev adminer.vm.dev xhprof.vm.dev pimpmylog.vm.dev`

Here is what my hosts file looks like
```
# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
127.0.0.1       docroot.dd
127.0.0.1       nysafeschools.dev.dd
127.0.0.1       nyspcentennial.dev.dd
127.0.0.1       nysptracs.dev.dd
192.168.88.88   nysptracs.dev nysafeschools.dev adminer.vm.dev xhprof.vm.dev pimpmylog.vm.dev
```

### Create the databases for each site 
**Only needed if you don't setup the databases in your config file** 
1. Open a browser and go to the url : http://adminer.vm.dev
2. login with the root/root
3. Create a database for each site you want to wire up

## Download the database to your local virtual machine
$ `drush @YOUR-ACQUIA-REMOTE-ALIAS.dev sql-dump --structure-tables-list="hist*,cache*,*cache,sessions" | drush @<SITE-A>.vm sql-cli`

Here is the drush command for updating my nysptracs database
$`drush @nysptracs.dev sql-dump --structure-tables-list="hist*,cache*,*cache,sessions" | drush @nysptracs.vm sql-cli`

#OPTIONAL - START
#Install the Drush registry_rebuild "module"
Note: For Drupal 7 I needed to make sure I had the `drush registry_rebuild` available and it doesn't ship with drush 8. You can install it via:

$ `drush @<SITE-A>.vm dl registry_rebuild`

clear your drush cache
$ `drush @<SITE-A>.vm cc drush`

### Truncate all database tables
login to the http://adminer.vm.dev and select all of the cache tables, and truncate them.
u: drupal
p: drupal
db: drupal

### Rebuild the registry via
`drush @<SITE-A>.vm rr --fire-bazooka`
#OPTIONAL - END

# Visit your new fancy site @
http://YOUR-SITE-NAME.dev

example:
http://nysptracs.dev

# Rejoice :tada:

### Notes:
If for some reason the the site doesn't load, you can try to restart the apache server
$`vagrant ssh` // from within your drupal-vm folder
$`sudo service apache2 stop`
$`sudo service apache2 start`

Behat tests
======================================
ssh into the vagrant box
$ `ssh vagrant`

Create a btests folder one level above your drupal docroot and add the following files in there.
example `/var/www/devdesktop/nysptracs/btests/`

**behat.yml**
```yaml
default:
  gherkin:
    filters:
      tags: "~@skip"
  suites:
    homepage:
      paths: [%paths.base%/features/homepage]
      contexts:
        - FeatureContext
        - DrupalFeatureContext
        - Drupal\DrupalExtension\Context\MinkContext
        - Drupal\DrupalExtension\Context\MessageContext
        - Drupal\DrupalExtension\Context\DrushContext
  extensions:
    Behat\MinkExtension:
      base_url: http://nysptracs.dev
      files_path: '/var/www/btests/files'
      goutte: ~
      selenium2:
        wd_host: "http://localhost:8643/wd/hub"
    Drupal\DrupalExtension:
      blackbox: ~
      api_driver: 'drupal'
      drush:
        alias: 'local'
      drupal:
        drupal_root: '/var/www/devdesktop/nysptracs/docroot'
      region_map:
        header: "#header"
        logo:  "#logo"
      selectors:
        message_selector: '.messages'
        error_message_selector: '.messages.messages.error'
        success_message_selector: '.messages.messages.status'
```

**composer.json**
```json
{
  "require": {
    "drupal/drupal-extension": "~3.0"
},
  "config": {
    "bin-dir": "bin/"
  }
}

```

features/bootstrap/DrupalFeatureContext.php
```php
<?php

use Drupal\DrupalExtension\Context\RawDrupalContext;
use Behat\Behat\Context\SnippetAcceptingContext;
use Behat\Gherkin\Node\PyStringNode;
use Behat\Gherkin\Node\TableNode;

/**
 * Defines application features from the specific context.
 */
class DrupalFeatureContext extends RawDrupalContext implements SnippetAcceptingContext {

  /**
   * Initializes context.
   *
   * Every scenario gets its own context instance.
   * You can also pass arbitrary arguments to the
   * context constructor through behat.yml.
   */
  public function __construct() {
  }
}
```

features/bootstrap/FeatureContext.php
```php
<?php

use Drupal\DrupalExtension\Context\RawDrupalContext;
use Behat\Behat\Context\SnippetAcceptingContext;
use Behat\Gherkin\Node\PyStringNode;
use Behat\Gherkin\Node\TableNode;

/**
 * Defines application features from the specific context.
 */
class FeatureContext extends RawDrupalContext implements SnippetAcceptingContext {

  /**
   * Initializes context.
   *
   * Every scenario gets its own context instance.
   * You can also pass arbitrary arguments to the
   * context constructor through behat.yml.
   */
  public function __construct() {
  }

}
```

homepage/frontpage.feature
```
Feature:  Be the Borg
  As a superior cybernetic organism
  I need to assimilate other species
  In order to grow the hive mind
  And become the best borg I can be

  Scenario:  Global Nav Area
    Given I am on the homepage
    Then I should see a ".nygov-universal-container" element

  Scenario:  Global Footer Area
    Given I am on the homepage
    Then I should see a ".nys-global-footer" element
```

Run your behat tests from within the `btests` folder

runs all tests
$ `behat`

runs just the tests in the homepage folder
$ `behat -s hompage`

Visual Regression Tests
======================================

ssh into the vagrant box
$ `ssh vagrant`

Install the following node libraries
$ `sudo npm install -g jquery`
$ `sudo npm install -g phantomcss`
$ `sudo npm install -g phantomjs@"1.9.8"`
$ `sudo npm install -g webdriverio@"2.4.5"`

Here's my globally installed node packages:
$ `npm list -g --depth=0`
```
├── npm@3.5.3
├── phantomjs@1.9.19
├── selenium-standalone@4.9.0
├── webdriverio@2.4.5
```

Create a vtests folder one level above your drupal docroot and add the following files in there.
example `/var/www/devdesktop/nysptracs/vtests/`

**webdrivercsstest.js**
```javascript
var assert = require('assert');

// init WebdriverIO
var client = require('webdriverio').remote({desiredCapabilities:{browserName: 'phantomjs'}})
// init WebdriverCSS
require('webdrivercss').init(client, {
  screenWidth: [320,480,768,960,1280]
});

client
    .init()
    .url('http://nysptracs.dev') // change for the site you're testting for
    .webdrivercss('startpage',[
        {
            name: 'page',
            elem: '#page',
            exclude:  [
             ".container-to-exclude",
            ]
        }
    ], function(err, res) {
        assert.ifError(err);
        assert.ok(res.page[0].isWithinMisMatchTolerance);
    })
    .end();
```

Start the selenium server from within the vagrant ssh session
$ `sudo /etc/init.d/selenium start`
$ `cd /var/www/sites/nysptracs/vtests`
$ `node webdrivercsstest.js --verbose`

If you get an imagemagick/graphicsmagick error, to fix, you can run:
$ `sudo apt-get install graphicsmagick`
