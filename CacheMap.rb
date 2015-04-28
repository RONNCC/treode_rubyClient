class CacheMap
    def initialize
        @in_cache = Hash.new # a hashtable of {(table,key) -> DLL(value_time, cached_time, value) }
        @bufDLL = DoublyLinkedList.new # we use this as a LRU Doubly Linked List.
        # The oldest are at the front and the newest are at the end
        @in_cache.extend(MonitorMixin)
        @bufDLL.extend(MonitorMixin)
        # we can get the head and tail of the DLL from the bufDLL object
        
        
        #via the client document each cache (table,key) -> array of Cache Object
        # all of which are managed by a LRU Policy for all of them combined
    end
    
    #returns the most recent value if it exists, else returns nil
    def get(read_time, table, key)
        #type checking
        raise TypeError, "read_time needs to be a " unless read_time.is_a?(TxClock)
        raise TypeError, "table needs to be a " unless table.is_a?(String)
        raise TypeError, "key needs to be a " unless  key.is_a?(String)
        
        @LRUCache.synchronize do
            bucket_entries =@LRUCache.get([table,key])
            return nil if (bucket_entries.nil? or bucket_entries.len.zero?)
            node = bucket_entries.head
            most_recent_node = node
            found_one = nil
            if( node.value_time <= read_time)
                found_one = true
            end
            while(node != nil) do
                node = node.next_node
                if( (most_recent_node.value_time < node.value_time) and (node.value_time <= read_time) )
                    most_recent_node = node
                    found_one = true
                end
            end
            
          end
    end


  # returns nil no matter what
  def put(read_time, value_time, table, key, value)
    #type checking
    raise TypeError, "cached_time needs to be a " unless read_time.is_a?(TxClock)
    raise TypeError, 'The Value Time has to be a TxClock' unless value_time.is_a?(TxClock)
    raise TypeError, "table needs to be a " unless table.is_a?(String)
    raise TypeError, "key needs to be a " unless  key.is_a?(String)
    raise TypeError, 'Value needs to be a supported return type included in ' +
      CacheResult.supported_values unless CacheResult.supported_values.include?(value)

    @in_cache.synchronize do
        @bufDLL.synchronize do
            #get the bucket to add to
             bucket_entries = @LRUCache.get([table,key])
             if bucket_entries.nil?
              @LRUCache.put()
              @LRUCache.put
               bucket_entries = @in_cache[[table,key]]
             end

            
        end
      end
  end
    

        # bucket_end = bucket_entries.peek_tail()
        # while bucket_end != nil
        #   if bucket_end.value[0] == value_time
        #     bucket_end.value[1] = [read_time, bucket_end.value[1]].max
        #     return
        #   end
        #   bucket_end = bucket_end.prev_node
        # end

        # # else we need to add a new tuple
        # @in_cache[[table,key]].insert_tail [value_time, read_time, value]
    
    
end