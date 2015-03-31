require './cache'
require 'pp'

describe Cache do
        describe "a default cache " do
              before do
                @cache = Cache.new(10)
              end
             
              it "should have a default LRU Policy" do
                expect(@cache.policy).to eq('LRU')
              end
             
              it "should have a limit " do
                expect(@cache.limit).to eq(10)
              end
              
              it "should start at a current_size of 0 " do
                expect(@cache.current_size).to eq(0)
              end
        end
        
        describe "a cache with one object  " do
              before do
                @cache = Cache.new(10)
                @cache.write("a", "dinosaur", 5)
              end
             
              it "should have a default LRU Policy" do
                expect(@cache.policy).to eq('LRU')
              end
             
              it "should have a limit" do
                expect(@cache.limit).to eq(10)
              end
              
              it "should have a current_size of 5" do
                expect(@cache.current_size).to eq(5)
              end
              
              it "should have 5 in the cache" do
                expect(@cache.in_cache.size).to eq(1)
              end
              
              it "should have 'a' in the buffer" do
                expect(@cache.bufPQ).to eq(["a"])
              end
              
              it "should be able to read 'a' from the cache " do
                expect(@cache.read("a")).to eq("dinosaur")
              end
              
            it "should be able to read a value not in the cache as nil" do
                expect(@cache.read('z')).to eq(nil)
              end
        end
        
        describe "a cache with objects falling out of cache" do
              before do
                @cache = Cache.new(10)
                @cache.write("a", "lorem", 3)
                @cache.write("b", "ipsum", 4)
                @cache.write("c", "delor", 5)
              end
             
              it "should have a default LRU Policy" do
                expect(@cache.policy).to eq('LRU')
              end
             
              it "should have a limit " do
                expect(@cache.limit).to eq(10)
              end
              
              it "should have a current_size of 9 " do
                expect(@cache.current_size).to eq(9)
              end
                          
              it "should not be able to read 'a' from the cache " do
                expect(@cache.read('a')).to eq(nil)
              end
              
              it "should be able to read 'c' from the cache " do
                expect(@cache.read('c')).to eq("delor")
              end
              
              it "should be able to read a value not in the cache as nil" do
                expect(@cache.read('z')).to eq(nil)
              end

              it "should be able to update a value" do
                @cache.write("c", "epsom", 6)
                expect(@cache.read('c')).to eq('epsom')
              end
              
        end
        
        describe "a cache should be safe for multithreaded writes" do
            before do
                @cache = Cache.new(30)
            end
            
            it "should maintain its size " do
                100.times do
                    Thread.new do
                        @cache.write(rand(30), rand(30), rand(30) )
                    end
                end
                expect(@cache.current_size).to be <= 30
            end
        end
        
end