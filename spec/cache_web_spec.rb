require './cache'
require 'pp'

describe Cache do
  describe "a cache should be able to get requests " do
    before do
      @server = 'https://treode.testing.server.com/'
      port=80
      max_age = nil
      no_cache = false
      @cache =  Cache.new(@server, port , max_age, no_cache)
    end

    it "should be able to query the server" do
      uri = URI(@server)
      response = Net::HTTP.get(uri)
      expect(response).to be_an_instance_of(String)
    end
    

  end

end
