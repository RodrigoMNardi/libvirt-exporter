require 'sinatra/base'

require_relative 'libvirt'

module Exporter
  class Collector < Sinatra::Base
    def initialize(app = nil)
      super
    end

    get '/metrics' do
      msg = Exporter::PrometheusLibvirt.export
      File.write('metrics.txt', msg)
      send_file 'metrics.txt'
    end
  end
end
