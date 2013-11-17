class pacemaker::config {

  # Corosync is our cluster infrastructure option
  class{'pacemaker::corosync::config':}

  # Pacemaker service is managed by cluster infrastructure layer ( Like any other cluster resource )
  # Setting this critical service here.
  pacemaker::corosync::cs_service{'pacemaker':
    require => Class['pacemaker::corosync::config'],
    before  => Class['pacemaker::corosync::service']
  }

  file{'/usr/lib/ocf/resource.d/sp':
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/${module_name}/sp-ocf",
    owner   => 'root',
    group   => 'root',
    mode    => '0755'
  }

  file{'/etc/default/corosync':
    ensure  => present,
    content => 'START=yes',
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }
}
