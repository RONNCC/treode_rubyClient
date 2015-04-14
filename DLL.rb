class DoublyLinkedList
    def initialize
        @root = nil
        @end = nil
        @len = 0
    end

    attr_accessor :len

    def insert_head(data)
        @len += 1 
        if @root.nil?
            @root = DLLNode.new(data)
            @end = @root
            return @root
        else
            tmpNode = DLLNode.new(data)
            @root.prev_node, tmpNode.next_node = tmpNode, @root
            @root = tmpNode
            return @root
        end
    end
    
    def insert_tail(data)
        @len += 1 
        if @root.nil?
            @root = DLLNode.new(data)
            @end = @root
            return @root
        else
            tmpNode = DLLNode.new(data)
            tmpNode.prev_node, @end.next_node = @end, tmpNode
            @end = tmpNode
            return @end
        end
    end
    
    def to_s
        output = '['
        node_iter = @root
        until node_iter.nil?
            output <<  node_iter.to_s + ','
            node_iter = node_iter.next_node
        end
        output << ']'
        output
    end

end


class DLLNode
    @prev_node, @next_node = nil, nil
    
    def initialize(arg_data = nil)
        @data = arg_data
    end
    
    #automatically writes getters/setters
    attr_accessor :prev_node, :next_node, :data

    def to_s
        @data.to_s
    end
end


