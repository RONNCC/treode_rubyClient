class StaleException < StandardError
   def initialize(read_time, value_time)
       if not (read_time.is_a?(TxClock) and value_time.is_a?(TxClock))
         raise TypeError, "StaleException needs two TxClocks passed as arguments"
       end
   end
end