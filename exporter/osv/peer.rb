require 'rest-client'
require 'json'
module Exporter
  module PrometheusOsv
    module Peer
      def stats
        begin
          resp = RestClient.get "#{$OSv_URL}/peers"
          return '' if resp.nil?
          json = JSON.parse(resp)
          return '' if json.nil? or json.empty?
        rescue Exception
          return ''
        end

        info = {established_count: 0, idle_count: 0, unknown_counter: 0, peers: {}}
        json.each do |entry|
          info[:established_count] += 1 if entry.key? :state and entry[:state].capitalize == 'Established'
          info[:idle_count] += 1        if entry.key? :state and entry[:state].capitalize == 'Idle'
          info[:unknown_counter] += 1   if !entry.key? :state
          info[:peers][entry[:address]] =
            {
              id:        entry[:id],
              local_as:  entry[:local_as],
              remote_as: entry[:remote_as],
              opens:     (entry.key? :opens)? entry[:opens] : 0,
              queue:     (entry.key? :queue)? entry[:queue] : 0,
              state:     (entry.key? :state)? entry[:state] : 'Unknown',
              updates:   (entry.key? :updates)? entry[:updates] : 0,
            }
        end
        info
      end
    end
  end
end
