require 'rubygems'
require 'rack'

app = proc do |env|
    html = 'It is alive!';
    Rack::Response.new(html, 200).finish
end
 
run app
