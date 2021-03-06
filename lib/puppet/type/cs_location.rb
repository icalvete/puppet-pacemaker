module Puppet
  newtype(:cs_location) do
    @doc = "Type for manipulating corosync/pacemaker location.  Location
      may be used to do asymmetrical clusters.

      More information on Corosync/Pacemaker location can be found here:

      * http://clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/_deciding_which_nodes_a_resource_can_run_on.html"

    ensurable

    newparam(:name) do
      desc "Identifier of the colocation entry.  This value needs to be unique
        across the entire Corosync/Pacemaker configuration since it doesn't have
        the concept of name spaces per type."

      isnamevar
    end
    
    newproperty(:primitive) do
      desc "Corosync resource active in x_node."
    end
    
    newproperty(:x_node) do
      desc "Corosync x_node for resource."
    end

    newparam(:cib) do
      desc "Corosync applies its configuration immediately. Using a CIB allows
        you to group multiple primitives and relationships to be applied at
        once. This can be necessary to insert complex configurations into
        Corosync correctly.

        This paramater sets the CIB this colocation should be created in. A
        cs_shadow resource with a title of the same name as this value should
        also be added to your manifest."
    end

    newproperty(:score) do
      desc "The priority of this colocation.  Primitives can be a part of
        multiple colocation groups and so there is a way to control which
        primitives get priority when forcing the move of other primitives.
        This value can be an integer but is often defined as the string
        INFINITY."

        defaultto 'INFINITY'
    end

    autorequire(:cs_shadow) do
      [ @parameters[:cib] ]
    end

    autorequire(:service) do
      [ 'corosync' ]
    end

    autorequire(:cs_primitive) do
      autos = []

      autos << unmunge_cs_primitive(@parameters[:primitive].should)

      autos
    end

    def unmunge_cs_primitive(name)
      name = name.split(':')[0]
      if name.start_with? 'ms_'
        name = name[3..-1]
      end

      name
    end
  end
end
