require 'libvirt'
require_relative 'lib/basic'
require_relative 'lib/domains'
require_relative 'lib/interfaces'

class Collector
  include Basic
  include Domains
  include Interfaces

  def initialize
    @conn = Libvirt::open("qemu:///system")
  end
end
