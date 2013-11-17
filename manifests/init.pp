# == Class: pacemaker
#
# A Puppet module, using storeconfigs, to model an pacemaker cluster
#
# === Requirement/Dependencies:
#
# Currently requires our corosync module based on
# https://forge.puppetlabs.com/puppetlabs/corosync
#
#  - This module have some native types to manage corosync.
#  - This module has been improved with new corosync native type
#    to manage corosync locations.
#
# === Authors
#
# Israel Calvete <icalvete@gmail.com>
#

class pacemaker (

  $asymetrical       = false,
  $unicast_addresses = undef

) inherits pacemaker::params {

  anchor{'pacemaker::begin':
    before => Class['pacemaker::install']
  }

  class{'pacemaker::install':
    require => Anchor['pacemaker::begin']
  }

  class{'pacemaker::config':
    require => Class['pacemaker::install']
  }

  class{'pacemaker::service':
    require => Class['pacemaker::config']
  }

  class{'pacemaker::postconfig':
    asymetrical => $asymetrical,
    require     => Class['pacemaker::service']
  }

  anchor{'pacemaker::end':
    require => Class['pacemaker::postconfig']
  }
}
