module Node
  def node_status
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

  def memory_usage
    cellsmem = @conn.node_cells_free_memory
    nodes = {}
    cellsmem.each_with_index do |cell,index|
      nodes[index] = cell
    end
    nodes
  end

  def node_memory_stats
    @conn.node_memory_stats
  end

  def node_free_memory
    @conn.node_free_memory
  end

  def node_cells_free_memory
    @conn.node_cells_free_memory
  end

  def node_cpu_stats
    @conn.node_cpu_stats
  end

  def hypervision_memory_usage
    @conn.node_free_memory
  end
end
