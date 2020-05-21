module Interfaces
  def num_interfaces
    @conn.num_of_interfaces
  end

  def active_interfaces
    @conn.list_interfaces.size
  end

  def inactive_interfaces
    @conn.num_of_defined_interfaces.size
  end

  def interfaces
    active = @conn.list_interfaces
    inactive = @conn.list_defined_interfaces
    (active+inactive).map {|interface_name| interface_name}
  end

  def num_networks
    @conn.num_of_networks
  end

  def active_networks
    @conn.num_of_defined_networks
  end

  def inactive_networks
    @conn.num_of_networks
  end

  def node_devices
    @conn.num_of_nodedevices
  end

  def node_list
    @conn.list_nodedevices.map {|node_name| node_name}
  end
end
