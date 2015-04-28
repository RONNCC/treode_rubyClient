require_relative './DLL'
require_relative './TxClock'
require_relative './HTTPInterface'
require 'monitor'
require 'algorithms'
require 'json'


# current behavior is not as expected for repeats of a value
# as we require the cache_object to be unique - otherwise we don't have
# a unique index

# right now if you try to add "a" and "a" is already in it, it will do nothing
# as expected


# we assume one shared Cache among all connections
# hence we use instance variables rather than
# explicit class locking

#design detail: if we write (object "a",size 5, value 3 )
# =>            then we write (object "a", size 6, value 4)
# =>            then we consider that the old value being updated make space for it
# =>            and update it in the LRU cache

class Cache
  attr_accessor :server, :port, :max_age, :no_cache, :connection
  # server args
  def initialize(server, port=80, max_age=nil, no_cache=False)

    #check param types
    raise TypeError, 'Server needs to be a string e.g. www.example.com' unless server.is_a?(String)
    raise TypeError, 'Port needs to be an integer' unless port.is_a?(Integer)
    raise TypeError, 'The Max Age of a cache object needs to be an integer' unless max_age.nil? or max_age.is_a?(Integer)
    raise TypeError, 'The no_cache setting must be a boolean' unless no_cache.nil? or (no_cache.is_a?(TrueClass) || no_cache.is_a?(FalseClass))
    
    
    @cache_map = CacheMap.new
    @http_facade = HTTPFacade.new(server, port)
    
    @server = server
    @port = port
    @max_age = max_age
    @no_cache = no_cache

  end
  
  def read(read_time, table, key, max_age=nil, no_cache=false)
    #type checking
    raise TypeError, "read_time needs to be a TxClock" unless read_time.is_a?(TxClock)
    raise TypeError, "table needs to be a string" unless table.is_a?(String)
    raise TypeError, "key needs to be a string" unless  key.is_a?(String)
    raise TypeError, "max_age needs to be a TxClock" unless (max_age.nil? or max_age.is_a?(TxClock))
    raise TypeError, "no_cache needs to be a Boolean" unless (no_cache.is_a?(TrueClass) || no_cache.is_a?(FalseClass))

    @cache_map.synchronize do
        check_cache = get(read_time, table,key)
        #check if the result is current enough to use
        
        if (not check_cache.nil?) and ( (read_time > check_cache.cached_time) and 
          (check_cache.cached_time < (read_time + max_age)))
          # we can use it!
          return check_cache
          
        else # we cant use it - so ask the db for a result 
          max_age = [max_age, @max_age] #TODO: add the 2 from the transaction read method here
          read_from_db = @http_facade.read(read_time, table, key, max_age=max_age, no_cache=no_cache)
          # we expected a (cached_time, value_time, value) from this
          @cache_map.put(read_from_db.cached_time, read_from_db.value_time, read_from_db.value)
        end
      end
        
  end
  
  def write(condition_txclock, tx_view)
    raise TypeError, "Condition_Time needs to be a TxClock" unless (condition_txclock.nil? or condition_txclock.is_a?(TxClock))
    raise TypeError, "tx_view needs to be a TxView" unless (tx_view.is_a?(TxView))
    batch_write(op_list, condition_txclock = condition_txclock)
    
  end

  def batch_write(op_list, unmodified_since = nil, transaction_id = nil, condition_txclock = nil)
    #type checking
    raise TypeError, "Condition_Time needs to be a TxClock" unless (condition_txclock.nil? or condition_txclock.is_a?(TxClock))
    raise TypeError, "Unmodified_since needs to be a DateTime" unless (unmodified_since.nil? or unmodified_since.is_a?(DateTime))
    @HTTPInterface.write(condition_txclock, tx_view)
  end


end
