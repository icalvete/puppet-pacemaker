class pacemaker::corosync::config (

  $secauth           = $pacemaker::params::secauth,
  $mcastpot          = $pacemaker::params::mcastport,
  $threads           = $::processorcount,
  $bind_address      = $pacemaker::params::bind_address,
  $force_online      = false,
  $check_standby     = false,
  $debug             = false,
  $unicast_addresses = $pacemaker::unicast_addresses

) inherits pacemaker::corosync::params {

  if ! $unicast_addresses {
    fail('Pacemaker/Corosync cluster need at least two IPs')
  }

  file{$pacemaker::corosync::params::conf_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  #file{'corosync_authkey':
  #  ensure => link,
  #  path   => "${pacemaker::corosync::params::conf_dir}/authkey",
  #  target => '/var/lib/puppet/ssl/certs/ca.pem',
  #  owner  => 'root',
  #  group  => 'root',
  #  mode   => '0400'
  #}

  file{'corosync_authkey':
    ensure => present,
    path   => "${pacemaker::corosync::params::conf_dir}/authkey",
    source => "puppet:///modules/${module_name}/authkey",
    owner  => 'root',
    group  => 'root',
    mode   => '0400'
  }


  file{'corosync_conf':
    ensure  => present,
    path    => "${pacemaker::corosync::params::conf_dir}/corosync.conf",
    content => template("${module_name}/corosync.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }
}
