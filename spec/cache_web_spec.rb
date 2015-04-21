require './cache'
require 'pp'

describe Cache do
        describe "a cache should be able to get requests " do
              before do
                server = 'https://treode_testing_server.com/'
                port=80
                max_age = nil
                no_cache = false
                @cache =  Cache.new(server, port , max_age, no_cache)
              end
             
             
        end
        
end