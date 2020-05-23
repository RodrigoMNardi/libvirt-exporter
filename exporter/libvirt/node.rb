require 'nokogiri'
module Exporter
  module PrometheusLibvirt
    module Node
      def libvirt_capabilities
        @conn.capabilities
      end

      def libvirt_hypervisor_version
        @conn.version
      end

      def libvirt_version
        @conn.libversion
      end

      def libvirt_hostname
        @conn.hostname
      end

      def libvirt_uri
        @conn.uri
      end

      def libvirt_vcpus
        @conn.max_vcpus
      end

      def libvirt_connection_type
        @conn.type
      end

      def libvirt_num_interfaces
        @conn.num_of_interfaces
      end

      def libvirt_active_interfaces
        @conn.list_interfaces.size
      end

      def libvirt_inactive_interfaces
        @conn.num_of_defined_interfaces.size
      end

      def libvirt_interfaces
        active = @conn.list_interfaces
        inactive = @conn.list_defined_interfaces
        (active+inactive).map {|interface_name| interface_name}
      end

      def libvirt_num_networks
        @conn.num_of_networks
      end

      def libvirt_active_networks
        @conn.num_of_defined_networks
      end

      def libvirt_inactive_networks
        @conn.num_of_networks
      end

      def libvirt_node_devices
        @conn.num_of_nodedevices
      end

      def libvirt_node_list
        @conn.list_nodedevices.map {|node_name| node_name}
      end

      def libvirt_node_status
        nodeinfo = @conn.node_get_info
        {
          model:     nodeinfo.model,
          memory:    nodeinfo.memory,
          cpus:      nodeinfo.cpus,
          frequency: nodeinfo.mhz,
          nodes:     nodeinfo.nodes,
          sockets:   nodeinfo.sockets,
          cores:     nodeinfo.cores,
          threads:   nodeinfo.threads,
        }
      end

      def libvirt_memory_usage
        cellsmem = @conn.node_cells_free_memory
        nodes = {}
        cellsmem.each_with_index do |cell,index|
          nodes[index] = cell
        end
        nodes
      end

      def libvirt_node_memory_stats
        @conn.node_memory_stats
      end

      def libvirt_node_free_memory
        @conn.node_free_memory
      end

      def libvirt_node_cells_free_memory
        @conn.node_cells_free_memory
      end

      def libvirt_node_cpu_stats
        @conn.node_cpu_stats
      end

      def libvirt_hypervision_memory_usage
        @conn.node_free_memory
      end

      def libvirt_num_domains
        @conn.num_of_domains
      end

      def libvirt_domains_info
        domains = {}
        @conn.list_domains.each do |domain_id|
          dom        = @conn.lookup_domain_by_id(domain_id)
          xml        = dom.xml_desc
          interfaces = get_interface_name(xml)
          filename   = get_disk_name(xml)
          domains[dom.name] = {
            cpu_time: dom.info.cpu_time,
            max_mem: dom.info.max_mem, memory: dom.info.memory,
            nr_virt_cpu: dom.info.nr_virt_cpu, state: dom.info.state,
            errs: 0,
            rd_bytes: 0, rd_req: 0,
            wr_bytes: 0, wr_req: 0
          }

          if filename
            stats = dom.block_stats(filename)
            domains[dom.name][:errs]     = stats.errs
            domains[dom.name][:rd_bytes] = stats.rd_bytes
            domains[dom.name][:rd_req]   = stats.rd_req
            domains[dom.name][:wr_bytes] = stats.wr_bytes
            domains[dom.name][:wr_req]   = stats.wr_req

            disk_size = dom.blockinfo(filename)
            domains[dom.name][:capacity]   = disk_size.capacity
            domains[dom.name][:allocation] = disk_size.allocation
            domains[dom.name][:physical]   = disk_size.physical
          end

          unless interfaces.empty?
            domains[dom.name][:net_stats] = {}
            interfaces.each do |iface|
              begin
                iface_info = dom.ifinfo(iface)
                domains[dom.name][:net_stats][iface]              = {}
                domains[dom.name][:net_stats][iface][:rx_bytes]   = iface_info.rx_bytes
                domains[dom.name][:net_stats][iface][:rx_drop]    = iface_info.rx_drop
                domains[dom.name][:net_stats][iface][:rx_errs]    = iface_info.rx_errs
                domains[dom.name][:net_stats][iface][:rx_packets] = iface_info.rx_packets
                domains[dom.name][:net_stats][iface][:tx_bytes]   = iface_info.tx_bytes
                domains[dom.name][:net_stats][iface][:tx_drop]    = iface_info.tx_drop
                domains[dom.name][:net_stats][iface][:tx_errs]    = iface_info.tx_errs
                domains[dom.name][:net_stats][iface][:tx_packets] = iface_info.tx_packets
              rescue Libvirt::RetrieveError => e
                puts e
              end

            end
          end
        end
        domains
      end

      def libvirt_active_domains
        @conn.list_domains.size
      end

      def libvirt_inactive_domains
        @conn.list_defined_domains.size
      end

      def libvirt_active_num_storage_pool
        @conn.num_of_storage_pools
      end

      def libvirt_inactive_num_storage_pool
        @conn.num_of_defined_storage_pools
      end

      def libvirt_storage_pools
        active = @conn.list_storage_pools
        inactive = @conn.list_defined_storage_pools
        (active+inactive).map{|pool_name| pool_name}
      end

      private

      def get_disk_name(xml)
        Nokogiri::XML(xml).xpath('//devices').each do |devices|
          devices.xpath('//disk').each do |disk|
            disk.xpath('//source').each do |source|
              return source.attributes['file'].value if source.attributes.key? 'file'
            end
          end
        end
        nil
      end

      def get_interface_name(xml)
        interfaces = []
        Nokogiri::XML(xml).xpath('//devices').each do |devices|
          devices.xpath('//interface').each do |interface|
            interface.xpath('//target').each do |target|
              interfaces << target.attributes['dev'].value if target.attributes.key? 'dev'
            end
          end
        end
        interfaces
      end
    end
  end
end
