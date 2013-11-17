class pacemaker::params {

  $secauth      = 'on'
  $mcastport    = '5405'
  $bind_address = $::ipaddress_eth0

  case $::operatingsystem {
    /^(Debian|Ubuntu)$/: {

      $packages = []
    }
    /^(Redhat|CentOS)$/: {

      $packages      = ['python-dateutil', 'redhat-rpm-config']
      $pssh_package  = 'pssh-2.3.1-15.1.x86_64.rpm'
      $crmsh_package = 'crmsh-1.2.5-55.8.x86_64.rpm'
    }
    default: {
      fail ("${::operatingsystem} not supported.")
    }
  }
}
