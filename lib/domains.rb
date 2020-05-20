module Domains
  def num_domains
    @conn.num_of_domains
  end

  def domains
    domains = []
    @conn.list_domains.each do |domain_id|
      dom = conn.lookup_domain_by_id(domain_id)
      domains << dom.name
    end
    domains
  end

  def domains_info
    domains = {}
    @conn.list_domains.each do |domain_id|
      dom = conn.lookup_domain_by_id(domain_id)
      domains[dom.name] = {cpu_time: dom.cpu_time,
                           max_mem: dom.max_mem, memory: dom.memory,
                           nr_virt_cpu: dom.nr_virt_cpu, state: dom.state}
    end
    domains
  end

  def domains_block_states
    domains = {}
    @conn.list_domains.each do |domain_id|
      dom = conn.lookup_domain_by_id(domain_id)
      domains[dom.name] = {errs: dom.errs,
                           rd_bytes: dom.rd_bytes, rd_req: dom.rd_req,
                           wr_bytes: dom.wr_bytes, wr_req: dom.wr_req}
    end
    domains
  end

  def inactive_domains
    @conn.num_of_defined_domains
  end

  def inactive_domain_names
    @conn.list_defined_domains.map{|domain_name| domain_name}
  end
end
