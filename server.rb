require 'beaneater'
require 'redis'
require 'logger'
require 'json'
class Server
  def initialize
    @beaneater = Beaneater::Pool.new ["localhost:11300"]
    @tube = @beaneater.tubes["mytube"]
    @logger = Logger.new(STDOUT)
  end

  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    hash_response = {}
    json_data = JSON.parse(request.body.read)
    @logger.info json_data
    if (json_data && json_data["command"] == 'factorial')
        hash_response = FactorialProcessor.process json_data["params"]
    else
        hash_response = { :result => :error, :message => "invalid request"}
    end
    response.body = [hash_response.to_json.to_s]
    response.status = 200
    
    response.finish
  end

end

class FactorialProcessor
    def self.process params
        ##put into queue
        { :id => '111'}
    end
end
