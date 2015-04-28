require './cache'
require 'pp'

describe Cache do
        describe "a default cache " do
              before do
                server = 'https://treode_testing_server.com/'
                port=80
                max_age = nil
                no_cache = false
                @cache =  Cache.new(server, port , max_age, no_cache)
              end
             
              it "should have a connection " do 
                expect(@cache.connection).to_not be_nil
              end
              
              it "should have a server " do 
                expect(@cache.server).to eq('https://treode_testing_server.com/')
              end
              
              it "should have a port" do 
                expect(@cache.port).to eq(80)
              end
              
              it "should have a max_age" do
                expect(@cache.max_age).to eq(nil)
              end
              
              it "should have a no_cache parameter" do 
                expect(@cache.no_cache).to eq(false)
              end
        end
        
        describe "a cache with objects being inserted" do
              before do
                server = 'https://treode_testing_server.com/'
                port=80
                max_age = nil
                no_cache = false
                @cache =  Cache.new(server, port , max_age, no_cache)
              end

              it "should evict objects that are least recently used" do
              end
              
        end
        
        # describe "a cache with objects falling out of cache" do
        #       before do
        #         server = 'https://treode_testing_server.com/'
        #         port=80
        #         max_age = nil
        #         no_cache = false
        #         @cache =  Cache.new(server, port , max_age, no_cache)
        #         @cache.write("a", "lorem", 3)
        #         @cache.write("b", "ipsum", 4)
        #         @cache.write("c", "delor", 5)
        #       end
             
        #       it "should have a default LRU Policy" do
        #         expect(@cache.policy).to eq('LRU')
        #       end
             
        #       it "should have a limit " do
        #         expect(@cache.limit).to eq(10)
        #       end
              
        #       it "should have a current_size of 9 " do
        #         expect(@cache.current_size).to eq(9)
        #       end
                          
        #       it "should not be able to read 'a' from the cache " do
        #         expect(@cache.read('a')).to eq(nil)
        #       end
              
        #       it "should be able to read 'c' from the cache " do
        #         expect(@cache.read('c')).to eq("delor")
        #       end
              
        #       it "should be able to read a value not in the cache as nil" do
        #         expect(@cache.read('z')).to eq(nil)
        #       end

        #       it "should be able to update a value" do
        #         @cache.write("c", "epsom", 6)
        #         expect(@cache.read('c')).to eq('epsom')
        #       end
              
        # end
        
        # describe "a cache should be safe for multithreaded writes" do
        #     before do
        #         server = 'https://treode_testing_server.com/'
        #         port=80
        #         max_age = nil
        #         no_cache = false
        #         @cache =  Cache.new(server, port , max_age, no_cache)
        #     end
            
        #     it "should maintain its size " do
        #         100.times do
        #             Thread.new do
        #                 @cache.write(rand(30), rand(30), rand(30) )
        #             end
        #         end
        #         expect(@cache.current_size).to be <= 30
        #     end
        # end
        
end