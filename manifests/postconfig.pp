class pacemaker::postconfig (

  $asymetrical = false

) {

  cs_property{'cs_stonith-enabled':
    name  => 'stonith-enabled',
    value => 'false'
  }

  # With 2 nodes we cannot attain a quorum
  cs_property{'cs_no-quorum-policy':
    name  => 'no-quorum-policy',
    value => 'ignore'
  }

  if $asymetrical {
    cs_property{'symmetric-cluster':
      name  => 'symmetric-cluster',
      value => 'false'
    }
  }
}
