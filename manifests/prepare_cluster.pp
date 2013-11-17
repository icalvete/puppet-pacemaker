class pacemaker::prepare_cluster {

  file {'prepare_cluster_lock':
    ensure => directory,
    path   => hiera('prepare_cluster_dir'),
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }
}
