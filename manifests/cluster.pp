define pacemaker::cluster (

  $asymetrical     = false,
  $service         = undef,
  $vip             = undef,
  $cidr_netmask    = '16',
  $drbd_resource   = undef,
  $drbd_device     = undef,
  $drbd_mountpoint = undef,
  $node_active     = undef,
  $node_passive     = undef

) {

  if ! $service {
    fail('$service must be defined in pacemaker::cluster.')
  }

  if ! $vip {
    fail('$vip must be defined in pacemaker::cluster.')
  }

  if ! $drbd_resource  {
    fail('$drbd_resource must be defined in pacemaker::cluster.')
  }

  if ! $drbd_device {
    fail('$node_passive must be defined in pacemaker::cluster.')
  }

  if ! $drbd_mountpoint {
    fail('$drbd_mountpoint must be defined in pacemaker::cluster.')
  }

  if $asymetrical == '' {

    if ! $node_active {
      fail('$node_active must be defined in pacemaker::cluster.')
    }
    if ! $node_passive  {
      fail('$node_passive must be defined in pacemaker::cluster.')
    }
  }

  cs_primitive { "${name}_vip":
    primitive_class => 'ocf',
    primitive_type  => 'IPaddr2',
    provided_by     => 'heartbeat',
    parameters      => { 'ip' => $vip, 'cidr_netmask' => $cidr_netmask },
    operations      => { 'monitor' => { 'interval' => '10s' } },
  }

  if $drbd_device {

    cs_primitive { "${name}_drbd":
      primitive_class => 'ocf',
      primitive_type  => 'drbd',
      provided_by     => 'linbit',
      parameters      => { 'drbd_resource' => $drbd_resource },
      operations      => {
        'monitor'     => { 'interval' => '29s', 'role' => 'Master' },
        'monitor'     => { 'interval' => '31s', 'role' => 'Slave' },
      },
      promotable      => true,
      ms_metadata     => {
                          'master-max'      => '1',
                          'master-node-max' => '1',
                          'clone-max'       => '2',
                          'clone-node-max'  => '1',
                          'notify'          => true,
      },
      require         => Cs_primitive["${name}_vip"],
    }

    cs_primitive { "${name}_filesystem":
      primitive_class => 'ocf',
      primitive_type  => 'Filesystem',
      provided_by     => 'heartbeat',
      parameters      => {  'device'  => $drbd_device,
                          'directory' => $drbd_mountpoint,
                          'fstype'    => 'ext4'
      },
      operations      => {
                          'monitor' => { 'interval' => '120s', 'timeout' => '60s'},
                          'start'   => { 'interval' => '0', 'timeout' => '60s'},
                          'stop'    => { 'interval' => '0', 'timeout' => '60s'},
                        },
      require         => Cs_primitive["${name}_drbd"],
      before          => Cs_primitive["${name}_service"]
    }
  }

  cs_primitive { "${name}_service":
    primitive_class => 'lsb',
    primitive_type  => $service,
    provided_by     => 'heartbeat',
    operations      => {
      'monitor'     => { 'interval' => '10s', 'timeout' => '30s', 'start-delay' => '2' },
      'start'       => { 'interval' => '0', 'timeout'   => '30s', 'on-fail'     => 'restart' }
    },
  }

  if $drbd_device {

    cs_group {"${name}_resource_group":
      primitives  => ["${name}_vip", "${name}_filesystem", "${name}_service"],
      require     => Cs_primitive["${name}_service"],
    }

    cs_colocation { "${name}_resource_set":
      primitives => [ "ms_${name}_drbd:Master", "${name}_resource_group"],
      require    => Cs_group["${name}_resource_group"],
    }

    cs_order { "${name}_drbd_before_resources":
      first   => "ms_${name}_drbd:promote",
      second  => "${name}_resource_group:start",
      require => [ Cs_primitive["${name}_drbd"], Cs_group["${name}_resource_group"] ]
    }
  } else {
    cs_group {"${name}_resource_group":
      primitives  => ["${name}_vip", "${name}_service"],
      require     => Cs_primitive["${name}_service"],
    }
  }

  if $asymetrical {

    if ! $node_active {
      fail('$node_active must be defined in pacemaker::cluster')
    }

    if ! $node_passive {
      fail('$node_passive must be defined in pacemaker::cluster')
    }

    if $drbd_device  {
      cs_location { "${name}_drdb_active":
        primitive => "ms_${name}_drbd",
        x_node    => $node_active,
        score     => '200',
        require   => Cs_primitive["${name}_drbd"],
      }

      cs_location { "${name}_drbd_passive":
        primitive => "ms_${name}_drbd",
        x_node    => $node_passive,
        score     => '0',
        require   => Cs_primitive["${name}_drbd"],
      }
    }

    cs_location { "${name}_resource_set_active":
      primitive => "${name}_resource_group",
      x_node    => $node_active,
      score     => '200',
      require   => Cs_group["${name}_resource_group"]
    }

    cs_location { "${name}_resource_set_passive":
      primitive => "${name}_resource_group",
      x_node    => $node_passive,
      score     => '0',
      require   => Cs_group["${name}_resource_group"]
    }
  }
}
