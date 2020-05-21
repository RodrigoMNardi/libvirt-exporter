require 'libvirt'
require 'sinatra/base'

Dir.entries("#{File.dirname(__FILE__)}/lib").each do |entry|
  file = "#{File.dirname(__FILE__)}/lib/#{entry}"
  next if %w(. ..).include? entry
  require_relative file
end

class Collector < Sinatra::Base
  include Basic
  include Domains
  include Interfaces
  include Node
  include Storage

  def initialize(app = nil)
    @conn = Libvirt::open("qemu:///system")
    super
  end

  get '/metrics' do
    erb :'metrics.html'
  end
end
