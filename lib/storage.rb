module Storage
  def active_num_storage_pool
    @conn.num_of_storage_pools
  end

  def inactive_num_storage_pool
    @conn.num_of_defined_storage_pools
  end

  def storage_pools
    active = @conn.list_storage_pools
    inactive = @conn.list_defined_storage_pools
    (active+inactive).map{|pool_name| pool_name}
  end
end
