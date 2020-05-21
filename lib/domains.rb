require 'nokogiri'
module Domains
  def num_domains
    @conn.num_of_domains
  end

  def domains_info
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

  def active_domains
    @conn.list_domains.size
  end

  def inactive_domains
    @conn.list_defined_domains.size
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
