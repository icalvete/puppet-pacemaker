class pacemaker::install {

  package {$pacemaker::params::packages:
    ensure  => present
  }

  case $::operatingsystem {
    /^(Debian|Ubuntu)$/: {}
    /^(Redhat|CentOS)$/: {
      case $::operatingsystemrelease {
        '6.4': {

          file{'pssh':
            ensure => present,
            path   => "/tmp/${pacemaker::params::pssh_package}",
            source => "puppet:///modules/${module_name}/centos64/${pacemaker::params::pssh_package}",
          }

          file {'crmsh':
            ensure => present,
            path   => "/tmp/${pacemaker::params::crmsh_package}",
            source => "puppet:///modules/${module_name}/centos64/${pacemaker::params::crmsh_package}",
          }

          exec {'install pssh':
            command => "/bin/rpm -i ${pacemaker::params::pssh_package}",
            user    => 'root',
            unless  => '/usr/bin/test -f /usr/bin/pssh',
            require => [Package[$pacemaker::params::packages], File['pssh']]
          }

          exec {'install crmsh':
            command => "/bin/rpm -i ${pacemaker::params::crmsh_package}",
            user    => 'root',
            unless  => '/usr/bin/test -f /usr/sbin/crm',
            require => [Package[$pacemaker::params::packages], File['crmsh'], Exec['install pssh']]
          }
        }
        default:{}
      }
    }
    default:{}
  }

  package {'pacemaker':
    ensure  => 'present',
    require => Package[$pacemaker::params::packages]
  }
}
