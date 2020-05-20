module Node
  def node_info
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

  def hypervision_memory_usage
    @conn.node_free_memory
  end
end
