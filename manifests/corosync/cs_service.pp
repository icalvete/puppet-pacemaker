define pacemaker::corosync::cs_service (

  $service = $name,
  $version = '0'

) {

  file {"corosync_service_${name}":
    ensure  => 'present',
    path    => "/etc/corosync/service.d/${name}",
    content => template("${module_name}/corosync_service.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }
}
