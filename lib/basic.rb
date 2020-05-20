module Basic
  def capabilities
    @conn.capabilities
  end

  def hypervisor_version
    @conn.version
  end

  def libvirt_version
    @conn.libversion
  end

  def hostname
    @conn.hostname
  end

  def uri
    @conn.uri
  end

  def vcpus
    @conn.max_vcpus
  end

  def connection_type
    @conn.type
  end
end
