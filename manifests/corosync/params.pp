class pacemaker::corosync::params {

  $conf_dir = '/etc/corosync'

  case $::operatingsystem {
    /^(Debian|Ubuntu)$/: {
      $log_root = 'corosync'
    }
    /^(CentOS|RedHat)$/: {
      $log_root = 'cluster'
    }
    default: {
      fail("Operating system ${::operatingsystem} is not supported")
    }
  }
}

