require 'bundler/setup'
require 'beaneater'
require 'json'
require 'logger'
 
@processing = true
@bt = Beaneater::Pool.new ["localhost:11300"]
@logger = Logger.new(STDOUT)
 
def process_job job
  body = JSON.parse job.body
  @logger.info body.inspect
  parsed_job = body["job"]
  case parsed_job["type"]
    when "quit" then @processing = false
  end
  job.delete
end
 
while @processing do
    job = @bt.tubes.reserve
    @logger.info job.inspect
    process_job job
end