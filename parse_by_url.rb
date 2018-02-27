require 'awesome_print'
require 'pry'

class ExtractData
  REGEX = /.*method=(?<method>(\w*)) .*path=(?<path>(\w|\/)*).*ip_camera="(?<ip_camera>(.*))".*home_id=(?<home_id>(.*)) connect=(?<connect_ms>(\d+)).*service=(?<service_ms>(\d+))/


  def initialize(log_file)
    @log_file = log_file
    @requests = []
    @array_get_camera = []
    @array_get_home = []
    @array_get_all_cameras = []
    @array_post_users = []
    @array_get_users = []
    parse_file
    select_url
  end

  def number_every_camera_for(array)
    data = array.map{|log| log[:home_id] }
    data.inject(Hash.new(0)) {|h, v| h[v] += 1; h}
  end

  def number_every_camera
    number_every_camera_hash = {}
    number_every_camera_hash[:get_camera] = number_every_camera_for(@array_get_camera)
    number_every_camera_hash[:get_home] = number_every_camera_for(@array_get_home)
    number_every_camera_hash[:get_all_cameras] = number_every_camera_for(@array_get_all_cameras)
    number_every_camera_hash[:post_users] = number_every_camera_for(@array_post_users)
    #number_every_camera_hash[:get_users] = number_every_camera_for(@array_get_users)
    number_every_camera_hash
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

  def save_in_fine
   stats = global_stas
  end

  def average_of_connect_time(array)
    data = array.map{|log| log[:connect] }
    avg_connect = data.inject{ |sum, el| sum + el }.to_f / data.size
  end


  def average_of_service_time(array)
    data = array.map{|log| log[:service] }
    avg_service = data.inject{ |sum, el| sum + el }.to_f / data.size
  end

  def average_of_response_time_for(array)
    avg_response =  average_of_connect_time(array) + average_of_service_time(array)
  end

  def average_of_response_time
    average_response_time_hash = {}
    average_response_time_hash[:get_camera] = average_of_response_time_for(@array_get_camera)
    average_response_time_hash[:get_home] = average_of_response_time_for(@array_get_home)
    average_response_time_hash[:get_all_cameras] = average_of_response_time_for(@array_get_all_cameras)
    average_response_time_hash[:post_users] = average_of_response_time_for(@array_post_users)
    average_response_time_hash[:get_users] = average_of_response_time_for(@array_get_users)
    average_response_time_hash
  end



  def median_of_connect_time
    median_connect_time_hash = {}
    median_connect_time_hash[:get_camera] = median_of_connect_time_for(@array_get_camera)
    median_connect_time_hash[:get_home] = median_of_connect_time_for(@array_get_home)
    median_connect_time_hash[:get_all_cameras] = median_of_connect_time_for(@array_get_all_cameras)
    median_connect_time_hash[:post_users] = median_of_connect_time_for(@array_post_users)
    #median_connect_time_hash[:get_users] = median_of_connect_time_for(@array_get_users)
    median_connect_time_hash
  end

  def median_of_connect_time_for(array)
    data = array.map{|log| log[:connect] }
    sorted = data.sort
    len = sorted.length
    final = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def median_of_service_time
    median_service_time_hash = {}
    median_service_time_hash[:get_camera] = median_of_service_time_for(@array_get_camera)
    median_service_time_hash[:get_home] = median_of_service_time_for(@array_get_home)
    median_service_time_hash[:get_all_cameras] = median_of_service_time_for(@array_get_all_cameras)
    median_service_time_hash[:post_users] = median_of_service_time_for(@array_post_users)
    #median_service_time_hash[:get_users] = median_of_service_time_for(@array_get_users)
    median_service_time_hash
  end

  def median_of_service_time_for(array)
    data = array.map{|log| log[:service] }
    sorted = data.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def median_of_response_time
    median_response_time_hash = {}
    median_response_time_hash[:get_camera] = median_of_response_time_for(@array_get_camera)
    median_response_time_hash[:get_home] = median_of_response_time_for(@array_get_home)
    median_response_time_hash[:get_all_cameras] = median_of_response_time_for(@array_get_all_cameras)
    median_response_time_hash[:post_users] = median_of_response_time_for(@array_post_users)
    #median_response_time_hash[:get_users] = median_of_response_time_for(@array_get_users)
    median_response_time_hash
  end

  def median_of_response_time_for(array)
  data = array.map{|log| log[:response] = log[:connect] + log[:service] }
  sorted = data.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def mode_of_connect_time
    mode_connect_time_hash = {}
    mode_connect_time_hash[:get_camera] = mode_of_connect_time_for(@array_get_camera)
    mode_connect_time_hash[:get_home] = mode_of_connect_time_for(@array_get_home)
    mode_connect_time_hash[:get_all_cameras] = mode_of_connect_time_for(@array_get_all_cameras)
    mode_connect_time_hash[:post_users] = mode_of_connect_time_for(@array_post_users)
    #mode_connect_time_hash[:get_users] = mode_of_connect_time_for(@array_get_users)
    mode_connect_time_hash
  end

  def mode_of_connect_time_for(array)
  data = array.map{|log| log[:connect] }
  mode = data.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  max = mode.max_by{|k,v| v}
  max[0]
  end

  def mode_of_service_time
    mode_service_time_hash = {}
    mode_service_time_hash[:get_camera] = mode_of_service_time_for(@array_get_camera)
    mode_service_time_hash[:get_home] = mode_of_service_time_for(@array_get_home)
    mode_service_time_hash[:get_all_cameras] = mode_of_service_time_for(@array_get_all_cameras)
    mode_service_time_hash[:post_users] = mode_of_service_time_for(@array_post_users)
    #mode_service_time_hash[:get_users] = mode_of_service_time_for(@array_get_users)
    mode_service_time_hash
  end

  def mode_of_service_time_for(array)
    data = array.map{|log| log[:service] }
    mode = data.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    max = mode.max_by{|k,v| v}
    max[0]
  end


def mode_of_response_time
    mode_response_time_hash = {}
    mode_response_time_hash[:get_camera] = mode_of_response_time_for(@array_get_camera)
    mode_response_time_hash[:get_home] = mode_of_response_time_for(@array_get_home)
    mode_response_time_hash[:get_all_cameras] = mode_of_response_time_for(@array_get_all_cameras)
    mode_response_time_hash[:post_users] = mode_of_response_time_for(@array_post_users)
    #mode_response_time_hash[:get_users] = mode_of_response_time_for(@array_get_users)
    mode_response_time_hash
  end

  def mode_of_response_time_for(array)
    data = array.map{|log| log[:response] = log[:connect] + log[:service] }
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
      elsif (log[:method] == "POST") && (log[:url].include? "/api/users")
        @array_post_users << log
      elsif (log[:method] = "GET") && (log[:url].match("/api.users.\d+/"))
        @array_get_users << log
      end
    end
  end

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
ap ed.save_in_fine
#ed.number_every_camera
ap ed.average_of_response_time
#ed.median_of_connect_time
#ed.median_of_service_time
ap ed.median_of_response_time
#ed.mode_of_connect_time
#ed.mode_of_service_time
ap ed.mode_of_response_time



