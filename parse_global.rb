require 'awesome_print'
require 'pry'

class ExtractData
  REGEX = /.*method=(?<method>(\w*)) .*path=(?<path>(\w|\/)*).*ip_camera="(?<ip_camera>(.*))".*home_id=(?<home_id>(.*)) connect=(?<connect_ms>(\d+)).*service=(?<service_ms>(\d+))/


  def initialize(log_file)
    @log_file = log_file
    @requests = []
    parse_file
  end

  def number_every_camera
    data = @requests.map{|log| log[:ip_camera] }
    data.inject(Hash.new(0)) {|h, v| h[v] += 1; h}
  end

  def number_requests
    @requests.count
  end

  def global_stas
    {
      number_every_camera: number_every_camera,
      number_requests: number_requests
    }
  end

  def save_in_fine(file)
    stats = global_stas
    stats.sort{|a,b| b}
  end

  def average_of_connect_time
    data = @requests.map{|log| log[:connect] }
    @avg_connect = data.inject{ |sum, el| sum + el }.to_f / data.size
  end

  def average_of_service_time
    data = @requests.map{|log| log[:service] }
    @avg_service = data.inject{ |sum, el| sum + el }.to_f / data.size
  end

  def average_of_response_time
    avg_response =  @avg_connect + @avg_service
  end

  def median_of_connect_time
    data = @requests.map{|log| log[:connect] }
    sorted = data.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def median_of_service_time
    data = @requests.map{|log| log[:service] }
    sorted = data.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def median_of_response_time
  data = @requests.map{|log| log[:response] = log[:connect] + log[:service] }
  sorted = data.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def mode_of_connect_time
  data = @requests.map{|log| log[:connect] }
  mode = data.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  max = mode.max_by{|k,v| v}
  max[0]
  end

  def mode_of_service_time
    data = @requests.map{|log| log[:service] }
    mode = data.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    max = mode.max_by{|k,v| v}
    max[0]
  end

  def mode_of_response_time
    data = @requests.map{|log| log[:response] = log[:connect] + log[:service] }
    mode = data.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    max = mode.max_by{|k,v| v}
    max[0]
  end

  def select_url
   @requests.each do |log|
      if log[:url].include? "get_camera"
        @array_get_camera << log
      elsif log[:url].include? "get_home"
      @array_get_home << log
      elsif log[:url].include? "get_all_cameras"
      @array_get_all_cameras << log
      elsif log[:method] == ("POST") && (log[:url].include? "/api/users")
      @array_post_users << log
      elsif log[:method] = ("GET") && (log[:url].include? "/api/users")
        @array_get_users << log
      end
    end
  end

  #def ranking_of_devices
    #data = @requests.map
    #end
  #end

private

  def parse_file
    logs = File.readlines(@log_file)
    logs.each do |log|
    @requests << parse_request(log)
    end
  end

  def parse_request(log)
    match_data = log.match(REGEX)
    id = match_data[:path].match(/\d+/)
    user_id = id ? id[0] : nil

    {
      user_id: user_id,
      home_id: match_data[:home_id],
      ip_camera: match_data[:ip_camera],
      connect: match_data[:connect_ms].to_i,
      service: match_data[:service_ms].to_i,
      url: match_data[:path],
      method: match_data[:method]
    }
  end
end



ed = ExtractData.new('sample_appysphere.log')
ed.save_in_fine("file_out")
ed.number_every_camera
ap ed.average_of_connect_time
ap ed.average_of_service_time
ap ed.average_of_response_time
ap ed.median_of_connect_time
ap ed.median_of_service_time
ap ed.median_of_response_time
ap ed.mode_of_connect_time
ap ed.mode_of_service_time
ap ed.mode_of_response_time
#ed.ranking_of_devices

