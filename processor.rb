require 'beaneater'
require 'json'
require 'redis'

TUBE_NAME = 'factorial'
beaneater = Beaneater::Pool.new(['localhost:11300'])
tube = beaneater.tubes[TUBE_NAME]
redis = Redis.new
loop do
  job = tube.reserve
  puts "Start Processing ID: "+ job.body
  #set status as processing
  params = JSON.parse(redis.get TUBE_NAME + job.body)
  params[:status] = :processing
  redis.set TUBE_NAME + job.body, params.to_json

  #get fact base
  fact_base = params["param"].to_i
  result = ((1..fact_base).inject(:*) || 1).to_s

  #update status in memory
  params[:status] = :done
  params[:result] = result
  redis.set TUBE_NAME + job.body, params.to_json
  puts "Stop Processing ID: "+ job.body # prints "hello"
  job.delete
end