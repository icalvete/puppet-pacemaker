class pacemaker::service {

  # Pacemaker service is managed by cluster infrastructure layer ( Like any other cluster resource )
  # So, here we up cluster infrastructure service.
  include pacemaker::corosync::service
}
