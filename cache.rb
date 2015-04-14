require_relative './DLL'
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
  # size is specified in bytes
  # policy is a string
  def initialize(arg_size)
    if not arg_size.is_a?(Fixnum) or arg_size <= 0
      raise TypeError, 'We need the cache limit to be a positive integer.'
    end

    @limit = arg_size
    @current_size = 0


    # we use a doubly linked list & hash table as a priorityQueue here
    # since the provided priorityQueue lacks
    # many accessors methods from it's Java peer
    @in_cache = Hash.new # a hashtable of {(cache object, object size, object_value)}
    @bufPQ = DoublyLinkedList.new # we use this as a LRU Doubly Linked List.
    # The oldest are at the front and the newest are at the end
    @in_cache.extend(MonitorMixin)
    @bufPQ.extend(MonitorMixin)
    @bufPQ_commit_lock = @bufPQ.new_cond # to be used later
    @in_cache_commit_lock = @bufPQ.new_cond # to be used later
  end

  # co_object is the cache object
  # co_size is the cache object size
  def write(co_object, co_value, co_size)
    @bufPQ.synchronize do
        @in_cache.synchronize do 
            if not co_size.is_a?(Fixnum) and (co_size <= 0)
              raise TypeError, 'The size of the object you are trying to write' \
                               ' must be a positive integer.'
            end
    
            if @in_cache.has_key?(co_object)
                if co_size > @limit
                    raise ArgumentError, 'Updated value cannot be fit in our cache '
                end
                
                old_version = @bufPQ.delete(co_object)
                @current_size -= @in_cache[old_version][0] 
                
                while co_size + @current_size > @limit
                  dropped = @bufPQ[0]
                  @bufPQ.shift
                  dropped_size = @in_cache.delete(dropped)
                  @current_size -= dropped_size
                end

                @in_cache[co_object] = [co_size, co_value]
                @bufPQ.delete(co_object)
                @bufPQ << co_object
            else
              # check if we need to evict
              cache_with_object = co_size + @current_size
            
              if cache_with_object > @limit
              # TODO: This should probably be changed
              # i'm guessing that it would just pass through the object?
              # or does it need to stream or ....? How would we keep a e.g.
              # 8gb video file in memory before committing?
                if co_size > @limit
                  raise ArgumentError, 'We cannot fit this element in our cache '
                end
      
                #otherwise we can fit in the cache
                # and we just need to remove a few things
                
                while co_size + @current_size > @limit
                  dropped = @bufPQ[0]
                  @bufPQ.shift
                  dropped_size = @in_cache.delete(dropped)
                  @current_size -= dropped_size[0]
                end

              end
              @bufPQ << co_object
              @in_cache[co_object] = [co_size, co_value]
              @current_size += co_size
            end
        end
    end
  end
  
  # the read object reads from the cache
  # it updates the LRU value for the object if it is
  # successful and returns nil otherwise
  def read(co_object)
      @bufPQ.synchronize do
        @in_cache.synchronize do 
            if not @in_cache.has_key?(co_object)
                return nil
            end
            # this means it's in the cache
            # hence update the location in the bufPQ
            # this deletes all objects that are 'equal' to co_object
            @bufPQ.delete(co_object)
            @bufPQ << co_object
            @in_cache[co_object][1]
        end
      end
  end
      
  attr_reader :limit, :current_size, :policy, :in_cache, :bufPQ

  private


end

