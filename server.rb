require 'logger'
require 'json'
require 'beaneater'
require 'redis'
require 'securerandom'
#
# how to add job

# curl -v -H "Content-type: application/json" 
# -d '{"action":"factorial","command":"addjob","params":{"value":"300"}}' 
# http://localhost:9292

# checkjob - by id
class Server
  def initialize
    @logger = Logger.new(STDOUT)
    @beaneater = Beaneater::Pool.new(['localhost:11300'])
    @redis = Redis.new
  end

  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    hash_response = {}
    json_data = JSON.parse(request.body.read)
    @logger.info json_data
    if (json_data && json_data["action"] == 'factorial')
        hash_response = FactorialProcessor.new(@beaneater, @redis).process json_data
    else
        hash_response = { :result => :error, :message => "invalid request"}
    end
    response.body = [hash_response.to_json.to_s]
    response.status = 200
    response.finish
  end

end

class FactorialProcessor
    TUBE_NAME = 'factorial'

    def initialize beaneater,redis
        @tube = beaneater.tubes[TUBE_NAME]
        @redis = redis
    end

    def process params
        result = {}
        command_name = params['command'].to_sym
        if self.respond_to? command_name
            result = self.send(command_name, params)
        else
            result['error'] = 'Unknown action name'
        end 
        result
    end

    def addjob params
        id = SecureRandom.hex
        job = {}
        job[:id] = id
        job[:status] = :enqueued
        job[:param] = params['params']['value'].to_i
        @redis.set TUBE_NAME + id, job.to_json
        @tube.put id
        job
    end

    def checkjob params
        id = params['params']['id']
        job = JSON.parse(@redis.get TUBE_NAME + id)
        job
    end
    def quit #TO DO
    end

    def cleanup # TO DO
    end

    def status params
        stats = @tube.stats
        result = {}
        stats.instance_variables.each do |var|
             result[var.to_s.delete("@")] = stats.instance_variable_get(var)
        end
        result['hash']
    end
end

