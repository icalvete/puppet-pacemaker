class pacemaker::corosync::service {

  service {'corosync':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}
