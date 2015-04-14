class CacheResult
    attr_accessor :value_time, :cached_time, :value
    
    def initialize(value_time,cached_time, value)
        supported_values = ['JSON'] #extend to xml later?
        if not value_time.is_a?(TxClock)
            raise TypeError, 'The Value Time has to be a TxClock'
        end
    
        if not cached_time.is_a?(TxClock)
            raise TypeError, 'The Cached Time has to be a TxClock'
        end
        
        if (not value.is_a?(String)) or (not supported_values.include?(value))
            raise TypeError, 'Value needs to be a supported return type included in ' + supported_values
        end
        @value_time = value_time
        @cached_time = cached_time
        @value = value
    end
end