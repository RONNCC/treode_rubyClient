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
    
    @server = server
    @port = port
    @max_age = max_age
    @no_cache = no_cache
    
    # we use a doubly linked list & hash table as a priorityQueue here
    # since the provided priorityQueue lacks
    # many accessors methods from it's Java peer
    #@in_cache = Hash.new # a hashtable of {(cache object, object size, object_value)}
    #@bufPQ = DoublyLinkedList.new # we use this as a LRU Doubly Linked List.
    # The oldest are at the front and the newest are at the end
    #@in_cache.extend(MonitorMixin)
    #@bufPQ.extend(MonitorMixin)
    #@bufPQ_commit_lock = @bufPQ.new_cond # to be used later
    #@in_cache_commit_lock = @bufPQ.new_cond # to be used later
  end


  def write(condition_time, op_list)
    #type checking
    raise TypeError, "Condition_Time needs to be a TxClock", unless condition_time.is_a?(TxClock)
    raise TypeError, "Op_list needs to be a TxView", unless op_list.is_a?(TxView)


   
  end
  
  def read(read_time: TxClock, table: String, key: String, max_age: int, no_cache: bool)
    raise TypeError, "Read_Time needs to be a TxClock", unless read_time
    raise TypeError, table
    raise TypeError, key
    raise TypeError, max_age
    raise TypeError, no_cache
  end
      

  private


end

