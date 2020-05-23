require 'libvirt'
require_relative 'libvirt/node'
module Exporter
  module PrometheusLibvirt

    class << self
      include Exporter::PrometheusLibvirt::Node

      def export
        @conn = Libvirt::open("qemu:///system")
        msg  = "# Active domains
libvirt_domains_total #{libvirt_num_domains}
# Inactive domains
libvirt_domains_active #{libvirt_active_domains}
# Inactive domains
libvirt_domains_inactive #{libvirt_inactive_domains}
# Get domains information
"
        libvirt_domains_info.each_pair do |domain, info|
          msg += "libvirt_domains_cpu_time{domain=\"#{ domain }\"} #{ info[:cpu_time] }
libvirt_domains_max_mem{domain=\"#{ domain }\"} #{ info[:max_mem] }
libvirt_domains_memory{domain=\"#{ domain }\"} #{ info[:memory] }
libvirt_domains_nr_virt_cpu{domain=\"#{ domain }\"} #{ info[:nr_virt_cpu] }
libvirt_domains_state{domain=\"#{ domain }\"} #{ info[:state] }
libvirt_domains_disk_errors{domain=\"#{ domain }\"} #{ info[:errs] }
libvirt_domains_disk_read_bytes{domain=\"#{ domain }\"} #{ info[:rd_bytes] }
libvirt_domains_disk_read_requests{domain=\"#{ domain }\"} #{ info[:rd_req] }
libvirt_domains_disk_write_bytes{domain=\"#{ domain }\"} #{ info[:wr_bytes] }
libvirt_domains_disk_write_requests{domain=\"#{ domain }\"} #{ info[:wr_req] }
libvirt_domains_disk_capacity{domain=\"#{ domain }\"} #{ info[:capacity] }
libvirt_domains_disk_allocation{domain=\"#{ domain }\"} #{ info[:allocation] }
libvirt_domains_disk_physical{domain=\"#{ domain }\"} #{ info[:physical] }
          "
          info[:net_stats].each_pair do |iface, data|
            msg += "libvirt_domains_network_rx_bytes{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:rx_bytes]}
libvirt_domains_network_rx_drop{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:rx_drop]}
libvirt_domains_network_rx_errs{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:rx_errs]}
libvirt_domains_network_rx_packets{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:rx_packets]}
libvirt_domains_network_tx_bytes{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:tx_bytes]}
libvirt_domains_network_tx_drop{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:tx_drop]}
libvirt_domains_network_tx_errs{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:tx_errs]}
libvirt_domains_network_tx_packets{domain=\"#{ domain }\", iface=\"#{iface}\"} #{data[:tx_packets]}"
          end
        end

        msg + "
# Total of interfaces
libvirt_interfaces_total #{ libvirt_num_interfaces }
# Active interfaces
libvirt_interfaces_active #{ libvirt_active_interfaces }
# Inactive interfaces
libvirt_interfaces_inactive #{ libvirt_inactive_interfaces }
# Total of networks
libvirt_networks_total #{ libvirt_num_networks }
# Active networks
libvirt_networks_active #{ libvirt_active_networks }
# Inactive networks
libvirt_networks_inactive #{ libvirt_inactive_networks }
# Hypervision version
libvirt_hypervisor_version{name=\"#{ libvirt_connection_type }\"} #{ libvirt_hypervisor_version }
# Libvirt version
libvirt_version #{ libvirt_version }
# Virtual CPUs
libvirt_virtual_cpus #{ libvirt_vcpus }
        "
      end
    end
  end
end