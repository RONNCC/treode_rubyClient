require_relative './DLL'
require_relative './TxClock'
require 'monitor'
require 'algorithms'


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
  attr_accessor :server, :port, :max_age, :no_cache
  # server args
  def initialize(server, port=80, max_age=nil, no_cache=False)
      
    #check param types
    if not server.is_a?(String)
      raise TypeError, 'Server needs to be a string e.g. www.example.com'
    end
    if not port.is_a?(Integer)
      raise TypeError, 'Port needs to be an integer'
    end
    if not max_age.is_a?(Integer)
      raise TypeError, 'The Max Age of a cache object needs to be an integer'
    end
    if not no_cache.is_a?(TrueClass) || no_cache.is_a?(FalseClass)
      raise TypeError, 'The no_cache setting must be a boolean'
    end
    
    @connection = HTTPInterface.new(server, port)
    @server = server
    @port = port
    @max_age = max_age
    @no_cache = no_cache
    
    # we use a doubly linked list & hash table as a priorityQueue here
    # since the provided priorityQueue lacks
    # many accessors methods from it's Java peer
    @in_cache = Hash.new # a hashtable of {(table,key) -> DLL(value_time, cached_time, value) }
    @bufDLL = DoublyLinkedList.new # we use this as a LRU Doubly Linked List.
    # The oldest are at the front and the newest are at the end
    @in_cache.extend(MonitorMixin)
    @bufDLL.extend(MonitorMixin)
    #@bufPQ_commit_lock = @bufPQ.new_cond # to be used later
    #@in_cache_commit_lock = @bufPQ.new_cond # to be used later
  end

  def write(condition_time, op_list)
    #type checking
    raise TypeError, "Condition_Time needs to be a TxClock", unless condition_time.is_a?(TxClock)
    raise TypeError, "Op_list needs to be a TxView", unless op_list.is_a?(TxView)
   

    @in_cache.synchronize do
      @bufDLL.synchronize do
      end
    end

  end
  
  def read(read_time, table, key, max_age, no_cache)
    #type checking
    raise TypeError, "read_time needs to be a " unless read_time.is_a?(TxClock)
    raise TypeError, "table needs to be a " unless table.is_a?(String)
    raise TypeError, "key needs to be a " unless  key.is_a?(String)
    raise TypeError, "max_age needs to be a " unless max_age.is_a?(Integer )
    raise TypeError, "no_cache needs to be a " unless (no_cache.is_a?(TrueClass) || no_cache.is_a?(FalseClass))


    @in_cache.synchronize do
      @bufDLL.synchronize do

        check_cache = get(read_time, table,key)
        #check if the result is current enough to use
        if(check_cache.nil? or ( (read_time < check_cache[1])  and (check_cache[1] < (read_time + max_age))))
          read_from_db = @connection.GET_Request()
          params = Hash.new()
          max_age = [max_age, @max_age] #TODO: add the 2 from the transaction read method here
          no_cache = 
          params['Cache-Control:' = "max-age:#{max_age}, #{'no-cache' if no_cache}"]
          case read_from_db.code
          when 200
            put(read_from_db['Read-TxClock'], read_from_db['Value-TxClock'], table, key, read_from_db.body)
          when 404
            put(read_from_db['Read-TxClock'], read_from_db['Value-TxClock'], table, key, nil)
          else
            raise TypeError, 'Error: Wrong Status Code Returned'
          end
      end
    end

  end

  
  #returns the most recent value if it exists, else returns nil
  def get(read_time, table, key)
    #type checking
    raise TypeError, "read_time needs to be a " unless read_time.is_a?(TxClock)
    raise TypeError, "table needs to be a " unless table.is_a?(String)
    raise TypeError, "key needs to be a " unless  key.is_a?(String)

    @in_cache.synchronize do
      @bufDLL.synchronize do
        bucket_entries = @in_cache[[table,key]]
        return nil if (bucket_entries.nil? or bucket_entries.len.zero?)
        bucket_entries.peek_tail()
      end
    end
  end    


  # returns nil no matter what 
  def put(read_time, value_time, table, key, value)
    #type checking 
    raise TypeError, "read_time needs to be a " unless read_time.is_a?(TxClock)
    raise TypeError, 'The Value Time has to be a TxClock' unless value_time.is_a?(TxClock)
    raise TypeError, "table needs to be a " unless table.is_a?(String)
    raise TypeError, "key needs to be a " unless  key.is_a?(String)
    raise TypeError, 'Value needs to be a supported return type included in ' + 
          CacheResult.supported_values unless CacheResult.supported_values.incude?(value)

    @in_cache.synchronize do
      @bufDLL.synchronize do
        bucket_entries = @in_cache[[table,key]]
        if bucket_entries.nil?
          @in_cache[[table,key]] = DoublyLinkedList.new()
          bucket_entries = @in_cache[[table,key]]
        end

        bucket_end = bucket_entries.peek_tail()
        while bucket_end != nil 
          if bucket_end.value[0] == value_time
            bucket_end.value[1] = [read_time, bucket_end.value[1]].max
            return
          end
          bucket_end = bucket_end.prev_node
        end

        # else we need to add a new tuple
        @in_cache[[table,key]].insert_tail [value_time, cached_time, value]

      end
    end
  end
end

