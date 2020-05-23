require 'sinatra'
require_relative 'exporter/collector'

$OSv_URL = '0.0.0.0:45678'

run Exporter::Collector
