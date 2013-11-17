#puppet-pacemaker

Puppet manifest to install and configure a pacemaker cluster

[![Build Status](https://secure.travis-ci.org/icalvete/puppet-pacemaker.png)](http://travis-ci.org/icalvete/puppet-pacemaker)

See [Clusters from Scratch](http://clusterlabs.org/doc/en-US/Pacemaker/1.1-crmsh/html/Clusters_from_Scratch/index.html)

##Actions:

* Works in Debian|Ubuntu|RedHat|CentOS
* Install and configure an Actice/Standby cluster with (at least) an resource group with:
  + VIP
  + Associate service
  + DRBD volume

##Requires:

* https://github.com/icalvete/puppet-common
* https://github.com/icalvete/puppet-drbd 
* **Use your own authkey**

##Example:


```
node 'ubuntu01.smartpurposes.net' inherits test_defaults {
  include roles::puppet_agent
  include roles::apache2_server

  roles::pacemaker_cluster{'test':
    service_name    => 'apache2',
    drbd_mountpoint => '/test',
    node_active     => 'ubuntu01',
    ip_active       => '192.168.10.59',
    node_passive    => 'ubuntu02',
    ip_passive      => '192.168.10.56',
    vip             => '192.168.10.200',
    drbd_disk       => '/dev/sdb',
  }
}

node 'ubuntu02.smartpurposes.net' inherits test_defaults {
  include roles::puppet_agent
  include roles::apache2_server

  roles::pacemaker_cluster{'test':
    service_name    => 'apache2',
    drbd_mountpoint => '/test',
    node_active     => 'ubuntu01',
    ip_active       => '192.168.10.59',
    node_passive    => 'ubuntu02',
    ip_passive      => '192.168.10.56',
    vip             => '192.168.10.200',
    drbd_disk       => '/dev/sdb',
  }
}
```

Where  roles::pacemaker_cluster is:


```
define roles::pacemaker_cluster(

  $cluster_name    = $name,
  $service_name    = $name,
  $drbd_resource   = $name,
  $drbd_device     = '/dev/drbd0',
  $drbd_disk       = '/dev/vdb1',
  $drbd_port       = '7789',
  $drbd_mountpoint = undef,
  $node_active     = undef,
  $ip_active       = undef,
  $node_passive    = undef,
  $ip_passive      = undef,
  $vip             = undef,
  $cidr_netmask    = '24',

) {
  
  anchor{"roles::pacemaker_cluster::${name}::begin":}
    
  if $node_active == $::fqdn {
    $ha_primary    = true
    $initial_setup = true
  } else {
    $ha_primary    = false
    $initial_setup = false
  }

  if ! defined(Class['pacemaker']) {
    class { 'pacemaker':
      asymetrical       => false,
      unicast_addresses => [$ip_active, $ip_passive],
      require           => Anchor["roles::pacemaker_cluster::${name}::begin"],
      before            => Anchor["roles::pacemaker_cluster::${name}::end"]
    }
  }
  
  drbd::resource { $drbd_resource:
    host1         => $node_active,
    host2         => $node_passive,
    ip1           => $ip_active,
    ip2           => $ip_passive,
    disk          => $drbd_disk,
    port          => $drbd_port,
    device        => $drbd_device,
    manage        => true,
    verify_alg    => 'sha1',
    ha_primary    => $ha_primary,
    initial_setup => $initial_setup,
    automount     => false,
```

##Authors:

Israel Calvete Talavera <icalvete@gmail.com>
